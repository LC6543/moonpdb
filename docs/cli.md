# Inspection CLI

MoonPDB includes a file-backed read-only CLI for inspecting PDB and PE inputs.
The executable package is in `cmd/main`; the core library remains pure and does
not perform I/O.

## Commands

```text
moon run cmd/main -- summary <pdb>
moon run cmd/main -- modules <pdb>
moon run cmd/main -- types <pdb> [limit]
moon run cmd/main -- symbols <pdb> [limit]
moon run cmd/main -- publics <pdb> [limit]
moon run cmd/main -- find <pdb> <name>
moon run cmd/main -- address <pe> <pdb> <segment> <offset>
```

`address` accepts decimal or `0x`-prefixed segment and offset values. The
command reports the section, RVA, image virtual address, nearest public symbol,
and source location when available.

## Examples

```text
moon run cmd/main -- summary test-data/llvm/global-name-lookup.pdb
moon run cmd/main -- find test-data/llvm/global-name-lookup.pdb main
moon run cmd/main -- address app.exe app.pdb 1 0x1000
```

All list commands use a default limit of 100 and reject limits above 10,000.
The CLI reports parse failures without panicking and does not modify either
input file.
