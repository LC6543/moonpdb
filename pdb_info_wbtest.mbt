///|
fn test_pdb_info_bytes_with(
  key_offset : UInt32,
  stream_index : UInt32,
  second_stream_index : UInt32,
  present_bits : UInt32,
  feature_bytes : Bytes,
) -> Bytes {
  let names = b"/names\x00/HeaderBlock\x00"
  let buffer = Buffer::Buffer(size_hint=128)
  buffer.write_uint_le(20000404U)
  buffer.write_uint_le(0x12345678U)
  buffer.write_uint_le(1U)
  buffer.write_bytes(
    b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f".exact_view(),
  )
  buffer.write_uint_le(names.length().reinterpret_as_uint())
  buffer.write_bytes(names.exact_view())
  buffer.write_uint_le(2U)
  buffer.write_uint_le(3U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(present_bits)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(key_offset)
  buffer.write_uint_le(stream_index)
  buffer.write_uint_le(7U)
  buffer.write_uint_le(second_stream_index)
  buffer.write_bytes(feature_bytes.exact_view())
  buffer.to_bytes()
}

///|
fn test_pdb_info_bytes() -> Bytes {
  test_pdb_info_bytes_with(0U, 10U, 11U, 0b011U, b"\x4e\x4f\x54\x4d")
}

///|
fn test_msf_with_info(info : Bytes) -> Bytes {
  let stream_two = test_stream_two_data()
  let directory = Buffer::Buffer(size_hint=28)
  directory.write_uint_le(3U)
  directory.write_uint_le(0U)
  directory.write_uint_le(info.length().reinterpret_as_uint())
  directory.write_uint_le(6000U)
  directory.write_uint_le(7U)
  directory.write_uint_le(5U)
  directory.write_uint_le(6U)
  let file = Buffer::Buffer(size_hint=8 * TEST_BLOCK_SIZE)
  file.write_bytes(padded_test_block(test_superblock()).exact_view())
  file.write_bytes(padded_test_block(b"").exact_view())
  file.write_bytes(padded_test_block(b"").exact_view())
  file.write_bytes(padded_test_block(test_block_map()).exact_view())
  file.write_bytes(padded_test_block(directory.to_bytes()).exact_view())
  file.write_bytes(
    padded_test_block(stream_two.exact_view(start=0, end=4096).to_owned()).exact_view(),
  )
  file.write_bytes(
    padded_test_block(stream_two.exact_view(start=4096, end=6000).to_owned()).exact_view(),
  )
  file.write_bytes(padded_test_block(info).exact_view())
  file.to_bytes()
}

///|
test "parse PDB info header and named streams" {
  let info = parse_pdb_info(test_pdb_info_bytes(), 32, PdbInfoLimits::default())
  assert_eq(info.version(), 20000404U)
  assert_eq(info.signature(), 0x12345678U)
  assert_eq(info.age(), 1U)
  assert_eq(info.guid_string(), "03020100-0504-0706-0809-0a0b0c0d0e0f")
  assert_eq(info.named_stream_count(), 2)
  assert_eq(info.named_stream_index("/names"), Some(10))
  assert_eq(info.named_stream_index("/HeaderBlock"), Some(11))
  assert_eq(info.named_stream_index("/missing"), None)
  assert_true(info.has_feature(0x4D544F4EU))
}

///|
test "read PDB info from MSF stream one" {
  let info_bytes = test_pdb_info_bytes_with(
    0U, 0U, 2U, 0b011U, b"\x4e\x4f\x54\x4d",
  )
  let msf = parse_msf(test_msf_with_info(info_bytes), MsfLimits::default())
  let info = msf.pdb_info(PdbInfoLimits::default())
  assert_eq(info.age(), 1U)
  assert_eq(info.named_stream_index("/names"), Some(0))
}

///|
test "reject malformed PDB info records" {
  let bad_count = test_pdb_info_bytes_with(0U, 10U, 11U, 0b111U, b"")
  try parse_pdb_info(bad_count, 32, PdbInfoLimits::default()) catch {
    InvalidInfoValue(_) => ()
    _ => fail("unexpected present-bit error")
  } noraise {
    _ => fail("expected present-bit mismatch to be rejected")
  }
  let bad_offset = test_pdb_info_bytes_with(100U, 10U, 11U, 0b011U, b"")
  try parse_pdb_info(bad_offset, 32, PdbInfoLimits::default()) catch {
    InvalidNamedStream(_) => ()
    _ => fail("unexpected name-offset error")
  } noraise {
    _ => fail("expected invalid name offset to be rejected")
  }
  let bad_stream = test_pdb_info_bytes_with(0U, 99U, 11U, 0b011U, b"")
  try parse_pdb_info(bad_stream, 32, PdbInfoLimits::default()) catch {
    InvalidNamedStream(_) => ()
    _ => fail("unexpected stream-index error")
  } noraise {
    _ => fail("expected invalid named stream index to be rejected")
  }
  let bad_features = test_pdb_info_bytes_with(
    0U, 10U, 11U, 0b011U, b"\x00\x00\x00",
  )
  try parse_pdb_info(bad_features, 32, PdbInfoLimits::default()) catch {
    InvalidInfoValue(_) => ()
    _ => fail("unexpected feature alignment error")
  } noraise {
    _ => fail("expected unaligned feature bytes to be rejected")
  }
}

///|
test "enforce PDB info limits" {
  let limits = PdbInfoLimits::{
    max_string_bytes: 1024,
    max_named_streams: 1,
    max_hash_capacity: 1024,
    max_features: 8,
  }
  try parse_pdb_info(test_pdb_info_bytes(), 32, limits) catch {
    LimitExceededInfo(_) => ()
    _ => fail("unexpected named-stream limit error")
  } noraise {
    _ => fail("expected named-stream limit to be enforced")
  }
}
