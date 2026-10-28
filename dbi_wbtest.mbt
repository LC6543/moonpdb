///|
fn write_dbi_test_u16(buffer : Buffer, value : UInt32) -> Unit {
  buffer.write_byte(value.to_byte())
  buffer.write_byte((value >> 8).to_byte())
}

///|
fn write_dbi_test_sc(
  buffer : Buffer,
  version : SectionContributionVersion,
  section_index : UInt32,
  module_index : UInt32,
) -> Unit {
  write_dbi_test_u16(buffer, section_index)
  write_dbi_test_u16(buffer, 0U)
  buffer.write_uint_le(0x100U)
  buffer.write_uint_le(0x200U)
  buffer.write_uint_le(0x40000040U)
  write_dbi_test_u16(buffer, module_index)
  write_dbi_test_u16(buffer, 0U)
  buffer.write_uint_le(0x11111111U)
  buffer.write_uint_le(0x22222222U)
  match version {
    V2 => buffer.write_uint_le(7U)
    _ => ()
  }
}

///|
fn dbi_test_modules() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=192)
  let names = b"a.obj\x00a.obj\x00"
  buffer.write_uint_le(0U)
  write_dbi_test_sc(buffer, V60, 1U, 0U)
  write_dbi_test_u16(buffer, 0x0202U)
  write_dbi_test_u16(buffer, 10U)
  buffer.write_uint_le(0x10U)
  buffer.write_uint_le(0x20U)
  buffer.write_uint_le(0x30U)
  write_dbi_test_u16(buffer, 1U)
  write_dbi_test_u16(buffer, 0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(2U)
  buffer.write_bytes(names.exact_view())
  for _ in 0..<((4 - (64 + names.length()) % 4) % 4) {
    buffer.write_byte(0)
  }
  let names = b"b.obj\x00b.obj\x00"
  buffer.write_uint_le(0U)
  write_dbi_test_sc(buffer, V60, 2U, 1U)
  write_dbi_test_u16(buffer, 0x0102U)
  write_dbi_test_u16(buffer, 11U)
  buffer.write_uint_le(0x40U)
  buffer.write_uint_le(0x50U)
  buffer.write_uint_le(0x60U)
  write_dbi_test_u16(buffer, 2U)
  write_dbi_test_u16(buffer, 0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(3U)
  buffer.write_uint_le(4U)
  buffer.write_bytes(names.exact_view())
  for _ in 0..<((4 - (64 + names.length()) % 4) % 4) {
    buffer.write_byte(0)
  }
  buffer.to_bytes()
}

///|
fn dbi_test_contributions(version : SectionContributionVersion) -> Bytes {
  let buffer = Buffer::Buffer(size_hint=68)
  let version_raw = match version {
    V60 => DBI_SECTION_CONTRIBUTION_60
    V2 => DBI_SECTION_CONTRIBUTION_2
    None => 0U
  }
  buffer.write_uint_le(version_raw)
  write_dbi_test_sc(buffer, version, 1U, 0U)
  write_dbi_test_sc(buffer, version, 2U, 1U)
  buffer.to_bytes()
}

///|
fn dbi_test_section_map() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=44)
  write_dbi_test_u16(buffer, 2U)
  write_dbi_test_u16(buffer, 1U)
  write_dbi_test_u16(buffer, 0x0001U)
  write_dbi_test_u16(buffer, 0U)
  write_dbi_test_u16(buffer, 0xFFFFU)
  write_dbi_test_u16(buffer, 0U)
  write_dbi_test_u16(buffer, 10U)
  write_dbi_test_u16(buffer, 20U)
  buffer.write_uint_le(0x1000U)
  buffer.write_uint_le(0x2000U)
  write_dbi_test_u16(buffer, 0x0005U)
  write_dbi_test_u16(buffer, 1U)
  write_dbi_test_u16(buffer, 0xFFFFU)
  write_dbi_test_u16(buffer, 0xFFFFU)
  write_dbi_test_u16(buffer, 0xFFFFU)
  write_dbi_test_u16(buffer, 0xFFFFU)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0x3000U)
  buffer.to_bytes()
}

///|
fn dbi_test_names() -> Bytes {
  b"src/a.cpp\x00src/b.cpp\x00include/c.h\x00"
}

///|
fn dbi_test_file_info_names() -> Bytes {
  let names = dbi_test_names()
  let buffer = Buffer::Buffer(size_hint=64)
  write_dbi_test_u16(buffer, 2U)
  write_dbi_test_u16(buffer, 2U)
  write_dbi_test_u16(buffer, 0U)
  write_dbi_test_u16(buffer, 1U)
  write_dbi_test_u16(buffer, 1U)
  write_dbi_test_u16(buffer, 2U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(10U)
  buffer.write_uint_le(20U)
  buffer.write_bytes(names.exact_view())
  buffer.to_bytes()
}

///|
fn dbi_test_optional_debug_header() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=22)
  for
    value in [
      5U, 0xFFFFU, 0xFFFFU, 0xFFFFU, 0xFFFFU, 12U, 13U, 14U, 15U, 16U, 17U,
    ] {
    write_dbi_test_u16(buffer, value)
  }
  buffer.to_bytes()
}

