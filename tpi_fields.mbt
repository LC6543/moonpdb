///|
const LF_BCLASS : UInt16 = 0x1400

///|
const LF_VBCLASS : UInt16 = 0x1401

///|
const LF_IVBCLASS : UInt16 = 0x1402

///|
const LF_INDEX : UInt16 = 0x1404

///|
const LF_VFUNCTAB : UInt16 = 0x1409

///|
const LF_FRIENDCLS : UInt16 = 0x140A

///|
const LF_ENUMERATE : UInt16 = 0x1502

///|
const LF_MEMBER : UInt16 = 0x150D

///|
const LF_STMEMBER : UInt16 = 0x150E

///|
const LF_METHOD : UInt16 = 0x150F

///|
const LF_NESTTYPE : UInt16 = 0x1510

///|
const LF_ONEMETHOD : UInt16 = 0x1511

///|
/// CodeView field attributes shared by members, bases, and enumerators.
pub struct FieldAttributes {
  raw : UInt16
}

///|
pub fn FieldAttributes::raw(self : FieldAttributes) -> UInt16 {
  self.raw
}

///|
pub fn FieldAttributes::access(self : FieldAttributes) -> UInt16 {
  self.raw & 0x0003
}

///|
pub fn FieldAttributes::method_kind(self : FieldAttributes) -> UInt16 {
  (self.raw >> 2) & 0x0007
}

///|
pub fn FieldAttributes::is_introducing_virtual(self : FieldAttributes) -> Bool {
  let kind = self.method_kind()
  kind == 0x0004 || kind == 0x0006
}

///|
pub struct BaseClassField {
  attributes : FieldAttributes
  base_type : UInt32
  offset : NumericValue
}

///|
pub fn BaseClassField::attributes(self : BaseClassField) -> FieldAttributes {
  self.attributes
}

///|
pub fn BaseClassField::base_type(self : BaseClassField) -> UInt32 {
  self.base_type
}

///|
pub fn BaseClassField::offset(self : BaseClassField) -> NumericValue {
  self.offset
}

///|
pub struct VirtualBaseClassField {
  virtual_inheritance : Bool
  attributes : FieldAttributes
  base_type : UInt32
  vbptr_type : UInt32
  vbptr_offset : NumericValue
  vtable_index : NumericValue
}

///|
pub fn VirtualBaseClassField::virtual_inheritance(
  self : VirtualBaseClassField,
) -> Bool {
  self.virtual_inheritance
}

///|
pub fn VirtualBaseClassField::attributes(
  self : VirtualBaseClassField,
) -> FieldAttributes {
  self.attributes
}

///|
pub fn VirtualBaseClassField::base_type(self : VirtualBaseClassField) -> UInt32 {
  self.base_type
}

///|
pub fn VirtualBaseClassField::vbptr_type(
  self : VirtualBaseClassField,
) -> UInt32 {
  self.vbptr_type
}

///|
pub fn VirtualBaseClassField::vbptr_offset(
  self : VirtualBaseClassField,
) -> NumericValue {
  self.vbptr_offset
}

///|
pub fn VirtualBaseClassField::vtable_index(
  self : VirtualBaseClassField,
) -> NumericValue {
  self.vtable_index
}

///|
pub struct DataField {
  attributes : FieldAttributes
  type_index : UInt32
  offset : NumericValue
  name : String
}

///|
pub fn DataField::attributes(self : DataField) -> FieldAttributes {
  self.attributes
}

///|
pub fn DataField::type_index(self : DataField) -> UInt32 {
  self.type_index
}

///|
pub fn DataField::offset(self : DataField) -> NumericValue {
  self.offset
}

///|
pub fn DataField::name(self : DataField) -> String {
  self.name
}

///|
pub struct StaticDataField {
  attributes : FieldAttributes
  type_index : UInt32
  name : String
}

///|
pub fn StaticDataField::attributes(self : StaticDataField) -> FieldAttributes {
  self.attributes
}

///|
pub fn StaticDataField::type_index(self : StaticDataField) -> UInt32 {
  self.type_index
}

///|
pub fn StaticDataField::name(self : StaticDataField) -> String {
  self.name
}

///|
pub struct EnumeratedField {
  attributes : FieldAttributes
  value : NumericValue
  name : String
}

///|
pub fn EnumeratedField::attributes(self : EnumeratedField) -> FieldAttributes {
  self.attributes
}

///|
pub fn EnumeratedField::value(self : EnumeratedField) -> NumericValue {
  self.value
}

///|
pub fn EnumeratedField::name(self : EnumeratedField) -> String {
  self.name
}

///|
pub struct OverloadedMethodField {
  count : UInt16
  method_list : UInt32
  name : String
}

///|
pub fn OverloadedMethodField::count(self : OverloadedMethodField) -> UInt16 {
  self.count
}

///|
pub fn OverloadedMethodField::method_list(
  self : OverloadedMethodField,
) -> UInt32 {
  self.method_list
}

