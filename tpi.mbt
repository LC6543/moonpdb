///|
const TPI_HEADER_SIZE : Int32 = 56

///|
const TPI_TYPE_INDEX_BEGIN : UInt32 = 0x1000U

///|
const LF_MODIFIER : UInt16 = 0x1001

///|
const LF_POINTER : UInt16 = 0x1002

///|
const LF_PROCEDURE : UInt16 = 0x1008

///|
const LF_MFUNCTION : UInt16 = 0x1009

///|
const LF_LABEL : UInt16 = 0x000E

///|
const LF_ARGLIST : UInt16 = 0x1201

///|
const LF_FIELDLIST : UInt16 = 0x1203

///|
const LF_BITFIELD : UInt16 = 0x1205

///|
const LF_ARRAY : UInt16 = 0x1503

///|
const LF_CLASS : UInt16 = 0x1504

///|
const LF_STRUCTURE : UInt16 = 0x1505

///|
const LF_UNION : UInt16 = 0x1506

///|
const LF_ENUM : UInt16 = 0x1507

///|
const LF_ALIAS : UInt16 = 0x150A

///|
const LF_TYPESERVER2 : UInt16 = 0x1515

///|
const LF_INTERFACE : UInt16 = 0x1519

///|
const LF_FUNC_ID : UInt16 = 0x1601

///|
const LF_MFUNC_ID : UInt16 = 0x1602

///|
const LF_BUILDINFO : UInt16 = 0x1603

///|
const LF_SUBSTR_LIST : UInt16 = 0x1604

///|
const LF_STRING_ID : UInt16 = 0x1605

///|
const LF_UDT_SRC_LINE : UInt16 = 0x1606

///|
const LF_UDT_MOD_SRC_LINE : UInt16 = 0x1607

///|
/// The direction represented by a simple CodeView type-index mode.
pub enum SimpleTypeMode {
  Direct
  NearPointer
  FarPointer
  HugePointer
  Pointer32
  FarPointer32
  Pointer64
  Reserved
}

///|
/// The logical category of a simple CodeView type.
pub enum SimpleTypeKind {
  NoType
  Void
  SignedInteger
  UnsignedInteger
  Boolean
  Real
  Character
  WideCharacter
  Bit
  Unknown
}

///|
/// A decoded simple type index below 0x1000.
pub struct SimpleType {
  raw : UInt32
  base : Int32
  mode : SimpleTypeMode
  kind : SimpleTypeKind
  name : String
  byte_size : Int32
}

///|
pub fn SimpleType::raw(self : SimpleType) -> UInt32 {
  self.raw
}

///|
pub fn SimpleType::base(self : SimpleType) -> Int32 {
  self.base
}

///|
pub fn SimpleType::mode(self : SimpleType) -> SimpleTypeMode {
  self.mode
}

///|
pub fn SimpleType::kind(self : SimpleType) -> SimpleTypeKind {
  self.kind
}

///|
pub fn SimpleType::name(self : SimpleType) -> String {
  self.name
}

///|
pub fn SimpleType::byte_size(self : SimpleType) -> Int32 {
  self.byte_size
}

///|
pub fn SimpleType::is_pointer(self : SimpleType) -> Bool {
  match self.mode {
    Direct => false
    _ => true
  }
}

///|
/// Resource limits for a TPI or IPI type stream.
pub struct TpiLimits {
  max_stream_bytes : Int32
  max_records : Int32
  max_record_bytes : Int32
  max_type_refs : Int32
}

///|
pub fn TpiLimits::default() -> TpiLimits {
  TpiLimits::{
    max_stream_bytes: 64 * 1024 * 1024,
    max_records: 1_000_000,
    max_record_bytes: 4 * 1024 * 1024,
    max_type_refs: 1_000_000,
  }
}

///|
/// The fixed 56-byte header shared by TPI and IPI streams.
pub struct TpiHeader {
  version : UInt32
  header_size : Int32
  type_index_begin : UInt32
  type_index_end : UInt32
  type_record_bytes : Int32
  hash_stream_index : Int32
  hash_aux_stream_index : Int32
  hash_key_size : UInt32
  hash_bucket_count : UInt32
  hash_value_offset : Int32
  hash_value_bytes : Int32
  index_offset_offset : Int32
  index_offset_bytes : Int32
  hash_adjust_offset : Int32
  hash_adjust_bytes : Int32
}

///|
pub fn TpiHeader::version(self : TpiHeader) -> UInt32 {
  self.version
}

///|
pub fn TpiHeader::header_size(self : TpiHeader) -> Int32 {
  self.header_size
}

///|
pub fn TpiHeader::type_index_begin(self : TpiHeader) -> UInt32 {
  self.type_index_begin
}

///|
pub fn TpiHeader::type_index_end(self : TpiHeader) -> UInt32 {
  self.type_index_end
}

///|
pub fn TpiHeader::type_record_bytes(self : TpiHeader) -> Int32 {
  self.type_record_bytes
}

///|
pub fn TpiHeader::type_record_count(self : TpiHeader) -> UInt32 {
  self.type_index_end - self.type_index_begin
}

///|
pub fn TpiHeader::hash_stream_index(self : TpiHeader) -> Int32 {
  self.hash_stream_index
}

///|
pub fn TpiHeader::hash_aux_stream_index(self : TpiHeader) -> Int32 {
  self.hash_aux_stream_index
}

///|
pub fn TpiHeader::hash_key_size(self : TpiHeader) -> UInt32 {
  self.hash_key_size
}

///|
pub fn TpiHeader::hash_bucket_count(self : TpiHeader) -> UInt32 {
  self.hash_bucket_count
}

///|
pub fn TpiHeader::hash_value_offset(self : TpiHeader) -> Int32 {
  self.hash_value_offset
}

///|
pub fn TpiHeader::hash_value_bytes(self : TpiHeader) -> Int32 {
  self.hash_value_bytes
}

///|
pub fn TpiHeader::index_offset_offset(self : TpiHeader) -> Int32 {
  self.index_offset_offset
}

///|
pub fn TpiHeader::index_offset_bytes(self : TpiHeader) -> Int32 {
  self.index_offset_bytes
}

///|
pub fn TpiHeader::hash_adjust_offset(self : TpiHeader) -> Int32 {
  self.hash_adjust_offset
}

