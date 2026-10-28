///|
const CV_SIGNATURE_C13 : UInt32 = 4U

///|
const S_END : UInt16 = 0x0006

///|
const S_OBJNAME : UInt16 = 0x1101

///|
const S_THUNK32 : UInt16 = 0x1102

///|
const S_BLOCK32 : UInt16 = 0x1103

///|
const S_LABEL32 : UInt16 = 0x1105

///|
const S_CONSTANT : UInt16 = 0x1107

///|
const S_UDT : UInt16 = 0x1108

///|
const S_BPREL32 : UInt16 = 0x110B

///|
const S_LDATA32 : UInt16 = 0x110C

///|
const S_GDATA32 : UInt16 = 0x110D

///|
const S_PUB32 : UInt16 = 0x110E

///|
const S_LPROC32 : UInt16 = 0x110F

///|
const S_GPROC32 : UInt16 = 0x1110

///|
const S_REGREL32 : UInt16 = 0x1111

///|
const S_LTHREAD32 : UInt16 = 0x1112

///|
const S_GTHREAD32 : UInt16 = 0x1113

///|
const S_PROCREF : UInt16 = 0x1125

///|
const S_LPROCREF : UInt16 = 0x1127

///|
const S_FRAMEPROC : UInt16 = 0x1012

///|
const S_INLINESITE_END : UInt16 = 0x114E

///|
const S_PROC_ID_END : UInt16 = 0x114F

///|
/// Resource limits for CodeView symbol and module debug streams.
pub struct SymbolLimits {
  max_stream_bytes : Int32
  max_records : Int32
  max_record_bytes : Int32
  max_global_refs : Int32
  max_hash_records : Int32
  max_public_symbols : Int32
}

///|
pub fn SymbolLimits::default() -> SymbolLimits {
  SymbolLimits::{
    max_stream_bytes: 128 * 1024 * 1024,
    max_records: 2_000_000,
    max_record_bytes: 4 * 1024 * 1024,
    max_global_refs: 1_000_000,
    max_hash_records: 2_000_000,
    max_public_symbols: 1_000_000,
  }
}

///|
pub struct PublicSymbol {
  flags : UInt32
  offset : UInt32
  segment : UInt16
  name : String
}

///|
pub fn PublicSymbol::flags(self : PublicSymbol) -> UInt32 {
  self.flags
}

///|
pub fn PublicSymbol::offset(self : PublicSymbol) -> UInt32 {
  self.offset
}

///|
pub fn PublicSymbol::segment(self : PublicSymbol) -> UInt16 {
  self.segment
}

///|
pub fn PublicSymbol::name(self : PublicSymbol) -> String {
  self.name
}

///|
pub struct DataSymbol {
  type_index : UInt32
  offset : UInt32
  segment : UInt16
  name : String
}

///|
pub fn DataSymbol::type_index(self : DataSymbol) -> UInt32 {
  self.type_index
}

///|
pub fn DataSymbol::offset(self : DataSymbol) -> UInt32 {
  self.offset
}

///|
pub fn DataSymbol::segment(self : DataSymbol) -> UInt16 {
  self.segment
}

///|
pub fn DataSymbol::name(self : DataSymbol) -> String {
  self.name
}

///|
pub struct ProcedureSymbol {
  parent : UInt32
  end : UInt32
  next : UInt32
  code_size : UInt32
  debug_start : UInt32
  debug_end : UInt32
  function_type : UInt32
  code_offset : UInt32
  segment : UInt16
  flags : Int32
  name : String
}

///|
pub fn ProcedureSymbol::parent(self : ProcedureSymbol) -> UInt32 {
  self.parent
}

///|
pub fn ProcedureSymbol::end(self : ProcedureSymbol) -> UInt32 {
  self.end
}

///|
pub fn ProcedureSymbol::next(self : ProcedureSymbol) -> UInt32 {
  self.next
}

///|
pub fn ProcedureSymbol::code_size(self : ProcedureSymbol) -> UInt32 {
  self.code_size
}

