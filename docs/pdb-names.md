# PDB `/names` String Table

The PDB `/names` stream provides a shared byte-offset string table used by
CodeView records such as C13 file checksums.

## Supported

- Signature and hash-version validation
- Bounded string-buffer extraction
- Name ID hash-array parsing
- Name-count epilogue validation
- String lookup by byte offset
- Explicit limits for table bytes and name entries

## API

```moonbit
let info = msf.pdb_info(@moonpdb.PdbInfoLimits::default())
let names = msf.pdb_string_table(
  info,
  "/names",
  @moonpdb.PdbStringTableLimits::default(),
)
let source = names.string_for_id(offset)
```

`MsfFile::module_c13_info` automatically uses this table when a module's C13
FileChecksums subsection has no local StringTable.

## Format References

- LLVM `DebugInfo/PDB/Native/PDBStringTable.h`
- LLVM `DebugInfo/PDB/Native/PDBStringTable.cpp`
- Microsoft `microsoft-pdb`, PDB string-table structures
