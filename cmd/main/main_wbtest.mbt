///|
test "parse CLI numbers in decimal and hexadecimal" {
  assert_eq(parse_uint64("0"), Some(0UL))
  assert_eq(parse_uint64("4096"), Some(4096UL))
  assert_eq(parse_uint64("0x1000"), Some(4096UL))
  assert_eq(parse_uint64("0XFF"), Some(255UL))
  assert_eq(parse_uint64("0x"), None)
  assert_eq(parse_uint64("12xz"), None)
  assert_eq(parse_uint64(""), None)
}

///|
test "parse CLI output limits" {
  assert_eq(optional_limit(["moonpdb", "types", "a.pdb"], 3), 100)
  assert_eq(optional_limit(["moonpdb", "types", "a.pdb", "5"], 3), 5)
  assert_eq(optional_limit(["moonpdb", "types", "a.pdb", "0x10"], 3), 16)
  try optional_limit(["moonpdb", "types", "a.pdb", "0"], 3) catch {
    CliError(_) => ()
  } noraise {
    _ => fail("expected zero limit to be rejected")
  }
  try optional_limit(["moonpdb", "types", "a.pdb", "bad"], 3) catch {
    CliError(_) => ()
  } noraise {
    _ => fail("expected invalid limit to be rejected")
  }
}