///|
pub fn ProcedureSymbol::debug_start(self : ProcedureSymbol) -> UInt32 {
  self.debug_start
}

///|
pub fn ProcedureSymbol::debug_end(self : ProcedureSymbol) -> UInt32 {
  self.debug_end
}

///|
pub fn ProcedureSymbol::function_type(self : ProcedureSymbol) -> UInt32 {
  self.function_type
}

///|
pub fn ProcedureSymbol::code_offset(self : ProcedureSymbol) -> UInt32 {
  self.code_offset
}

///|
pub fn ProcedureSymbol::segment(self : ProcedureSymbol) -> UInt16 {
  self.segment
}

///|
pub fn ProcedureSymbol::flags(self : ProcedureSymbol) -> Int32 {
  self.flags
}

///|
pub fn ProcedureSymbol::name(self : ProcedureSymbol) -> String {
  self.name
}

///|
pub struct ThunkSymbol {
  parent : UInt32
  end : UInt32
  next : UInt32
  offset : UInt32
  segment : UInt16
  length : UInt16
  ordinal : Int32
  name : String
  variant_bytes : Bytes
}

///|
pub fn ThunkSymbol::parent(self : ThunkSymbol) -> UInt32 {
  self.parent
}

///|
pub fn ThunkSymbol::end(self : ThunkSymbol) -> UInt32 {
  self.end
}

///|
pub fn ThunkSymbol::next(self : ThunkSymbol) -> UInt32 {
  self.next
}

///|
pub fn ThunkSymbol::offset(self : ThunkSymbol) -> UInt32 {
  self.offset
}

///|
pub fn ThunkSymbol::segment(self : ThunkSymbol) -> UInt16 {
  self.segment
}

///|
pub fn ThunkSymbol::length(self : ThunkSymbol) -> UInt16 {
  self.length
}

///|
pub fn ThunkSymbol::ordinal(self : ThunkSymbol) -> Int32 {
  self.ordinal
}

///|
pub fn ThunkSymbol::name(self : ThunkSymbol) -> String {
  self.name
}

///|
pub fn ThunkSymbol::variant_bytes(self : ThunkSymbol) -> Bytes {
  self.variant_bytes
}

///|
pub struct BlockSymbol {
  parent : UInt32
  end : UInt32
  code_size : UInt32
  code_offset : UInt32
  segment : UInt16
  name : String
}

///|
pub fn BlockSymbol::parent(self : BlockSymbol) -> UInt32 {
  self.parent
}

///|
pub fn BlockSymbol::end(self : BlockSymbol) -> UInt32 {
  self.end
}

///|
pub fn BlockSymbol::code_size(self : BlockSymbol) -> UInt32 {
  self.code_size
}

///|
pub fn BlockSymbol::code_offset(self : BlockSymbol) -> UInt32 {
  self.code_offset
}

///|
pub fn BlockSymbol::segment(self : BlockSymbol) -> UInt16 {
  self.segment
}

///|
pub fn BlockSymbol::name(self : BlockSymbol) -> String {
  self.name
}

///|
pub struct LabelSymbol {
  code_offset : UInt32
  segment : UInt16
  flags : Int32
  name : String
}

///|
pub fn LabelSymbol::code_offset(self : LabelSymbol) -> UInt32 {
  self.code_offset
}

///|
pub fn LabelSymbol::segment(self : LabelSymbol) -> UInt16 {
  self.segment
}

///|
pub fn LabelSymbol::flags(self : LabelSymbol) -> Int32 {
  self.flags
}

///|
pub fn LabelSymbol::name(self : LabelSymbol) -> String {
  self.name
}

///|
pub struct ConstantSymbol {
  type_index : UInt32
  value : NumericValue
  name : String
}

///|
pub fn ConstantSymbol::type_index(self : ConstantSymbol) -> UInt32 {
  self.type_index
}

///|
pub fn ConstantSymbol::value(self : ConstantSymbol) -> NumericValue {
  self.value
}

