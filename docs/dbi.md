# DBI Structure Stream

DBI is fixed MSF stream 3. It records the executable's module layout, section
contributions, source-file associations, and indexes for optional debug data.
MoonPDB parses the structural substreams without resolving symbol or line
records yet.

## Supported

- Fixed 64-byte DBI header with version, age, flags, machine, and stream indexes
- Exact substream-size and alignment validation
- Variable-length, 4-byte-aligned module descriptors
- Module and object names, module stream index, C11/C13 byte counts, and EC flags
- Embedded per-module section contribution
- Section contribution versions 60 and 2
- Section map header and entries
- File info module indexes, per-module file counts, name offsets, and names
- Type-server map and EC substream preservation
- Optional debug header entries for FPO, exception, fixup, OMAP, section,
  token RID, XDATA, PDATA, new FPO, and original section-header streams
- Limits for modules, contributions, section-map entries, source files,
  strings, and debug-stream entries

## API

```moonbit
let msf = @moonpdb.parse_msf(bytes, @moonpdb.MsfLimits::default())
let dbi = msf.dbi(@moonpdb.DbiLimits::default())
let modules = dbi.modules()
let sources = modules[0].source_files()
let map = dbi.section_map()
let debug_streams = dbi.optional_debug_streams()
```

`parse_dbi` accepts stream bytes directly. Module source files are resolved
from the DBI file-info substream rather than from the untrusted 16-bit source
file count in its fixed header.

## Current boundary

DBI module debug streams, public/global symbol streams, C11 line data, and C13
line subsections are not decoded in this milestone. Type-server and EC payloads
are preserved for later layers. The optional debug header exposes stream
indexes; it does not follow or parse those streams yet.

## Format references

- Microsoft `microsoft-pdb`, `PDB/dbi` and `include/cvinfo.h`
- LLVM `DebugInfo/PDB/Native/RawTypes.h`
- LLVM `DebugInfo/PDB/Native/DbiStream.cpp`
- LLVM `DebugInfo/PDB/Native/DbiModuleList.cpp`

The implementation is original MoonBit code. Referenced files are public
format documentation under their respective upstream licenses.
