///|
fn pad_tpi_field(buffer : Buffer) -> Unit {
  let padding = (4 - buffer.length() % 4) % 4
  for _ in 0..<padding {
    buffer.write_byte((0xF0 + padding).to_byte())
  }
}

///|
fn tpi_field_list_payload() -> Bytes {
  let payload = Buffer::Buffer(size_hint=220)
  write_test_u16(payload, UInt32(LF_MEMBER.to_uint()))
  write_test_u16(payload, 2U)
  payload.write_uint_le(0x74U)
  write_test_u16(payload, 0x8003U)
  payload.write_uint_le(0U)
  payload.write_bytes(b"x\x00".exact_view())
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_ENUMERATE.to_uint()))
  write_test_u16(payload, 3U)
  write_test_u16(payload, 0x8004U)
  payload.write_uint_le(42U)
  payload.write_bytes(b"answer\x00".exact_view())
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_NESTTYPE.to_uint()))
  write_test_u16(payload, 0U)
  payload.write_uint_le(0x1000U)
  payload.write_bytes(b"Widget\x00".exact_view())
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_METHOD.to_uint()))
  write_test_u16(payload, 1U)
  payload.write_uint_le(0x1206U)
  payload.write_bytes(b"run\x00".exact_view())
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_ONEMETHOD.to_uint()))
  write_test_u16(payload, 0x0010U)
  payload.write_uint_le(0x1008U)
  payload.write_uint_le(8U)
  payload.write_bytes(b"run\x00".exact_view())
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_VFUNCTAB.to_uint()))
  write_test_u16(payload, 0U)
  payload.write_uint_le(0x1002U)
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_FRIENDCLS.to_uint()))
  write_test_u16(payload, 0U)
  payload.write_uint_le(0x1004U)
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_BCLASS.to_uint()))
  write_test_u16(payload, 3U)
  payload.write_uint_le(0x1005U)
  write_test_u16(payload, 0x8003U)
  payload.write_uint_le(0U)
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_VBCLASS.to_uint()))
  write_test_u16(payload, 1U)
  payload.write_uint_le(0x1006U)
  payload.write_uint_le(0x1002U)
  write_test_u16(payload, 0x8003U)
  payload.write_uint_le(0U)
  write_test_u16(payload, 0x8004U)
  payload.write_uint_le(1U)
  pad_tpi_field(payload)
  write_test_u16(payload, UInt32(LF_INDEX.to_uint()))
  write_test_u16(payload, 0U)
  payload.write_uint_le(0x2000U)
  pad_tpi_field(payload)
  payload.to_bytes()
}

///|
test "parse CodeView field-list member records" {
  let list = parse_field_list(tpi_field_list_payload())
  assert_eq(list.member_count(), 9)
  assert_eq(list.continuation(), Some(0x2000U))
  match list.member_at(0).unwrap() {
    Data(value) => {
      assert_eq(value.name(), "x")
      assert_eq(value.type_index(), 0x74U)
      assert_eq(value.offset().as_unsigned(), Some(0UL))
      assert_eq(value.attributes().access(), 2)
    }
    _ => fail("expected LF_MEMBER")
  }
  match list.member_at(1).unwrap() {
    Enumerated(value) => {
      assert_eq(value.name(), "answer")
      assert_eq(value.value().as_unsigned(), Some(42UL))
    }
    _ => fail("expected LF_ENUMERATE")
  }
  match list.member_at(2).unwrap() {
    NestedType(value) => {
      assert_eq(value.name(), "Widget")
      assert_eq(value.type_index(), 0x1000U)
    }
    _ => fail("expected LF_NESTTYPE")
  }
  match list.member_at(3).unwrap() {
    OverloadedMethod(value) => {
      assert_eq(value.name(), "run")
      assert_eq(value.count(), 1)
      assert_eq(value.method_list(), 0x1206U)
    }
    _ => fail("expected LF_METHOD")
  }
  match list.member_at(4).unwrap() {
    OneMethod(value) => {
      assert_eq(value.vtable_offset(), Some(8))
      assert_true(value.attributes().is_introducing_virtual())
    }
    _ => fail("expected LF_ONEMETHOD")
  }
  match list.member_at(5).unwrap() {
    VFunctionTable(value) => assert_eq(value.type_index(), 0x1002U)
    _ => fail("expected LF_VFUNCTAB")
  }
  match list.member_at(6).unwrap() {
    FriendClass(value) => assert_eq(value.type_index(), 0x1004U)
    _ => fail("expected LF_FRIENDCLS")
  }
  match list.member_at(7).unwrap() {
    BaseClass(value) => {
      assert_eq(value.base_type(), 0x1005U)
      assert_eq(value.attributes().access(), 3)
    }
    _ => fail("expected LF_BCLASS")
  }
  match list.member_at(8).unwrap() {
    VirtualBaseClass(value) => {
      assert_eq(value.base_type(), 0x1006U)
      assert_eq(value.vbptr_type(), 0x1002U)
      assert_false(value.virtual_inheritance())
    }
    _ => fail("expected LF_VBCLASS")
  }
}

