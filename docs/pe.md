# PE Image Mapping

PDB public symbols and C13 line records use one-based section numbers plus
section-relative byte offsets. MoonPDB parses the minimum PE image structure
needed to convert those values to RVAs and image virtual addresses.

## Supported

- DOS `MZ` header and PE header offset
- PE signature and COFF header
- PE32 optional header and 32-bit image base
- PE32+ optional header and 64-bit image base
- Bounded section table with names, virtual size/address, raw size/offset, and
  characteristics
- One-based PDB segment mapping to section-relative offset, RVA, and VA
- Section span checks using the larger of virtual and raw size
- Overflow checks for section address arithmetic and image-base addition
- File-size and section-count limits

## API

```moonbit
let image = @moonpdb.parse_pe_image(
  pe_bytes,
  @moonpdb.PeLimits::default(),
)
let mapped = image.map_segment_offset(1, 0x1010)
```

This is intentionally not a general-purpose PE loader. It does not map raw
sections, resolve imports, parse relocations, or execute the image.

## Current Boundary

PDB section indices are treated as one-based PE section-table indices. Images
with stripped section tables, overlays, or PE layouts that cannot provide a
matching section cannot be mapped. Object files and COFF-only inputs are not
accepted by this parser.
