///|
/// Resource limits for the PDB Info stream.
pub struct PdbInfoLimits {
  max_string_bytes : Int32
  max_named_streams : Int32
  max_hash_capacity : Int32
  max_features : Int32
}

///|
pub fn PdbInfoLimits::default() -> PdbInfoLimits {
  PdbInfoLimits::{
    max_string_bytes: 1024 * 1024,
    max_named_streams: 4096,
    max_hash_capacity: 1_048_576,
    max_features: 256,
  }
}

///|
/// One name-to-stream-index entry in the PDB Info stream.
pub struct NamedStream {
  name : String
  stream_index : Int32
}

///|
pub fn NamedStream::name(self : NamedStream) -> String {
  self.name
}

///|
pub fn NamedStream::stream_index(self : NamedStream) -> Int32 {
  self.stream_index
}

///|
/// The fixed header and variable sections of the PDB Info stream.
pub struct PdbInfo {
  version : UInt32
  signature : UInt32
  age : UInt32
  guid : Bytes
  named_streams : Array[NamedStream]
  feature_codes : Array[UInt32]
}

///|
pub fn PdbInfo::version(self : PdbInfo) -> UInt32 {
  self.version
}

///|
pub fn PdbInfo::signature(self : PdbInfo) -> UInt32 {
  self.signature
}

///|
pub fn PdbInfo::age(self : PdbInfo) -> UInt32 {
  self.age
}

///|
pub fn PdbInfo::guid(self : PdbInfo) -> Bytes {
  self.guid
}

///|
pub fn PdbInfo::named_stream_count(self : PdbInfo) -> Int32 {
  self.named_streams.length()
}

///|
pub fn PdbInfo::named_streams(self : PdbInfo) -> Array[NamedStream] {
  self.named_streams.copy()
}

///|
pub fn PdbInfo::named_stream_index(self : PdbInfo, name : String) -> Int32? {
  for stream in self.named_streams {
    if stream.name == name {
      return Some(stream.stream_index)
    }
  }
  None
}

///|
pub fn PdbInfo::feature_codes(self : PdbInfo) -> Array[UInt32] {
  self.feature_codes.copy()
}

///|
pub fn PdbInfo::has_feature(self : PdbInfo, code : UInt32) -> Bool {
  for feature in self.feature_codes {
    if feature == code {
      return true
    }
  }
  false
}

///|
/// Format the PDB GUID using the conventional Windows field order.
pub fn PdbInfo::guid_string(self : PdbInfo) -> String {
  let guid = self.guid
  guid.at(3).to_hex() +
  guid.at(2).to_hex() +
  guid.at(1).to_hex() +
  guid.at(0).to_hex() +
  "-" +
  guid.at(5).to_hex() +
  guid.at(4).to_hex() +
  "-" +
  guid.at(7).to_hex() +
  guid.at(6).to_hex() +
  "-" +
  guid.at(8).to_hex() +
  guid.at(9).to_hex() +
  "-" +
  guid.at(10).to_hex() +
  guid.at(11).to_hex() +
  guid.at(12).to_hex() +
  guid.at(13).to_hex() +
  guid.at(14).to_hex() +
  guid.at(15).to_hex()
}

///|
/// Parse stream 1 of an already parsed MSF file.
pub fn MsfFile::pdb_info(
  self : MsfFile,
  limits : PdbInfoLimits,
) -> PdbInfo raise PdbInfoError {
  let info_bytes = self.stream(1) catch { _ => raise InfoStreamUnavailable }
  parse_pdb_info(info_bytes, self.stream_count(), limits)
}

///|
/// Parse the PDB Info stream bytes.
pub fn parse_pdb_info(
  data : Bytes,
  msf_stream_count : Int32,
  limits : PdbInfoLimits,
) -> PdbInfo raise PdbInfoError {
  if data.length() < 28 {
    raise TruncatedInfo(data.length())
  }
  if msf_stream_count <= 0 {
    raise InvalidInfoValue("MSF stream count must be positive")
  }
  let (version, cursor) = read_info_u32_le(data, 0, data.length())
  let (signature, cursor) = read_info_u32_le(data, cursor, data.length())
  let (age, cursor) = read_info_u32_le(data, cursor, data.length())
  let (guid, cursor) = read_info_bytes(data, cursor, data.length(), 16)
  let (string_buffer_size_raw, cursor) = read_info_u32_le(
    data,
    cursor,
    data.length(),
  )
  let string_buffer_size = info_uint_to_int(
    string_buffer_size_raw, "named stream string bytes",
  )
  if string_buffer_size > limits.max_string_bytes {
    raise LimitExceededInfo("named stream string byte limit exceeded")
  }
  let (string_buffer, cursor) = read_info_bytes(
    data,
    cursor,
    data.length(),
    string_buffer_size,
  )
  let (named_streams, cursor) = parse_named_stream_map(
    data, cursor, string_buffer, msf_stream_count, limits,
  )
  let feature_codes = parse_feature_codes(data, cursor, limits)
  PdbInfo::{ version, signature, age, guid, named_streams, feature_codes, }
}

