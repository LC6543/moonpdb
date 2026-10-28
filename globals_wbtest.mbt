///|
fn globals_test_data_payload(name : Bytes) -> Bytes {
  let payload = Buffer::Buffer(size_hint=16)
  write_symbol_u32(payload, 0x74U)
  write_symbol_u32(payload, 0x100U)
  write_symbol_u16(payload, 1U)
  payload.write_bytes(name.exact_view())
  payload.to_bytes()
}

///|
fn globals_test_symbols() -> SymbolTable raise SymbolError {
  let buffer = Buffer::Buffer(size_hint=64)
  write_symbol_record(buffer, S_GDATA32, globals_test_data_payload(b"A\x00"))
  write_symbol_record(buffer, S_GDATA32, globals_test_data_payload(b"B\x00"))
  write_symbol_record(buffer, S_GDATA32, globals_test_data_payload(b"AA\x00"))
  parse_symbols(buffer.to_bytes(), SymbolLimits::default())
}

///|
fn globals_test_stream(
  symbols : SymbolTable,
  first_bucket : UInt32,
  version : UInt32,
) -> Bytes {
  let buffer = Buffer::Buffer(size_hint=700)
  write_symbol_u32(buffer, GSI_SIGNATURE)
  write_symbol_u32(buffer, version)
  write_symbol_u32(buffer, (symbols.record_count() * 8).reinterpret_as_uint())
  write_symbol_u32(buffer, 3U)
  for index in 0..<symbols.record_count() {
    let record = symbols.record_at(index).unwrap()
    write_symbol_u32(buffer, (record.offset() + 1).reinterpret_as_uint())
    write_symbol_u32(buffer, 1U)
  }
  for word_index in 0..<GSI_BITMAP_WORDS {
    let word = if word_index == 17 {
      (1U << 1) | (1U << 2)
    } else if word_index == 25 {
      1U << 5
    } else {
      0U
    }
    write_symbol_u32(buffer, word)
  }
  write_symbol_u32(buffer, first_bucket)
  write_symbol_u32(buffer, 12U)
  write_symbol_u32(buffer, 24U)
  buffer.to_bytes()
}

///|
test "compute PDB version-one string hashes" {
  assert_eq(hash_string_v1("A"), 539231297U)
  assert_eq(hash_string_v1("AB"), 539248201U)
  assert_eq(hash_string_v1("ABC"), 539248138U)
  assert_eq(hash_string_v1("abc"), 539248138U)
  assert_eq(hash_string_v1(""), 539231232U)
}

///|
test "look up names in an empty Globals table" {
  let data = Buffer::Buffer(size_hint=GSI_HEADER_SIZE)
  write_symbol_u32(data, GSI_SIGNATURE)
  write_symbol_u32(data, GSI_VERSION)
  write_symbol_u32(data, 0U)
  write_symbol_u32(data, 0U)
  let symbols = parse_symbols(b"", SymbolLimits::default())
  let globals = parse_globals_stream(
    data.to_bytes(),
    symbols,
    SymbolLimits::default(),
  )
  assert_eq(globals.gsi().hash_record_count(), 0)
  assert_eq(globals.find_records_by_name("main").length(), 0)
}

///|
test "parse Globals GSI and find symbols by name" {
  let symbols = globals_test_symbols()
  let globals = parse_globals_stream(
    globals_test_stream(symbols, 0U, GSI_VERSION),
    symbols,
    SymbolLimits::default(),
  )
  assert_eq(globals.gsi().hash_record_count(), 3)
  assert_eq(globals.gsi().bucket_map_index(545), Some(0))
  assert_eq(globals.gsi().bucket_map_index(546), Some(1))
  assert_eq(globals.gsi().bucket_map_index(805), Some(2))
  let first_hash = globals.gsi().hash_record_at(0).unwrap()
  assert_eq(first_hash.raw_offset(), 1U)
  assert_eq(first_hash.symbol_offset(), Some(0U))
  let a = globals.find_records_by_name("A")
  assert_eq(a.length(), 1)
  assert_eq(a[0].kind(), S_GDATA32)
  let b = globals.find_records_by_name("B")
  assert_eq(b.length(), 1)
  let aa = globals.find_records_by_name("AA")
  assert_eq(aa.length(), 1)
  assert_eq(globals.find_records_by_name("missing").length(), 0)
  assert_eq(globals.find_records_by_name("a").length(), 0)
}

///|
test "reject malformed Globals GSI streams" {
  let symbols = globals_test_symbols()
  let bad_version = globals_test_stream(symbols, 0U, 1U)
  try
    parse_globals_stream(bad_version, symbols, SymbolLimits::default())
  catch {
    UnsupportedGsiVersion(1) => ()
    _ => fail("unexpected Globals version error")
  } noraise {
    _ => fail("expected an unsupported Globals version to be rejected")
  }
  let bad_bucket = parse_globals_stream(
    globals_test_stream(symbols, 999U, GSI_VERSION),
    symbols,
    SymbolLimits::default(),
  )
  try bad_bucket.find_records_by_name("A") catch {
    InvalidGlobalIndex(_) => ()
    _ => fail("unexpected Globals bucket error")
  } noraise {
    _ => fail("expected an invalid GSI bucket to be rejected")
  }
  let valid = globals_test_stream(symbols, 0U, GSI_VERSION)
  let trailing = Buffer::Buffer(size_hint=valid.length() + 1)
  trailing.write_bytes(valid.exact_view())
  trailing.write_byte(0)
  try
    parse_globals_stream(trailing.to_bytes(), symbols, SymbolLimits::default())
  catch {
    InvalidGlobalIndex(_) => ()
    _ => fail("unexpected Globals trailing-byte error")
  } noraise {
    _ => fail("expected trailing Globals bytes to be rejected")
  }
}

///|
test "enforce Globals hash-record limits" {
  let symbols = globals_test_symbols()
  let limits = SymbolLimits::{
    max_stream_bytes: 4096,
    max_records: 100,
    max_record_bytes: 4096,
    max_global_refs: 100,
    max_hash_records: 1,
    max_public_symbols: 100,
  }
  try
    parse_globals_stream(
      globals_test_stream(symbols, 0U, GSI_VERSION),
      symbols,
      limits,
    )
  catch {
    PublicsLimitExceeded(_) => ()
    _ => fail("unexpected Globals hash-record limit error")
  } noraise {
    _ => fail("expected the Globals hash-record limit to be enforced")
  }
}
