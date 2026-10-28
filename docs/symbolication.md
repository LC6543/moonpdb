# Unified Address Symbolication

MoonPDB combines PE section mapping, Publics address lookup, and C13 line data
without introducing a database or a debugging UI.

## Supported

- Input `(segment, section_offset)` from PDB public symbols or line records
- PE section name, RVA, and image virtual address
- Nearest public symbol in the same segment
- Nearest C13 source line in a matching line-fragment code range
- Optional file path, line range, statement bit, and source columns
- Batch symbolication with unmapped addresses skipped

## API

```moonbit
let report = @moonpdb.symbolicate_address(
  pe,
  publics,
  [c13_module],
  1,
  0x1018,
)
```

The report returns `None` only when PE section mapping fails. A valid mapped
address may contain neither a public symbol nor source line information.

## Boundary

The current multi-module policy returns the first C13 match. Inline frames,
locals, register state, stack unwinding, and source-server retrieval are out of
scope. Global symbol name indexes and public address indexes are exposed as
separate data layers so callers can build richer reports.
