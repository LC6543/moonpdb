# Security Policy

## Supported versions

Security fixes are applied to the latest `0.1.x` line while the project is in
initial review.

## Reporting

Please use GitHub's private security advisory flow from the repository Security
tab. Do not open a public issue for a suspected vulnerability.

Include:

- affected version or commit;
- minimal input or a description of the malformed structure;
- expected and observed behavior;
- whether the issue can cause out-of-bounds access, unbounded allocation,
  excessive CPU use, or another denial-of-service condition.

PDB files are untrusted build artifacts. Length fields, block indexes, stream
counts, directory sizes, named-stream offsets, and bit-vector capacities must be
validated before allocation or indexing.

## Disclosure

Please allow time to reproduce, fix, test, and prepare a release before public
disclosure.