///|
pub fn OverloadedMethodField::name(self : OverloadedMethodField) -> String {
  self.name
}

///|
pub struct NestedTypeField {
  type_index : UInt32
  name : String
}

///|
pub fn NestedTypeField::type_index(self : NestedTypeField) -> UInt32 {
  self.type_index
}

///|
pub fn NestedTypeField::name(self : NestedTypeField) -> String {
  self.name
}

///|
pub struct OneMethodField {
  attributes : FieldAttributes
  type_index : UInt32
  vtable_offset : Int32?
  name : String
}

///|
pub fn OneMethodField::attributes(self : OneMethodField) -> FieldAttributes {
  self.attributes
}

///|
pub fn OneMethodField::type_index(self : OneMethodField) -> UInt32 {
  self.type_index
}

///|
pub fn OneMethodField::vtable_offset(self : OneMethodField) -> Int32? {
  self.vtable_offset
}

///|
pub fn OneMethodField::name(self : OneMethodField) -> String {
  self.name
}

///|
pub struct VFunctionTableField {
  type_index : UInt32
}

///|
pub fn VFunctionTableField::type_index(self : VFunctionTableField) -> UInt32 {
  self.type_index
}

///|
pub struct FriendClassField {
  type_index : UInt32
}

///|
pub fn FriendClassField::type_index(self : FriendClassField) -> UInt32 {
  self.type_index
}

///|
pub struct UnknownFieldTail {
  kind : UInt16
  payload : Bytes
}

///|
pub fn UnknownFieldTail::kind(self : UnknownFieldTail) -> UInt16 {
  self.kind
}

///|
pub fn UnknownFieldTail::payload(self : UnknownFieldTail) -> Bytes {
  self.payload
}

///|
pub enum FieldListMember {
  BaseClass(BaseClassField)
  VirtualBaseClass(VirtualBaseClassField)
  Data(DataField)
  StaticData(StaticDataField)
  Enumerated(EnumeratedField)
  OverloadedMethod(OverloadedMethodField)
  NestedType(NestedTypeField)
  OneMethod(OneMethodField)
  VFunctionTable(VFunctionTableField)
  FriendClass(FriendClassField)
  UnknownTail(UnknownFieldTail)
}

///|
/// Resolve a field-list record and all records reached by LF_INDEX continuations.
pub fn TypeTable::field_list_members(
  self : TypeTable,
  type_index : UInt32,
) -> Array[FieldListMember] raise TpiError {
  let members = []
  let visited = []
  let mut current = Some(type_index)
  while current is Some(index) {
    if visited.contains(index) {
      raise InvalidTypeRecord("field-list continuation cycle")
    }
    visited.push(index)
    let record = match self.record(index) {
      Some(value) => value
      None => raise InvalidTypeRecord("field-list type index is out of range")
    }
    match record.details() {
      FieldList(value) => {
        for field_item in value.members() {
          members.push(field_item)
        }
        current = value.continuation()
      }
      _ => raise InvalidTypeRecord("type index does not reference LF_FIELDLIST")
    }
  }
  members
}

