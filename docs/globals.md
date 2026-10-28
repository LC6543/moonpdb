# Globals Stream and Name Index

The Globals stream is referenced by the DBI header. It is a GSI hash table whose
records point into the DBI symbol-record stream. MoonPDB supports exact symbol
name lookup through the PDB version-one string hash.

## Supported

- PDB case-insensitive version-one string hashing
- GSI header, hash records, 4097-bit bitmap, and compressed buckets
- Expansion from the 4097-entry name bucket to a compressed bucket index
- Bucket byte ranges converted to hash-record index ranges
- On-disk zero-adjusted symbol offsets
- Exact-name matching after bucket lookup
- Symbol kinds with names: public, data, procedure, thunk, block, label,
  constant, UDT, object, BP-relative, register-relative, and procedure-reference
- Duplicate exact-name matches and bounded result counts

## API

```moonbit
let dbi = msf.dbi(@moonpdb.DbiLimits::default())
let globals = msf.globals_stream(
  dbi, @moonpdb.SymbolLimits::default(),
)

let records = globals.find_records_by_name("main")
let bucket = @moonpdb.hash_string_v1("Main") % 4097
```

Hashing is case-insensitive, while returned records must match the requested
name exactly. This mirrors the PDB index contract and preserves aliases or
duplicate records.

## Current Boundary

The `/names` string table and source-name indexes are not decoded yet. Global
lookup returns symbol records but does not yet expose a higher-level typed
union for every returned symbol. Address-to-name and line-to-source composition
is provided by composing this layer with Publics, C13, and PE mapping.

## Format References

- Microsoft `microsoft-pdb`, `PDB/dbi/gsi.h`
- LLVM `DebugInfo/PDB/Native/GlobalsStream.cpp`
- LLVM `DebugInfo/PDB/Native/Hash.cpp`
- LLVM `DebugInfo/PDB/Native/HashTable.h`

The implementation is original MoonBit code. Referenced files are public
format documentation under their respective upstream licenses.
