# CodeView Symbols and Module Debug Streams

MoonPDB reads CodeView symbol records from module debug streams and the global
symbol-record stream referenced by DBI. Each record is length-prefixed,
4-byte-aligned, and bounded by an explicit record limit.

## Supported Symbol Records

- `S_PUB32`
- `S_LDATA32`, `S_GDATA32`, `S_LTHREAD32`, `S_GTHREAD32`
- `S_LPROC32`, `S_GPROC32`
- `S_THUNK32`, `S_BLOCK32`, `S_LABEL32`
- `S_BPREL32`, `S_REGREL32`
- `S_CONSTANT`, `S_UDT`, `S_OBJNAME`
- `S_PROCREF`, `S_LPROCREF`
- `S_FRAMEPROC`
- `S_END`, `S_INLINESITE_END`, `S_PROC_ID_END`

Unknown records retain their kind and complete padded payload. Known records
reject truncation, invalid numeric leaves, non-zero padding, and incorrect
alignment.

## Module Streams

A module debug stream is split using the sizes stored in its DBI module
descriptor:

1. 4-byte C13 signature and CodeView symbols
2. optional C11 line data
3. optional C13 line data
4. optional global-reference count and uint32 index list

C11 and C13 data cannot both be present. The current milestone exposes C11/C13
bytes but does not interpret line subsections.

## API

```moonbit
let dbi = msf.dbi(@moonpdb.DbiLimits::default())
let module_stream = msf.module_debug_stream(
  dbi, 0, @moonpdb.SymbolLimits::default(),
)
let symbols = module_stream.symbols()
let records = msf.symbol_record_stream(
  dbi, @moonpdb.SymbolLimits::default(),
)
```

Symbol offsets are retained relative to their containing stream, which allows
later GSI and scope records to reference them without reserialization.

## Current Boundary

Publics address maps, Globals name indexes, and C13 line/source mapping are
decoded in their respective layers. PE section-to-RVA mapping and a unified
symbolication report remain subsequent milestones.

## Format References

- Microsoft `microsoft-pdb`, `include/cvinfo.h`
- LLVM `DebugInfo/CodeView/SymbolRecord.h`
- LLVM `DebugInfo/CodeView/SymbolRecordMapping.cpp`
- LLVM `DebugInfo/PDB/Native/ModuleDebugStream.cpp`

The implementation is original MoonBit code. Referenced files are public
format documentation under their respective upstream licenses.
