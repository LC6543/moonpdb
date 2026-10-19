# Contributing

MoonPDB is developed as a pure MoonBit library with no FFI dependency in the
parser core. Contributions should preserve that boundary unless a platform
adapter is explicitly proposed.

## Development

Run the following commands before submitting a change:

```text
moon check --deny-warn
moon test --deny-warn
moon fmt --check
```

Run `moon info` when public declarations change and review the generated
`.mbti` diff.

## Change scope

- Keep one coherent feature or fix per pull request.
- Add tests for new parsing paths and malformed input.
- Validate all lengths, offsets, counts, and block references before reading.
- Do not silently copy code, fixtures, or test data from another project.
- Document upstream formats, references, licenses, and generated content.

## Commit messages

Use a concise conventional prefix such as `feat(msf):`, `fix(pdb):`,
`test(dbi):`, or `docs:`. Do not create empty or mechanical commits.

## License

By contributing, you agree that your contribution is licensed under the
repository's Apache-2.0 license.

## Security

Do not report memory-safety, unbounded-allocation, or malformed-input issues in
a public issue. Follow [SECURITY.md](SECURITY.md).
