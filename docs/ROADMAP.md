# Roadmap

The project is developed in independently testable protocol layers.

## v0.1 - Container foundation

- MSF superblock, block map, stream directory, and bounded stream reads
- PDB Info stream, GUID/age, named streams, and feature codes
- Structured errors and malformed-input tests

## v0.2 - Types

- TPI and IPI stream headers
- CodeView type record framing
- Common primitive, pointer, aggregate, and member type decoding
- Type-record bounds and cycle protection

## v0.3 - Symbols

- DBI header and module list
- Module information streams
- Public and global symbol streams
- Symbol name and address indexes

## v0.4 - Source locations

- Line tables and source-file mapping
- Address-to-function and address-to-source lookup
- Symbolication reports over captured addresses

## v0.5 - Tooling and interoperability

- Inspection CLI
- Real Windows PDB fixtures
- Qpid-independent PDB interoperability tests
- README examples and reproducible CI evidence

## v1.0 - Stable release

- Stable public API and compatibility policy
- Runnable examples for supported workflows
- Mooncakes publication and release notes
- Complete license and provenance documentation
