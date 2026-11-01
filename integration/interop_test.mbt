///|
test "parse the real LLVM PDB and query public names" {
  let msf = @integration.parse_fixture_pdb()
  assert_eq(msf.stream_count(), 15)
  let info = msf.pdb_info(@lib.PdbInfoLimits::default())
  assert_eq(info.version(), 20000404U)
  assert_eq(info.age(), 1U)
  assert_eq(info.guid_string(), "d1069da9-aff4-4af7-ab5c-c98419e4a83d")
  assert_eq(info.named_stream_index("/names"), Some(13))
  assert_eq(info.named_stream_index("/LinkInfo"), Some(5))
  let dbi = msf.dbi(@lib.DbiLimits::default())
  assert_eq(dbi.module_count(), 2)
  let tpi = msf.tpi(@lib.TpiLimits::default())
  assert_eq(tpi.record_count(), 13)
  let symbols = msf.symbol_record_stream(dbi, @lib.SymbolLimits::default())
  assert_eq(symbols.record_count(), 13)
  let publics = msf.publics_stream(dbi, @lib.SymbolLimits::default())
  assert_eq(publics.public_symbol_count(), 6)
  let main_public = publics.find_public_exact(1, 160).unwrap()
  assert_eq(main_public.name(), "main")
  let globals = msf.globals_stream(dbi, @lib.SymbolLimits::default())
  assert_eq(globals.find_records_by_name("main").length(), 1)
  assert_eq(globals.find_records_by_name("OvlGlobalFn").length(), 3)
}

///|
test "parse a real PE32+ image and map a section offset" {
  let image = @integration.parse_fixture_pe()
  assert_true(image.section_count() > 0)
  let mapped = image.map_segment_offset(1, 0).unwrap()
  assert_eq(mapped.segment(), 1)
  assert_true(mapped.rva() >= image.section_at(0).unwrap().virtual_address())
}

///|
test "symbolicate a matching generated PE and PDB to source" {
  let pdb = @integration.read_demo_pdb()
  let pe_bytes = @integration.read_demo_pe()
  let msf = @lib.parse_msf(pdb, @lib.MsfLimits::default())
  let pe = @lib.parse_pe_image(pe_bytes, @lib.PeLimits::default())
  let dbi = msf.dbi(@lib.DbiLimits::default())
  let publics = msf.publics_stream(dbi, @lib.SymbolLimits::default())
  let info = msf.pdb_info(@lib.PdbInfoLimits::default())
  let names = msf.pdb_string_table(
    info,
    "/names",
    @lib.PdbStringTableLimits::default(),
  )
  assert_true(names.name_id_count() > 0)
  let c13 = msf.module_c13_info(
    dbi,
    0,
    @lib.SymbolLimits::default(),
    @lib.C13Limits::default(),
  )
  let result = @lib.symbolicate_address(pe, publics, [c13], 1, 0).unwrap()
  assert_eq(result.public_symbol().unwrap().name(), "moonpdb_add")
  let source = result.source().unwrap()
  assert_true(source.file_path().contains("sample.c"))
  assert_eq(source.line_start(), 4U)
}
