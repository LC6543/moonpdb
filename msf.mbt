///|
const MSF_MAGIC : Bytes = b"Microsoft C/C++ MSF 7.00\r\n\x1aDS\x00\x00\x00"

///|
/// The fixed MSF 7.0 superblock fields that describe the container layout.
pub struct MsfHeader {
  block_size : Int
  free_block_map_block : Int
  num_blocks : Int
  num_directory_bytes : Int
  block_map_addr : Int
}

///|
pub fn MsfHeader::block_size(self : MsfHeader) -> Int {
  self.block_size
}

///|
pub fn MsfHeader::free_block_map_block(self : MsfHeader) -> Int {
  self.free_block_map_block
}

///|
pub fn MsfHeader::num_blocks(self : MsfHeader) -> Int {
  self.num_blocks
}

///|
pub fn MsfHeader::num_directory_bytes(self : MsfHeader) -> Int {
  self.num_directory_bytes
}

///|
pub fn MsfHeader::block_map_addr(self : MsfHeader) -> Int {
  self.block_map_addr
}

///|
/// Parse and validate the MSF superblock.
pub fn parse_msf_header(
  data : Bytes,
  limits : MsfLimits,
) -> MsfHeader raise MsfError {
  if data.length() < 56 {
    raise TooSmall(data.length())
  }
  if data.length() > limits.max_file_bytes {
    raise LimitExceeded("file byte limit exceeded")
  }
  if !bytes_equal(data, 0, MSF_MAGIC, 32) {
    raise BadMagic
  }
  let block_size =
    uint_to_int(read_u32_le_at(data, 32), "block size")
  let valid_block_size = block_size == 512 || block_size == 1024 || block_size == 2048 || block_size == 4096
  if !valid_block_size {
    raise UnsupportedBlockSize(block_size)
  }
  let free_block_map_block =
    uint_to_int(read_u32_le_at(data, 36), "free block map block")
  if free_block_map_block != 1 && free_block_map_block != 2 {
    raise InvalidFreeBlockMap(free_block_map_block)
  }
  let num_blocks = uint_to_int(read_u32_le_at(data, 40), "block count")
  if num_blocks <= 0 {
    raise InvalidBlockCount(num_blocks)
  }
  let expected_size = checked_mul(num_blocks, block_size, "file size")
  if expected_size != data.length() {
    raise InvalidBlockCount(num_blocks)
  }
  let num_directory_bytes =
    uint_to_int(read_u32_le_at(data, 44), "directory byte count")
  if num_directory_bytes <= 0 {
    raise InvalidDirectory("directory must not be empty")
  }
  if num_directory_bytes > limits.max_directory_bytes {
    raise LimitExceeded("directory byte limit exceeded")
  }
  let block_map_addr =
    uint_to_int(read_u32_le_at(data, 52), "block map address")
  if block_map_addr < 0 || block_map_addr >= num_blocks {
    raise InvalidBlockIndex(block_map_addr)
  }
  MsfHeader::{
    block_size,
    free_block_map_block,
    num_blocks,
    num_directory_bytes,
    block_map_addr,
  }
}

///|
fn bytes_equal(
  left : Bytes,
  left_offset : Int,
  right : Bytes,
  length : Int,
) -> Bool {
  if left_offset < 0 {
    return false
  }
  if length < 0 {
    return false
  }
  if left_offset + length > left.length() {
    return false
  }
  if length > right.length() {
    return false
  }
  let mut index = 0
  while index < length {
    if left.at(left_offset + index) != right.at(index) {
      return false
    }
    index = index + 1
  }
  true
}