///|
pub fn ConstantSymbol::name(self : ConstantSymbol) -> String {
  self.name
}

///|
pub struct UdtSymbol {
  type_index : UInt32
  name : String
}

///|
pub fn UdtSymbol::type_index(self : UdtSymbol) -> UInt32 {
  self.type_index
}

///|
pub fn UdtSymbol::name(self : UdtSymbol) -> String {
  self.name
}

///|
pub struct ObjectNameSymbol {
  signature : UInt32
  name : String
}

///|
pub fn ObjectNameSymbol::signature(self : ObjectNameSymbol) -> UInt32 {
  self.signature
}

///|
pub fn ObjectNameSymbol::name(self : ObjectNameSymbol) -> String {
  self.name
}

///|
pub struct BPRelativeSymbol {
  offset : Int32
  type_index : UInt32
  name : String
}

///|
pub fn BPRelativeSymbol::offset(self : BPRelativeSymbol) -> Int32 {
  self.offset
}

///|
pub fn BPRelativeSymbol::type_index(self : BPRelativeSymbol) -> UInt32 {
  self.type_index
}

///|
pub fn BPRelativeSymbol::name(self : BPRelativeSymbol) -> String {
  self.name
}

///|
pub struct RegRelativeSymbol {
  offset : UInt32
  type_index : UInt32
  register : UInt16
  name : String
}

///|
pub fn RegRelativeSymbol::offset(self : RegRelativeSymbol) -> UInt32 {
  self.offset
}

///|
pub fn RegRelativeSymbol::type_index(self : RegRelativeSymbol) -> UInt32 {
  self.type_index
}

///|
pub fn RegRelativeSymbol::register(self : RegRelativeSymbol) -> UInt16 {
  self.register
}

///|
pub fn RegRelativeSymbol::name(self : RegRelativeSymbol) -> String {
  self.name
}

///|
pub struct ProcedureReferenceSymbol {
  name_hash : UInt32
  symbol_offset : UInt32
  module_index : UInt16
  name : String
}

///|
pub fn ProcedureReferenceSymbol::name_hash(
  self : ProcedureReferenceSymbol,
) -> UInt32 {
  self.name_hash
}

///|
pub fn ProcedureReferenceSymbol::symbol_offset(
  self : ProcedureReferenceSymbol,
) -> UInt32 {
  self.symbol_offset
}

///|
pub fn ProcedureReferenceSymbol::module_index(
  self : ProcedureReferenceSymbol,
) -> UInt16 {
  self.module_index
}

///|
pub fn ProcedureReferenceSymbol::name(
  self : ProcedureReferenceSymbol,
) -> String {
  self.name
}

///|
pub struct FrameProcedureSymbol {
  total_frame_bytes : UInt32
  padding_frame_bytes : UInt32
  offset_to_padding : UInt32
  callee_saved_bytes : UInt32
  exception_handler_offset : UInt32
  exception_handler_section : UInt16
  flags : UInt32
}

///|
pub fn FrameProcedureSymbol::total_frame_bytes(
  self : FrameProcedureSymbol,
) -> UInt32 {
  self.total_frame_bytes
}

///|
pub fn FrameProcedureSymbol::padding_frame_bytes(
  self : FrameProcedureSymbol,
) -> UInt32 {
  self.padding_frame_bytes
}

///|
pub fn FrameProcedureSymbol::offset_to_padding(
  self : FrameProcedureSymbol,
) -> UInt32 {
  self.offset_to_padding
}

///|
pub fn FrameProcedureSymbol::callee_saved_bytes(
  self : FrameProcedureSymbol,
) -> UInt32 {
  self.callee_saved_bytes
}

///|
pub fn FrameProcedureSymbol::exception_handler_offset(
  self : FrameProcedureSymbol,
) -> UInt32 {
  self.exception_handler_offset
}

///|
pub fn FrameProcedureSymbol::exception_handler_section(
  self : FrameProcedureSymbol,
) -> UInt16 {
  self.exception_handler_section
}

