///|
fn write_c13_subsection(
  buffer : Buffer,
  kind : UInt32,
  payload : Bytes,
) -> Unit {
  write_symbol_u32(buffer, kind)
  write_symbol_u32(buffer, payload.length().reinterpret_as_uint())
  buffer.write_bytes(payload.exact_view())
  for _ in 0..<((4 - payload.length() % 4) % 4) {
    buffer.write_byte(0)
  }
}

///|
fn c13_test_strings() -> Bytes {
  b"\x00src/main.cpp\x00include/header.h\x00"
}

///|
fn write_c13_checksum(
  buffer : Buffer,
  file_name_offset : UInt32,
  kind : UInt32,
  checksum : Bytes,
) -> Unit {
  write_symbol_u32(buffer, file_name_offset)
  write_symbol_u8(buffer, checksum.length().reinterpret_as_uint())
  write_symbol_u8(buffer, kind)
  buffer.write_bytes(checksum.exact_view())
  for _ in 0..<((4 - (6 + checksum.length()) % 4) % 4) {
    buffer.write_byte(0)
  }
}

///|
fn c13_test_checksums() -> Bytes {
  let checksums = Buffer::Buffer(size_hint=52)
  write_c13_checksum(
    checksums, 1U, 1U, b"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10",
  )
  write_c13_checksum(
    checksums, 14U, 2U, b"\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20\x21\x22\x23\x24",
  )
  checksums.to_bytes()
}

///|
fn c13_line_flags(
  line_start : UInt32,
  line_end : UInt32,
  is_statement : Bool,
) -> UInt32 {
  line_start | (line_end << 24) | (if is_statement { 0x80000000U } else { 0U })
}

///|
fn c13_test_lines(columns : Bool, file_checksum_offset : UInt32) -> Bytes {
  let lines = Buffer::Buffer(size_hint=80)
  write_symbol_u32(lines, 0x1000U)
  write_symbol_u16(lines, 1U)
  write_symbol_u16(lines, if columns { 1U } else { 0U })
  write_symbol_u32(lines, 0x100U)
  let first_block_size = if columns { 36U } else { 28U }
  write_symbol_u32(lines, file_checksum_offset)
  write_symbol_u32(lines, 2U)
  write_symbol_u32(lines, first_block_size)
  write_symbol_u32(lines, 0x1000U)
  write_symbol_u32(lines, c13_line_flags(10U, 11U, true))
  write_symbol_u32(lines, 0x1010U)
  write_symbol_u32(lines, c13_line_flags(12U, 13U, false))
  if columns {
    write_symbol_u16(lines, 1U)
    write_symbol_u16(lines, 10U)
    write_symbol_u16(lines, 5U)
    write_symbol_u16(lines, 14U)
  }
  let second_block_size = if columns { 24U } else { 20U }
  write_symbol_u32(lines, 24U)
  write_symbol_u32(lines, 1U)
  write_symbol_u32(lines, second_block_size)
  write_symbol_u32(lines, 0x1020U)
  write_symbol_u32(lines, c13_line_flags(20U, 20U, true))
  if columns {
    write_symbol_u16(lines, 2U)
    write_symbol_u16(lines, 8U)
  }
  lines.to_bytes()
}

///|
fn c13_test_stream(
  include_strings : Bool,
  columns : Bool,
  line_checksum_offset : UInt32,
) -> Bytes {
  let stream = Buffer::Buffer(size_hint=220)
  if include_strings {
    write_c13_subsection(stream, C13_KIND_STRING_TABLE, c13_test_strings())
  }
  write_c13_subsection(stream, C13_KIND_FILE_CHECKSUMS, c13_test_checksums())
  write_c13_subsection(
    stream,
    C13_KIND_LINES,
    c13_test_lines(columns, line_checksum_offset),
  )
  write_c13_subsection(stream, 0x1234U, b"unknown")
  stream.to_bytes()
}

