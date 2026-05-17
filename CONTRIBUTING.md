# Contributing to meta-skill-process-architect

## Ways to Contribute

### 1. Report a Bug
Open an issue with:
- What you expected to happen
- What actually happened
- Steps to reproduce
- CLI version (`process-architect --version`)

### 2. Submit a Process Skill
If you've generated a process Skill that others might find useful:
1. Run `validate --skill ./your-process/` — must be 18/18
2. Run `ttl-check --skill ./your-process/` — must have zero expired markers
3. Include a README.md following the template in `references/distribution-guidelines.md`
4. Submit as a pull request to `examples/`

### 3. Improve the Archetype
The `references/process-archetype.md` is the core schema. Improvements to:
- Gap Handling rules
- Anti-pattern detection
- L0-L6 field definitions
- Lifecycle operations

Should reference specific plan ADRs (see `DESIGN.md`).

### 4. Add a Platform Adapter
To add support for a new platform:
1. Create `agents/{platform}.yaml`
2. Update `references/platform-adapters.md`
3. If packaging changes are needed, update `cli/meta-skill-process-architect.py` `cmd_package`

### 5. Fix a Bug
For CLI bugs:
- Reproduce with `python cli/meta-skill-process-architect.py validate --skill examples/sp007-customer-refund`
- Fix in `cli/meta-skill-process-architect.py`
- Re-run all 6 e2e-test validations

For template bugs:
- Fix in `templates/` (both EN and ZH)
- Test by generating a Skill and running `validate`

## Development Setup

```bash
git clone <repo-url>
cd meta-skill-process-architect

# No dependencies needed — CLI uses Python stdlib only
python cli/meta-skill-process-architect.py --version

# Run validation on example
python cli/meta-skill-process-architect.py validate --skill examples/sp007-customer-refund
```

## Quality Gates

Before submitting a PR:
- [ ] `validate` on examples/sp007 passes 18/18
- [ ] `ttl-check` on examples/sp007 shows zero expired
- [ ] All 6 e2e-test Skills pass validate (17/18 minimum, 18/18 preferred)
- [ ] New features have corresponding updates to SKILL.md or references/
- [ ] Bilingual parity maintained (EN + ZH templates)

## Design Authority

`DESIGN.md` is the authoritative design reference. Major architectural changes should update it.
The full plan (`meta-skill-process-architect-plan.md`) contains detailed design discussions and Phase history.