///|
fn parse_field_list(payload : Bytes) -> FieldListType raise TpiError {
  let members = []
  let mut continuation : UInt32? = None
  let mut cursor = 0
  while cursor < payload.length() {
    let start = cursor
    let (kind, after_kind) = read_tpi_u16(payload, cursor, payload.length())
    if kind == LF_INDEX {
      let (padding, cursor) = read_tpi_u16(
        payload,
        after_kind,
        payload.length(),
      )
      if padding != 0 {
        raise InvalidTypeRecord("LF_INDEX padding is not zero")
      }
      let (next_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
      let cursor = skip_field_padding(payload, cursor, payload.length())
      if cursor != payload.length() {
        raise InvalidTypeRecord("LF_INDEX is not the final field member")
      }
      continuation = Some(next_index)
      break
    }
    let known = kind == LF_BCLASS ||
      kind == LF_VBCLASS ||
      kind == LF_IVBCLASS ||
      kind == LF_ENUMERATE ||
      kind == LF_MEMBER ||
      kind == LF_STMEMBER ||
      kind == LF_METHOD ||
      kind == LF_NESTTYPE ||
      kind == LF_ONEMETHOD ||
      kind == LF_VFUNCTAB ||
      kind == LF_FRIENDCLS
    if !known {
      members.push(
        UnknownTail(UnknownFieldTail::{
          kind,
          payload: payload
          .exact_view(start=after_kind, end=payload.length())
          .to_owned(),
        }),
      )
      break
    }
    let (field_item, after_member) = match kind {
      LF_BCLASS => parse_base_class(payload, after_kind)
      LF_VBCLASS => parse_virtual_base_class(payload, after_kind, false)
      LF_IVBCLASS => parse_virtual_base_class(payload, after_kind, true)
      LF_ENUMERATE => parse_enumerated(payload, after_kind)
      LF_MEMBER => parse_data_field(payload, after_kind)
      LF_STMEMBER => parse_static_data_field(payload, after_kind)
      LF_METHOD => parse_overloaded_method(payload, after_kind)
      LF_NESTTYPE => parse_nested_type(payload, after_kind)
      LF_ONEMETHOD => parse_one_method(payload, after_kind)
      LF_VFUNCTAB => parse_vfunction_table(payload, after_kind)
      LF_FRIENDCLS => parse_friend_class(payload, after_kind)
      _ => raise InvalidTypeRecord("unreachable unknown field kind")
    }
    members.push(field_item)
    cursor = skip_field_padding(payload, after_member, payload.length())
    if cursor <= start {
      raise InvalidTypeRecord("field-list member did not advance")
    }
  }
  FieldListType::{ bytes: payload, members, continuation, }
}

///|
fn parse_base_class(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (attributes, cursor) = read_field_attributes(payload, start)
  let (base_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (offset, cursor) = read_numeric_value(payload, cursor, payload.length())
  (BaseClass(BaseClassField::{ attributes, base_type, offset, }), cursor)
}

///|
fn parse_virtual_base_class(
  payload : Bytes,
  start : Int32,
  virtual_inheritance : Bool,
) -> (FieldListMember, Int32) raise TpiError {
  let (attributes, cursor) = read_field_attributes(payload, start)
  let (base_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (vbptr_type, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (vbptr_offset, cursor) = read_numeric_value(
    payload,
    cursor,
    payload.length(),
  )
  let (vtable_index, cursor) = read_numeric_value(
    payload,
    cursor,
    payload.length(),
  )
  (
    VirtualBaseClass(VirtualBaseClassField::{
      virtual_inheritance,
      attributes,
      base_type,
      vbptr_type,
      vbptr_offset,
      vtable_index,
    }),
    cursor,
  )
}

///|
fn parse_enumerated(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (attributes, cursor) = read_field_attributes(payload, start)
  let (value, cursor) = read_numeric_value(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  (Enumerated(EnumeratedField::{ attributes, value, name, }), cursor)
}

///|
fn parse_data_field(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (attributes, cursor) = read_field_attributes(payload, start)
  let (type_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (offset, cursor) = read_numeric_value(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  (Data(DataField::{ attributes, type_index, offset, name, }), cursor)
}

///|
fn parse_static_data_field(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (attributes, cursor) = read_field_attributes(payload, start)
  let (type_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  (StaticData(StaticDataField::{ attributes, type_index, name, }), cursor)
}

///|
fn parse_overloaded_method(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (count, cursor) = read_tpi_u16(payload, start, payload.length())
  let (method_list, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  (
    OverloadedMethod(OverloadedMethodField::{ count, method_list, name, }),
    cursor,
  )
}

///|
fn parse_nested_type(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (padding, cursor) = read_tpi_u16(payload, start, payload.length())
  if padding != 0 {
    raise InvalidTypeRecord("LF_NESTTYPE padding is not zero")
  }
  let (type_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  (NestedType(NestedTypeField::{ type_index, name, }), cursor)
}

///|
fn parse_one_method(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (attributes, cursor) = read_field_attributes(payload, start)
  let (type_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
  let (vtable_offset, cursor) = if attributes.is_introducing_virtual() {
    let (value, next) = read_tpi_u32(payload, cursor, payload.length())
    (Some(value.reinterpret_as_int()), next)
  } else {
    (None, cursor)
  }
  let (name, cursor) = read_tpi_string(payload, cursor, payload.length())
  (
    OneMethod(OneMethodField::{ attributes, type_index, vtable_offset, name, }),
    cursor,
  )
}

///|
fn parse_vfunction_table(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (padding, cursor) = read_tpi_u16(payload, start, payload.length())
  if padding != 0 {
    raise InvalidTypeRecord("LF_VFUNCTAB padding is not zero")
  }
  let (type_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
  (VFunctionTable(VFunctionTableField::{ type_index, }), cursor)
}

///|
fn parse_friend_class(
  payload : Bytes,
  start : Int32,
) -> (FieldListMember, Int32) raise TpiError {
  let (padding, cursor) = read_tpi_u16(payload, start, payload.length())
  if padding != 0 {
    raise InvalidTypeRecord("LF_FRIENDCLS padding is not zero")
  }
  let (type_index, cursor) = read_tpi_u32(payload, cursor, payload.length())
  (FriendClass(FriendClassField::{ type_index, }), cursor)
}

///|
fn read_field_attributes(
  payload : Bytes,
  start : Int32,
) -> (FieldAttributes, Int32) raise TpiError {
  let (raw, cursor) = read_tpi_u16(payload, start, payload.length())
  (FieldAttributes::{ raw, }, cursor)
}

///|
fn skip_field_padding(payload : Bytes, start : Int32, end : Int32) -> Int32 {
  let mut cursor = start
  while cursor < end && payload.at(cursor).to_int() >= 0xF0 {
    cursor = cursor + 1
  }
  cursor
}
