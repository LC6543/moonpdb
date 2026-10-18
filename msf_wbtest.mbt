///|
const TEST_BLOCK_SIZE : Int32 = 4096

///|
fn padded_test_block(contents : Bytes) -> Bytes {
  let buffer = Buffer::Buffer(size_hint=TEST_BLOCK_SIZE)
  buffer.write_bytes(contents.exact_view())
  for _ in contents.length()..<TEST_BLOCK_SIZE {
    buffer.write_byte(0)
  }
  buffer.to_bytes()
}

///|
fn test_stream_two_data() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=6000)
  for index in 0..<6000 {
    buffer.write_byte((index % 251).to_byte())
  }
  buffer.to_bytes()
}

///|
fn test_superblock() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=56)
  buffer.write_bytes(
    b"Microsoft C/C++ MSF 7.00\r\n\x1aDS\x00\x00\x00".exact_view(),
  )
  buffer.write_uint_le(4096U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(8U)
  buffer.write_uint_le(28U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(3U)
  buffer.to_bytes()
}

///|
fn test_directory() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=28)
  buffer.write_uint_le(3U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(8U)
  buffer.write_uint_le(6000U)
  buffer.write_uint_le(7U)
  buffer.write_uint_le(5U)
  buffer.write_uint_le(6U)
  buffer.to_bytes()
}

///|
fn test_block_map() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=4)
  buffer.write_uint_le(4U)
  buffer.to_bytes()
}

///|
fn make_test_msf() -> Bytes {
  let stream_two = test_stream_two_data()
  let file = Buffer::Buffer(size_hint=8 * TEST_BLOCK_SIZE)
  file.write_bytes(padded_test_block(test_superblock()).exact_view())
  file.write_bytes(padded_test_block(b"").exact_view())
  file.write_bytes(padded_test_block(b"").exact_view())
  file.write_bytes(padded_test_block(test_block_map()).exact_view())
  file.write_bytes(padded_test_block(test_directory()).exact_view())
  file.write_bytes(
    padded_test_block(stream_two.exact_view(start=0, end=4096).to_owned()).exact_view(),
  )
  file.write_bytes(
    padded_test_block(stream_two.exact_view(start=4096, end=6000).to_owned()).exact_view(),
  )
  file.write_bytes(padded_test_block(b"PDBINFO!").exact_view())
  file.to_bytes()
}

///|
test "parse MSF superblock" {
  let header = parse_msf_header(make_test_msf(), MsfLimits::default())
  assert_eq(header.block_size(), 4096)
  assert_eq(header.free_block_map_block(), 1)
  assert_eq(header.num_blocks(), 8)
  assert_eq(header.num_directory_bytes(), 28)
  assert_eq(header.block_map_addr(), 3)
}

///|
test "read streams through the directory" {
  let msf = parse_msf(make_test_msf(), MsfLimits::default())
  assert_eq(msf.stream_count(), 3)
  assert_eq(msf.stream_info(0).size(), 0)
  assert_eq(msf.stream_info(1).size(), 8)
  assert_eq(msf.stream_info(2).size(), 6000)
  assert_eq(msf.stream_info(2).block_count(), 2)
  assert_eq(msf.stream(0), b"")
  assert_eq(msf.stream(1), b"PDBINFO!")
  assert_eq(msf.stream(2), test_stream_two_data())
}

///|
test "reject malformed MSF headers" {
  try parse_msf_header(b"short", MsfLimits::default()) catch {
    TooSmall(_) => ()
    _ => fail("unexpected short-header error")
  } noraise {
    _ => fail("expected short header to be rejected")
  }
  let bad_magic = make_test_msf()
  let corrupted = b"X" +
    bad_magic.exact_view(start=1, end=bad_magic.length()).to_owned()
  try parse_msf_header(corrupted, MsfLimits::default()) catch {
    BadMagic => ()
    _ => fail("unexpected magic error")
  } noraise {
    _ => fail("expected bad magic to be rejected")
  }
}

///|
test "reject invalid stream indexes" {
  let msf = parse_msf(make_test_msf(), MsfLimits::default())
  try msf.stream(3) catch {
    InvalidStream(3) => ()
    _ => fail("unexpected stream-index error")
  } noraise {
    _ => fail("expected out-of-range stream to be rejected")
  }
}

///|
test "enforce stream and directory limits" {
  let stream_limits = MsfLimits::{
    max_file_bytes: 1_000_000,
    max_directory_bytes: 1024,
    max_streams: 8,
    max_stream_bytes: 100,
  }
  try parse_msf(make_test_msf(), stream_limits) catch {
    LimitExceeded(_) => ()
    _ => fail("unexpected stream-limit error")
  } noraise {
    _ => fail("expected stream byte limit to be enforced")
  }
  let directory_limits = MsfLimits::{
    max_file_bytes: 1_000_000,
    max_directory_bytes: 8,
    max_streams: 8,
    max_stream_bytes: 10_000,
  }
  try parse_msf(make_test_msf(), directory_limits) catch {
    LimitExceeded(_) => ()
    _ => fail("unexpected directory-limit error")
  } noraise {
    _ => fail("expected directory byte limit to be enforced")
  }
}
