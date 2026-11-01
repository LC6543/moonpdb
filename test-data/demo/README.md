# Matching PE/PDB Demo Fixture

This directory contains a small deterministic Windows PE and PDB pair used for
end-to-end source symbolication tests.

- Toolchain: Zig 0.16.0, bundled LLVM/LLD 21.1.0
- Target: `x86_64-windows-gnu`
- Debug format: CodeView with an external PDB
- Source path embedded in the fixture: `/moonpdb/test-data/demo/sample.c`

## Files

- `sample.c`
  - SHA-256: `b237c108d0a2fadce7a2faaa8f5546f1866a40a33d36fd95ff211a498dc302b5`
- `sample-tiny.exe`
  - SHA-256: `8e25ace5f6b49ae475567fcbf03f48ec226de4f608313fa70a7de5ef148c6bf0`
- `sample-tiny.pdb`
  - SHA-256: `3c29be60802689f6ee5aa74172e715e6c14871dba27d1488b9d6c9dac6ae394e`

Run `generate.ps1 -Zig <path-to-zig>` to regenerate the pair. The toolchain is
not vendored into this repository.
