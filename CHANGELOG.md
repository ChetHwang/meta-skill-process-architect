# Changelog — meta-skill-process-architect

All notable changes to this project follow [Semantic Versioning](https://semver.org/).

This Changelog tracks the **meta-skill itself**. Each generated `process-{name}` Skill maintains its own separate CHANGELOG using `templates/CHANGELOG.md.template.{en,zh}`.

## Versioning Rules

| Bump | When |
|---|---|
| MAJOR | Breaking change to the L0-L6 archetype; output Skill structure changes; templates incompatible with prior generated Skills |
| MINOR | New input mode; new reference; new template; new optional layer |
| PATCH | Wording polish; bug fixes; doc clarifications; new examples in archetype |

---

## [1.2.4] — 全量脱敏（深度修复）+ tag history 清理 (2026-05-16)

### Fixed (BREAKING — 历史 commit 含未脱敏内容)
- 全量审计所有公开文件，**移除残留的内部术语**：
  - `references/process-archetype.md` 设计案例改为通用表述
  - `references/cross-process-network.md` Mermaid 图改用 generic 进程名（refund-process / unlock-process / enrollment-process）
  - `references/auto-scan-mode.md` 示例 URL 改为 example.com
  - `templates/references/output-recipes.md.template.{en,zh}` 工具引用改为 `<internal admin system>` 等占位
  - `SELF-VALIDATION.md` 修复记录改用通用角色名
  - `test-prompts.json` 测试 prompt 改用通用业务角色（Customer Success / Finance / Operations / Account Manager）
  - `CHANGELOG.md` 历史条目中所有内部术语统一替换为通用占位符
  - `INITIAL_COMMIT.sh` 注释中的内部引用脱敏

### Cleanup actions (manual, see INITIAL_COMMIT.sh)
- 删除远端旧 tag v1.1.1 + v1.2.2（指向含未脱敏内容的 commit）
- 重新 force push v1.2.4 为唯一可达 release

### Rationale
- v1.2.3 只脱敏了 `examples/` 目录，但**设计文档、模板、CHANGELOG、测试 prompt** 等多处仍引用内部术语
- 公开 GitHub 上的克隆验证（`grep -rE "<internal-terms-regex>"`）暴露了 30+ 处残留
- v1.2.4 做了**全量深度审计**，确保任何 grep 不再命中内部术语

---

## [1.2.3] — 示例脱敏化 + 公开发布安全 (2026-05-16)

### Changed (BREAKING — examples 内容)
- `examples/<original-internal-example>/` → `examples/process-employee-it-onboarding/`（**完全重写**为虚构示例）
- 原 the prior example（基于内部 SOP）+ 原 channel-investment（基于内部流程图）的真实内容已**移出公开范围**，备份至 `_private-examples/`（不进 git）
- `examples/process-channel-investment/` 内部团队名、工具名、流程引用全部脱敏（internal team / tool names anonymized to generic equivalents、the prior refund-process example→退款处理流程）
- 两个 examples 都在 SKILL.md 顶部加 "本流程为虚构示例" 免责声明

### Fixed
- Self-validation 与 README 中 the prior example 引用全部更新为 process-employee-it-onboarding
- 防止内部业务情报通过 examples 被公开仓库暴露

### Rationale
- v1.2.2 之前的 examples 含真实内部 SOP（12 条质检红线、内部系统名、团队结构、课程定价规则）
- 元技能本身是中立工具，但 examples 暴露了用户公司的运营情报
- 解决方法：元技能继续公开，examples 换成结构同等丰富但完全虚构的例子；原内容备份在 `_private-examples/`（同级目录，不在 skill 文件夹内，不进 git）

---

## [1.2.2] — G12 archetype 一致性强制 + 章节名统一 (2026-05-16)

### Added
- **G12 archetype 一致性检查** — meta-self-check 新增第三道防线：扫描每个 example 是否实现 archetype 规定的横切要求
  - 当前覆盖：C5 Cycle Time annotation / C6 Internal Handoff Summary
  - 扩展模式：新增 archetype 要求时，在 `archetype_requirements` registry 加一行 (id, name, file, pattern)
- the prior internal example 补 C6 `Internal Handoff Summary` 章节（之前漏了，由 G12 抓出）

### Fixed
- channel-investment 章节标题统一：`### 内部 handoff 摘要` → `### Internal Handoff Summary`
  - 统一格式让 G12 模式匹配可靠；避免中英混杂带来的检测漂移
- README Documentation Map 中 SELF-VALIDATION 描述维持 "自验证报告"，仍准确

### Rationale (Q3 中期项 C-2 落地)
- 之前 plan §3 加 C5 时，the prior example 没跟上 → 手工补回
- 现在 archetype 加新要求时，meta-self-check 会立即在所有 examples 上失败 → 强制补齐
- "元技能自我打脸"病灶（plan 说要 X 但自己例子没 X）从此被机器拦住

---

## [1.2.1] — G10/G11 自动化 + 一致性病灶修复 (2026-05-16)

### Added
- **CLI `meta-self-check`** — 自动化 G10 + G11 检查（VERSION / CLI / README badge / SELF-VAL title / CHANGELOG 五处版本号一致性 + examples generated_by_meta_skill_version 同步）。不一致即 exit 1，可接 CI / pre-commit。
- SELF-VALIDATION § G10/G11 自动化命令使用说明 + 防 P0 复发机制

### Fixed
- **P0 病灶复发修复**：README badge `1.1.1` → `1.2.1`；SELF-VAL title `v1.1.1` → `v1.2.1`；examples `1.2.0` → `1.2.1`（与 VERSION + CLI + CHANGELOG 重新对齐）
- v1.2.0 发布时漏了 README/SELF-VAL 同步——同一个 P0 病灶第二次复发，本版本通过引入自动化检查命令防止第三次发生

### Rationale
- 用户 Q3 暴露的本质问题不是"meta-skill 改了下游没跟上"，而是**"靠人工自验证的检查项不可持续"**
- G10/G11 在 v1.1.1/v1.2.0 加入但仍靠手工，故 P0 复发
- v1.2.1 把自检从"文档要求"升级为"CLI 强制"

---

## [1.2.0] — 版本追踪 + 时间有效性 (2026-05-16)

### Added
- **Version Tracking** — 生成 Skill 的 SKILL.md frontmatter 自动写入 `generated_by_meta_skill_version`；模板同步；SELF-VALIDATION G11 跨示例一致性检查
- **Temporal Validity** — 每个流程版本记录 `valid_from`/`valid_until`/`lifecycle_phase`/`trial_until`
- **Lifecycle Phases** — 5 阶段状态机：draft → trial → active → superseded → retired
- **CLI `which-version`** — 按时间点回查适用版本；`bump` 支持 `--phase`/`--valid-from`/`--trial-until`
- **lifecycle-operations.md §7** — Temporal Query 完整文档（查询逻辑 + 审计行为 + CLI 示例）
- **templates** — SKILL.md 模板加 temporal 字段；CHANGELOG 模板加时间窗口

### Fixed
- the prior example process-brief 补 C5 Cycle Time 注释（fastest=5d, slowest=12d, bottleneck=S3.1）
- examples 补 `generated_by_meta_skill_version: 1.2.0`
- process-archetype.md L0 扩展 4 个 temporal 字段 + Lifecycle Phase Definitions 表
- CLI VERSION 1.1.1 → 1.2.0；`cmd_generate` 写入 temporal 字段 + 版本追踪

## [1.1.5] — Darwin 收尾轮: 全量微优化 (2026-05-16)

### Added
- **Frontmatter description** — 新增排除声明："Not for: simple 1-2 step flows, product introductions"
- **Overview "When NOT to use"** — 4 条排除规则（简单流程/产品介绍/纯数据管道/一次性任务）
- **Phase coverage** — 补齐 Phase 5（Impact Analysis）

### Fixed
- **Overview** — capabilities 数量从 4 → 6（C1-C6 全部列出，C5/C6 此前遗漏）
- **Constraints** — "Retry & Timeout Contract" 重命名为 "Retry, Timeout & Escape Contract"（Constraint 14 universal escape hatch 在此节）

## [1.1.4] — Darwin Round 3: 指令具体性强化 (2026-05-16)

### Changed
- **Step 6** — 14 recipes 完整清单从跨文件引用变为内联表格（#1-#14 + Primary Role + Auto-Generate Rule），agent 无需再查阅 `process-archetype.md` 即可生成正确的 recipe 集
- **Step 4 L3** — 行指令从硬编码 6 个 recipe 名改为引用 Step 6 完整目录

## [1.1.3] — Darwin Round 2: 检查点强化 (2026-05-16)

### Added
- **Step 4 L1 Checkpoint** — L1.1-.9 生成完成后插入用户确认检查点：验证 9 子段完整、数据与 Step 3 一致、TTL 已标记、Cycle Time 已计算，确认后才生成 L2-L6。防止 L1 数据错误引发衍生层全线返工
- **TL;DR + Execution Budget** — 同步新增 L1 checkpoint 的暂停和 turn 计数引用

## [1.1.2] — Darwin Round 1: 实测表现修复 (2026-05-16)

### Fixed
- **Constraint 5** — 覆盖规则从固定 `≥ 3 roles` 改为动态 `≥ min(involved_roles_count, 3)`：2 角色流程只需覆盖 ≥ 2，消除低角色数流程的不可能约束
- **Step 2 P0 Blocker Check** — trigger 检测从仅拒绝 "开始"/"Start" 扩展为同时拒绝抽象状态（"到期"/"超时"/"完成" 无具体事件），防止模糊 trigger 通过 P0 检查
- **Step 6 Coverage check** — 同步动态覆盖规则
- **Step 7 Validation** — 同步 `Coverage test` 和 `L3` checklist

## [1.1.1] — Comprehensive optimization (2026-05-15)

### P0 Fixes
- **Version consistency** — unified version across `VERSION` (1.1.1) / `cli/...py` (1.1.1) / `README.md` badge (1.1.1) / `SELF-VALIDATION.md` (1.1.1) / `CHANGELOG.md` (this entry)
- Resolves silent drift between 1.0.1 → 1.1.1 (untracked changes during P2 optimization runs)

### P1 Fixes
- Git initial commit + `v1.1.1` tag
- `examples/<original-internal-example>/references/cases-library.md` — added 3 real cases from the prior example's version evolution evolution history

### P2 Enhancements
- `plan.md` reverse-sync: added C5 (Cycle Time Analysis) + C6 (Internal Handoff Detection) to §3; new ADR-12 ~ ADR-16 in §17
- `assets/flowcharts/` — added swimlane + decision-tree Mermaid starters
- `examples/process-channel-investment/` — second example covering multi-team + back-edge + payment-window scenarios
- Network command end-to-end test verified across 2 example skills

### SELF-VALIDATION update
- Added G10 (cross-file version consistency check)
- Previous SELF-VALIDATION dimensions still pass

---

## [1.1.0] — Production hardening (2026-05-15)

> Documented retroactively. The 13 production-hardening features below were added during 1.0.1 → 1.1.1 but never properly CHANGELOG'd. This entry restores traceability.

### Cross-cutting capabilities (new in this release)
- **C5 Cycle Time Analysis** — automatic fastest-path / slowest-path / bottleneck calculation
- **C6 Internal Handoff Detection** — detect role transitions within same department, prevent "throw-it-over-the-wall"

### Workflow hardening (SKILL.md)
- **TL;DR for agents** at top of SKILL.md
- **Execution Budget** — 30 turn hard cap, 20 turn warning threshold
- **Step 0.5 Input Size Gate** — token drain prevention (>100KB warn, >500KB reject)
- **Step 5.5 Trace Check** — drift analysis integration
- **Step 6.5 Recipe Checkpoint** — review before packaging
- **Step 8 Cross-Process Sync** — automatic backlink suggestion
- **Step 8.5 Session Integrity** — STATUS.md for interruption recovery
- **Circuit Breaker** — halt if archetype/role-model fail to load (no memory-based guessing)
- **Universal Escape Hatch** — Constraint #14: last step S{N}.X catch-all
- **Retry & Timeout Contract** — max 2 retries, [FAILED] tagging, no unbounded loops
- **Hard / Soft Constraints split** — clear authority hierarchy

---

## [1.0.1] — v1.0 Polish (2026-05-15)

### Multi-Platform Agent Configs
- `agents/openai.yaml` — updated from product-architect stub to process-architect
- `agents/claude.yaml` — Claude Code / Anthropic config
- `agents/workbuddy.yaml` — WorkBuddy config
- `agents/openclaw.yaml` — OpenClaw config
- `agents/codex.yaml` — Standalone / Codex / Generic agent config

### Design Reference
- `DESIGN.md` — standalone design reference with 11 ADRs (extracted from plan.md v1.0.3)
- SKILL.md/README.md/README.zh.md — updated to reference DESIGN.md
- Design authority clarified: DESIGN.md (standalone) + plan.md (monorepo)

### Repository Polish
- `CONTRIBUTING.md` — contribution guide (bug reports, PRs, quality gates)
- `.gitkeep` in empty directories (assets/, examples/agents/, examples/assets/flowcharts/)
- README Documentation Map expanded (+DESIGN.md, +CONTRIBUTING.md, +SELF-VALIDATION.md, +agents/)
- README Platform Compatibility table added

### Cross-Platform
- CLI confirmed cross-platform (pathlib/tarfile/argparse — Python 3.9+ stdlib only)
- YAML output is optional (PyYAML in try/except)
- Platform compatibility documented for macOS/Windows/Linux + 5 agent platforms

### CLI Fix
- `bullet_role_pattern` regex: `{2,8}` → `{0,20}`, char class expanded to `（）()/`
- Fixes role detection for single-keyword roles like single-keyword roles (e.g., finance, QA)

---

## [1.0.0] — Phase 4 Complete (2026-05-15)

### Documentation
- `README.md` — Phase 1 stub → complete v1.0.0 README (badges, Quick Start, Architecture Mermaid diagram, Documentation Map, CLI command reference, version history)
- `README.zh.md` — Chinese version
- `SELF-VALIDATION.md` — 7-dimension self-validation report (all pass)

### Examples
- `examples/<original-internal-example>/` — Complete working example Skill (8 files)
  - validate: 18/18, anti-patterns: 10/10 clean
  - ttl-check: 0 expired, coverage: 7/7 roles

### Release
- VERSION: 0.9.0 → 1.0.0
- CLI internal VERSION: 0.9.0 → 1.0.0
- SKILL.md Phase coverage: Phase 4 (complete)
- git init

### Self-Validation
- SKILL.md completeness: 8/8 ✅
- No TODOs/stubs/placeholders: clean ✅
- Anti-pattern scan on example: 10/10 clean ✅
- Generate→validate pipeline: 18/18 ✅
- P0 blocker checks: 5/5 ✅
- All reference files present: 10/10 ✅
- README completeness: 7/7 ✅

---

## [0.9.0] — Phase 3 Complete (2026-05-15)

### Lifecycle Operations
- `references/lifecycle-operations.md` — Phase 1 stub → complete operational guide (7 sections: Bump, TTL Management, Diff-Plan, State Machine, Schedule, Integration, Quick Reference)
- CLI `bump` command: `process-architect bump --skill ./ --type minor "msg" --dry-run`
- CLI `ttl-check` command: `process-architect ttl-check --skill ./` (single) or `--skills a,b` (batch)
- CLI `diff-plan` command: `process-architect diff-plan --skill ./ --since 1.0.0 [--new-materials ./]`
- Template TTL embedding: process-brief.zh, SKILL.zh, artifacts-registry.zh — TTL annotation examples in volatile fields (SLA, roles, storage locations)

### Trace Mode
- `references/trace-mode.md` — complete drift analysis guide (9 sections: Classification, Input Sources, Algorithm, Report Format, CLI Integration, Schema Extension, Schedule, Limitations, Quick Reference)
- CLI `validate --trace`: Drift analysis from CSV flow logs/SLA reports with step classification (matched/shadow/dead/drifted/unobserved) + drift score
- L1.4 `trace_status` field schema: `trace_status`, `trace_last_check`, `trace_delta`, `trace_note`
- Health threshold: drift ≤ 10% healthy, ≤ 25% warning, ≤ 50% unhealthy, > 50% critical
- SKILL.md Step 5.5: Trace Check workflow integrated

### Cross-Process Network
- `references/cross-process-network.md` — complete network design guide (11 sections: Reference Types, Handoff Spec, Algorithm, Map Format, Visualization, Bidirectional Sync, Health Metrics, CLI, Integration, Limitations)
- CLI `network` command: `process-architect network --skills ./_e2e-test/ [--sync] [--output network-map.json]`
  - Auto-discovers process-* directories, parses L1.9 out_of_scope, fuzzy-resolves targets
  - Detects missing backlinks, orphan nodes, unresolved references
  - Generates Mermaid graph visualization
- SKILL.md Step 8: Cross-Process Sync workflow integrated

### CLI Validation Enhancements
- `validate --exceptions`: AP-006 stub → functional implementation (parses L1.4 step IDs, keyword-based criticality detection, .E/.A exception path checking)
- `validate --coverage`: New role coverage check (recipe mentions per role, ≥ 3 covered threshold, uncovered role suggestions)
- `validate --trace`: New flag with `--trace-source`, `--sla-report`, `--source-type`, `--output` options

### SKILL.md Updates
- Step 5.5: Trace Check integrated into generation workflow
- Step 8: Cross-Process Sync integrated after packaging
- Phase coverage updated: Phase 1 (complete), Phase 2 (complete), Phase 3 (complete), Phase 4 (future)
- References Map: trace-mode.md and cross-process-network.md added

### Meta
- VERSION: 0.5.0 → 0.9.0
- CLI internal VERSION: 0.1.0 → 0.9.0

---

## [0.5.0] — Phase 2 Complete (2026-05-15)

### Input Acquisition Modes (3 new)
- `references/interview-mode.md` — 3-party interview logic (Owner + Operator + Auditor) with merge algorithm and conflict resolution
- `references/auto-scan-mode.md` — URL→draft extraction rules for Confluence/Notion/Jira/BPMN
- `references/gap-survey-guide.md` — role-targeted questionnaire dispatch guide
- 3 interview script templates × bilingual = 6 files
- 4 gap survey templates × bilingual = 8 files

### Output Recipes (8 new, total 14)
- Trainee: Training Module, Onboarding Checklist
- Auditor/Executive: Compliance Memo, Stakeholder One-Pager
- Engineer/All: Metrics Dashboard Spec, Change Announcement
- Operator/Owner: Quick Reference Card, Post-Mortem Template
- All 8 recipes in `output-recipes.md.template.{en,zh}` with structure + tips + tone + anti-example

### L4-L6 Templates (6 new)
- `artifacts-registry.md.template.{en,zh}` — artifact↔step cross-reference
- `visualization-spec.md.template.{en,zh}` — color semantics + rendering rules
- `cases-library.md.template.{en,zh}` — case index + search + template

### CLI Improvements
- CN_BUSINESS_TERMS_ALLOWLIST (37 terms), VAGUE_TERM_WHITELIST, Chinese role pattern matching

### End-to-End (3 SOPs, 18/18 × 3)
- refund process (placeholder) (8 roles), unlock-process (3 roles), enrollment-process (4 scenarios)

---

## [0.1.0] — Phase 1 Complete (2026-05-15)

### Design (from plan v1.0.2)
- L0-L6 seven-layer progressive-loading framework for business processes
- 4 cross-cutting capabilities: Extract, Detect Gaps, Cross-Process, Long-Lived
- 7-role audience model with 5 nature classifications
- 11 Architecture Decision Records (plan §17)
- Gap Handling Policy (4-level response: Detect, Tag, Block, Inferred)
- Anti-Pattern Detection (10 rules: AP-001 through AP-010)

### Verification (pre-Phase-1)
- Spike-01: refund process spike (SOP-type material) (SOP-type material) — passed
- Spike-02: Channel investment process (flowchart-type sparse material) — passed

### Core (Phase 1 delivered)
- `SKILL.md` — entry point with Workflow Step 0-7, constraints, validation checklist
- `references/process-archetype.md` — L0-L6 complete schema (29.3KB), Gap Handling Policy, Anti-Pattern Detection, Lifecycle rules
- `references/role-audience-model.md` — 7 standard roles, 5 nature classifications, recipe→role mapping, coverage rules
- `templates/SKILL.md.template.{en,zh}` — bilingual Skill entry templates
- `templates/references/process-brief.md.template.{en,zh}` — bilingual L1 9-sub-section templates
- `templates/references/foundational-logic.md.template.{en,zh}` — bilingual L2 templates
- `templates/references/output-recipes.md.template.{en,zh}` — bilingual L3 templates with 6 high-frequency recipes (SOP, Runbook, RACIO, FAQ, Process Map, Exception Playbook), each with structure + writing tips + tone sample + anti-example
- `templates/CHANGELOG.md.template.{en,zh}` — bilingual changelog templates
- `templates/VERSION.template` — version file template
- `cli/meta-skill-process-architect.py` — CLI with init/generate/validate/package commands, anti-pattern scanning (6 of 10 checks active in Phase 1)
- `LICENSE` (MIT), `.gitignore`, `CHANGELOG.md`
- `VERSION` set to 0.1.0

### End-to-End Test
- CLI init → generate → validate → package pipeline tested with internal refund SOP materials
- Validate passed 16/18 checks (2 warnings for placeholder content, expected)
- Package (tar.gz) produced successfully

### Decisions
- OQ-001 resolved: Mermaid as primary diagram format (BPMN deferred to Phase 3)
- Plan remains canonical source of truth; all implementation references plan ADRs
