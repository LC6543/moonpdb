# PDB Info Stream

The PDB Info stream is fixed stream index 1. MoonPDB reads it from an already
parsed MSF container and exposes the metadata needed to identify a PDB and
locate its named streams.

## Supported

- Version, signature, and age fields
- 16-byte PDB GUID with conventional Windows formatting
- Named stream string buffer
- Serialized uint32 hash table, including present/deleted bit-vector checks
- Name-to-MSF-stream-index lookup
- Feature codes consuming the remaining stream bytes
- Limits for string bytes, named streams, hash capacity, and feature count

## API

```moonbit
let msf = @moonpdb.parse_msf(bytes, @moonpdb.MsfLimits::default())
let info = msf.pdb_info(@moonpdb.PdbInfoLimits::default())
let age = info.age()
let guid = info.guid_string()
let names_index = info.named_stream_index("/names")
```

`parse_pdb_info` is also public for callers that already have stream 1 bytes
and know the MSF stream count.

## Current boundary

This milestone does not decode TPI/IPI records, DBI modules, public/global
symbols, or line tables. Feature codes are exposed as raw values; their impact
on later streams will be interpreted by those layers.