///|
pub fn TpiHeader::hash_adjust_bytes(self : TpiHeader) -> Int32 {
  self.hash_adjust_bytes
}

///|
/// A CodeView numeric leaf used for sizes, offsets, and enumerator values.
pub enum NumericValue {
  Signed(Int64)
  Unsigned(UInt64)
  Opaque(UInt16, Bytes)
}

///|
pub fn NumericValue::as_signed(self : NumericValue) -> Int64? {
  match self {
    Signed(value) => Some(value)
    Unsigned(value) =>
      if value <= 0x7FFFFFFFFFFFFFFFUL {
        Some(value.reinterpret_as_int64())
      } else {
        None
      }
    Opaque(_, _) => None
  }
}

///|
pub fn NumericValue::as_unsigned(self : NumericValue) -> UInt64? {
  match self {
    Signed(value) =>
      if value >= 0L {
        Some(value.reinterpret_as_uint64())
      } else {
        None
      }
    Unsigned(value) => Some(value)
    Opaque(_, _) => None
  }
}

///|
pub struct ModifierType {
  modified_type : UInt32
  modifiers : UInt16
}

///|
pub fn ModifierType::modified_type(self : ModifierType) -> UInt32 {
  self.modified_type
}

///|
pub fn ModifierType::modifiers(self : ModifierType) -> UInt16 {
  self.modifiers
}

///|
pub fn ModifierType::is_const(self : ModifierType) -> Bool {
  (self.modifiers & 0x0001) != 0
}

///|
pub fn ModifierType::is_volatile(self : ModifierType) -> Bool {
  (self.modifiers & 0x0002) != 0
}

///|
pub fn ModifierType::is_unaligned(self : ModifierType) -> Bool {
  (self.modifiers & 0x0004) != 0
}

///|
pub struct PointerType {
  referent_type : UInt32
  attributes : UInt32
  containing_type : UInt32?
  member_representation : UInt16?
}

///|
pub fn PointerType::referent_type(self : PointerType) -> UInt32 {
  self.referent_type
}

///|
pub fn PointerType::attributes(self : PointerType) -> UInt32 {
  self.attributes
}

///|
pub fn PointerType::kind(self : PointerType) -> UInt32 {
  self.attributes & 0x1FU
}

///|
pub fn PointerType::mode(self : PointerType) -> UInt32 {
  (self.attributes >> 5) & 0x07U
}

///|
pub fn PointerType::byte_size(self : PointerType) -> Int32 {
  ((self.attributes >> 13) & 0xFFU).reinterpret_as_int()
}

///|
pub fn PointerType::containing_type(self : PointerType) -> UInt32? {
  self.containing_type
}

///|
pub fn PointerType::member_representation(self : PointerType) -> UInt16? {
  self.member_representation
}

///|
pub fn PointerType::is_const(self : PointerType) -> Bool {
  (self.attributes & 0x00000400U) != 0U
}

///|
pub fn PointerType::is_volatile(self : PointerType) -> Bool {
  (self.attributes & 0x00000200U) != 0U
}

///|
pub fn PointerType::is_unaligned(self : PointerType) -> Bool {
  (self.attributes & 0x00000800U) != 0U
}

///|
pub fn PointerType::is_restrict(self : PointerType) -> Bool {
  (self.attributes & 0x00001000U) != 0U
}

///|
pub struct ProcedureType {
  return_type : UInt32
  calling_convention : Int32
  function_options : Int32
  parameter_count : UInt16
  argument_list : UInt32
}

///|
pub fn ProcedureType::return_type(self : ProcedureType) -> UInt32 {
  self.return_type
}

///|
pub fn ProcedureType::calling_convention(self : ProcedureType) -> Int32 {
  self.calling_convention
}

///|
pub fn ProcedureType::function_options(self : ProcedureType) -> Int32 {
  self.function_options
}

///|
pub fn ProcedureType::parameter_count(self : ProcedureType) -> UInt16 {
  self.parameter_count
}

///|
pub fn ProcedureType::argument_list(self : ProcedureType) -> UInt32 {
  self.argument_list
}

///|
pub struct MemberFunctionType {
  return_type : UInt32
  class_type : UInt32
  this_type : UInt32
  calling_convention : Int32
  function_options : Int32
  parameter_count : UInt16
  argument_list : UInt32
  this_adjustment : Int32
}

///|
pub fn MemberFunctionType::return_type(self : MemberFunctionType) -> UInt32 {
  self.return_type
}

///|
pub fn MemberFunctionType::class_type(self : MemberFunctionType) -> UInt32 {
  self.class_type
}

///|
pub fn MemberFunctionType::this_type(self : MemberFunctionType) -> UInt32 {
  self.this_type
}

///|
pub fn MemberFunctionType::calling_convention(
  self : MemberFunctionType,
) -> Int32 {
  self.calling_convention
}

///|
pub fn MemberFunctionType::function_options(self : MemberFunctionType) -> Int32 {
  self.function_options
}

///|
pub fn MemberFunctionType::parameter_count(self : MemberFunctionType) -> UInt16 {
  self.parameter_count
}

///|
pub fn MemberFunctionType::argument_list(self : MemberFunctionType) -> UInt32 {
  self.argument_list
}

///|
pub fn MemberFunctionType::this_adjustment(self : MemberFunctionType) -> Int32 {
  self.this_adjustment
}

///|
pub struct ArgListType {
  type_indices : Array[UInt32]
}

///|
pub fn ArgListType::count(self : ArgListType) -> Int32 {
  self.type_indices.length()
}

///|
pub fn ArgListType::type_indices(self : ArgListType) -> Array[UInt32] {
  self.type_indices.copy()
}

///|
pub fn ArgListType::type_index(self : ArgListType, index : Int32) -> UInt32? {
  if index < 0 || index >= self.type_indices.length() {
    None
  } else {
    Some(self.type_indices[index])
  }
}

///|
pub struct FieldListType {
  bytes : Bytes
}

///|
pub fn FieldListType::bytes(self : FieldListType) -> Bytes {
  self.bytes
}

///|
pub struct BitFieldType {
  underlying_type : UInt32
  bit_size : Int32
  bit_offset : Int32
}

///|
pub fn BitFieldType::underlying_type(self : BitFieldType) -> UInt32 {
  self.underlying_type
}

