///|
test "combine PE, public symbols, and C13 source lines" {
  let pe = parse_pe_image(
    pe_test_image(true, PE_OPTIONAL_MAGIC_PE32_PLUS.to_uint(), 2U),
    PeLimits::default(),
  )
  let symbols = publics_test_symbol_table()
  let publics = parse_publics_stream(
    publics_test_stream(symbols, GSI_VERSION, true, true),
    symbols,
    SymbolLimits::default(),
  )
  let c13 = parse_c13_debug_info(
    c13_test_stream(true, true, 0U),
    C13Limits::default(),
  )
  let result = symbolicate_address(pe, publics, [c13], 1, 0x1005U).unwrap()
  assert_eq(result.section_name(), ".text")
  assert_eq(result.rva(), 0x2005U)
  assert_eq(result.image_address(), 0x0000000140002005UL)
  assert_eq(result.public_symbol().unwrap().name(), "second")
  assert_eq(result.source().unwrap().file_path(), "src/main.cpp")
  assert_eq(result.source().unwrap().line_start(), 10U)
}

///|
test "symbolicate address batches and skip unmapped addresses" {
  let pe = parse_pe_image(
    pe_test_image(true, PE_OPTIONAL_MAGIC_PE32_PLUS.to_uint(), 2U),
    PeLimits::default(),
  )
  let symbols = publics_test_symbol_table()
  let publics = parse_publics_stream(
    publics_test_stream(symbols, GSI_VERSION, true, true),
    symbols,
    SymbolLimits::default(),
  )
  let c13 = parse_c13_debug_info(
    c13_test_stream(true, true, 0U),
    C13Limits::default(),
  )
  let report = symbolicate_addresses(pe, publics, [c13], [
    (1, 0x1018U),
    (3, 0x10U),
    (1, 0x1022U),
  ])
  assert_eq(report.length(), 2)
  assert_eq(report[0].source().unwrap().line_start(), 12U)
  assert_eq(report[1].source().unwrap().line_start(), 20U)
  assert_eq(report[1].rva(), 0x2022U)
}
