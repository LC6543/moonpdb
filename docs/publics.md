# Publics Stream and GSI Address Index

The Publics stream is referenced by the DBI header. It contains a fixed header,
a GSI hash index, an address map, a thunk map, and per-section offsets. The
symbol records themselves live in the DBI symbol-record stream.

## Supported

- 28-byte Publics header with symbol hash, address-map size, thunk metadata,
  section count, and thunk-table location
- GSI signature and version validation
- `PSHashRecord` entries with raw and zero-adjusted symbol offsets
- The 4097-bit GSI bitmap and compressed bucket array
- Address-map validation and resolution to `S_PUB32` records
- Exact segment/offset lookup
- Nearest-preceding public symbol lookup within the same segment
- Thunk-map and section-offset parsing
- Duplicate public addresses, as used by identical code folding, remain ordered
  and searchable

## API

```moonbit
let dbi = msf.dbi(@moonpdb.DbiLimits::default())
let publics = msf.publics_stream(
  dbi, @moonpdb.SymbolLimits::default(),
)

let exact = publics.find_public_exact(1, 0x1000)
let nearest = publics.find_public_nearest(1, 0x1040)
let records = publics.gsi().hash_records()
```

The Publics parser resolves every address-map entry before returning, so a
missing or non-`S_PUB32` target is reported as corruption instead of being
silently skipped.

## Current Boundary

Public lookup reports segment and section offset; mapping through PE section
headers to RVAs and image addresses is provided by the PE symbolication layer.
Global name lookup is provided by the separate Globals/GSI layer. C13 line
subsections are provided by the separate C13 line layer.

## Format References

- Microsoft `microsoft-pdb`, `PDB/dbi/gsi.h`
- LLVM `DebugInfo/PDB/Native/PublicsStream.cpp`
- LLVM `DebugInfo/PDB/Native/GlobalsStream.cpp`
- LLVM `DebugInfo/PDB/Native/RawTypes.h`
- LLVM `DebugInfo/PDB/Native/HashTable.h`

The implementation is original MoonBit code. Referenced files are public
format documentation under their respective upstream licenses.