///|
pub fn BitFieldType::bit_size(self : BitFieldType) -> Int32 {
  self.bit_size
}

///|
pub fn BitFieldType::bit_offset(self : BitFieldType) -> Int32 {
  self.bit_offset
}

///|
pub struct ArrayType {
  element_type : UInt32
  index_type : UInt32
  size : NumericValue
  name : String
}

///|
pub fn ArrayType::element_type(self : ArrayType) -> UInt32 {
  self.element_type
}

///|
pub fn ArrayType::index_type(self : ArrayType) -> UInt32 {
  self.index_type
}

///|
pub fn ArrayType::size(self : ArrayType) -> NumericValue {
  self.size
}

///|
pub fn ArrayType::name(self : ArrayType) -> String {
  self.name
}

///|
pub struct AggregateType {
  leaf_kind : UInt16
  member_count : UInt16
  properties : UInt16
  field_list : UInt32
  derived_from : UInt32
  vtable_shape : UInt32
  size : NumericValue
  name : String
  unique_name : String?
}

///|
pub fn AggregateType::leaf_kind(self : AggregateType) -> UInt16 {
  self.leaf_kind
}

///|
pub fn AggregateType::member_count(self : AggregateType) -> UInt16 {
  self.member_count
}

///|
pub fn AggregateType::properties(self : AggregateType) -> UInt16 {
  self.properties
}

///|
pub fn AggregateType::field_list(self : AggregateType) -> UInt32 {
  self.field_list
}

///|
pub fn AggregateType::derived_from(self : AggregateType) -> UInt32 {
  self.derived_from
}

///|
pub fn AggregateType::vtable_shape(self : AggregateType) -> UInt32 {
  self.vtable_shape
}

///|
pub fn AggregateType::size(self : AggregateType) -> NumericValue {
  self.size
}

///|
pub fn AggregateType::name(self : AggregateType) -> String {
  self.name
}

///|
pub fn AggregateType::unique_name(self : AggregateType) -> String? {
  self.unique_name
}

///|
pub fn AggregateType::is_forward_reference(self : AggregateType) -> Bool {
  (self.properties & 0x0080) != 0
}

///|
pub fn AggregateType::has_unique_name(self : AggregateType) -> Bool {
  (self.properties & 0x0200) != 0
}

///|
pub struct UnionType {
  member_count : UInt16
  properties : UInt16
  field_list : UInt32
  size : NumericValue
  name : String
  unique_name : String?
}

///|
pub fn UnionType::member_count(self : UnionType) -> UInt16 {
  self.member_count
}

///|
pub fn UnionType::properties(self : UnionType) -> UInt16 {
  self.properties
}

///|
pub fn UnionType::field_list(self : UnionType) -> UInt32 {
  self.field_list
}

///|
pub fn UnionType::size(self : UnionType) -> NumericValue {
  self.size
}

///|
pub fn UnionType::name(self : UnionType) -> String {
  self.name
}

///|
pub fn UnionType::unique_name(self : UnionType) -> String? {
  self.unique_name
}

///|
pub struct EnumType {
  member_count : UInt16
  properties : UInt16
  underlying_type : UInt32
  field_list : UInt32
  name : String
  unique_name : String?
}

///|
pub fn EnumType::member_count(self : EnumType) -> UInt16 {
  self.member_count
}

///|
pub fn EnumType::properties(self : EnumType) -> UInt16 {
  self.properties
}

///|
pub fn EnumType::underlying_type(self : EnumType) -> UInt32 {
  self.underlying_type
}

///|
pub fn EnumType::field_list(self : EnumType) -> UInt32 {
  self.field_list
}

///|
pub fn EnumType::name(self : EnumType) -> String {
  self.name
}

///|
pub fn EnumType::unique_name(self : EnumType) -> String? {
  self.unique_name
}

///|
pub struct AliasType {
  underlying_type : UInt32
  name : String
}

///|
pub fn AliasType::underlying_type(self : AliasType) -> UInt32 {
  self.underlying_type
}

///|
pub fn AliasType::name(self : AliasType) -> String {
  self.name
}

///|
pub struct LabelType {
  mode : UInt16
}

///|
pub fn LabelType::mode(self : LabelType) -> UInt16 {
  self.mode
}

///|
pub struct FunctionIdType {
  parent_scope : UInt32
  function_type : UInt32
  name : String
}

///|
pub fn FunctionIdType::parent_scope(self : FunctionIdType) -> UInt32 {
  self.parent_scope
}

///|
pub fn FunctionIdType::function_type(self : FunctionIdType) -> UInt32 {
  self.function_type
}

///|
pub fn FunctionIdType::name(self : FunctionIdType) -> String {
  self.name
}

///|
pub struct MemberFunctionIdType {
  class_type : UInt32
  function_type : UInt32
  name : String
}

///|
pub fn MemberFunctionIdType::class_type(self : MemberFunctionIdType) -> UInt32 {
  self.class_type
}

///|
pub fn MemberFunctionIdType::function_type(
  self : MemberFunctionIdType,
) -> UInt32 {
  self.function_type
}

///|
pub fn MemberFunctionIdType::name(self : MemberFunctionIdType) -> String {
  self.name
}

///|
pub struct StringIdType {
  id : UInt32
  value : String
}

///|
pub fn StringIdType::id(self : StringIdType) -> UInt32 {
  self.id
}

///|
pub fn StringIdType::value(self : StringIdType) -> String {
  self.value
}

///|
pub struct BuildInfoType {
  argument_indices : Array[UInt32]
}

///|
pub fn BuildInfoType::argument_indices(self : BuildInfoType) -> Array[UInt32] {
  self.argument_indices.copy()
}

///|
pub struct UdtSourceLineType {
  udt : UInt32
  source_file : UInt32
  line_number : UInt32
  module_index : UInt32?
}

///|
pub fn UdtSourceLineType::udt(self : UdtSourceLineType) -> UInt32 {
  self.udt
}

///|
pub fn UdtSourceLineType::source_file(self : UdtSourceLineType) -> UInt32 {
  self.source_file
}

///|
pub fn UdtSourceLineType::line_number(self : UdtSourceLineType) -> UInt32 {
  self.line_number
}

///|
pub fn UdtSourceLineType::module_index(self : UdtSourceLineType) -> UInt32? {
  self.module_index
}

