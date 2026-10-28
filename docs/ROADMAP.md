# Roadmap

The project is developed in independently testable protocol layers.

## v0.1 - Container foundation

- MSF superblock, block map, stream directory, and bounded stream reads
- PDB Info stream, GUID/age, named streams, and feature codes
- Structured errors and malformed-input tests

## v0.2 - Types

- [x] TPI and IPI stream headers
- [x] Type-index ranges and CodeView record framing
- [x] Simple, modifier, pointer, procedure, aggregate, enum, array, and alias types
- [x] Bounded record traversal and raw preservation for unknown leaves
- [ ] Field-list member records and LF_INDEX continuation chains
- [ ] Full type hashing and lookup acceleration

## v0.3 - Symbols

- [x] DBI header, module list, and source-file mapping
- [x] Section contributions, section map, EC/type-server substreams
- [x] Optional debug header and indexed stream lookup
- [x] Module debug stream segmentation and global-reference lists
- [x] Common module/global CodeView symbol records
- [x] Public GSI hash metadata, bitmap, compressed buckets, and address map
- [x] Public/global exact and nearest segment-offset address lookup
- [x] Global name-hash lookup and exact-name record matches
- String-table and source-name indexes

## v0.4 - Source locations

- [x] C13 line tables and source-file mapping
- [x] Module segment-offset to source line lookup
- [x] PE section mapping and unified address-to-source lookup
- [x] Symbolication reports over captured addresses
- [ ] Multi-module symbolication policy and CLI reports

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