///|
fn dbi_test_header(
  modi_bytes : Int32,
  contribution_bytes : Int32,
  section_map_bytes : Int32,
  file_info_bytes : Int32,
  type_server_bytes : Int32,
  ec_bytes : Int32,
  debug_bytes : Int32,
) -> Bytes {
  let buffer = Buffer::Buffer(size_hint=DBI_HEADER_SIZE)
  buffer.write_uint_le(0xFFFFFFFFU)
  buffer.write_uint_le(20091201U)
  buffer.write_uint_le(42U)
  write_dbi_test_u16(buffer, 5U)
  write_dbi_test_u16(buffer, 0x8A01U)
  write_dbi_test_u16(buffer, 6U)
  write_dbi_test_u16(buffer, 0x1234U)
  write_dbi_test_u16(buffer, 7U)
  write_dbi_test_u16(buffer, 9U)
  buffer.write_uint_le(modi_bytes.reinterpret_as_uint())
  buffer.write_uint_le(contribution_bytes.reinterpret_as_uint())
  buffer.write_uint_le(section_map_bytes.reinterpret_as_uint())
  buffer.write_uint_le(file_info_bytes.reinterpret_as_uint())
  buffer.write_uint_le(type_server_bytes.reinterpret_as_uint())
  buffer.write_uint_le(0U)
  buffer.write_uint_le(debug_bytes.reinterpret_as_uint())
  buffer.write_uint_le(ec_bytes.reinterpret_as_uint())
  write_dbi_test_u16(buffer, 0x0003U)
  write_dbi_test_u16(buffer, 0x8664U)
  buffer.write_uint_le(0U)
  buffer.to_bytes()
}

///|
fn dbi_test_stream(version : SectionContributionVersion) -> Bytes {
  let modi = dbi_test_modules()
  let contributions = dbi_test_contributions(version)
  let section_map = dbi_test_section_map()
  let file_info = dbi_test_file_info_names()
  let type_server = b""
  let ec = b""
  let debug = dbi_test_optional_debug_header()
  let header = dbi_test_header(
    modi.length(),
    contributions.length(),
    section_map.length(),
    file_info.length(),
    type_server.length(),
    ec.length(),
    debug.length(),
  )
  let stream = Buffer::Buffer(size_hint=256)
  stream.write_bytes(header.exact_view())
  stream.write_bytes(modi.exact_view())
  stream.write_bytes(contributions.exact_view())
  stream.write_bytes(section_map.exact_view())
  stream.write_bytes(file_info.exact_view())
  stream.write_bytes(type_server.exact_view())
  stream.write_bytes(ec.exact_view())
  stream.write_bytes(debug.exact_view())
  stream.to_bytes()
}

///|
test "parse DBI header and module records" {
  let dbi = parse_dbi(dbi_test_stream(V60), DbiLimits::default())
  assert_eq(dbi.header().version(), 20091201U)
  assert_eq(dbi.header().age(), 42U)
  assert_eq(dbi.header().global_symbol_stream_index(), 5)
  assert_eq(dbi.header().public_symbol_stream_index(), 6)
  assert_eq(dbi.header().symbol_record_stream_index(), 7)
  assert_eq(dbi.header().machine_type(), 0x8664)
  assert_true(dbi.header().is_incrementally_linked())
  assert_true(dbi.header().is_stripped())
  assert_false(dbi.header().has_c_types())
  assert_eq(dbi.module_count(), 2)
  let item = dbi.module_at(1).unwrap()
  assert_eq(item.module_name(), "b.obj")
  assert_eq(item.object_name(), "b.obj")
  assert_eq(item.module_stream_index(), 11)
  assert_eq(item.symbol_debug_bytes(), 0x40U)
  assert_eq(item.c11_line_bytes(), 0x50U)
  assert_eq(item.c13_line_bytes(), 0x60U)
  assert_eq(item.declared_source_file_count(), 2)
  assert_true(item.has_ec_info())
  assert_eq(item.type_server_index(), 1)
}

///|
test "parse DBI section contributions and section map" {
  let dbi = parse_dbi(dbi_test_stream(V60), DbiLimits::default())
  match dbi.section_contribution_version() {
    V60 => ()
    _ => fail("expected section contribution version 60")
  }
  assert_eq(dbi.section_contribution_count(), 2)
  let contribution = dbi.section_contribution(1).unwrap()
  assert_eq(contribution.section_index(), 2)
  assert_eq(contribution.offset(), 0x100)
  assert_eq(contribution.size(), 0x200)
  assert_eq(contribution.module_index(), 1)
  assert_eq(contribution.coff_section_index(), None)
  assert_eq(dbi.section_map().physical_count(), 2)
  assert_eq(dbi.section_map().logical_count(), 1)
  assert_eq(dbi.section_map().entry_count(), 2)
  let entry = dbi.section_map().entry(0).unwrap()
  assert_eq(entry.flags(), 0x0001)
  assert_eq(entry.class_name_offset(), 20)
  assert_eq(entry.section_name_offset(), 10)
  assert_eq(entry.offset(), 0x1000U)
  assert_eq(entry.byte_length(), 0x2000U)
}