///|
test "resolve field-list continuation records" {
  let first = Buffer::Buffer(size_hint=32)
  write_test_u16(first, UInt32(LF_MEMBER.to_uint()))
  write_test_u16(first, 2U)
  first.write_uint_le(0x74U)
  write_test_u16(first, 0x8003U)
  first.write_uint_le(0U)
  first.write_bytes(b"a\x00".exact_view())
  pad_tpi_field(first)
  write_test_u16(first, UInt32(LF_INDEX.to_uint()))
  write_test_u16(first, 0U)
  first.write_uint_le(0x1001U)
  pad_tpi_field(first)
  let second = Buffer::Buffer(size_hint=24)
  write_test_u16(second, UInt32(LF_MEMBER.to_uint()))
  write_test_u16(second, 1U)
  second.write_uint_le(0x75U)
  write_test_u16(second, 0x8003U)
  second.write_uint_le(4U)
  second.write_bytes(b"b\x00".exact_view())
  pad_tpi_field(second)
  let records = Buffer::Buffer(size_hint=80)
  write_test_type_record(records, LF_FIELDLIST, first.to_bytes())
  write_test_type_record(records, LF_FIELDLIST, second.to_bytes())
  let table = parse_tpi(
    test_tpi_with_records(records.to_bytes(), 2U),
    TpiLimits::default(),
  )
  let members = table.field_list_members(0x1000U)
  assert_eq(members.length(), 2)
}

///|
test "reject field-list continuation cycles" {
  let first = Buffer::Buffer(size_hint=12)
  write_test_u16(first, UInt32(LF_INDEX.to_uint()))
  write_test_u16(first, 0U)
  first.write_uint_le(0x1001U)
  pad_tpi_field(first)
  let second = Buffer::Buffer(size_hint=12)
  write_test_u16(second, UInt32(LF_INDEX.to_uint()))
  write_test_u16(second, 0U)
  second.write_uint_le(0x1000U)
  pad_tpi_field(second)
  let records = Buffer::Buffer(size_hint=48)
  write_test_type_record(records, LF_FIELDLIST, first.to_bytes())
  write_test_type_record(records, LF_FIELDLIST, second.to_bytes())
  let table = parse_tpi(
    test_tpi_with_records(records.to_bytes(), 2U),
    TpiLimits::default(),
  )
  try table.field_list_members(0x1000U) catch {
    InvalidTypeRecord(_) => ()
    _ => fail("unexpected continuation-cycle error")
  } noraise {
    _ => fail("expected a continuation cycle to be rejected")
  }
}

///|
test "preserve unknown field-list tails" {
  let payload = Buffer::Buffer(size_hint=8)
  write_test_u16(payload, 0x7777U)
  payload.write_bytes(b"tail".exact_view())
  let list = parse_field_list(payload.to_bytes())
  assert_eq(list.member_count(), 1)
  match list.member_at(0).unwrap() {
    UnknownTail(value) => {
      assert_eq(value.kind(), 0x7777)
      assert_eq(value.payload(), b"tail")
    }
    _ => fail("expected unknown field tail")
  }
}
