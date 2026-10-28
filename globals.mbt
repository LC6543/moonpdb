///|
/// Compute the case-insensitive PDB v1 string hash used by GSI tables.
pub fn hash_string_v1(value : String) -> UInt32 {
  let bytes = @utf8.encode(value)
  let length = bytes.length()
  let mut result = 0U
  let mut cursor = 0
  while cursor + 4 <= length {
    let word = UInt32(
      (bytes.at(cursor + 3).to_int().reinterpret_as_uint() << 24) |
      (bytes.at(cursor + 2).to_int().reinterpret_as_uint() << 16) |
      (bytes.at(cursor + 1).to_int().reinterpret_as_uint() << 8) |
      bytes.at(cursor).to_int().reinterpret_as_uint(),
    )
    result = result ^ word
    cursor = cursor + 4
  }
  if length - cursor >= 2 {
    let word = ((bytes.at(cursor + 1).to_int() << 8) | bytes.at(cursor).to_int()).reinterpret_as_uint()
    result = result ^ UInt32(word)
    cursor = cursor + 2
  }
  if length - cursor == 1 {
    result = result ^ UInt32(bytes.at(cursor).to_int().reinterpret_as_uint())
  }
  result = result | 0x20202020U
  result = result ^ (result >> 11)
  result ^ (result >> 16)
}

///|
/// The Globals/GSI stream and the symbol records it indexes.
pub struct GlobalsStream {
  gsi : GsiTable
  symbols : SymbolTable
  max_results : Int32
}

///|
pub fn GlobalsStream::gsi(self : GlobalsStream) -> GsiTable {
  self.gsi
}

///|
pub fn GlobalsStream::symbols(self : GlobalsStream) -> SymbolTable {
  self.symbols
}

///|
/// Return all symbol records whose exact names match `name`.
pub fn GlobalsStream::find_records_by_name(
  self : GlobalsStream,
  name : String,
) -> Array[SymbolRecord] raise SymbolError {
  if self.gsi.hash_records.length() == 0 {
    return []
  }
  let expanded_bucket = (hash_string_v1(name) % 4097U).reinterpret_as_int()
  let compressed = match self.gsi.bucket_map_index(expanded_bucket) {
    Some(value) => value
    None => raise InvalidGlobalIndex("expanded bucket is outside the GSI map")
  }
  if compressed < 0 {
    return []
  }
  let bucket_index = compressed
  if bucket_index >= self.gsi.buckets.length() {
    raise InvalidGlobalIndex("compressed bucket is outside the bucket table")
  }
  let start_bytes = self.gsi.buckets[bucket_index]
  let end_bytes = if bucket_index + 1 < self.gsi.buckets.length() {
    self.gsi.buckets[bucket_index + 1]
  } else {
    (self.gsi.hash_records.length() * 12).reinterpret_as_uint()
  }
  if start_bytes % 12U != 0U || end_bytes % 12U != 0U {
    raise InvalidGlobalIndex("GSI bucket is not aligned to a hash record")
  }
  let start = symbol_uint_to_int(start_bytes / 12U, "GSI bucket start")
  let end = symbol_uint_to_int(end_bytes / 12U, "GSI bucket end")
  if start < 0 || end < start || end > self.gsi.hash_records.length() {
    raise InvalidGlobalIndex("GSI bucket range is outside the hash records")
  }
  let matches = []
  for index in start..<end {
    let hash_record = self.gsi.hash_records[index]
    let symbol_offset = match hash_record.symbol_offset() {
      Some(value) => value
      None => raise InvalidGlobalIndex("GSI hash record has no symbol offset")
    }
    let record = match
      self.symbols.record_at_offset(
        symbol_uint_to_int(symbol_offset, "GSI symbol offset"),
      ) {
      Some(value) => value
      None => raise InvalidGlobalIndex("GSI references a missing symbol record")
    }
    match symbol_record_name(record) {
      Some(record_name) =>
        if record_name == name {
          if matches.length() >= self.max_results {
            raise PublicsLimitExceeded("global name-match limit exceeded")
          }
          matches.push(record)
        }
      None => ()
    }
  }
  matches
}

///|
/// Read the Globals/GSI stream referenced by the DBI header.
pub fn MsfFile::globals_stream(
  self : MsfFile,
  dbi : DbiFile,
  limits : SymbolLimits,
) -> GlobalsStream raise SymbolError {
  let index = dbi.header().global_symbol_stream_index()
  if index == 0xFFFF {
    raise GlobalsStreamUnavailable(index)
  }
  let bytes = self.stream(index.to_int()) catch {
    _ => raise GlobalsStreamUnavailable(index)
  }
  let symbols = self.symbol_record_stream(dbi, limits)
  parse_globals_stream(bytes, symbols, limits)
}

///|
/// Parse a standalone Globals/GSI stream and its symbol table.
pub fn parse_globals_stream(
  data : Bytes,
  symbols : SymbolTable,
  limits : SymbolLimits,
) -> GlobalsStream raise SymbolError {
  if data.length() > limits.max_stream_bytes {
    raise PublicsLimitExceeded("Globals stream byte limit exceeded")
  }
  let (gsi, end) = parse_gsi_table(data, 0, limits)
  if end != data.length() {
    raise InvalidGlobalIndex("Globals stream has trailing bytes")
  }
  GlobalsStream::{ gsi, symbols, max_results: limits.max_public_symbols, }
}

///|
fn symbol_record_name(record : SymbolRecord) -> String? {
  match record.details() {
    Public(value) => Some(value.name())
    Data(value) => Some(value.name())
    Procedure(value) => Some(value.name())
    Thunk(value) => Some(value.name())
    Block(value) => Some(value.name())
    Label(value) => Some(value.name())
    Constant(value) => Some(value.name())
    Udt(value) => Some(value.name())
    ObjectName(value) => Some(value.name())
    BPRelative(value) => Some(value.name())
    RegRelative(value) => Some(value.name())
    ProcedureReference(value) => Some(value.name())
    FrameProcedure(_) => None
    ScopeEnd => None
    Unknown(_) => None
  }
}
