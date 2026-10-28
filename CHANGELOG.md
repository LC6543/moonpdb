# Changelog

All notable changes to this project are documented here.

## 0.2.0 - 2026-10-28

### Added

- TPI/IPI header, hash metadata, type-index range, and bounded record traversal
- Simple CodeView type-index classification
- Typed decoding for common CodeView type records
- Raw preservation of unknown type leaves
- Synthetic coverage for valid, malformed, and resource-limited type streams
- DBI header, module descriptors, section contributions, and section map
- DBI file info with per-module source-file associations
- EC and type-server substream preservation
- Optional DBI debug stream indexes with typed lookup
- Synthetic coverage for valid, malformed, and resource-limited DBI streams
- Bounded CodeView symbol-record framing with 4-byte padding validation
- Typed public, data, procedure, thunk, block, label, constant, UDT,
  BP-relative, register-relative, procedure-reference, and frame records
- Module debug stream signature, symbol, C11/C13, and global-reference splitting
- Global symbol-record stream access through the DBI header
- Publics stream header, GSI hash records, bitmap, and compressed buckets
- Public address, thunk, and section-offset maps
- Exact and nearest segment-offset public symbol lookup
- Case-insensitive PDB v1 name hashing with exact-name symbol matching
- Globals/GSI stream parsing and compressed bucket-range lookup
- C13 debug subsection parsing with aligned raw preservation
- Module string tables, file checksums, line fragments, and column records
- Segment-offset to source path, line, and column lookup
- PE32 and PE32+ headers, image base, and section-table parsing
- PDB segment/offset mapping to PE RVA and image virtual address
- Unified public-symbol and source-location symbolication reports

### Planned

- Field-list member records and continuation chains
- CLI and real PDB/PE interoperability fixtures
- Source line lookup and address symbolication
- Inspection CLI and real PDB interoperability fixtures

## 0.1.0 - 2026-10-19

### Added

- MSF superblock and directory block-map validation
- Stream directory parsing with bounded stream reads
- PDB Info header, GUID/age, named stream map, and feature codes
- Typed errors for MSF and PDB Info parsing
- Synthetic valid, malformed, and resource-limit tests
- GitHub Actions check and test workflow

### Documentation

- Initial review proposal
- MSF and PDB Info format boundaries
- Project roadmap and contribution/security policies