///|
pub fn FrameProcedureSymbol::flags(self : FrameProcedureSymbol) -> UInt32 {
  self.flags
}

///|
pub struct UnknownSymbol {
  kind : UInt16
  payload : Bytes
}

///|
pub fn UnknownSymbol::kind(self : UnknownSymbol) -> UInt16 {
  self.kind
}

///|
pub fn UnknownSymbol::payload(self : UnknownSymbol) -> Bytes {
  self.payload
}

///|
/// The decoded payload of a known CodeView symbol record.
pub enum SymbolDetails {
  Public(PublicSymbol)
  Data(DataSymbol)
  Procedure(ProcedureSymbol)
  Thunk(ThunkSymbol)
  Block(BlockSymbol)
  Label(LabelSymbol)
  Constant(ConstantSymbol)
  Udt(UdtSymbol)
  ObjectName(ObjectNameSymbol)
  BPRelative(BPRelativeSymbol)
  RegRelative(RegRelativeSymbol)
  ProcedureReference(ProcedureReferenceSymbol)
  FrameProcedure(FrameProcedureSymbol)
  ScopeEnd
  Unknown(UnknownSymbol)
}

///|
pub struct SymbolRecord {
  offset : Int32
  kind : UInt16
  details : SymbolDetails
}

///|
pub fn SymbolRecord::offset(self : SymbolRecord) -> Int32 {
  self.offset
}

///|
pub fn SymbolRecord::kind(self : SymbolRecord) -> UInt16 {
  self.kind
}

///|
pub fn SymbolRecord::details(self : SymbolRecord) -> SymbolDetails {
  self.details
}

///|
pub struct SymbolTable {
  data : Bytes
  records : Array[SymbolRecord]
}

///|
pub fn SymbolTable::data(self : SymbolTable) -> Bytes {
  self.data
}

///|
pub fn SymbolTable::record_count(self : SymbolTable) -> Int32 {
  self.records.length()
}

///|
pub fn SymbolTable::record_at(
  self : SymbolTable,
  index : Int32,
) -> SymbolRecord? {
  if index < 0 || index >= self.records.length() {
    None
  } else {
    Some(self.records[index])
  }
}

///|
pub fn SymbolTable::records(self : SymbolTable) -> Array[SymbolRecord] {
  self.records.copy()
}

///|
pub fn SymbolTable::record_at_offset(
  self : SymbolTable,
  offset : Int32,
) -> SymbolRecord? {
  let mut low = 0
  let mut high = self.records.length()
  while low < high {
    let middle = low + (high - low) / 2
    let record = self.records[middle]
    if record.offset < offset {
      low = middle + 1
    } else {
      high = middle
    }
  }
  if low < self.records.length() && self.records[low].offset == offset {
    Some(self.records[low])
  } else {
    None
  }
}

///|
/// One module debug stream split into symbols, line data, and global refs.
pub struct ModuleDebugStream {
  signature : UInt32
  symbols : SymbolTable
  c11_lines : Bytes
  c13_lines : Bytes
  global_refs : Array[UInt32]
}

///|
pub fn ModuleDebugStream::signature(self : ModuleDebugStream) -> UInt32 {
  self.signature
}

///|
pub fn ModuleDebugStream::symbols(self : ModuleDebugStream) -> SymbolTable {
  self.symbols
}

///|
pub fn ModuleDebugStream::c11_lines(self : ModuleDebugStream) -> Bytes {
  self.c11_lines
}

///|
pub fn ModuleDebugStream::c13_lines(self : ModuleDebugStream) -> Bytes {
  self.c13_lines
}

///|
pub fn ModuleDebugStream::global_refs(
  self : ModuleDebugStream,
) -> Array[UInt32] {
  self.global_refs.copy()
}

///|
/// Parse a standalone CodeView symbol stream without a module signature.
pub fn parse_symbols(
  data : Bytes,
  limits : SymbolLimits,
) -> SymbolTable raise SymbolError {
  parse_symbols_from(data, 0, data.length(), limits)
}

