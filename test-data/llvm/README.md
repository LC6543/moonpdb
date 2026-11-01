# LLVM Interoperability Fixtures

These files are copied unmodified from the LLVM project for reproducible
interoperability tests.

- Upstream: https://github.com/llvm/llvm-project
- Upstream commit: `4575c053e0519b968ad6117b5df4d248326725a7`
- Upstream license: Apache-2.0 WITH LLVM-exception, see `LICENSE.TXT`

## Files

- `global-name-lookup.pdb`
  - Source: `llvm/test/DebugInfo/PDB/Inputs/global-name-lookup.pdb`
  - SHA-256: `171ca72c32f8bef8ec832a4e26939d5fc2db4fa6ff78a347cbc9aaf3835188fc`
- `global-name-lookup.cpp`
  - Source: `llvm/test/DebugInfo/PDB/Inputs/global-name-lookup.cpp`
  - SHA-256: `d4ee0e29d3be6567ff9462d5337a8dd174dcebc93ed6cb47425af372f1699e8a`
- `coff-no-load-config.exe`
  - Source: `llvm/test/tools/llvm-readobj/COFF/Inputs/coff-no-load-config.exe`
  - SHA-256: `958015158f771792a3573394ec90357d5280ac4d1a129ce20f0788fde9f2e439`
- `LICENSE.TXT`
  - Source: repository root `LICENSE.TXT`
  - SHA-256: `8d85c1057d742e597985c7d4e6320b015a9139385cff4cba6effc0ebe89afee`

The fixtures are test data only. MoonPDB does not copy LLVM implementation code.