///|
test "parse C13 strings, checksums, and line blocks" {
  let info = parse_c13_debug_info(
    c13_test_stream(true, true, 0U),
    C13Limits::default(),
  )
  assert_eq(info.subsection_count(), 4)
  let strings = info.string_table().unwrap()
  assert_eq(strings.string_at(1U), Some("src/main.cpp"))
  assert_eq(strings.string_at(14U), Some("include/header.h"))
  assert_eq(info.file_checksum_count(), 2)
  let first_file = info.file_checksum_at(0).unwrap()
  assert_eq(first_file.kind(), 1)
  assert_eq(first_file.file_path(), "src/main.cpp")
  assert_eq(first_file.subsection_offset(), 0U)
  assert_eq(first_file.checksum().length(), 16)
  assert_eq(info.line_fragment_count(), 1)
  let fragment = info.line_fragment_at(0).unwrap()
  assert_true(fragment.has_columns())
  assert_eq(fragment.block_count(), 2)
  let first_block = fragment.block_at(0).unwrap()
  assert_eq(first_block.file_path(), "src/main.cpp")
  assert_eq(first_block.record_size(), 36U)
  assert_eq(first_block.line_count(), 2)
}

///|
test "map C13 segment offsets to source lines" {
  let info = parse_c13_debug_info(
    c13_test_stream(true, true, 0U),
    C13Limits::default(),
  )
  let first = info.find_line(1, 0x1005U).unwrap()
  assert_eq(first.file_path(), "src/main.cpp")
  assert_eq(first.line_start(), 10U)
  assert_eq(first.line_end(), 11U)
  assert_true(first.is_statement())
  match first.columns() {
    Some(columns) => {
      assert_eq(columns.start(), 1)
      assert_eq(columns.end(), 10)
    }
    None => fail("expected source columns")
  }
  let second = info.find_line(1, 0x1018U).unwrap()
  assert_eq(second.line_start(), 12U)
  assert_false(second.is_statement())
  let third = info.find_line(1, 0x1022U).unwrap()
  assert_eq(third.file_path(), "include/header.h")
  assert_eq(third.line_start(), 20U)
  match info.find_line(1, 0x2000U) {
    None => ()
    Some(_) => fail("expected an address outside the fragment to have no line")
  }
  match info.find_line(2, 0x1005U) {
    None => ()
    Some(_) => fail("expected a different segment to have no line")
  }
}

///|
test "parse C13 line blocks without columns" {
  let info = parse_c13_debug_info(
    c13_test_stream(true, false, 0U),
    C13Limits::default(),
  )
  let lines = info.find_line(1, 0x1001U).unwrap()
  assert_eq(lines.line_start(), 10U)
  match lines.columns() {
    None => ()
    Some(_) => fail("expected no column information")
  }
}

///|
test "reject malformed C13 debug streams" {
  let bad_length = Buffer::Buffer(size_hint=12)
  write_symbol_u32(bad_length, C13_KIND_LINES)
  write_symbol_u32(bad_length, 100U)
  try parse_c13_debug_info(bad_length.to_bytes(), C13Limits::default()) catch {
    TruncatedC13(_) => ()
    _ => fail("unexpected C13 length error")
  } noraise {
    _ => fail("expected a truncated C13 subsection to be rejected")
  }
  try
    parse_c13_debug_info(c13_test_stream(false, true, 0U), C13Limits::default())
  catch {
    MissingC13StringTable => ()
    _ => fail("unexpected missing string-table error")
  } noraise {
    _ => fail("expected checksums without a string table to be rejected")
  }
  try
    parse_c13_debug_info(
      c13_test_stream(true, true, 999U),
      C13Limits::default(),
    )
  catch {
    InvalidLineInfo(_) => ()
    _ => fail("unexpected missing-checksum error")
  } noraise {
    _ => fail("expected a line block with a missing checksum to be rejected")
  }
}

///|
test "enforce C13 line-entry limits" {
  let limits = C13Limits::{
    max_bytes: 4096,
    max_subsections: 16,
    max_file_checksums: 16,
    max_line_fragments: 16,
    max_line_entries: 1,
  }
  try parse_c13_debug_info(c13_test_stream(true, true, 0U), limits) catch {
    C13LimitExceeded(_) => ()
    _ => fail("unexpected line-entry limit error")
  } noraise {
    _ => fail("expected the C13 line-entry limit to be enforced")
  }
}
