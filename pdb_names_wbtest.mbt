///|
fn pdb_names_test_bytes(signature : UInt32, version : UInt32) -> Bytes {
  let strings = b"\x00src.c\x00file.h\x00"
  let buffer = Buffer::Buffer(size_hint=64)
  buffer.write_uint_le(signature)
  buffer.write_uint_le(version)
  buffer.write_uint_le(strings.length().reinterpret_as_uint())
  buffer.write_bytes(strings.exact_view())
  buffer.write_uint_le(2U)
  buffer.write_uint_le(1U)
  buffer.write_uint_le(7U)
  buffer.write_uint_le(2U)
  buffer.to_bytes()
}

///|
test "parse the PDB names string table" {
  let table = parse_pdb_string_table(
    pdb_names_test_bytes(PDB_STRING_TABLE_SIGNATURE, 1U),
    PdbStringTableLimits::default(),
  )
  assert_eq(table.signature(), PDB_STRING_TABLE_SIGNATURE)
  assert_eq(table.hash_version(), 1U)
  assert_eq(table.name_id_count(), 2)
  assert_eq(table.name_count(), 2U)
  assert_eq(table.string_for_id(1U), Some("src.c"))
  assert_eq(table.string_for_id(7U), Some("file.h"))
}

///|
test "reject malformed PDB names tables" {
  try
    parse_pdb_string_table(
      pdb_names_test_bytes(0U, 1U),
      PdbStringTableLimits::default(),
    )
  catch {
    InvalidPdbStringTable(_) => ()
    _ => fail("unexpected /names signature error")
  } noraise {
    _ => fail("expected an invalid /names signature to be rejected")
  }
  try
    parse_pdb_string_table(
      pdb_names_test_bytes(PDB_STRING_TABLE_SIGNATURE, 3U),
      PdbStringTableLimits::default(),
    )
  catch {
    InvalidPdbStringTable(_) => ()
    _ => fail("unexpected /names version error")
  } noraise {
    _ => fail("expected an unsupported /names version to be rejected")
  }
  let valid = pdb_names_test_bytes(PDB_STRING_TABLE_SIGNATURE, 1U)
  let extra = Buffer::Buffer(size_hint=valid.length() + 1)
  extra.write_bytes(valid.exact_view())
  extra.write_byte(0)
  try
    parse_pdb_string_table(extra.to_bytes(), PdbStringTableLimits::default())
  catch {
    InvalidPdbStringTable(_) => ()
    _ => fail("unexpected /names trailing-byte error")
  } noraise {
    _ => fail("expected trailing /names bytes to be rejected")
  }
}
