# MSF Container Support

MoonPDB's first milestone reads the Multi-Stream File (MSF) container used by
PDB 7.0 files. It does not interpret CodeView type or symbol records yet.

## Supported

- MSF 7.0 magic and fixed superblock fields
- Block sizes 512, 1024, 2048, and 4096
- Directory block map indirection
- Stream size table and per-stream block lists
- Logical stream extraction across non-contiguous file blocks
- File, directory, stream-count, and stream-size limits
- Structured errors for bad magic, invalid blocks, truncation, and limits

## API

```moonbit
let msf = @moonpdb.parse_msf(bytes, @moonpdb.MsfLimits::default())
let header = msf.header()
let stream_count = msf.stream_count()
let pdb_info = msf.stream(1)
```

`parse_msf_header` is also public for callers that only need container
metadata. `MsfFile::stream` validates every referenced block before reading.

## Current boundary

The MSF layer is intentionally transport-free and allocation-bounded. The PDB
Info stream is now parsed on top of it. TPI/IPI, DBI, module streams,
public/global symbols, and line tables are later milestones. The current
package must not be treated as a complete PDB symbol reader.

## Format references

- LLVM, "The MSF File Format"
- Microsoft, `microsoft-pdb` public sample sources

The implementation is original MoonBit code. Public format documentation and
the Apache-2.0 Microsoft sample are used as references only.
