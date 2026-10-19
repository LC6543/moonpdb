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

Initial review stage. The API is not stable.

The current milestones parse the MSF container and the PDB Info stream,
including GUID/age, named streams, and feature codes. See
[docs/msf.md](docs/msf.md) and [docs/pdb-info.md](docs/pdb-info.md) for the
supported layout and API boundaries.

## Usage

```text
let msf = @moonpdb.parse_msf(file_bytes, @moonpdb.MsfLimits::default())
let info = msf.pdb_info(@moonpdb.PdbInfoLimits::default())
let names_stream = info.named_stream_index("/names")
let pdb_info_bytes = msf.stream(1)
```

All parsers validate file sizes, stream counts, directory sizes, and
allocation limits before reading untrusted data.

## Documentation

- [MSF container](docs/msf.md)
- [PDB Info stream](docs/pdb-info.md)
- [Roadmap](docs/ROADMAP.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

## License

Apache-2.0.
