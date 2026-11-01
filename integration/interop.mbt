///|
/// Read the pinned LLVM PDB fixture.
pub fn read_global_name_pdb() -> Bytes raise @fs.IOError {
  @fs.read_file_to_bytes("test-data/llvm/global-name-lookup.pdb")
}

///|
/// Read the pinned LLVM PE fixture.
pub fn read_llvm_pe() -> Bytes raise @fs.IOError {
  @fs.read_file_to_bytes("test-data/llvm/coff-no-load-config.exe")
}

///|
/// Parse the pinned LLVM PDB fixture.
pub fn parse_fixture_pdb() -> @lib.MsfFile raise @fs.IOError {
  let bytes = read_global_name_pdb()
  @lib.parse_msf(bytes, @lib.MsfLimits::default()) catch {
    _ => raise @fs.IOError("could not parse the pinned PDB fixture")
  }
}

///|
/// Parse the pinned LLVM PE fixture.
pub fn parse_fixture_pe() -> @lib.PeImage raise @fs.IOError {
  let bytes = read_llvm_pe()
  @lib.parse_pe_image(bytes, @lib.PeLimits::default()) catch {
    _ => raise @fs.IOError("could not parse the pinned PE fixture")
  }
}