///|
/// Parse the symbol-record stream referenced by the DBI header.
pub fn MsfFile::symbol_record_stream(
  self : MsfFile,
  dbi : DbiFile,
  limits : SymbolLimits,
) -> SymbolTable raise SymbolError {
  let index = dbi.header().symbol_record_stream_index()
  if index == 0xFFFF {
    raise SymbolStreamUnavailable(index)
  }
  let bytes = self.stream(index.to_int()) catch {
    _ => raise SymbolStreamUnavailable(index)
  }
  parse_symbols(bytes, limits)
}

///|
/// Read and parse one module's debug stream.
pub fn MsfFile::module_debug_stream(
  self : MsfFile,
  dbi : DbiFile,
  module_index : Int32,
  limits : SymbolLimits,
) -> ModuleDebugStream raise SymbolError {
  let item = match dbi.module_at(module_index) {
    Some(value) => value
    None => raise InvalidModuleStream("module index is outside the DBI table")
  }
  let index = item.module_stream_index()
  if index == 0xFFFF {
    raise ModuleStreamUnavailable(index)
  }
  let bytes = self.stream(index.to_int()) catch {
    _ => raise ModuleStreamUnavailable(index)
  }
  parse_module_debug_stream(
    bytes,
    item.symbol_debug_bytes(),
    item.c11_line_bytes(),
    item.c13_line_bytes(),
    limits,
  )
}

///|
/// Split and parse a module debug stream using sizes from its DBI descriptor.
pub fn parse_module_debug_stream(
  data : Bytes,
  symbol_bytes_raw : UInt32,
  c11_bytes_raw : UInt32,
  c13_bytes_raw : UInt32,
  limits : SymbolLimits,
) -> ModuleDebugStream raise SymbolError {
  if data.length() > limits.max_stream_bytes {
    raise SymbolLimitExceeded("module debug stream byte limit exceeded")
  }
  let symbol_bytes = symbol_uint_to_int(symbol_bytes_raw, "symbol bytes")
  let c11_bytes = symbol_uint_to_int(c11_bytes_raw, "C11 line bytes")
  let c13_bytes = symbol_uint_to_int(c13_bytes_raw, "C13 line bytes")
  if c11_bytes > 0 && c13_bytes > 0 {
    raise InvalidModuleStream("module has both C11 and C13 line data")
  }
  if symbol_bytes < 4 {
    raise InvalidModuleStream(
      "module symbol size is smaller than its signature",
    )
  }
  let symbol_end = symbol_bytes
  if symbol_end > data.length() {
    raise TruncatedSymbol(symbol_end)
  }
  let (signature, _) = read_symbol_u32(data, 0, 4)
  if signature != CV_SIGNATURE_C13 {
    raise UnsupportedModuleSignature(signature)
  }
  let symbols = parse_symbols_from(data, 4, symbol_end, limits)
  let c11_start = symbol_end
  let c11_end = checked_symbol_add(c11_start, c11_bytes, "C11 line data")
  let c13_end = checked_symbol_add(c11_end, c13_bytes, "C13 line data")
  if c13_end > data.length() {
    raise TruncatedSymbol(c13_end)
  }
  let c11_lines = data.exact_view(start=c11_start, end=c11_end).to_owned()
  let c13_lines = data.exact_view(start=c11_end, end=c13_end).to_owned()
  let global_refs = if c13_end == data.length() {
    []
  } else {
    let (count_raw, cursor) = read_symbol_u32(data, c13_end, data.length())
    let count = symbol_uint_to_int(count_raw, "global reference count")
    if count > limits.max_global_refs {
      raise SymbolLimitExceeded("global reference count limit exceeded")
    }
    let refs_end = checked_symbol_add(
      cursor,
      checked_symbol_mul(count, 4, "global references"),
      "global references",
    )
    if refs_end != data.length() {
      raise InvalidModuleStream(
        "global reference byte count does not match the module stream",
      )
    }
    let refs = []
    let mut position = cursor
    for _ in 0..<count {
      let (value, next) = read_symbol_u32(data, position, refs_end)
      refs.push(value)
      position = next
    }
    refs
  }
  ModuleDebugStream::{ signature, symbols, c11_lines, c13_lines, global_refs, }
}

