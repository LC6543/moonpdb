///|
fn publics_test_public_payload(
  segment : UInt32,
  offset : UInt32,
  name : Bytes,
) -> Bytes {
  let payload = Buffer::Buffer(size_hint=24)
  write_symbol_u32(payload, 0x00000002U)
  write_symbol_u32(payload, offset)
  write_symbol_u16(payload, segment)
  payload.write_bytes(name.exact_view())
  payload.to_bytes()
}

///|
fn publics_test_symbol_table() -> SymbolTable raise SymbolError {
  let buffer = Buffer::Buffer(size_hint=80)
  write_symbol_record(
    buffer,
    S_PUB32,
    publics_test_public_payload(1U, 0x100U, b"first\x00"),
  )
  write_symbol_record(
    buffer,
    S_PUB32,
    publics_test_public_payload(1U, 0x200U, b"second\x00"),
  )
  write_symbol_record(
    buffer,
    S_PUB32,
    publics_test_public_payload(2U, 0x050U, b"third\x00"),
  )
  parse_symbols(buffer.to_bytes(), SymbolLimits::default())
}

///|
fn publics_write_header(
  buffer : Buffer,
  address_count : Int32,
  thunk_count : UInt32,
  section_count : UInt32,
) -> Unit {
  write_symbol_u32(buffer, 0x12345678U)
  write_symbol_u32(buffer, (address_count * 4).reinterpret_as_uint())
  write_symbol_u32(buffer, thunk_count)
  write_symbol_u32(buffer, 4U)
  write_symbol_u16(buffer, 2U)
  write_symbol_u16(buffer, 0U)
  write_symbol_u32(buffer, 0x500U)
  write_symbol_u32(buffer, section_count)
}

///|
fn publics_write_gsi(
  buffer : Buffer,
  symbols : SymbolTable,
  version : UInt32,
  ordered : Bool,
) -> Unit {
  let count = symbols.record_count()
  write_symbol_u32(buffer, GSI_SIGNATURE)
  write_symbol_u32(buffer, version)
  write_symbol_u32(buffer, (count * 8).reinterpret_as_uint())
  write_symbol_u32(buffer, count.reinterpret_as_uint())
  for index in 0..<count {
    let record = symbols.record_at(index).unwrap()
    write_symbol_u32(buffer, (record.offset() + 1).reinterpret_as_uint())
    write_symbol_u32(buffer, 1U)
  }
  for word_index in 0..<GSI_BITMAP_WORDS {
    if word_index == 0 && count > 0 {
      write_symbol_u32(buffer, 0x7U)
    } else {
      write_symbol_u32(buffer, 0U)
    }
  }
  if ordered {
    write_symbol_u32(buffer, 0U)
    write_symbol_u32(buffer, 8U)
    write_symbol_u32(buffer, 16U)
  } else {
    write_symbol_u32(buffer, 16U)
    write_symbol_u32(buffer, 8U)
    write_symbol_u32(buffer, 0U)
  }
}

///|
fn publics_test_stream(
  symbols : SymbolTable,
  gsi_version : UInt32,
  ordered_addresses : Bool,
  ordered_buckets : Bool,
) -> Bytes {
  let stream = Buffer::Buffer(size_hint=700)
  publics_write_header(stream, symbols.record_count(), 1U, 2U)
  publics_write_gsi(stream, symbols, gsi_version, ordered_buckets)
  let indices = if ordered_addresses { [0, 1, 2] } else { [1, 0, 2] }
  for index in indices {
    let record = symbols.record_at(index).unwrap()
    write_symbol_u32(stream, record.offset().reinterpret_as_uint())
  }
  write_symbol_u32(stream, 0x77U)
  write_symbol_u32(stream, 0x1000U)
  write_symbol_u16(stream, 1U)
  write_symbol_u16(stream, 0U)
  write_symbol_u32(stream, 0x2000U)
  write_symbol_u16(stream, 2U)
  write_symbol_u16(stream, 0U)
  stream.to_bytes()
}