///|
fn parse_named_stream_map(
  data : Bytes,
  start : Int32,
  string_buffer : Bytes,
  msf_stream_count : Int32,
  limits : PdbInfoLimits,
) -> (Array[NamedStream], Int32) raise PdbInfoError {
  let size_and_cursor = read_info_u32_le(data, start, data.length())
  let size_raw = size_and_cursor.0
  let mut cursor = size_and_cursor.1
  let capacity_and_cursor = read_info_u32_le(data, cursor, data.length())
  let capacity_raw = capacity_and_cursor.0
  cursor = capacity_and_cursor.1
  let size = info_uint_to_int(size_raw, "named stream count")
  let capacity = info_uint_to_int(capacity_raw, "named stream capacity")
  if size > limits.max_named_streams {
    raise LimitExceededInfo("named stream count limit exceeded")
  }
  if capacity > limits.max_hash_capacity || capacity < size {
    raise InvalidInfoValue("invalid named stream hash capacity")
  }
  let present = read_bit_vector(data, cursor, capacity)
  let present_words = present.0
  cursor = present.1
  let deleted = read_bit_vector(data, cursor, capacity)
  let deleted_words = deleted.0
  cursor = deleted.1
  if bit_count(present_words) != size {
    raise InvalidInfoValue("present bit count does not match table size")
  }
  for index in 0..<present_words.length() {
    if (present_words[index] & deleted_words[index]) != 0U {
      raise InvalidInfoValue("a bucket cannot be both present and deleted")
    }
  }
  let streams = []
  for _ in 0..<size {
    let (key_offset_raw, next) = read_info_u32_le(data, cursor, data.length())
    let (stream_index_raw, next) = read_info_u32_le(data, next, data.length())
    let key_offset = info_uint_to_int(key_offset_raw, "named stream key offset")
    let stream_index = info_uint_to_int(stream_index_raw, "named stream index")
    if key_offset < 0 || key_offset >= string_buffer.length() {
      raise InvalidNamedStream("key offset is outside the string buffer")
    }
    if stream_index < 0 || stream_index >= msf_stream_count {
      raise InvalidNamedStream("stream index is outside the MSF file")
    }
    let name_end = find_nul(string_buffer, key_offset)
    let name = decode_named_stream(
      string_buffer.exact_view(start=key_offset, end=name_end),
    )
    streams.push(NamedStream::{ name, stream_index, })
    cursor = next
  }
  (streams, cursor)
}

///|
fn read_bit_vector(
  data : Bytes,
  start : Int32,
  capacity : Int32,
) -> (Array[UInt32], Int32) raise PdbInfoError {
  let (word_count_raw, cursor) = read_info_u32_le(data, start, data.length())
  let word_count = info_uint_to_int(word_count_raw, "bit vector word count")
  let expected_words = be_div_ceil(capacity, 32)
  if word_count != expected_words {
    raise InvalidInfoValue("bit vector word count does not match capacity")
  }
  let words = []
  let mut cursor = cursor
  for _ in 0..<word_count {
    let (word, next) = read_info_u32_le(data, cursor, data.length())
    words.push(word)
    cursor = next
  }
  (words, cursor)
}

///|
fn bit_count(words : Array[UInt32]) -> Int32 {
  let mut total = 0
  for word in words {
    total = total + word.popcnt()
  }
  total
}

///|
fn parse_feature_codes(
  data : Bytes,
  start : Int32,
  limits : PdbInfoLimits,
) -> Array[UInt32] raise PdbInfoError {
  let remaining = data.length() - start
  if remaining % 4 != 0 {
    raise InvalidInfoValue("feature code bytes are not aligned to 4 bytes")
  }
  let count = remaining / 4
  if count > limits.max_features {
    raise LimitExceededInfo("feature code limit exceeded")
  }
  let codes = []
  let mut cursor = start
  for _ in 0..<count {
    let (code, next) = read_info_u32_le(data, cursor, data.length())
    codes.push(code)
    cursor = next
  }
  codes
}

///|
fn read_info_u32_le(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt32, Int32) raise PdbInfoError {
  read_u32_le(data, pos, end) catch {
    Truncated(_) => raise TruncatedInfo(pos)
    _ => raise InvalidInfoValue("invalid PDB Info stream offset")
  }
}

///|
fn read_info_bytes(
  data : Bytes,
  pos : Int32,
  end : Int32,
  length : Int32,
) -> (Bytes, Int32) raise PdbInfoError {
  if length < 0 || pos < 0 || pos + length > end {
    raise TruncatedInfo(pos)
  }
  (data.exact_view(start=pos, end=pos + length).to_owned(), pos + length)
}

///|
fn info_uint_to_int(value : UInt32, field : String) -> Int32 raise PdbInfoError {
  let wide = value.to_int64()
  if wide > 0x7FFFFFFFL {
    raise InvalidInfoValue("\{field} exceeds Int range")
  }
  wide.to_int()
}

///|
fn find_nul(data : Bytes, start : Int32) -> Int32 raise PdbInfoError {
  let mut index = start
  while index < data.length() {
    if data.at(index) == 0 {
      return index
    }
    index = index + 1
  }
  raise InvalidNamedStream("named stream is not NUL-terminated")
}

///|
fn decode_named_stream(data : BytesView) -> String raise PdbInfoError {
  @utf8.decode(data) catch {
    _ => raise InvalidNamedStream("named stream is not valid UTF-8")
  }
}