///|
test "parse section contribution version two" {
  let data = dbi_test_contributions(V2)
  let (version, contributions) = parse_section_contributions(
    data,
    DbiLimits::default(),
  )
  match version {
    V2 => ()
    _ => fail("expected version-two section contributions")
  }
  let contribution = contributions[0]
  assert_eq(contribution.coff_section_index(), Some(7))
}

///|
test "attach file info to DBI modules" {
  let dbi = parse_dbi(dbi_test_stream(V60), DbiLimits::default())
  assert_eq(dbi.reported_source_file_count(), 2)
  assert_eq(dbi.source_file_count(), 3)
  let first = dbi.module_at(0).unwrap()
  assert_eq(first.source_files(), ["src/a.cpp"])
  let second = dbi.module_at(1).unwrap()
  assert_eq(second.source_files(), ["src/b.cpp", "include/c.h"])
}

///|
test "expose optional DBI debug streams" {
  let dbi = parse_dbi(dbi_test_stream(V60), DbiLimits::default())
  assert_eq(dbi.optional_debug_streams().length(), 11)
  assert_eq(dbi.debug_stream_index(Fpo), Some(5))
  assert_eq(dbi.debug_stream_index(NewFpo), Some(16))
  assert_eq(dbi.debug_stream_index(SectionHdrOrig), Some(17))
  assert_eq(DebugStreamKind::all().length(), 11)
}

///|
test "reject malformed DBI streams" {
  let short = dbi_test_stream(V60).exact_view(end=32).to_owned()
  try parse_dbi(short, DbiLimits::default()) catch {
    TruncatedDbi(_) => ()
    _ => fail("unexpected short DBI error")
  } noraise {
    _ => fail("expected a short DBI stream to be rejected")
  }
  let full = dbi_test_stream(V60)
  let truncated = full.exact_view(end=full.length() - 1).to_owned()
  try parse_dbi(truncated, DbiLimits::default()) catch {
    InvalidDbiHeader(_) => ()
    _ => fail("unexpected DBI length error")
  } noraise {
    _ => fail("expected a size mismatch to be rejected")
  }
  let unsupported = Buffer::Buffer(size_hint=4)
  unsupported.write_uint_le(1U)
  try
    parse_section_contributions(unsupported.to_bytes(), DbiLimits::default())
  catch {
    UnsupportedSectionContributionVersion(1) => ()
    _ => fail("unexpected section contribution version error")
  } noraise {
    _ => fail("expected unsupported section contributions to be rejected")
  }
}

///|
test "reject unsupported DBI versions" {
  let original = dbi_test_stream(V60)
  let buffer = Buffer::Buffer(size_hint=original.length())
  buffer.write_bytes(original.exact_view(end=4))
  buffer.write_uint_le(19990902U)
  buffer.write_bytes(original.exact_view(start=8, end=original.length()))
  try parse_dbi(buffer.to_bytes(), DbiLimits::default()) catch {
    UnsupportedDbiVersion(19990902) => ()
    _ => fail("unexpected DBI version error")
  } noraise {
    _ => fail("expected an old DBI version to be rejected")
  }
}

///|
test "reject unaligned DBI substreams" {
  let modi = dbi_test_modules()
  let padded_modi = Buffer::Buffer(size_hint=modi.length() + 1)
  padded_modi.write_bytes(modi.exact_view())
  padded_modi.write_byte(0)
  let modi_bytes = padded_modi.to_bytes()
  let contributions = dbi_test_contributions(V60)
  let section_map = dbi_test_section_map()
  let file_info = dbi_test_file_info_names()
  let debug = dbi_test_optional_debug_header()
  let stream = Buffer::Buffer(size_hint=256)
  stream.write_bytes(
    dbi_test_header(
      modi_bytes.length(),
      contributions.length(),
      section_map.length(),
      file_info.length(),
      0,
      0,
      debug.length(),
    ).exact_view(),
  )
  stream.write_bytes(modi_bytes.exact_view())
  stream.write_bytes(contributions.exact_view())
  stream.write_bytes(section_map.exact_view())
  stream.write_bytes(file_info.exact_view())
  stream.write_bytes(debug.exact_view())
  try parse_dbi(stream.to_bytes(), DbiLimits::default()) catch {
    InvalidDbiHeader(_) => ()
    _ => fail("unexpected DBI alignment error")
  } noraise {
    _ => fail("expected an unaligned MODI substream to be rejected")
  }
}

///|
test "enforce DBI limits" {
  let data = dbi_test_stream(V60)
  let limits = DbiLimits::{
    max_stream_bytes: 128 * 1024,
    max_modules: 1,
    max_section_contributions: 100,
    max_section_map_entries: 100,
    max_source_files: 100,
    max_string_bytes: 1024,
    max_debug_streams: 64,
  }
  try parse_dbi(data, limits) catch {
    DbiLimitExceeded(_) => ()
    _ => fail("unexpected module limit error")
  } noraise {
    _ => fail("expected the module limit to be enforced")
  }
}