///|
fn parse_symbols_from(
  data : Bytes,
  start : Int32,
  end : Int32,
  limits : SymbolLimits,
) -> SymbolTable raise SymbolError {
  if data.length() > limits.max_stream_bytes {
    raise SymbolLimitExceeded("symbol stream byte limit exceeded")
  }
  if start < 0 || end < start || end > data.length() || start % 4 != 0 {
    raise InvalidSymbolRecord("invalid symbol-stream bounds or alignment")
  }
  let records = []
  let mut cursor = start
  while cursor < end {
    if records.length() >= limits.max_records {
      raise SymbolLimitExceeded("symbol record count limit exceeded")
    }
    let record_start = cursor
    let (length_raw, after_length) = read_symbol_u16(data, cursor, end)
    let length = length_raw.to_int()
    if length < 2 {
      raise InvalidSymbolRecord("symbol record is shorter than its kind field")
    }
    if length > limits.max_record_bytes {
      raise SymbolLimitExceeded("symbol record byte limit exceeded")
    }
    let record_end = checked_symbol_add(after_length, length, "symbol record")
    if record_end > end {
      raise TruncatedSymbol(record_end)
    }
    if (record_end - record_start) % 4 != 0 {
      raise InvalidSymbolRecord("symbol record is not 4-byte aligned")
    }
    let (kind, payload_start) = read_symbol_u16(data, after_length, record_end)
    let payload = data
      .exact_view(start=payload_start, end=record_end)
      .to_owned()
    records.push(SymbolRecord::{
      offset: record_start,
      kind,
      details: decode_symbol(kind, payload),
    })
    cursor = record_end
  }
  if cursor != end {
    raise InvalidSymbolRecord("symbol stream has trailing bytes")
  }
  SymbolTable::{ data, records, }
}

///|
fn decode_symbol(
  kind : UInt16,
  payload : Bytes,
) -> SymbolDetails raise SymbolError {
  match kind {
    S_PUB32 => decode_public_symbol(payload)
    S_LDATA32 | S_GDATA32 | S_LTHREAD32 | S_GTHREAD32 =>
      decode_data_symbol(payload)
    S_LPROC32 | S_GPROC32 => decode_procedure_symbol(payload)
    S_THUNK32 => decode_thunk_symbol(payload)
    S_BLOCK32 => decode_block_symbol(payload)
    S_LABEL32 => decode_label_symbol(payload)
    S_CONSTANT => decode_constant_symbol(payload)
    S_UDT => decode_udt_symbol(payload)
    S_OBJNAME => decode_object_name_symbol(payload)
    S_BPREL32 => decode_bp_relative_symbol(payload)
    S_REGREL32 => decode_reg_relative_symbol(payload)
    S_PROCREF | S_LPROCREF => decode_procedure_reference_symbol(payload)
    S_FRAMEPROC => decode_frame_procedure_symbol(payload)
    S_END | S_INLINESITE_END | S_PROC_ID_END => {
      require_symbol_padding(payload, 0, "scope-end record")
      ScopeEnd
    }
    _ => Unknown(UnknownSymbol::{ kind, payload, })
  }
}

