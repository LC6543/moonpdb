///|
fn write_pe_zeros(buffer : Buffer, count : Int32) -> Unit {
  for _ in 0..<count {
    buffer.write_byte(0)
  }
}

///|
fn write_pe_section(
  buffer : Buffer,
  name : Bytes,
  virtual_size : UInt32,
  virtual_address : UInt32,
  raw_size : UInt32,
  raw_pointer : UInt32,
  characteristics : UInt32,
) -> Unit {
  buffer.write_bytes(name.exact_view())
  write_pe_zeros(buffer, 8 - name.length())
  write_symbol_u32(buffer, virtual_size)
  write_symbol_u32(buffer, virtual_address)
  write_symbol_u32(buffer, raw_size)
  write_symbol_u32(buffer, raw_pointer)
  write_symbol_u32(buffer, 0U)
  write_symbol_u32(buffer, 0U)
  write_symbol_u16(buffer, 0U)
  write_symbol_u16(buffer, 0U)
  write_symbol_u32(buffer, characteristics)
}

///|
fn pe_test_image(
  pe32_plus : Bool,
  optional_magic : UInt32,
  section_count : UInt32,
) -> Bytes {
  let optional_size = if pe32_plus { 240 } else { 224 }
  let pe_offset = 0x80
  let buffer = Buffer::Buffer(size_hint=0x200)
  buffer.write_bytes(b"MZ".exact_view())
  write_pe_zeros(buffer, 58)
  write_symbol_u32(buffer, 0x80U)
  write_pe_zeros(buffer, pe_offset - DOS_HEADER_SIZE)
  buffer.write_bytes(b"PE\x00\x00".exact_view())
  write_symbol_u16(buffer, 0x8664U)
  write_symbol_u16(buffer, section_count)
  write_symbol_u32(buffer, 0x12345678U)
  write_symbol_u32(buffer, 0U)
  write_symbol_u32(buffer, 0U)
  write_symbol_u16(buffer, optional_size.reinterpret_as_uint())
  write_symbol_u16(buffer, 0x0022U)
  write_symbol_u16(buffer, optional_magic)
  write_pe_zeros(buffer, if pe32_plus { 22 } else { 26 })
  if pe32_plus {
    write_symbol_u32(buffer, 0x40000000U)
    write_symbol_u32(buffer, 0x00000001U)
  } else {
    write_symbol_u32(buffer, 0x00400000U)
  }
  write_pe_zeros(buffer, optional_size - 32)
  write_pe_section(
    buffer, b".text", 0x2000U, 0x1000U, 0x1800U, 0x400U, 0x60000020U,
  )
  if section_count >= 2U {
    write_pe_section(
      buffer, b".rdata", 0x1000U, 0x3000U, 0x800U, 0x1C00U, 0x40000040U,
    )
  }
  buffer.to_bytes()
}

///|
test "parse PE32+ headers and map section offsets" {
  let image = parse_pe_image(
    pe_test_image(true, PE_OPTIONAL_MAGIC_PE32_PLUS.to_uint(), 2U),
    PeLimits::default(),
  )
  assert_eq(image.machine(), 0x8664)
  assert_eq(image.section_count(), 2)
  assert_eq(image.optional_magic(), PE_OPTIONAL_MAGIC_PE32_PLUS)
  assert_eq(image.image_base(), 0x0000000140000000UL)
  let text = image.section_at(0).unwrap()
  assert_eq(text.name(), ".text")
  assert_eq(text.virtual_address(), 0x1000U)
  assert_eq(text.virtual_span(), 0x2000U)
  let mapped = image.map_segment_offset(1, 0x105U).unwrap()
  assert_eq(mapped.segment(), 1)
  assert_eq(mapped.section_name(), ".text")
  assert_eq(mapped.section_offset(), 0x105U)
  assert_eq(mapped.rva(), 0x1105U)
  assert_eq(mapped.image_address(), 0x0000000140001105UL)
  let second = image.map_segment_offset(2, 0x20U).unwrap()
  assert_eq(second.rva(), 0x3020U)
  match image.map_segment_offset(0, 0U) {
    None => ()
    Some(_) => fail("expected segment zero to be invalid")
  }
  match image.map_segment_offset(1, 0x2000U) {
    None => ()
    Some(_) => fail("expected an offset outside the section to be invalid")
  }
}

///|
test "parse PE32 image base" {
  let image = parse_pe_image(
    pe_test_image(false, PE_OPTIONAL_MAGIC_PE32.to_uint(), 1U),
    PeLimits::default(),
  )
  assert_eq(image.optional_magic(), PE_OPTIONAL_MAGIC_PE32)
  assert_eq(image.image_base(), 0x00400000UL)
  assert_eq(image.section_count(), 1)
}

///|
test "reject malformed PE images" {
  try parse_pe_image(b"short", PeLimits::default()) catch {
    TooSmallPe(_) => ()
    _ => fail("unexpected short PE error")
  } noraise {
    _ => fail("expected a short PE file to be rejected")
  }
  let bad_dos = Buffer::Buffer(size_hint=64)
  bad_dos.write_bytes(b"ZZ".exact_view())
  write_pe_zeros(bad_dos, 62)
  try parse_pe_image(bad_dos.to_bytes(), PeLimits::default()) catch {
    BadDosMagic => ()
    _ => fail("unexpected DOS magic error")
  } noraise {
    _ => fail("expected a bad DOS magic to be rejected")
  }
  let unsupported = pe_test_image(true, 0x9999U, 1U)
  try parse_pe_image(unsupported, PeLimits::default()) catch {
    UnsupportedPeOptionalHeader(0x9999) => ()
    _ => fail("unexpected PE optional-header error")
  } noraise {
    _ => fail("expected an unsupported PE optional header to be rejected")
  }
  let limits = PeLimits::{ max_file_bytes: 4096, max_sections: 1, }
  try
    parse_pe_image(
      pe_test_image(true, PE_OPTIONAL_MAGIC_PE32_PLUS.to_uint(), 2U),
      limits,
    )
  catch {
    PeLimitExceeded(_) => ()
    _ => fail("unexpected PE section limit error")
  } noraise {
    _ => fail("expected the PE section limit to be enforced")
  }
}
