# Platform Adapters — Process Skills

> Cross-platform packaging for generated process Skills. Each platform has a specific directory structure and import format.

---

## Supported Platforms

| Platform | Format | CLI Command | Status |
|---|---|---|---|
| **WorkBuddy** | `.tar.gz` with `SKILL.md` entry | `package --format workbuddy` | ✅ Supported |
| **OpenClaw** | `.tar.gz` with `SKILL.md` entry | `package --format openclaw` | ✅ Supported |
| **Claude Code** | `.claude/skills/` directory | Future | 📋 Planned |
| **Standalone** | Markdown bundle + README | Future | 📋 Planned |
| **OpenAI GPTs** | Knowledge file upload bundle | Future | 📋 Planned |

---

## WorkBuddy Adapter

Generated Skill structure follows WorkBuddy conventions:
- `SKILL.md` as entry point with YAML frontmatter (`name`, `description`)
- `references/` directory for progressive-loading layers
- `agents/openai.yaml` for agent configuration
- Package command creates `.tar.gz` for direct import via WorkBuddy UI: Skills → Import

## OpenClaw Adapter

Same structure as WorkBuddy. OpenClaw reads `SKILL.md` frontmatter and `references/` for context injection. Import via `skills install <file>.tar.gz`.

## Future Platforms

### Claude Code
- Skill files go in `.claude/skills/{skill-name}/`
- Each reference file is loaded on-demand by Claude

### Standalone
- Single Markdown bundle with all layers inlined
- Suitable for human reading, PDF export, or Wiki import

### OpenAI GPTs
- Knowledge file upload format
- Chunked for context window limits

---

## Adapter Implementation Note

The current CLI `package` command only wraps the Skill directory into a `.tar.gz`. Platform-specific structural transformations (e.g., Claude Code's `.claude/skills/` layout) are not yet implemented. The packaging format is identical across WorkBuddy and OpenClaw because both read the same standard Skill structure.