///|
pub struct TypeServer2Type {
  guid : Bytes
  age : UInt32
  name : String
}

///|
pub fn TypeServer2Type::guid(self : TypeServer2Type) -> Bytes {
  self.guid
}

///|
pub fn TypeServer2Type::age(self : TypeServer2Type) -> UInt32 {
  self.age
}

///|
pub fn TypeServer2Type::name(self : TypeServer2Type) -> String {
  self.name
}

///|
pub struct UnknownType {
  kind : UInt16
  payload : Bytes
}

///|
pub fn UnknownType::kind(self : UnknownType) -> UInt16 {
  self.kind
}

///|
pub fn UnknownType::payload(self : UnknownType) -> Bytes {
  self.payload
}

///|
/// The decoded representation of one CodeView type record.
pub enum TypeDetails {
  Modifier(ModifierType)
  Pointer(PointerType)
  Procedure(ProcedureType)
  MemberFunction(MemberFunctionType)
  ArgList(ArgListType)
  FieldList(FieldListType)
  BitField(BitFieldType)
  Array(ArrayType)
  Aggregate(AggregateType)
  Union(UnionType)
  Enum(EnumType)
  Alias(AliasType)
  Label(LabelType)
  FunctionId(FunctionIdType)
  MemberFunctionId(MemberFunctionIdType)
  StringId(StringIdType)
  BuildInfo(BuildInfoType)
  UdtSourceLine(UdtSourceLineType)
  TypeServer2(TypeServer2Type)
  Unknown(UnknownType)
}

///|
/// One indexed TPI or IPI record.
pub struct TypeRecord {
  type_index : UInt32
  kind : UInt16
  payload : Bytes
  details : TypeDetails
}

///|
pub fn TypeRecord::type_index(self : TypeRecord) -> UInt32 {
  self.type_index
}

///|
pub fn TypeRecord::kind(self : TypeRecord) -> UInt16 {
  self.kind
}

///|
pub fn TypeRecord::payload(self : TypeRecord) -> Bytes {
  self.payload
}

///|
pub fn TypeRecord::details(self : TypeRecord) -> TypeDetails {
  self.details
}

///|
/// A parsed TPI or IPI stream.
pub struct TypeTable {
  data : Bytes
  header : TpiHeader
  records : Array[TypeRecord]
}

///|
pub fn TypeTable::data(self : TypeTable) -> Bytes {
  self.data
}

///|
pub fn TypeTable::header(self : TypeTable) -> TpiHeader {
  self.header
}

///|
pub fn TypeTable::record_count(self : TypeTable) -> Int32 {
  self.records.length()
}

///|
pub fn TypeTable::record_at(self : TypeTable, position : Int32) -> TypeRecord? {
  if position < 0 || position >= self.records.length() {
    None
  } else {
    Some(self.records[position])
  }
}

///|
pub fn TypeTable::record(self : TypeTable, type_index : UInt32) -> TypeRecord? {
  let begin = self.header.type_index_begin
  if type_index < begin || type_index >= self.header.type_index_end {
    return None
  }
  let position = (type_index - begin).reinterpret_as_int()
  self.record_at(position)
}

///|
pub fn TypeTable::records(self : TypeTable) -> Array[TypeRecord] {
  self.records.copy()
}

///|
/// Parse stream 2 of an MSF file as a TPI type table.
pub fn MsfFile::tpi(
  self : MsfFile,
  limits : TpiLimits,
) -> TypeTable raise TpiError {
  let bytes = self.stream(2) catch { _ => raise TypeStreamUnavailable(2) }
  parse_tpi(bytes, limits)
}

///|
/// Parse stream 4 of an MSF file as an IPI type table.
pub fn MsfFile::ipi(
  self : MsfFile,
  limits : TpiLimits,
) -> TypeTable raise TpiError {
  let bytes = self.stream(4) catch { _ => raise TypeStreamUnavailable(4) }
  parse_tpi(bytes, limits)
}

///|
/// Parse a TPI or IPI stream, including all indexed type records.
pub fn parse_tpi(data : Bytes, limits : TpiLimits) -> TypeTable raise TpiError {
  if data.length() > limits.max_stream_bytes {
    raise TpiLimitExceeded("type stream byte limit exceeded")
  }
  let header = parse_tpi_header(data)
  let records_end = checked_tpi_add(
    header.header_size,
    header.type_record_bytes,
    "type record region",
  )
  if records_end > data.length() {
    raise TruncatedTpi(records_end)
  }
  if header.type_record_count() > limits.max_records.reinterpret_as_uint() {
    raise TpiLimitExceeded("type record count limit exceeded")
  }
  let records = []
  let mut cursor = header.header_size
  let mut position = 0
  while cursor < records_end {
    let (length_raw, next) = read_tpi_u16(data, cursor, records_end)
    cursor = next
    let length = length_raw.to_int()
    if length < 2 {
      raise InvalidTypeRecord("record length is smaller than its kind field")
    }
    if length > limits.max_record_bytes {
      raise TpiLimitExceeded("type record byte limit exceeded")
    }
    let record_end = checked_tpi_add(cursor, length, "type record end")
    if record_end > records_end {
      raise TruncatedTpi(record_end)
    }
    let (kind, payload_start) = read_tpi_u16(data, cursor, record_end)
    let payload = data
      .exact_view(start=payload_start, end=record_end)
      .to_owned()
    let type_index = header.type_index_begin + position.reinterpret_as_uint()
    if type_index >= header.type_index_end {
      raise InvalidTypeRecord(
        "type record count exceeds the declared type-index range",
      )
    }
    records.push(TypeRecord::{
      type_index,
      kind,
      payload,
      details: decode_type_details(kind, payload, limits),
    })
    cursor = record_end
    position = position + 1
  }
  if cursor != records_end {
    raise InvalidTypeRecord("type record region has trailing bytes")
  }
  if position.reinterpret_as_uint() != header.type_record_count() {
    raise InvalidTypeRecord(
      "type record count does not match the declared type-index range",
    )
  }
  TypeTable::{ data, header, records, }
}

