///|
fn write_test_u16(buffer : Buffer, value : UInt32) -> Unit {
  buffer.write_byte(value.to_byte())
  buffer.write_byte((value >> 8).to_byte())
}

///|
fn write_test_type_record(
  buffer : Buffer,
  kind : UInt16,
  payload : Bytes,
) -> Unit {
  write_test_u16(buffer, (payload.length() + 2).reinterpret_as_uint())
  write_test_u16(buffer, UInt32(kind.to_uint()))
  buffer.write_bytes(payload.exact_view())
}

///|
fn test_tpi_header(type_record_bytes : Int32, type_count : UInt32) -> Buffer {
  let buffer = Buffer::Buffer(size_hint=TPI_HEADER_SIZE)
  buffer.write_uint_le(20040203U)
  buffer.write_uint_le(TPI_HEADER_SIZE.reinterpret_as_uint())
  buffer.write_uint_le(TPI_TYPE_INDEX_BEGIN)
  buffer.write_uint_le(TPI_TYPE_INDEX_BEGIN + type_count)
  buffer.write_uint_le(type_record_bytes.reinterpret_as_uint())
  write_test_u16(buffer, 0xFFFFU)
  write_test_u16(buffer, 0xFFFFU)
  buffer.write_uint_le(4U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  buffer.write_uint_le(0U)
  buffer
}

///|
fn test_tpi_with_records(records : Bytes, count : UInt32) -> Bytes {
  let buffer = test_tpi_header(records.length(), count)
  buffer.write_bytes(records.exact_view())
  buffer.to_bytes()
}

///|
fn test_modifier_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=6)
  payload.write_uint_le(0x74U)
  write_test_u16(payload, 0x0001U)
  payload.to_bytes()
}

///|
fn test_pointer_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=8)
  payload.write_uint_le(0x74U)
  payload.write_uint_le(0x0001040CU)
  payload.to_bytes()
}

///|
fn test_arg_list_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=12)
  payload.write_uint_le(2U)
  payload.write_uint_le(0x74U)
  payload.write_uint_le(0x75U)
  payload.to_bytes()
}

///|
fn test_bitfield_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=6)
  payload.write_uint_le(0x74U)
  payload.write_byte(3)
  payload.write_byte(5)
  payload.to_bytes()
}

///|
fn test_array_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=17)
  payload.write_uint_le(0x74U)
  payload.write_uint_le(0x23U)
  write_test_u16(payload, 0x8004U)
  payload.write_uint_le(16U)
  payload.write_bytes(b"values\x00".exact_view())
  payload.to_bytes()
}

///|
fn test_aggregate_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=32)
  write_test_u16(payload, 2U)
  write_test_u16(payload, 0x0200U)
  payload.write_uint_le(0x1003U)
  payload.write_uint_le(0U)
  payload.write_uint_le(0U)
  write_test_u16(payload, 0x8002U)
  write_test_u16(payload, 32U)
  payload.write_bytes(b"Widget\x00??@Widget\x00".exact_view())
  payload.to_bytes()
}

///|
fn test_combined_type_records() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=128)
  write_test_type_record(buffer, LF_MODIFIER, test_modifier_payload())
  write_test_type_record(buffer, LF_POINTER, test_pointer_payload())
  write_test_type_record(buffer, LF_ARGLIST, test_arg_list_payload())
  write_test_type_record(buffer, LF_BITFIELD, test_bitfield_payload())
  write_test_type_record(buffer, LF_ARRAY, test_array_payload())
  write_test_type_record(buffer, LF_STRUCTURE, test_aggregate_payload())
  write_test_type_record(buffer, 0x7777, b"opaque")
  buffer.to_bytes()
}

///|
test "parse TPI header and indexed records" {
  let records = test_combined_type_records()
  let data = test_tpi_with_records(records, 7U)
  let table = parse_tpi(data, TpiLimits::default())
  assert_eq(table.record_count(), 7)
  assert_eq(table.header().version(), 20040203U)
  assert_eq(table.header().type_index_begin(), 0x1000U)
  assert_eq(table.header().type_index_end(), 0x1007U)
  assert_eq(table.header().type_record_count(), 7U)
  match table.record_at(-1) {
    None => ()
    Some(_) => fail("expected a negative record position to be rejected")
  }
  match table.record_at(7) {
    None => ()
    Some(_) => fail("expected an out-of-range record position to be rejected")
  }
  assert_eq(table.record(0x1000U).unwrap().kind(), LF_MODIFIER)
  assert_eq(table.record(0x1006U).unwrap().type_index(), 0x1006U)
  match table.record(0x1007U) {
    None => ()
    Some(_) => fail("expected an invalid type index to return None")
  }
}