///|
test "parse Publics header, GSI table, and section offsets" {
  let symbols = publics_test_symbol_table()
  let publics = parse_publics_stream(
    publics_test_stream(symbols, GSI_VERSION, true, true),
    symbols,
    SymbolLimits::default(),
  )
  assert_eq(publics.header().symbol_hash(), 0x12345678U)
  assert_eq(publics.header().address_map_bytes(), 12U)
  assert_eq(publics.header().thunk_count(), 1U)
  assert_eq(publics.header().thunk_size(), 4U)
  assert_eq(publics.header().thunk_table_section(), 2)
  assert_eq(publics.header().thunk_table_offset(), 0x500U)
  assert_eq(publics.header().section_count(), 2U)
  assert_eq(publics.gsi().header().signature(), GSI_SIGNATURE)
  assert_eq(publics.gsi().header().version(), GSI_VERSION)
  assert_eq(publics.gsi().hash_record_count(), 3)
  assert_eq(publics.gsi().bitmap().length(), 129)
  assert_eq(publics.gsi().bucket_count(), 3)
  assert_eq(publics.gsi().bucket_map_index(0), Some(0))
  assert_eq(publics.gsi().bucket_map_index(1), Some(1))
  assert_eq(publics.gsi().bucket_map_index(2), Some(2))
  assert_eq(publics.gsi().bucket_map_index(3), Some(-1))
  assert_eq(publics.address_map().length(), 3)
  assert_eq(publics.thunk_map(), [0x77U])
  assert_eq(publics.section_offsets().length(), 2)
  assert_eq(publics.section_offsets()[1].section(), 2)
  assert_eq(publics.section_offsets()[1].offset(), 0x2000U)
}

///|
test "resolve Publics address map to S_PUB32 symbols" {
  let symbols = publics_test_symbol_table()
  let publics = parse_publics_stream(
    publics_test_stream(symbols, GSI_VERSION, true, true),
    symbols,
    SymbolLimits::default(),
  )
  assert_eq(publics.public_symbol_count(), 3)
  let first = publics.public_symbol_at(0).unwrap()
  assert_eq(first.name(), "first")
  assert_eq(first.segment(), 1)
  assert_eq(first.offset(), 0x100U)
  let exact = publics.find_public_exact(1, 0x200U).unwrap()
  assert_eq(exact.name(), "second")
  let nearest = publics.find_public_nearest(1, 0x280U).unwrap()
  assert_eq(nearest.name(), "second")
  let previous_segment = publics.find_public_nearest(2, 0x060U).unwrap()
  assert_eq(previous_segment.name(), "third")
  match publics.find_public_nearest(1, 0x050U) {
    None => ()
    Some(_) => fail("expected no public symbol before the first address")
  }
  match publics.find_public_exact(1, 0x180U) {
    None => ()
    Some(_) => fail("expected exact lookup to reject a gap")
  }
}

///|
test "reject invalid Publics and GSI streams" {
  let symbols = publics_test_symbol_table()
  let bad_version = publics_test_stream(symbols, 1U, true, true)
  try
    parse_publics_stream(bad_version, symbols, SymbolLimits::default())
  catch {
    UnsupportedGsiVersion(1) => ()
    _ => fail("unexpected GSI version error")
  } noraise {
    _ => fail("expected an unsupported GSI version to be rejected")
  }
  let unsorted = publics_test_stream(symbols, GSI_VERSION, false, true)
  try parse_publics_stream(unsorted, symbols, SymbolLimits::default()) catch {
    InvalidPublicSymbol(_) => ()
    _ => fail("unexpected Publics ordering error")
  } noraise {
    _ => fail("expected an unsorted address map to be rejected")
  }
  let short = publics_test_stream(symbols, GSI_VERSION, true, true)
    .exact_view(end=20)
    .to_owned()
  try parse_publics_stream(short, symbols, SymbolLimits::default()) catch {
    TruncatedPublics(_) => ()
    _ => fail("unexpected short Publics error")
  } noraise {
    _ => fail("expected a short Publics stream to be rejected")
  }
}

///|
test "enforce Publics limits" {
  let symbols = publics_test_symbol_table()
  let limits = SymbolLimits::{
    max_stream_bytes: 4096,
    max_records: 100,
    max_record_bytes: 4096,
    max_global_refs: 100,
    max_hash_records: 1,
    max_public_symbols: 100,
  }
  try
    parse_publics_stream(
      publics_test_stream(symbols, GSI_VERSION, true, true),
      symbols,
      limits,
    )
  catch {
    PublicsLimitExceeded(_) => ()
    _ => fail("unexpected hash-record limit error")
  } noraise {
    _ => fail("expected the GSI hash-record limit to be enforced")
  }
}