///|
/// Return the standard interpretation of a simple type index below 0x1000.
pub fn simple_type(type_index : UInt32) -> SimpleType? {
  if type_index >= TPI_TYPE_INDEX_BEGIN {
    return None
  }
  let base_int = (type_index & 0xFFU).reinterpret_as_int()
  let mode = match (type_index >> 8) & 0x7U {
    0U => Direct
    1U => NearPointer
    2U => FarPointer
    3U => HugePointer
    4U => Pointer32
    5U => FarPointer32
    6U => Pointer64
    _ => Reserved
  }
  let (kind, name, byte_size) = classify_simple_type(base_int)
  Some(SimpleType::{
    raw: type_index,
    base: base_int,
    mode,
    kind,
    name,
    byte_size,
  })
}

///|
fn classify_simple_type(base : Int32) -> (SimpleTypeKind, String, Int32) {
  match base {
    0x00 => (NoType, "notype", 0)
    0x03 => (Void, "void", 0)
    0x08 => (SignedInteger, "hresult", 4)
    0x10 => (Character, "char", 1)
    0x11 => (SignedInteger, "short", 2)
    0x12 => (SignedInteger, "long", 4)
    0x13 => (SignedInteger, "quad", 8)
    0x14 => (SignedInteger, "oct", 16)
    0x20 => (UnsignedInteger, "uchar", 1)
    0x21 => (UnsignedInteger, "ushort", 2)
    0x22 => (UnsignedInteger, "ulong", 4)
    0x23 => (UnsignedInteger, "uquad", 8)
    0x24 => (UnsignedInteger, "uoct", 16)
    0x30 => (Boolean, "bool8", 1)
    0x31 => (Boolean, "bool16", 2)
    0x32 => (Boolean, "bool32", 4)
    0x33 => (Boolean, "bool64", 8)
    0x40 => (Real, "real32", 4)
    0x41 => (Real, "real64", 8)
    0x42 => (Real, "real80", 10)
    0x43 => (Real, "real128", 16)
    0x60 => (Bit, "bit", 0)
    0x61 => (Character, "pascal_char", 1)
    0x62 => (Boolean, "bool32_ff", 4)
    0x68 => (SignedInteger, "int8", 1)
    0x69 => (UnsignedInteger, "uint8", 1)
    0x70 => (Character, "rchar", 1)
    0x71 => (WideCharacter, "wchar", 2)
    0x72 => (SignedInteger, "int16", 2)
    0x73 => (UnsignedInteger, "uint16", 2)
    0x74 => (SignedInteger, "int32", 4)
    0x75 => (UnsignedInteger, "uint32", 4)
    0x76 => (SignedInteger, "int64", 8)
    0x77 => (UnsignedInteger, "uint64", 8)
    0x78 => (SignedInteger, "int128", 16)
    0x79 => (UnsignedInteger, "uint128", 16)
    0x7A => (WideCharacter, "char16", 2)
    0x7B => (WideCharacter, "char32", 4)
    _ => (Unknown, "unknown", 0)
  }
}

///|
fn parse_tpi_header(data : Bytes) -> TpiHeader raise TpiError {
  if data.length() < TPI_HEADER_SIZE {
    raise TruncatedTpi(data.length())
  }
  let (version, cursor) = read_tpi_u32(data, 0, data.length())
  let (header_size_raw, cursor) = read_tpi_u32(data, cursor, data.length())
  let header_size = tpi_uint_to_int(header_size_raw, "header size")
  if header_size < TPI_HEADER_SIZE || header_size > data.length() {
    raise InvalidTpiHeader("header size is outside the stream")
  }
  let (type_index_begin, cursor) = read_tpi_u32(data, cursor, data.length())
  let (type_index_end, cursor) = read_tpi_u32(data, cursor, data.length())
  if type_index_begin < TPI_TYPE_INDEX_BEGIN ||
    type_index_end <= type_index_begin {
    raise InvalidTpiHeader("invalid type-index range")
  }
  let (type_record_bytes_raw, cursor) = read_tpi_u32(
    data,
    cursor,
    data.length(),
  )
  let type_record_bytes = tpi_uint_to_int(
    type_record_bytes_raw, "type record bytes",
  )
  if type_record_bytes < 0 ||
    checked_tpi_add(header_size, type_record_bytes, "type records") >
    data.length() {
    raise InvalidTpiHeader("type records are outside the stream")
  }
  let (hash_stream_index_raw, cursor) = read_tpi_u16(
    data,
    cursor,
    data.length(),
  )
  let (hash_aux_stream_index_raw, cursor) = read_tpi_u16(
    data,
    cursor,
    data.length(),
  )
  let (hash_key_size, cursor) = read_tpi_u32(data, cursor, data.length())
  let (hash_bucket_count, cursor) = read_tpi_u32(data, cursor, data.length())
  let (hash_value_offset_raw, cursor) = read_tpi_u32(
    data,
    cursor,
    data.length(),
  )
  let (hash_value_bytes_raw, cursor) = read_tpi_u32(data, cursor, data.length())
  let (index_offset_offset_raw, cursor) = read_tpi_u32(
    data,
    cursor,
    data.length(),
  )
  let (index_offset_bytes_raw, cursor) = read_tpi_u32(
    data,
    cursor,
    data.length(),
  )
  let (hash_adjust_offset_raw, cursor) = read_tpi_u32(
    data,
    cursor,
    data.length(),
  )
  let (hash_adjust_bytes_raw, _) = read_tpi_u32(data, cursor, data.length())
  let hash_value_offset = hash_value_offset_raw.reinterpret_as_int()
  let hash_value_bytes = tpi_uint_to_int(
    hash_value_bytes_raw, "hash value bytes",
  )
  let index_offset_offset = index_offset_offset_raw.reinterpret_as_int()
  let index_offset_bytes = tpi_uint_to_int(
    index_offset_bytes_raw, "index offset bytes",
  )
  let hash_adjust_offset = hash_adjust_offset_raw.reinterpret_as_int()
  let hash_adjust_bytes = tpi_uint_to_int(
    hash_adjust_bytes_raw, "hash adjust bytes",
  )
  validate_embedded_region(
    data, hash_value_offset, hash_value_bytes, "hash values",
  )
  validate_embedded_region(
    data, index_offset_offset, index_offset_bytes, "type index offsets",
  )
  validate_embedded_region(
    data, hash_adjust_offset, hash_adjust_bytes, "hash adjusters",
  )
  TpiHeader::{
    version,
    header_size,
    type_index_begin,
    type_index_end,
    type_record_bytes,
    hash_stream_index: hash_stream_index_raw.to_int(),
    hash_aux_stream_index: hash_aux_stream_index_raw.to_int(),
    hash_key_size,
    hash_bucket_count,
    hash_value_offset,
    hash_value_bytes,
    index_offset_offset,
    index_offset_bytes,
    hash_adjust_offset,
    hash_adjust_bytes,
  }
}

