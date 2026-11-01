///|
const PDB_STRING_TABLE_SIGNATURE : UInt32 = 0xEFFEEFFEU

///|
/// Resource limits for the PDB `/names` string table.
pub struct PdbStringTableLimits {
  max_bytes : Int32
  max_names : Int32
}

///|
pub fn PdbStringTableLimits::default() -> PdbStringTableLimits {
  PdbStringTableLimits::{ max_bytes: 64 * 1024 * 1024, max_names: 1_000_000, }
}

///|
/// Parsed PDB `/names` stream.
pub struct PdbStringTable {
  signature : UInt32
  hash_version : UInt32
  strings : DebugStringTable
  name_ids : Array[UInt32]
  name_count : UInt32
}

///|
pub fn PdbStringTable::signature(self : PdbStringTable) -> UInt32 {
  self.signature
}

///|
pub fn PdbStringTable::hash_version(self : PdbStringTable) -> UInt32 {
  self.hash_version
}

///|
pub fn PdbStringTable::strings(self : PdbStringTable) -> DebugStringTable {
  self.strings
}

///|
pub fn PdbStringTable::name_id_count(self : PdbStringTable) -> Int32 {
  self.name_ids.length()
}

///|
pub fn PdbStringTable::name_id_at(
  self : PdbStringTable,
  index : Int32,
) -> UInt32? {
  if index < 0 || index >= self.name_ids.length() {
    None
  } else {
    Some(self.name_ids[index])
  }
}

///|
pub fn PdbStringTable::name_count(self : PdbStringTable) -> UInt32 {
  self.name_count
}

///|
pub fn PdbStringTable::string_for_id(
  self : PdbStringTable,
  id : UInt32,
) -> String? {
  self.strings.string_at(id)
}

///|
/// Parse the `/names` stream referenced by PDB Info.
pub fn parse_pdb_string_table(
  data : Bytes,
  limits : PdbStringTableLimits,
) -> PdbStringTable raise SymbolError {
  if data.length() > limits.max_bytes {
    raise C13LimitExceeded("PDB string table byte limit exceeded")
  }
  if data.length() < 16 {
    raise TruncatedC13(data.length())
  }
  let (signature, cursor) = read_symbol_u32(data, 0, data.length())
  if signature != PDB_STRING_TABLE_SIGNATURE {
    raise InvalidPdbStringTable("invalid /names signature")
  }
  let (hash_version, cursor) = read_symbol_u32(data, cursor, data.length())
  if hash_version != 1U && hash_version != 2U {
    raise InvalidPdbStringTable("unsupported /names hash version")
  }
  let (byte_size_raw, cursor) = read_symbol_u32(data, cursor, data.length())
  let byte_size = symbol_uint_to_int(byte_size_raw, "PDB string byte size")
  let strings_end = checked_symbol_add(cursor, byte_size, "PDB strings")
  if strings_end > data.length() {
    raise TruncatedC13(strings_end)
  }
  let strings = DebugStringTable::{
    bytes: data.exact_view(start=cursor, end=strings_end).to_owned(),
  }
  let hash_count_offset = strings_end
  let (hash_count_raw, cursor) = read_symbol_u32(
    data,
    hash_count_offset,
    data.length(),
  )
  let hash_count = symbol_uint_to_int(hash_count_raw, "/names hash count")
  if hash_count > limits.max_names {
    raise C13LimitExceeded("/names hash count limit exceeded")
  }
  let ids_end = checked_symbol_add(
    cursor,
    checked_symbol_mul(hash_count, 4, "/names IDs"),
    "/names IDs",
  )
  if ids_end > data.length() {
    raise TruncatedC13(ids_end)
  }
  let name_ids = []
  let mut cursor = cursor
  for _ in 0..<hash_count {
    let (id, next) = read_symbol_u32(data, cursor, ids_end)
    name_ids.push(id)
    cursor = next
  }
  let (name_count, cursor) = read_symbol_u32(data, cursor, data.length())
  if cursor != data.length() {
    raise InvalidPdbStringTable("/names stream has trailing bytes")
  }
  if name_count.reinterpret_as_int() > limits.max_names {
    raise C13LimitExceeded("/names count limit exceeded")
  }
  PdbStringTable::{ signature, hash_version, strings, name_ids, name_count, }
}

///|
/// Read and parse a named PDB string table.
pub fn MsfFile::pdb_string_table(
  self : MsfFile,
  info : PdbInfo,
  name : String,
  limits : PdbStringTableLimits,
) -> PdbStringTable raise SymbolError {
  let index = match info.named_stream_index(name) {
    Some(value) => value
    None => raise PdbStringTableUnavailable
  }
  let bytes = self.stream(index) catch { _ => raise PdbStringTableUnavailable }
  parse_pdb_string_table(bytes, limits)
}
