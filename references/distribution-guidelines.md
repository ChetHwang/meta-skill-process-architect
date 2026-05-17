# Distribution Guidelines — Process Skills

> Guidelines for publishing and sharing generated process Skills.

---

## Publishing to GitHub

### Repository Structure

```
process-{name}/
├── SKILL.md                    # Entry point
├── VERSION                     # Semver
├── CHANGELOG.md                # Change history
├── LICENSE                     # MIT
├── README.md                   # Generated Skill overview
├── references/
│   ├── process-brief.md        # L1 — 9 sub-sections
│   ├── foundational-logic.md   # L2
│   ├── output-recipes.md       # L3
│   ├── artifacts-registry.md   # L4
│   ├── visualization-spec.md   # L5
│   └── cases-library.md        # L6
└── assets/
    ├── flowcharts/
    ├── forms/
    └── templates/
```

### README Template for Generated Skills

```markdown
# process-{name}

> One-line description of the process.

## Quick Reference

| Role | Go-To Recipe |
|---|---|
| ... | ... |

## How to Use

1. First time? Start with the SOP.
2. Need to execute? Follow the Runbook.
...
```

---

## Skill Marketplace Submission

For platforms that support Skill marketplaces (WorkBuddy, OpenClaw, Claude Code):

1. **Package**: `process-architect package --format {platform} --skill ./process-{name}/`
2. **Validate**: Ensure `validate` reports 18/18 + zero anti-pattern blocks
3. **Submit**: Upload the `.tar.gz` via the platform's import UI

---

## Version Compatibility

- Generated Skills follow semantic versioning
- MAJOR version bumps indicate breaking changes to the process structure
- MINOR bumps indicate new steps, roles, or recipes
- PATCH bumps indicate fixes and clarifications

When sharing a Skill, declare the minimum meta-skill-process-architect version it was generated with.

---

## Example Skill Showcase

See `examples/sp007-customer-refund/` for a complete, validated example. This Skill:
- Passes 18/18 structural validation
- Has 10/10 anti-patterns clean
- Has 7 TTL markers, all valid
- Covers 7 roles with 14 output recipes

---

## Community Contribution

To contribute a process Skill:

1. Generate with `process-architect generate`
2. Run `validate` — must be 18/18
3. Run `ttl-check` — must have zero expired markers
4. Include a README.md with the template above
5. Submit as a pull request to the target repository
