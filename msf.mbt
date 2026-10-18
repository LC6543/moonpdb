///|
const MSF_MAGIC : Bytes = b"Microsoft C/C++ MSF 7.00\r\n\x1aDS\x00\x00\x00"

///|
/// The fixed MSF 7.0 superblock fields that describe the container layout.
pub struct MsfHeader {
  block_size : Int32
  free_block_map_block : Int32
  num_blocks : Int32
  num_directory_bytes : Int32
  block_map_addr : Int32
}

///|
pub fn MsfHeader::block_size(self : MsfHeader) -> Int32 {
  self.block_size
}

///|
pub fn MsfHeader::free_block_map_block(self : MsfHeader) -> Int32 {
  self.free_block_map_block
}

///|
pub fn MsfHeader::num_blocks(self : MsfHeader) -> Int32 {
  self.num_blocks
}

///|
pub fn MsfHeader::num_directory_bytes(self : MsfHeader) -> Int32 {
  self.num_directory_bytes
}

///|
pub fn MsfHeader::block_map_addr(self : MsfHeader) -> Int32 {
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
  let block_size = uint_to_int(read_u32_le_at(data, 32), "block size")
  let valid_block_size = block_size == 512 ||
    block_size == 1024 ||
    block_size == 2048 ||
    block_size == 4096
  if !valid_block_size {
    raise UnsupportedBlockSize(block_size)
  }
  let free_block_map_block = uint_to_int(
    read_u32_le_at(data, 36),
    "free block map block",
  )
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
  let num_directory_bytes = uint_to_int(
    read_u32_le_at(data, 44),
    "directory byte count",
  )
  if num_directory_bytes <= 0 {
    raise InvalidDirectory("directory must not be empty")
  }
  if num_directory_bytes > limits.max_directory_bytes {
    raise LimitExceeded("directory byte limit exceeded")
  }
  let block_map_addr = uint_to_int(
    read_u32_le_at(data, 52),
    "block map address",
  )
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
/// One stream and the physical file blocks that contain it.
pub struct MsfStream {
  index : Int32
  size : Int32
  blocks : Array[Int32]
}

///|
pub fn MsfStream::index(self : MsfStream) -> Int32 {
  self.index
}

///|
pub fn MsfStream::size(self : MsfStream) -> Int32 {
  self.size
}

///|
pub fn MsfStream::block_count(self : MsfStream) -> Int32 {
  self.blocks.length()
}

///|
/// A parsed MSF container with bounded stream access.
pub struct MsfFile {
  data : Bytes
  header : MsfHeader
  streams : Array[MsfStream]
}

///|
pub fn MsfFile::header(self : MsfFile) -> MsfHeader {
  self.header
}

///|
pub fn MsfFile::stream_count(self : MsfFile) -> Int32 {
  self.streams.length()
}

///|
pub fn MsfFile::stream_info(
  self : MsfFile,
  index : Int32,
) -> MsfStream raise MsfError {
  if index < 0 || index >= self.streams.length() {
    raise InvalidStream(index)
  }
  self.streams[index]
}

///|
/// Return the logical bytes of one stream.
pub fn MsfFile::stream(self : MsfFile, index : Int32) -> Bytes raise MsfError {
  let stream = self.stream_info(index)
  if stream.size == 0 {
    return b""
  }
  let buffer = Buffer::Buffer(size_hint=stream.size)
  let mut remaining = stream.size
  let block_size = self.header.block_size
  for block in stream.blocks {
    let available = block_size
    let take = if remaining < available { remaining } else { available }
    let start = checked_mul(block, block_size, "stream block offset")
    let end = checked_add(start, take, "stream block end")
    if end > self.data.length() {
      raise Truncated(end)
    }
    buffer.write_bytes(self.data.exact_view(start~, end~))
    remaining = remaining - take
  }
  if remaining != 0 {
    raise InvalidStream(index)
  }
  buffer.to_bytes()
}

///|
/// Parse the MSF container and its stream directory.
pub fn parse_msf(data : Bytes, limits : MsfLimits) -> MsfFile raise MsfError {
  let header = parse_msf_header(data, limits)
  let directory = read_stream_directory(data, header)
  let (streams, next) = parse_stream_directory(directory, header, limits)
  if next != directory.length() {
    raise InvalidDirectory("unexpected trailing directory bytes")
  }
  MsfFile::{ data, header, streams, }
}

///|
fn read_stream_directory(
  data : Bytes,
  header : MsfHeader,
) -> Bytes raise MsfError {
  let directory_blocks = be_div_ceil(
    header.num_directory_bytes,
    header.block_size,
  )
  let block_map_size = checked_mul(
    directory_blocks, 4, "directory block map size",
  )
  if block_map_size > header.block_size {
    raise LimitExceeded("directory block map exceeds one block")
  }
  let block_map_offset = checked_mul(
    header.block_map_addr,
    header.block_size,
    "directory block map offset",
  )
  let block_map_end = checked_add(
    block_map_offset, block_map_size, "directory block map end",
  )
  if block_map_end > data.length() {
    raise Truncated(block_map_end)
  }
  let directory = Buffer::Buffer(size_hint=header.num_directory_bytes)
  let mut cursor = block_map_offset
  for _ in 0..<directory_blocks {
    let (block_index, next) = read_u32_le(data, cursor, block_map_end)
    cursor = next
    let block = uint_to_int(block_index, "directory block index")
    if block < 0 || block >= header.num_blocks {
      raise InvalidBlockIndex(block)
    }
    let start = checked_mul(block, header.block_size, "directory block offset")
    let end = checked_add(start, header.block_size, "directory block end")
    if end > data.length() {
      raise Truncated(end)
    }
    directory.write_bytes(data.exact_view(start~, end~))
  }
  let bytes = directory.to_bytes()
  bytes.exact_view(end=header.num_directory_bytes).to_owned()
}

///|
fn parse_stream_directory(
  directory : Bytes,
  header : MsfHeader,
  limits : MsfLimits,
) -> (Array[MsfStream], Int32) raise MsfError {
  let count_and_cursor = read_u32_le(directory, 0, directory.length())
  let stream_count_raw = count_and_cursor.0
  let mut cursor = count_and_cursor.1
  let stream_count = uint_to_int(stream_count_raw, "stream count")
  if stream_count > limits.max_streams {
    raise LimitExceeded("stream count limit exceeded")
  }
  let sizes = []
  for _ in 0..<stream_count {
    let (size_raw, next) = read_u32_le(directory, cursor, directory.length())
    let size = uint_to_int(size_raw, "stream size")
    if size > limits.max_stream_bytes {
      raise LimitExceeded("stream byte limit exceeded")
    }
    sizes.push(size)
    cursor = next
  }
  let streams = []
  for index in 0..<stream_count {
    let size = sizes[index]
    let block_count = be_div_ceil(size, header.block_size)
    let blocks = []
    for _ in 0..<block_count {
      let (block_raw, next) = read_u32_le(directory, cursor, directory.length())
      let block = uint_to_int(block_raw, "stream block index")
      if block < 0 || block >= header.num_blocks {
        raise InvalidBlockIndex(block)
      }
      blocks.push(block)
      cursor = next
    }
    streams.push(MsfStream::{ index, size, blocks, })
  }
  (streams, cursor)
}

///|
fn bytes_equal(
  left : Bytes,
  left_offset : Int32,
  right : Bytes,
  length : Int32,
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