///|
fn validate_embedded_region(
  data : Bytes,
  offset : Int32,
  length : Int32,
  field : String,
) -> Unit raise TpiError {
  if length == 0 {
    return
  }
  if offset < 0 || length < 0 {
    raise InvalidTpiHeader("\{field} has a negative offset or length")
  }
  let end = checked_tpi_add(offset, length, field)
  if end > data.length() {
    raise InvalidTpiHeader("\{field} is outside the stream")
  }
}

///|
fn decode_type_details(
  kind : UInt16,
  payload : Bytes,
  limits : TpiLimits,
) -> TypeDetails raise TpiError {
  match kind {
    LF_MODIFIER => decode_modifier(payload)
    LF_POINTER => decode_pointer(payload)
    LF_PROCEDURE => decode_procedure(payload)
    LF_MFUNCTION => decode_member_function(payload)
    LF_ARGLIST | LF_SUBSTR_LIST =>
      TypeDetails::ArgList(decode_arg_list(payload, limits))
    LF_FIELDLIST => TypeDetails::FieldList(FieldListType::{ bytes: payload, })
    LF_BITFIELD => decode_bitfield(payload)
    LF_ARRAY => decode_array(payload)
    LF_CLASS | LF_STRUCTURE | LF_INTERFACE => decode_aggregate(kind, payload)
    LF_UNION => decode_union(payload)
    LF_ENUM => decode_enum(payload)
    LF_ALIAS => decode_alias(payload)
    LF_LABEL => decode_label(payload)
    LF_FUNC_ID => decode_function_id(payload)
    LF_MFUNC_ID => decode_member_function_id(payload)
    LF_STRING_ID => decode_string_id(payload)
    LF_BUILDINFO => decode_build_info(payload, limits)
    LF_UDT_SRC_LINE | LF_UDT_MOD_SRC_LINE =>
      decode_udt_source_line(kind, payload)
    LF_TYPESERVER2 => decode_type_server2(payload)
    _ => Unknown(UnknownType::{ kind, payload, })
  }
}

///|
fn decode_modifier(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 6, "LF_MODIFIER")
  let (modified_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (modifiers, _) = read_tpi_u16(payload, cursor, payload.length())
  Modifier(ModifierType::{ modified_type, modifiers, })
}