///|
test "decode common CodeView type records" {
  let table = parse_tpi(
    test_tpi_with_records(test_combined_type_records(), 7U),
    TpiLimits::default(),
  )
  match table.record(0x1000U).unwrap().details() {
    Modifier(value) => {
      assert_eq(value.modified_type(), 0x74U)
      assert_true(value.is_const())
      assert_false(value.is_volatile())
    }
    _ => fail("expected modifier record")
  }
  match table.record(0x1001U).unwrap().details() {
    Pointer(value) => {
      assert_eq(value.referent_type(), 0x74U)
      assert_eq(value.kind(), 0x0CU)
      assert_eq(value.byte_size(), 8)
      assert_true(value.is_const())
    }
    _ => fail("expected pointer record")
  }
  match table.record(0x1002U).unwrap().details() {
    ArgList(value) => {
      assert_eq(value.count(), 2)
      assert_eq(value.type_index(0), Some(0x74U))
      assert_eq(value.type_index(1), Some(0x75U))
    }
    _ => fail("expected argument-list record")
  }
  match table.record(0x1003U).unwrap().details() {
    BitField(value) => {
      assert_eq(value.underlying_type(), 0x74U)
      assert_eq(value.bit_size(), 3)
      assert_eq(value.bit_offset(), 5)
    }
    _ => fail("expected bit-field record")
  }
  match table.record(0x1004U).unwrap().details() {
    Array(value) => {
      assert_eq(value.element_type(), 0x74U)
      assert_eq(value.index_type(), 0x23U)
      assert_eq(value.name(), "values")
      assert_eq(value.size().as_unsigned(), Some(16UL))
    }
    _ => fail("expected array record")
  }
  match table.record(0x1005U).unwrap().details() {
    Aggregate(value) => {
      assert_eq(value.leaf_kind(), LF_STRUCTURE)
      assert_eq(value.member_count(), 2)
      assert_eq(value.field_list(), 0x1003U)
      assert_eq(value.name(), "Widget")
      assert_eq(value.unique_name(), Some("??@Widget"))
      assert_true(value.has_unique_name())
      assert_eq(value.size().as_unsigned(), Some(32UL))
    }
    _ => fail("expected aggregate record")
  }
  match table.record(0x1006U).unwrap().details() {
    Unknown(value) => {
      assert_eq(value.kind(), 0x7777)
      assert_eq(value.payload(), b"opaque")
    }
    _ => fail("expected unknown record preservation")
  }
}

///|
test "classify simple type indices" {
  match simple_type(0x74U) {
    Some(value) => {
      assert_eq(value.name(), "int32")
      assert_eq(value.byte_size(), 4)
      match value.mode() {
        Direct => ()
        _ => fail("expected direct int32")
      }
    }
    None => fail("expected simple int32")
  }
  match simple_type(0x0574U) {
    Some(value) => {
      assert_true(value.is_pointer())
      match value.mode() {
        FarPointer32 => ()
        _ => fail("expected 16:32 pointer mode")
      }
    }
    None => fail("expected simple pointer")
  }
  match simple_type(0x1000U) {
    None => ()
    Some(_) => fail("expected a type-stream index not to be simple")
  }
}

///|
test "reject malformed TPI framing" {
  let record = test_combined_type_records()
  let wrong_count = test_tpi_with_records(record, 8U)
  try parse_tpi(wrong_count, TpiLimits::default()) catch {
    InvalidTypeRecord(_) => ()
    _ => fail("unexpected TPI count error")
  } noraise {
    _ => fail("expected a type-count mismatch to be rejected")
  }
  let truncated_record = Buffer::Buffer(size_hint=8)
  write_test_u16(truncated_record, 10U)
  write_test_u16(truncated_record, LF_MODIFIER.to_uint())
  write_test_u16(truncated_record, 0U)
  let bad_bytes = test_tpi_with_records(truncated_record.to_bytes(), 1U)
  try parse_tpi(bad_bytes, TpiLimits::default()) catch {
    TruncatedTpi(_) => ()
    _ => fail("unexpected truncated TPI error")
  } noraise {
    _ => fail("expected a truncated record to be rejected")
  }
}

///|
test "enforce TPI record and stream limits" {
  let data = test_tpi_with_records(test_combined_type_records(), 7U)
  let record_limits = TpiLimits::{
    max_stream_bytes: 1024,
    max_records: 1,
    max_record_bytes: 1024,
    max_type_refs: 1024,
  }
  try parse_tpi(data, record_limits) catch {
    TpiLimitExceeded(_) => ()
    _ => fail("unexpected record-count limit error")
  } noraise {
    _ => fail("expected the record-count limit to be enforced")
  }
  let stream_limits = TpiLimits::{
    max_stream_bytes: 16,
    max_records: 10,
    max_record_bytes: 1024,
    max_type_refs: 1024,
  }
  try parse_tpi(data, stream_limits) catch {
    TpiLimitExceeded(_) => ()
    _ => fail("unexpected stream-size limit error")
  } noraise {
    _ => fail("expected the stream-size limit to be enforced")
  }
}
