# MoonPDB

[![CI](https://github.com/LC6543/moonpdb/actions/workflows/ci.yml/badge.svg)](https://github.com/LC6543/moonpdb/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

MoonPDB is a pure MoonBit reader for Microsoft PDB 7.0 debug information.
It targets Windows native symbolication, crash triage, build artifact audits,
and debugger or language-tool integrations.

The project is developed in independently testable layers:

1. MSF container and stream directory
2. PDB Info stream and named streams
3. TPI/IPI type records
4. DBI modules, public/global symbols, and line information
5. Source lookup, symbolication reports, and inspection CLI

MoonPDB does not replace MoonBit's existing ELF/DWARF tooling. PDB is a
separate Microsoft format that is not read by DWARF parsers.

## Status

Pre-release. The API is not stable, but the container foundation is usable.

The current milestones parse the MSF container, the PDB Info stream, TPI/IPI
type streams, the DBI structure stream, common CodeView symbol records, and the
Publics/GSI address index, Globals name index, C13 line information, and PE
address mapping. DBI support includes module
descriptors, section contributions, the section map, source-file mapping,
EC/type-server substreams, and optional debug stream indexes. See
[docs/msf.md](docs/msf.md), [docs/pdb-info.md](docs/pdb-info.md),
[docs/tpi.md](docs/tpi.md), [docs/dbi.md](docs/dbi.md), and
[docs/symbols.md](docs/symbols.md), [docs/publics.md](docs/publics.md), and
[docs/globals.md](docs/globals.md), [docs/c13.md](docs/c13.md),
[docs/pe.md](docs/pe.md), and [docs/symbolication.md](docs/symbolication.md).

## Usage

```text
let msf = @moonpdb.parse_msf(file_bytes, @moonpdb.MsfLimits::default())
let info = msf.pdb_info(@moonpdb.PdbInfoLimits::default())
let names_stream = info.named_stream_index("/names")
let tpi = msf.tpi(@moonpdb.TpiLimits::default())
let ipi = msf.ipi(@moonpdb.TpiLimits::default())
let int32_type = @moonpdb.simple_type(0x74)
let dbi = msf.dbi(@moonpdb.DbiLimits::default())
let modules = dbi.modules()
let module_debug = msf.module_debug_stream(
  dbi, 0, @moonpdb.SymbolLimits::default(),
)
let symbols = module_debug.symbols()
let publics = msf.publics_stream(
  dbi, @moonpdb.SymbolLimits::default(),
)
let nearest_public = publics.find_public_nearest(1, 0x1000)
let globals = msf.globals_stream(
  dbi, @moonpdb.SymbolLimits::default(),
)
let matches = globals.find_records_by_name("main")
let lines = msf.module_c13_info(
  dbi, 0, @moonpdb.SymbolLimits::default(), @moonpdb.C13Limits::default(),
)
let source = lines.find_line(1, 0x1000)
let pe = @moonpdb.parse_pe_image(pe_bytes, @moonpdb.PeLimits::default())
let report = @moonpdb.symbolicate_address(
  pe, publics, [lines], 1, 0x1000,
)
```

All parsers validate file sizes, stream counts, directory sizes, and
allocation limits before reading untrusted data.

## Documentation

- [MSF container](docs/msf.md)
- [PDB Info stream](docs/pdb-info.md)
- [TPI/IPI type streams](docs/tpi.md)
- [DBI structure stream](docs/dbi.md)
- [CodeView symbol records](docs/symbols.md)
- [Publics and GSI address index](docs/publics.md)
- [Globals name index](docs/globals.md)
- [C13 line information](docs/c13.md)
- [PE image mapping](docs/pe.md)
- [Unified symbolication](docs/symbolication.md)
- [Roadmap](docs/ROADMAP.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

## License

Apache-2.0.
