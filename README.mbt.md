# MoonPDB

MoonPDB is a pure MoonBit reader for Microsoft PDB 7.0 debug information.
It targets Windows native symbolication, crash triage, build artifact audits,
and debugger or language-tool integrations.

The project is developed in independently testable layers:

1. MSF container and stream directory (current milestone)
2. PDB Info stream and named streams
3. TPI/IPI type records
4. DBI modules, public/global symbols, and line information
5. Source lookup, symbolication reports, and inspection CLI

MoonPDB does not replace MoonBit's existing ELF/DWARF tooling. PDB is a
separate Microsoft format that is not read by DWARF parsers.

## Status

Initial review stage. The API is not stable.

## License

Apache-2.0.
