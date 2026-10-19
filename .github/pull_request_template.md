## Summary

Describe the feature or fix and the format layer it touches.

## Scope

- [ ] Focused on one coherent change
- [ ] Public API changes documented
- [ ] No unrelated files or generated artifacts included

## Validation

- [ ] `moon check --deny-warn`
- [ ] `moon test --deny-warn`
- [ ] `moon fmt --check`
- [ ] `moon info` reviewed when public declarations changed

## Compatibility and provenance

- [ ] New parsing paths validate lengths, indexes, counts, and limits
- [ ] Tests cover malformed input where applicable
- [ ] External formats, code, fixtures, and licenses are documented
