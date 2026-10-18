///|
fn assemble_test_msf(block_map : Bytes, directory : Bytes) -> Bytes {
  let stream_two = test_stream_two_data()
  let file = Buffer::Buffer(size_hint=8 * TEST_BLOCK_SIZE)
  file.write_bytes(padded_test_block(test_superblock()).exact_view())
  file.write_bytes(padded_test_block(b"").exact_view())
  file.write_bytes(padded_test_block(b"").exact_view())
  file.write_bytes(padded_test_block(block_map).exact_view())
  file.write_bytes(padded_test_block(directory).exact_view())
  file.write_bytes(
    padded_test_block(
      stream_two.exact_view(start=0, end=4096).to_owned(),
    ).exact_view(),
  )
  file.write_bytes(
    padded_test_block(
      stream_two.exact_view(start=4096, end=6000).to_owned(),
    ).exact_view(),
  )
  file.write_bytes(padded_test_block(b"PDBINFO!").exact_view())
  file.to_bytes()
}

///|
fn test_directory_with_stream_block(block : UInt) -> Bytes {
  let buffer = Buffer::Buffer(size_hint=28)
  buffer.write_uint_le(3U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(8U)
  buffer.write_uint_le(6000U)
  buffer.write_uint_le(7U)
  buffer.write_uint_le(block)
  buffer.write_uint_le(6U)
  buffer.to_bytes()
}

///|
test "reject an invalid directory block index" {
  let block_map = Buffer::Buffer(size_hint=4)
  block_map.write_uint_le(99U)
  let data = assemble_test_msf(block_map.to_bytes(), test_directory())
  try parse_msf(data, MsfLimits::default()) catch {
    InvalidBlockIndex(99) => ()
    _ => fail("unexpected directory block error")
  } noraise {
    _ => fail("expected invalid directory block to be rejected")
  }
}

///|
test "reject an invalid stream block index" {
  let directory = test_directory_with_stream_block(99U)
  let data = assemble_test_msf(test_block_map(), directory)
  try parse_msf(data, MsfLimits::default()) catch {
    InvalidBlockIndex(99) => ()
    _ => fail("unexpected stream block error")
  } noraise {
    _ => fail("expected invalid stream block to be rejected")
  }
}

///|
test "reject unsupported block sizes and free block maps" {
  let buffer = Buffer::Buffer(size_hint=56)
  buffer.write_bytes(b"Microsoft C/C++ MSF 7.00\r\n\x1aDS\x00\x00\x00".exact_view())
  buffer.write_uint_le(123U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(4U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  let data = padded_test_block(buffer.to_bytes())
  try parse_msf_header(data, MsfLimits::default()) catch {
    UnsupportedBlockSize(123) => ()
    _ => fail("unexpected block-size error")
  } noraise {
    _ => fail("expected unsupported block size to be rejected")
  }
  let buffer = Buffer::Buffer(size_hint=56)
  buffer.write_bytes(b"Microsoft C/C++ MSF 7.00\r\n\x1aDS\x00\x00\x00".exact_view())
  buffer.write_uint_le(4096U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(4U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  let data = padded_test_block(buffer.to_bytes())
  try parse_msf_header(data, MsfLimits::default()) catch {
    InvalidFreeBlockMap(0) => ()
    _ => fail("unexpected free-block-map error")
  } noraise {
    _ => fail("expected invalid free block map to be rejected")
  }
}

///|
test "reject truncated block-aligned files" {
  let data = make_test_msf()
  let truncated = data.exact_view(end=100).to_owned()
  try parse_msf_header(truncated, MsfLimits::default()) catch {
    InvalidBlockCount(8) => ()
    _ => fail("unexpected truncated-file error")
  } noraise {
    _ => fail("expected truncated file to be rejected")
  }
}