///|
fn decode_public_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 11, "S_PUB32")
  let (flags, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (offset, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (segment, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_PUB32")
  Public(PublicSymbol::{ flags, offset, segment, name, })
}

///|
fn decode_data_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 11, "S_DATA")
  let (type_index, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (offset, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (segment, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_DATA")
  Data(DataSymbol::{ type_index, offset, segment, name, })
}

///|
fn decode_procedure_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 36, "S_PROC32")
  let (parent, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (end, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (next, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (code_size, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (debug_start, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (debug_end, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (function_type, cursor) = read_symbol_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (code_offset, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (segment, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (flags, cursor) = read_symbol_u8(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_PROC32")
  Procedure(ProcedureSymbol::{
    parent,
    end,
    next,
    code_size,
    debug_start,
    debug_end,
    function_type,
    code_offset,
    segment,
    flags,
    name,
  })
}

///|
fn decode_thunk_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 22, "S_THUNK32")
  let (parent, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (end, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (next, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (offset, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (segment, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (length, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (ordinal, cursor) = read_symbol_u8(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  let variant_bytes = payload
    .exact_view(start=cursor, end=payload.length())
    .to_owned()
  Thunk(ThunkSymbol::{
    parent,
    end,
    next,
    offset,
    segment,
    length,
    ordinal,
    name,
    variant_bytes,
  })
}

///|
fn decode_block_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 19, "S_BLOCK32")
  let (parent, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (end, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (code_size, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (code_offset, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (segment, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_BLOCK32")
  Block(BlockSymbol::{ parent, end, code_size, code_offset, segment, name, })
}

///|
fn decode_label_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 8, "S_LABEL32")
  let (code_offset, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (segment, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (flags, cursor) = read_symbol_u8(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_LABEL32")
  Label(LabelSymbol::{ code_offset, segment, flags, name, })
}

///|
fn decode_constant_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 7, "S_CONSTANT")
  let (type_index, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (value, cursor) = read_numeric_value(payload, cursor, payload.length()) catch {
    _ => raise InvalidSymbolRecord("invalid constant numeric leaf")
  }
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_CONSTANT")
  Constant(ConstantSymbol::{ type_index, value, name, })
}

///|
fn decode_udt_symbol(payload : Bytes) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 5, "S_UDT")
  let (type_index, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_UDT")
  Udt(UdtSymbol::{ type_index, name, })
}

///|
fn decode_object_name_symbol(
  payload : Bytes,
) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 5, "S_OBJNAME")
  let (signature, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_OBJNAME")
  ObjectName(ObjectNameSymbol::{ signature, name, })
}

///|
fn decode_bp_relative_symbol(
  payload : Bytes,
) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 10, "S_BPREL32")
  let (offset, cursor) = read_symbol_i32(payload, 0, payload.length())
  let (type_index, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_BPREL32")
  BPRelative(BPRelativeSymbol::{ offset, type_index, name, })
}

///|
fn decode_reg_relative_symbol(
  payload : Bytes,
) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 12, "S_REGREL32")
  let (offset, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (type_index, cursor) = read_symbol_u32(payload, cursor, payload.length())
  let (register, cursor) = read_symbol_u16(payload, cursor, payload.length())
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_REGREL32")
  RegRelative(RegRelativeSymbol::{ offset, type_index, register, name, })
}

///|
fn decode_procedure_reference_symbol(
  payload : Bytes,
) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 12, "S_PROCREF")
  let (name_hash, cursor) = read_symbol_u32(payload, 0, payload.length())
  let (symbol_offset, cursor) = read_symbol_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (module_index, cursor) = read_symbol_u16(
    payload,
    cursor,
    payload.length(),
  )
  let (name, cursor) = read_symbol_string(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_PROCREF")
  ProcedureReference(ProcedureReferenceSymbol::{
    name_hash,
    symbol_offset,
    module_index,
    name,
  })
}

///|
fn decode_frame_procedure_symbol(
  payload : Bytes,
) -> SymbolDetails raise SymbolError {
  require_symbol_bytes(payload, 26, "S_FRAMEPROC")
  let (total_frame_bytes, cursor) = read_symbol_u32(
    payload,
    0,
    payload.length(),
  )
  let (padding_frame_bytes, cursor) = read_symbol_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (offset_to_padding, cursor) = read_symbol_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (callee_saved_bytes, cursor) = read_symbol_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (exception_handler_offset, cursor) = read_symbol_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (exception_handler_section, cursor) = read_symbol_u16(
    payload,
    cursor,
    payload.length(),
  )
  let (flags, cursor) = read_symbol_u32(payload, cursor, payload.length())
  require_symbol_padding(payload, cursor, "S_FRAMEPROC")
  FrameProcedure(FrameProcedureSymbol::{
    total_frame_bytes,
    padding_frame_bytes,
    offset_to_padding,
    callee_saved_bytes,
    exception_handler_offset,
    exception_handler_section,
    flags,
  })
}

///|
fn read_symbol_string(
  data : Bytes,
  start : Int32,
  end : Int32,
) -> (String, Int32) raise SymbolError {
  if start < 0 || start >= end {
    raise TruncatedSymbol(start)
  }
  let mut cursor = start
  while cursor < end {
    if data.at(cursor) == 0 {
      let length = cursor - start
      if length > 1024 * 1024 {
        raise SymbolLimitExceeded("symbol name length limit exceeded")
      }
      let name = @utf8.decode_lossy(data.exact_view(start~, end=cursor))
      return (name, cursor + 1)
    }
    cursor = cursor + 1
  }
  raise InvalidSymbolRecord("symbol name is not NUL-terminated")
}

///|
fn require_symbol_padding(
  payload : Bytes,
  start : Int32,
  _field : String,
) -> Unit raise SymbolError {
  if start < 0 || start > payload.length() || payload.length() - start > 3 {
    raise InvalidSymbolRecord("symbol record has an invalid padding size")
  }
  for index in start..<payload.length() {
    if payload.at(index) != 0 {
      raise InvalidSymbolRecord("symbol record padding is not zero")
    }
  }
}

///|
fn require_symbol_bytes(
  payload : Bytes,
  minimum : Int32,
  _field : String,
) -> Unit raise SymbolError {
  if payload.length() < minimum {
    raise TruncatedSymbol(payload.length())
  }
}

///|
fn read_symbol_u8(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (Int32, Int32) raise SymbolError {
  if pos < 0 || pos >= end || pos >= data.length() {
    raise TruncatedSymbol(pos)
  }
  (data.at(pos).to_int(), pos + 1)
}

///|
fn read_symbol_u16(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt16, Int32) raise SymbolError {
  if pos < 0 || pos + 2 > end || pos + 2 > data.length() {
    raise TruncatedSymbol(pos)
  }
  (
    ((data.at(pos + 1).to_int() << 8) | data.at(pos).to_int()).to_uint16(),
    pos + 2,
  )
}

///|
fn read_symbol_u32(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt32, Int32) raise SymbolError {
  if pos < 0 || pos + 4 > end || pos + 4 > data.length() {
    raise TruncatedSymbol(pos)
  }
  (
    UInt32(
      (data.at(pos + 3).to_int().reinterpret_as_uint() << 24) |
      (data.at(pos + 2).to_int().reinterpret_as_uint() << 16) |
      (data.at(pos + 1).to_int().reinterpret_as_uint() << 8) |
      data.at(pos).to_int().reinterpret_as_uint(),
    ),
    pos + 4,
  )
}

///|
fn read_symbol_i32(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (Int32, Int32) raise SymbolError {
  let (value, next) = read_symbol_u32(data, pos, end)
  (value.reinterpret_as_int(), next)
}

///|
fn symbol_uint_to_int(
  value : UInt32,
  field : String,
) -> Int32 raise SymbolError {
  if value > 0x7FFFFFFFU {
    raise InvalidSymbolRecord("\{field} exceeds Int range")
  }
  value.reinterpret_as_int()
}

///|
fn checked_symbol_add(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise SymbolError {
  if left < 0 || right < 0 || left > 0x7FFFFFFF - right {
    raise InvalidSymbolRecord("\{field} overflows Int range")
  }
  left + right
}

///|
fn checked_symbol_mul(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise SymbolError {
  if left < 0 || right < 0 || (left != 0 && right > 0x7FFFFFFF / left) {
    raise InvalidSymbolRecord("\{field} overflows Int range")
  }
  left * right
}
