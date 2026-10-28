///|
fn write_symbol_u8(buffer : Buffer, value : UInt32) -> Unit {
  buffer.write_byte(value.to_byte())
}

///|
fn write_symbol_u16(buffer : Buffer, value : UInt32) -> Unit {
  buffer.write_byte(value.to_byte())
  buffer.write_byte((value >> 8).to_byte())
}

///|
fn write_symbol_u32(buffer : Buffer, value : UInt32) -> Unit {
  buffer.write_uint_le(value)
}

///|
fn write_symbol_record(buffer : Buffer, kind : UInt16, payload : Bytes) -> Unit {
  let padding = (4 - (4 + payload.length()) % 4) % 4
  write_symbol_u16(
    buffer,
    (2 + payload.length() + padding).reinterpret_as_uint(),
  )
  write_symbol_u16(buffer, kind.to_uint())
  buffer.write_bytes(payload.exact_view())
  for _ in 0..<padding {
    buffer.write_byte(0)
  }
}

///|
fn symbol_test_public() -> Bytes {
  let payload = Buffer::Buffer(size_hint=16)
  write_symbol_u32(payload, 0x00000002U)
  write_symbol_u32(payload, 0x1234U)
  write_symbol_u16(payload, 1U)
  payload.write_bytes(b"main\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_data() -> Bytes {
  let payload = Buffer::Buffer(size_hint=18)
  write_symbol_u32(payload, 0x74U)
  write_symbol_u32(payload, 0x200U)
  write_symbol_u16(payload, 2U)
  payload.write_bytes(b"counter\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_procedure() -> Bytes {
  let payload = Buffer::Buffer(size_hint=44)
  write_symbol_u32(payload, 0U)
  write_symbol_u32(payload, 4U)
  write_symbol_u32(payload, 8U)
  write_symbol_u32(payload, 0x100U)
  write_symbol_u32(payload, 10U)
  write_symbol_u32(payload, 20U)
  write_symbol_u32(payload, 0x1000U)
  write_symbol_u32(payload, 0x300U)
  write_symbol_u16(payload, 1U)
  write_symbol_u8(payload, 0x80U)
  payload.write_bytes(b"run\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_thunk() -> Bytes {
  let payload = Buffer::Buffer(size_hint=28)
  write_symbol_u32(payload, 0U)
  write_symbol_u32(payload, 4U)
  write_symbol_u32(payload, 8U)
  write_symbol_u32(payload, 0x400U)
  write_symbol_u16(payload, 1U)
  write_symbol_u16(payload, 5U)
  write_symbol_u8(payload, 2U)
  payload.write_bytes(b"thunk\x00".exact_view())
  payload.write_byte(0xAA)
  payload.to_bytes()
}

///|
fn symbol_test_block() -> Bytes {
  let payload = Buffer::Buffer(size_hint=26)
  write_symbol_u32(payload, 0U)
  write_symbol_u32(payload, 4U)
  write_symbol_u32(payload, 0x20U)
  write_symbol_u32(payload, 0x500U)
  write_symbol_u16(payload, 1U)
  payload.write_bytes(b"block\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_label() -> Bytes {
  let payload = Buffer::Buffer(size_hint=14)
  write_symbol_u32(payload, 0x600U)
  write_symbol_u16(payload, 1U)
  write_symbol_u8(payload, 0U)
  payload.write_bytes(b"label\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_constant() -> Bytes {
  let payload = Buffer::Buffer(size_hint=16)
  write_symbol_u32(payload, 0x74U)
  write_symbol_u16(payload, 0x8003U)
  write_symbol_u32(payload, 42U)
  payload.write_bytes(b"answer\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_udt() -> Bytes {
  let payload = Buffer::Buffer(size_hint=12)
  write_symbol_u32(payload, 0x1000U)
  payload.write_bytes(b"Widget\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_object() -> Bytes {
  let payload = Buffer::Buffer(size_hint=12)
  write_symbol_u32(payload, 0xCAFEU)
  payload.write_bytes(b"a.obj\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_bp() -> Bytes {
  let payload = Buffer::Buffer(size_hint=16)
  write_symbol_u32(payload, 0xFFFFFFF0U)
  write_symbol_u32(payload, 0x74U)
  payload.write_bytes(b"local\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_reg() -> Bytes {
  let payload = Buffer::Buffer(size_hint=18)
  write_symbol_u32(payload, 0x18U)
  write_symbol_u32(payload, 0x74U)
  write_symbol_u16(payload, 7U)
  payload.write_bytes(b"reglocal\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_proc_ref() -> Bytes {
  let payload = Buffer::Buffer(size_hint=20)
  write_symbol_u32(payload, 0x12345678U)
  write_symbol_u32(payload, 0x80U)
  write_symbol_u16(payload, 3U)
  payload.write_bytes(b"refproc\x00".exact_view())
  payload.to_bytes()
}

///|
fn symbol_test_frame_proc() -> Bytes {
  let payload = Buffer::Buffer(size_hint=26)
  write_symbol_u32(payload, 0x80U)
  write_symbol_u32(payload, 0x10U)
  write_symbol_u32(payload, 0x20U)
  write_symbol_u32(payload, 0x30U)
  write_symbol_u32(payload, 0x40U)
  write_symbol_u16(payload, 1U)
  write_symbol_u32(payload, 0x55U)
  payload.to_bytes()
}

///|
fn symbol_test_stream() -> Bytes {
  let buffer = Buffer::Buffer(size_hint=256)
  write_symbol_record(buffer, S_PUB32, symbol_test_public())
  write_symbol_record(buffer, S_GDATA32, symbol_test_data())
  write_symbol_record(buffer, S_GPROC32, symbol_test_procedure())
  write_symbol_record(buffer, S_THUNK32, symbol_test_thunk())
  write_symbol_record(buffer, S_BLOCK32, symbol_test_block())
  write_symbol_record(buffer, S_LABEL32, symbol_test_label())
  write_symbol_record(buffer, S_CONSTANT, symbol_test_constant())
  write_symbol_record(buffer, S_UDT, symbol_test_udt())
  write_symbol_record(buffer, S_OBJNAME, symbol_test_object())
  write_symbol_record(buffer, S_BPREL32, symbol_test_bp())
  write_symbol_record(buffer, S_REGREL32, symbol_test_reg())
  write_symbol_record(buffer, S_PROCREF, symbol_test_proc_ref())
  write_symbol_record(buffer, S_FRAMEPROC, symbol_test_frame_proc())
  write_symbol_record(buffer, S_END, b"")
  write_symbol_record(buffer, 0x7777, b"opaque-symbol")
  buffer.to_bytes()
}

///|
test "parse common CodeView symbol records" {
  let table = parse_symbols(symbol_test_stream(), SymbolLimits::default())
  assert_eq(table.record_count(), 15)
  match table.record_at(-1) {
    None => ()
    Some(_) => fail("expected a negative symbol position to be rejected")
  }
  let first = table.record_at(0).unwrap()
  assert_eq(first.kind(), S_PUB32)
  match first.details() {
    Public(value) => {
      assert_eq(value.flags(), 2U)
      assert_eq(value.offset(), 0x1234U)
      assert_eq(value.segment(), 1)
      assert_eq(value.name(), "main")
    }
    _ => fail("expected public symbol")
  }
  match table.record_at(1).unwrap().details() {
    Data(value) => {
      assert_eq(value.type_index(), 0x74U)
      assert_eq(value.offset(), 0x200U)
      assert_eq(value.name(), "counter")
    }
    _ => fail("expected data symbol")
  }
  match table.record_at(2).unwrap().details() {
    Procedure(value) => {
      assert_eq(value.code_size(), 0x100U)
      assert_eq(value.function_type(), 0x1000U)
      assert_eq(value.code_offset(), 0x300U)
      assert_eq(value.flags(), 0x80)
      assert_eq(value.name(), "run")
    }
    _ => fail("expected procedure symbol")
  }
  match table.record_at(3).unwrap().details() {
    Thunk(value) => {
      assert_eq(value.offset(), 0x400U)
      assert_eq(value.length(), 5)
      assert_eq(value.ordinal(), 2)
      assert_eq(value.name(), "thunk")
      assert_eq(value.variant_bytes(), b"\xaa")
    }
    _ => fail("expected thunk symbol")
  }
  match table.record_at(4).unwrap().details() {
    Block(value) => {
      assert_eq(value.code_size(), 0x20U)
      assert_eq(value.code_offset(), 0x500U)
      assert_eq(value.name(), "block")
    }
    _ => fail("expected block symbol")
  }
  match table.record_at(5).unwrap().details() {
    Label(value) => {
      assert_eq(value.code_offset(), 0x600U)
      assert_eq(value.name(), "label")
    }
    _ => fail("expected label symbol")
  }
  match table.record_at(6).unwrap().details() {
    Constant(value) => {
      assert_eq(value.type_index(), 0x74U)
      assert_eq(value.value().as_signed(), Some(42L))
      assert_eq(value.name(), "answer")
    }
    _ => fail("expected constant symbol")
  }
  match table.record_at(7).unwrap().details() {
    Udt(value) => {
      assert_eq(value.type_index(), 0x1000U)
      assert_eq(value.name(), "Widget")
    }
    _ => fail("expected UDT symbol")
  }
  match table.record_at(8).unwrap().details() {
    ObjectName(value) => {
      assert_eq(value.signature(), 0xCAFEU)
      assert_eq(value.name(), "a.obj")
    }
    _ => fail("expected object-name symbol")
  }
  match table.record_at(9).unwrap().details() {
    BPRelative(value) => {
      assert_eq(value.offset(), -16)
      assert_eq(value.name(), "local")
    }
    _ => fail("expected BP-relative symbol")
  }
  match table.record_at(10).unwrap().details() {
    RegRelative(value) => {
      assert_eq(value.offset(), 0x18U)
      assert_eq(value.register(), 7)
      assert_eq(value.name(), "reglocal")
    }
    _ => fail("expected register-relative symbol")
  }
  match table.record_at(11).unwrap().details() {
    ProcedureReference(value) => {
      assert_eq(value.symbol_offset(), 0x80U)
      assert_eq(value.module_index(), 3)
      assert_eq(value.name(), "refproc")
    }
    _ => fail("expected procedure-reference symbol")
  }
  match table.record_at(12).unwrap().details() {
    FrameProcedure(value) => {
      assert_eq(value.total_frame_bytes(), 0x80U)
      assert_eq(value.exception_handler_section(), 1)
      assert_eq(value.flags(), 0x55U)
    }
    _ => fail("expected frame-procedure symbol")
  }
  match table.record_at(13).unwrap().details() {
    ScopeEnd => ()
    _ => fail("expected scope-end symbol")
  }
  match table.record_at(14).unwrap().details() {
    Unknown(value) => {
      assert_eq(value.kind(), 0x7777)
      assert_eq(value.payload(), b"opaque-symbol\x00\x00\x00")
    }
    _ => fail("expected unknown symbol preservation")
  }
}

///|
test "look up symbols by byte offset" {
  let table = parse_symbols(symbol_test_stream(), SymbolLimits::default())
  let first = table.record_at(0).unwrap()
  let second = table.record_at(1).unwrap()
  assert_eq(table.record_at_offset(first.offset()).unwrap().kind(), S_PUB32)
  assert_eq(table.record_at_offset(second.offset()).unwrap().kind(), S_GDATA32)
  match table.record_at_offset(-1) {
    None => ()
    Some(_) => fail("expected a negative symbol offset to be rejected")
  }
}

///|
fn symbol_test_module_stream() -> Bytes {
  let symbols = symbol_test_stream()
  let c13 = b"c13-lines"
  let stream = Buffer::Buffer(size_hint=300)
  write_symbol_u32(stream, CV_SIGNATURE_C13)
  stream.write_bytes(symbols.exact_view())
  stream.write_bytes(c13.exact_view())
  write_symbol_u32(stream, 2U)
  write_symbol_u32(stream, 0x1000U)
  write_symbol_u32(stream, 0x2000U)
  stream.to_bytes()
}

///|
test "parse module debug stream sections" {
  let data = symbol_test_module_stream()
  let symbols = symbol_test_stream()
  let stream = parse_module_debug_stream(
    data,
    (4 + symbols.length()).reinterpret_as_uint(),
    0U,
    9U,
    SymbolLimits::default(),
  )
  assert_eq(stream.signature(), CV_SIGNATURE_C13)
  assert_eq(stream.symbols().record_count(), 15)
  assert_eq(stream.c11_lines(), b"")
  assert_eq(stream.c13_lines(), b"c13-lines")
  assert_eq(stream.global_refs(), [0x1000U, 0x2000U])
}

///|
test "reject malformed symbol records" {
  let truncated = Buffer::Buffer(size_hint=8)
  write_symbol_u16(truncated, 20U)
  write_symbol_u16(truncated, S_PUB32.to_uint())
  try parse_symbols(truncated.to_bytes(), SymbolLimits::default()) catch {
    TruncatedSymbol(_) => ()
    _ => fail("unexpected truncated symbol error")
  } noraise {
    _ => fail("expected a truncated symbol record to be rejected")
  }
  let misaligned = Buffer::Buffer(size_hint=8)
  write_symbol_u16(misaligned, 3U)
  write_symbol_u16(misaligned, 0x7777U)
  misaligned.write_byte(0)
  try parse_symbols(misaligned.to_bytes(), SymbolLimits::default()) catch {
    InvalidSymbolRecord(_) => ()
    _ => fail("unexpected symbol-alignment error")
  } noraise {
    _ => fail("expected an unaligned symbol record to be rejected")
  }
}

///|
test "reject malformed module debug streams" {
  let symbols = symbol_test_stream()
  let bad_signature = Buffer::Buffer(size_hint=128)
  write_symbol_u32(bad_signature, 5U)
  bad_signature.write_bytes(symbols.exact_view())
  try
    parse_module_debug_stream(
      bad_signature.to_bytes(),
      (4 + symbols.length()).reinterpret_as_uint(),
      0U,
      0U,
      SymbolLimits::default(),
    )
  catch {
    UnsupportedModuleSignature(5) => ()
    _ => fail("unexpected module-signature error")
  } noraise {
    _ => fail("expected an unsupported module signature to be rejected")
  }
  let both_lines = Buffer::Buffer(size_hint=32)
  write_symbol_u32(both_lines, CV_SIGNATURE_C13)
  try
    parse_module_debug_stream(
      both_lines.to_bytes(),
      4U,
      4U,
      4U,
      SymbolLimits::default(),
    )
  catch {
    InvalidModuleStream(_) => ()
    _ => fail("unexpected C11/C13 conflict error")
  } noraise {
    _ => fail("expected simultaneous C11 and C13 data to be rejected")
  }
}

///|
test "enforce symbol stream limits" {
  let limits = SymbolLimits::{
    max_stream_bytes: 4096,
    max_records: 1,
    max_record_bytes: 4096,
    max_global_refs: 10,
    max_hash_records: 10,
    max_public_symbols: 10,
  }
  try parse_symbols(symbol_test_stream(), limits) catch {
    SymbolLimitExceeded(_) => ()
    _ => fail("unexpected symbol-count limit error")
  } noraise {
    _ => fail("expected the symbol-count limit to be enforced")
  }
}