///|
fn decode_pointer(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 8, "LF_POINTER")
  let (referent_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (attributes, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let mode = (attributes >> 5) & 0x07U
  if mode == 2U || mode == 3U {
    require_payload(payload, 14, "member LF_POINTER")
    let (containing_type, cursor) = read_tpi_u32(
      payload,
      cursor,
      payload.length(),
    )
    let (representation, next) = read_tpi_u16(payload, cursor, payload.length())
    if next != payload.length() {
      raise InvalidTypeRecord("member pointer has trailing bytes")
    }
    Pointer(PointerType::{
      referent_type,
      attributes,
      containing_type: Some(containing_type),
      member_representation: Some(representation),
    })
  } else {
    if cursor != payload.length() {
      raise InvalidTypeRecord("LF_POINTER has trailing bytes")
    }
    Pointer(PointerType::{
      referent_type,
      attributes,
      containing_type: None,
      member_representation: None,
    })
  }
}

///|
fn decode_procedure(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 12, "LF_PROCEDURE")
  let (return_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (calling_convention, cursor) = read_tpi_u8(
    payload,
    cursor,
    payload.length(),
  )
  let (function_options, cursor) = read_tpi_u8(
    payload,
    cursor,
    payload.length(),
  )
  let (parameter_count, cursor) = read_tpi_u16(
    payload,
    cursor,
    payload.length(),
  )
  let (argument_list, cursor) = read_tpi_u32(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_PROCEDURE")
  Procedure(ProcedureType::{
    return_type,
    calling_convention,
    function_options,
    parameter_count,
    argument_list,
  })
}

///|
fn decode_member_function(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 24, "LF_MFUNCTION")
  let (return_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (class_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (this_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (calling_convention, cursor) = read_tpi_u8(
    payload,
    cursor,
    payload.length(),
  )
  let (function_options, cursor) = read_tpi_u8(
    payload,
    cursor,
    payload.length(),
  )
  let (parameter_count, cursor) = read_tpi_u16(
    payload,
    cursor,
    payload.length(),
  )
  let (argument_list, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (this_adjustment, cursor) = read_tpi_u32(
    payload,
    cursor,
    payload.length(),
  )
  require_exact_end(cursor, payload.length(), "LF_MFUNCTION")
  MemberFunction(MemberFunctionType::{
    return_type,
    class_type,
    this_type,
    calling_convention,
    function_options,
    parameter_count,
    argument_list,
    this_adjustment: this_adjustment.reinterpret_as_int(),
  })
}

///|
fn decode_arg_list(
  payload : Bytes,
  limits : TpiLimits,
) -> ArgListType raise TpiError {
  let (count_raw, cursor0) = read_tpi_u32(payload, 0, payload.length())
  let mut cursor = cursor0
  let count = tpi_uint_to_int(count_raw, "argument count")
  if count > limits.max_type_refs {
    raise TpiLimitExceeded("argument type-reference limit exceeded")
  }
  let expected_end = checked_tpi_add(
    cursor,
    checked_tpi_mul(count, 4, "argument list"),
    "argument list",
  )
  if expected_end != payload.length() {
    raise InvalidTypeRecord("argument list size does not match its count")
  }
  let indices = []
  for _ in 0..<count {
    let (type_index, next) = read_tpi_u32(payload, cursor, payload.length())
    indices.push(type_index)
    cursor = next
  }
  ArgListType::{ type_indices: indices, }
}

///|
fn decode_bitfield(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 6, "LF_BITFIELD")
  let (underlying_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (bit_size, cursor) = read_tpi_u8(payload, cursor, payload.length())
  let (bit_offset, cursor) = read_tpi_u8(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_BITFIELD")
  BitField(BitFieldType::{ underlying_type, bit_size, bit_offset, })
}

///|
fn decode_array(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 9, "LF_ARRAY")
  let (element_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (index_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (size, cursor) = read_numeric_value(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_ARRAY")
  Array(ArrayType::{ element_type, index_type, size, name, })
}

///|
fn decode_aggregate(
  kind : UInt16,
  payload : Bytes,
) -> TypeDetails raise TpiError {
  require_payload(payload, 18, "LF_CLASS/LF_STRUCTURE")
  let (member_count, cursor) = read_tpi_u16(payload, 0, payload.length())
  let (properties, cursor) = read_tpi_u16(payload, cursor, payload.length())
  let (field_list, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (derived_from, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (vtable_shape, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (size, cursor) = read_numeric_value(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  let (unique_name, cursor) = if (properties & 0x0200) != 0 {
    let (value, next) = read_tpi_string(payload, cursor, payload.length())
    (Some(value), next)
  } else {
    (None, cursor)
  }
  require_exact_end(cursor, payload.length(), "aggregate")
  Aggregate(AggregateType::{
    leaf_kind: kind,
    member_count,
    properties,
    field_list,
    derived_from,
    vtable_shape,
    size,
    name,
    unique_name,
  })
}

///|
fn decode_union(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 10, "LF_UNION")
  let (member_count, cursor) = read_tpi_u16(payload, 0, payload.length())
  let (properties, cursor) = read_tpi_u16(payload, cursor, payload.length())
  let (field_list, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (size, cursor) = read_numeric_value(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  let (unique_name, cursor) = if (properties & 0x0200) != 0 {
    let (value, next) = read_tpi_string(payload, cursor, payload.length())
    (Some(value), next)
  } else {
    (None, cursor)
  }
  require_exact_end(cursor, payload.length(), "LF_UNION")
  Union(UnionType::{
    member_count,
    properties,
    field_list,
    size,
    name,
    unique_name,
  })
}

///|
fn decode_enum(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 12, "LF_ENUM")
  let (member_count, cursor) = read_tpi_u16(payload, 0, payload.length())
  let (properties, cursor) = read_tpi_u16(payload, cursor, payload.length())
  let (underlying_type, cursor) = read_tpi_u32(
    payload,
    cursor,
    payload.length(),
  )
  let (field_list, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  let (unique_name, cursor) = if (properties & 0x0200) != 0 {
    let (value, next) = read_tpi_string(payload, cursor, payload.length())
    (Some(value), next)
  } else {
    (None, cursor)
  }
  require_exact_end(cursor, payload.length(), "LF_ENUM")
  Enum(EnumType::{
    member_count,
    properties,
    underlying_type,
    field_list,
    name,
    unique_name,
  })
}

///|
fn decode_alias(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 5, "LF_ALIAS")
  let (underlying_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_ALIAS")
  Alias(AliasType::{ underlying_type, name, })
}

///|
fn decode_label(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 2, "LF_LABEL")
  let (mode, cursor) = read_tpi_u16(payload, 0, payload.length())
  require_exact_end(cursor, payload.length(), "LF_LABEL")
  Label(LabelType::{ mode, })
}

///|
fn decode_function_id(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 9, "LF_FUNC_ID")
  let (parent_scope, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (function_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_FUNC_ID")
  FunctionId(FunctionIdType::{ parent_scope, function_type, name, })
}

///|
fn decode_member_function_id(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 9, "LF_MFUNC_ID")
  let (class_type, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (function_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_MFUNC_ID")
  MemberFunctionId(MemberFunctionIdType::{ class_type, function_type, name, })
}

///|
fn decode_string_id(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 5, "LF_STRING_ID")
  let (id, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (value, cursor) = read_tpi_string(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_STRING_ID")
  StringId(StringIdType::{ id, value, })
}

///|
fn decode_build_info(
  payload : Bytes,
  limits : TpiLimits,
) -> TypeDetails raise TpiError {
  require_payload(payload, 2, "LF_BUILDINFO")
  let (count_raw, cursor0) = read_tpi_u16(payload, 0, payload.length())
  let mut cursor = cursor0
  let count = count_raw.to_int()
  if count > limits.max_type_refs {
    raise TpiLimitExceeded("build-info type-reference limit exceeded")
  }
  let references_end = checked_tpi_add(
    2,
    checked_tpi_mul(count, 4, "build info"),
    "build info",
  )
  if payload.length() != references_end {
    raise InvalidTypeRecord("build-info size does not match its count")
  }
  let indices = []
  for _ in 0..<count {
    let (type_index, next) = read_tpi_u32(payload, cursor, payload.length())
    indices.push(type_index)
    cursor = next
  }
  BuildInfo(BuildInfoType::{ argument_indices: indices, })
}

///|
fn decode_udt_source_line(
  kind : UInt16,
  payload : Bytes,
) -> TypeDetails raise TpiError {
  let expected = if kind == LF_UDT_MOD_SRC_LINE { 16 } else { 12 }
  require_payload(payload, expected, "LF_UDT_SRC_LINE")
  let (udt, cursor) = read_tpi_u32(payload, 0, payload.length())
  let (source_file, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (line_number, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (module_index, cursor) = if kind == LF_UDT_MOD_SRC_LINE {
    let (value, next) = read_tpi_u32(payload, cursor, payload.length())
    (Some(value), next)
  } else {
    (None, cursor)
  }
  require_exact_end(cursor, payload.length(), "LF_UDT_SRC_LINE")
  UdtSourceLine(UdtSourceLineType::{
    udt,
    source_file,
    line_number,
    module_index,
  })
}

///|
fn decode_type_server2(payload : Bytes) -> TypeDetails raise TpiError {
  require_payload(payload, 21, "LF_TYPESERVER2")
  let guid = payload.exact_view(start=0, end=16).to_owned()
  let (age, cursor) = read_tpi_u32(payload, 16, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  require_exact_end(cursor, payload.length(), "LF_TYPESERVER2")
  TypeServer2(TypeServer2Type::{ guid, age, name, })
}

///|
fn read_numeric_value(
  data : Bytes,
  start : Int32,
  end : Int32,
) -> (NumericValue, Int32) raise TpiError {
  let (kind, cursor) = read_tpi_u16(data, start, end)
  match kind {
    0x8000 => {
      let (value, next) = read_tpi_u8(data, cursor, end)
      let signed = value
      let normalized = if signed >= 0x80 { signed - 0x100 } else { signed }
      (Signed(normalized.to_int64()), next)
    }
    0x8001 => {
      let (value, next) = read_tpi_u16(data, cursor, end)
      let signed = value.to_int()
      let normalized = if signed >= 0x8000 { signed - 0x10000 } else { signed }
      (Signed(normalized.to_int64()), next)
    }
    0x8002 => {
      let (value, next) = read_tpi_u16(data, cursor, end)
      (Unsigned(value.to_uint().to_uint64()), next)
    }
    0x8003 => {
      let (value, next) = read_tpi_u32(data, cursor, end)
      (Signed(value.reinterpret_as_int().to_int64()), next)
    }
    0x8004 => {
      let (value, next) = read_tpi_u32(data, cursor, end)
      (Unsigned(value.to_uint64()), next)
    }
    0x8009 => {
      let (value, next) = read_tpi_u64(data, cursor, end)
      (Signed(value.reinterpret_as_int64()), next)
    }
    0x800A => {
      let (value, next) = read_tpi_u64(data, cursor, end)
      (Unsigned(value), next)
    }
    0x8010 => {
      let (length_raw, cursor) = read_tpi_u16(data, cursor, end)
      let length = length_raw.to_int()
      let next = checked_tpi_add(cursor, length, "variable numeric value")
      if next > end {
        raise TruncatedTpi(next)
      }
      (Opaque(kind, data.exact_view(start=cursor, end=next).to_owned()), next)
    }
    0x8017 | 0x8018 => {
      let next = checked_tpi_add(cursor, 16, "128-bit numeric value")
      if next > end {
        raise TruncatedTpi(next)
      }
      (Opaque(kind, data.exact_view(start=cursor, end=next).to_owned()), next)
    }
    0x8005 => skip_opaque_numeric(data, cursor, end, kind, 4)
    0x8006 => skip_opaque_numeric(data, cursor, end, kind, 8)
    0x8007 => skip_opaque_numeric(data, cursor, end, kind, 10)
    0x8008 => skip_opaque_numeric(data, cursor, end, kind, 16)
    0x800B => skip_opaque_numeric(data, cursor, end, kind, 6)
    0x800C => skip_opaque_numeric(data, cursor, end, kind, 8)
    0x800D => skip_opaque_numeric(data, cursor, end, kind, 16)
    0x800E => skip_opaque_numeric(data, cursor, end, kind, 20)
    0x800F => skip_opaque_numeric(data, cursor, end, kind, 32)
    0x801C => skip_opaque_numeric(data, cursor, end, kind, 2)
    _ => {
      let type_index = UInt32(kind.to_uint())
      (Unsigned(type_index.to_uint64()), cursor)
    }
  }
}

///|
fn skip_opaque_numeric(
  data : Bytes,
  start : Int32,
  end : Int32,
  kind : UInt16,
  length : Int32,
) -> (NumericValue, Int32) raise TpiError {
  let next = checked_tpi_add(start, length, "numeric value")
  if next > end {
    raise TruncatedTpi(next)
  }
  (Opaque(kind, data.exact_view(start~, end=next).to_owned()), next)
}

///|
fn read_tpi_string(
  data : Bytes,
  start : Int32,
  end : Int32,
) -> (String, Int32) raise TpiError {
  let mut cursor = start
  while cursor < end {
    if data.at(cursor) == 0 {
      let value = @utf8.decode(data.exact_view(start~, end=cursor)) catch {
        _ => raise InvalidTypeRecord("type name is not valid UTF-8")
      }
      return (value, cursor + 1)
    }
    cursor = cursor + 1
  }
  raise InvalidTypeRecord("type name is not NUL-terminated")
}

///|
fn require_payload(
  payload : Bytes,
  minimum : Int32,
  _record : String,
) -> Unit raise TpiError {
  if payload.length() < minimum {
    raise TruncatedTpi(payload.length())
  }
}

///|
fn require_exact_end(
  cursor : Int32,
  expected : Int32,
  _record : String,
) -> Unit raise TpiError {
  if cursor != expected {
    raise InvalidTypeRecord("\{_record} has trailing bytes")
  }
}

///|
fn read_tpi_u8(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (Int32, Int32) raise TpiError {
  if pos < 0 || pos >= end || pos >= data.length() {
    raise TruncatedTpi(pos)
  }
  (data.at(pos).to_int(), pos + 1)
}

///|
fn read_tpi_u16(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt16, Int32) raise TpiError {
  let (b0, pos) = read_tpi_u8(data, pos, end)
  let (b1, pos) = read_tpi_u8(data, pos, end)
  (((b1 << 8) | b0).to_uint16(), pos)
}

///|
fn read_tpi_u32(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt32, Int32) raise TpiError {
  let (b0, pos) = read_tpi_u8(data, pos, end)
  let (b1, pos) = read_tpi_u8(data, pos, end)
  let (b2, pos) = read_tpi_u8(data, pos, end)
  let (b3, pos) = read_tpi_u8(data, pos, end)
  (
    UInt32(
      (b3.reinterpret_as_uint() << 24) |
      (b2.reinterpret_as_uint() << 16) |
      (b1.reinterpret_as_uint() << 8) |
      b0.reinterpret_as_uint(),
    ),
    pos,
  )
}

///|
fn read_tpi_u64(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt64, Int32) raise TpiError {
  let (low, pos) = read_tpi_u32(data, pos, end)
  let (high, pos) = read_tpi_u32(data, pos, end)
  ((high.to_uint64() << 32) | low.to_uint64(), pos)
}

///|
fn tpi_uint_to_int(value : UInt32, field : String) -> Int32 raise TpiError {
  if value > 0x7FFFFFFFU {
    raise InvalidTpiHeader("\{field} exceeds Int range")
  }
  value.reinterpret_as_int()
}

///|
fn checked_tpi_add(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise TpiError {
  if left < 0 || right < 0 || left > 0x7FFFFFFF - right {
    raise InvalidTpiHeader("\{field} overflows Int range")
  }
  left + right
}

///|
fn checked_tpi_mul(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise TpiError {
  if left < 0 || right < 0 || (left != 0 && right > 0x7FFFFFFF / left) {
    raise InvalidTypeRecord("\{field} overflows Int range")
  }
  left * right
}
