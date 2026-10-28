# TPI and IPI Type Streams

TPI is fixed MSF stream 2 and IPI is fixed stream 4. Both use the same 56-byte
CodeView type-stream header, type-index range, and length-prefixed record
sequence. MoonPDB exposes one parser for both layouts.

## Supported

- Version, header size, type-index begin/end, and type-record byte count
- Hash stream indexes, key size, bucket count, and embedded-region bounds
- Deterministic type indexes derived from the declared index range
- Bounded record traversal with record and stream-size limits
- Simple type indexes below `0x1000`, including pointer modes
- Typed leaf variants for modifiers, pointers, procedures, member functions,
  argument lists, bit fields, arrays, classes/structures/interfaces, unions,
  enums, aliases, labels, function IDs, string IDs, build info, UDT source
  records, and type-server records
- Raw payload preservation for unknown leaves
- Structured errors for invalid headers, truncated records, count mismatches,
  malformed known records, and exceeded limits

## API

```moonbit
let msf = @moonpdb.parse_msf(bytes, @moonpdb.MsfLimits::default())
let tpi = msf.tpi(@moonpdb.TpiLimits::default())
let ipi = msf.ipi(@moonpdb.TpiLimits::default())

let record = tpi.record(0x1000)
let int32 = @moonpdb.simple_type(0x74)
```

`parse_tpi` accepts stream bytes directly. `TypeTable::record` performs the
type-index range check before indexing into the parsed record array.

## Current boundary

`LF_FIELDLIST` payloads are currently preserved as bounded raw bytes. Member
subrecords, `LF_INDEX` continuation chains, full type-hash lookup, and
type-name indexes are subsequent milestones. TPI/IPI parsing does not yet
resolve a type graph recursively.

## Format references

- Microsoft `microsoft-pdb`, `include/cvinfo.h`
- LLVM `DebugInfo/CodeView` type-record definitions
- LLVM `DebugInfo/PDB/Native/RawTypes.h`

The implementation is original MoonBit code. The referenced files are public
format documentation under their respective upstream licenses.
