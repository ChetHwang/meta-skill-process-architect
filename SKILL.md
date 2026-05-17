---
name: meta-skill-process-architect
description: Generate a complete, reusable business process Skill from any process's raw materials. Handles SOPs, flowcharts, Wiki pages, interview transcripts, and Jira logs; reshapes them into a standardized L0-L6 layered process knowledge base; outputs a cross-platform Skill package ready for WorkBuddy, OpenClaw, or Claude Code. Not for: simple 1-2 step flows, product introductions (use meta-skill-product-architect). 中文触发：生成流程 / 流程文档化 / 建立流程Skill / 流程梳理 / process documentation
agent_created: true
---

# Meta-Skill Process Architect

## TL;DR

如果你是 agent：先加载 `references/process-archetype.md` + `references/role-audience-model.md`（Step 1），然后按 Step 2→3→4→5→5.5→6→7→8 线性执行。Step 3 必须等用户确认。Step 4 完成 L1 后暂停确认 process-brief 再生成 L2-L6。Step 6 后暂停确认 recipe 生成结果再打包。遇到 P0 阻断（缺 process_name/trigger/owner/roles<2）立即停止，向用户索要信息。

## Overview

A meta-skill that transforms raw process materials into a complete, structured process Skill. The output Skill enables consistent process execution, training, auditing, and improvement across any role, format, or platform.

**What it produces**: A full Skill package named `process-{name}` following a standardized 7-layer progressive-loading architecture (L0-L6), with 6 cross-cutting capabilities (C1 Extract, C2 Detect Gaps, C3 Cross-Process, C4 Long-Lived, C5 Cycle Time, C6 Internal Handoff).

**Cross-platform**: The output Skill works on WorkBuddy, OpenClaw, Claude Code, or as a standalone knowledge bundle.

**Sister meta-skill**: `meta-skill-product-architect` — for product introductions vs process documentation. They share ~40% DNA but serve different domains.

**When NOT to use this skill**:
- Simple 1-2 step workflows that don't involve role handoffs, exceptions, or SLAs — a paragraph of text or a Mermaid diagram suffices
- Product/feature introductions → use `meta-skill-product-architect` instead
- Pure data pipelines (no human decision points) → consider a data pipeline skill
- Ad-hoc one-time tasks without reuse intent → a checklist is enough

---

## Execution Budget

This meta-skill loads significant context. Every run has a cost. The budget model is **honest** — based on what the agent can actually count (conversation turns), not what it can't (real-time token consumption).

| Budget Item | Limit | Enforcement |
|---|---|---|
| **Turn budget** | 30 conversation turns per full generation | Hard. Agent counts "this is turn N/30" at each checkpoint |
| **Warning threshold** | 20 turns | Agent warns: "{10} turns remaining. Continue or package now?" |
| **Exceeded** | > 30 turns | Deliver what's generated. Flag remaining layers as `[UNFINISHED]`. Write `STATUS.md` for resume |
| **Estimated token baseline** | ~15,000 tokens (SKILL.md + archetype + role-model) | Informational. Reported at Step 1 |

The agent MUST report its turn count at every checkpoint (Steps 3, 4 L1 checkpoint, 6.5): "Turn {N}/30. Estimated tokens consumed: ~{E}".

This is not a financial circuit breaker — it's a **conversation hygiene** contract that prevents unbounded generation loops.

---

## Before You Start — Required Inputs

To generate a quality process Skill, gather these materials before invoking this meta-skill. Sparse input produces a sparse Skill; complete input produces an executable one.

**Sparse input threshold**: If ≥3 of the 6 Required items are missing, stop and recommend Interview Mode or Gap Survey before proceeding. A Skill with too many gaps generates more follow-up questions than it answers.

### Required (minimum viable input)

| Category | What to provide | Why needed |
|---|---|---|
| Process identity | Process name, one-sentence purpose | L0 entry layer |
| Trigger event | What concrete event starts this process? ("Customer submits refund form" NOT "开始") | L1.1 — P0 blocker if missing |
| Process owner | Who is accountable for the process outcome? | L0 — P0 blocker if missing |
| Participating roles | ≥ 2 distinct roles involved in the process | L1.3 — P0 blocker if < 2 |
| Step sequence | At minimum: a rough list of steps in order | L1.4 — core structure |
| Outputs / deliverables | What does the process produce at the end? | L0 outputs_summary |

### Recommended (produces a much better Skill)

| Category | What to provide | Granularity |
|---|---|---|
| Standard Operating Procedure | Formal SOP document with numbered steps, decision points, SLAs | Full document |
| Flowchart / Process map | Visual flow (Mermaid, BPMN, Visio, Lucidchart, or hand-drawn) | Can be image or source file |
| RACI matrix | Step × Role accountability grid | Table format |
| SLA commitments | Time budgets for key steps + overall process | Concrete numbers (hours/days) |
| Exception handling | Known exception scenarios + handling procedures | Per-step if available |
| Decision criteria | How are branch decisions made? (algorithmic / discretionary / undocumented) | Per decision point |
| Compliance requirements | Regulatory standards, internal policies, audit requirements | Citation + clause reference |
| Historical cases | Past incidents, near-misses, successful executions | 1+ cases preferred |

### Optional (adds depth)

| Category | What to provide | Format |
|---|---|---|
| Training materials | Existing training docs, onboarding guides | Text or links |
| Tool references | System URLs, form IDs, API endpoints used in the process | URLs + context |
| Metrics data | Historical SLA compliance, throughput, error rates | Numbers |
| Interview access | 15-20 min with process owner + 1-2 operators | Scheduled conversation |
| Jira/Linear/Asana logs | Actual ticket flow data for Trace Mode (Phase 3) | Export or URL |

### Material Acquisition Modes

You don't need all materials upfront. Choose a mode:

| Mode | When to use | Reference |
|---|---|---|
| **BYO Materials** (default) | User has gathered SOPs, flowcharts, Wiki pages | This file's Required Inputs table |
| **Interview Mode** | Process owner + 1-2 operators available for 15-20 min each | `references/interview-mode.md` (Phase 2) |
| **Auto-Scan Mode** | Confluence / Notion / Jira URLs available | `references/auto-scan-mode.md` (Phase 2) |
| **Gap Survey** | Specific layers missing after another mode | `references/gap-survey-guide.md` (Phase 2) |
| **Hybrid** | Combine modes (e.g., Auto-Scan draft + Interview for gaps) | All of the above |

---

## Workflow

> **The agent-driven workflow below is canonical.** A companion CLI in `cli/meta-skill-process-architect.py` mirrors the same lifecycle for scriptable use, but the agent flow is the source of truth.

### Step 0 — Pre-Flight

Confirm three things before any material collection or analysis:

1. **Primary language** — Chinese (zh) or English (en). Selects template variants. Default = language of bulk materials.
2. **Process type at a glance** — SOP-type (documented, formal) or flowchart-type (visual, sparse). This calibrates Gap Detection sensitivity (flowchart-type materials will have more gaps).
3. **Output Skill name** — confirm `process-{kebab-case-name}` slug. Flag if the directory already exists.

Do not proceed past Pre-Flight without these three confirmations.

### Step 0.5 — Input Size Gate

Before loading the framework, estimate total input material size:

| Condition | Action |
|---|---|
| Total input > 100KB (text) or > 5 files | ⚠️ Flag `[LARGE INPUT]`. Ask user: "This is a large input set. Proceed, trim, or split into multiple runs?" |
| Single file > 500KB | 🚫 Reject. Suggest trimming to essential sections or splitting. |
| Total input < 1KB | ⚠️ Flag `[SPARSE INPUT]`. Confirm with user that they want to proceed with minimal materials. |

This gate prevents token drain from excessively large inputs and gives the user a cost expectation before any framework context is loaded.

### Step 1 — Load the Framework

Read these files fully before extraction:

1. **`references/process-archetype.md`** — L0-L6 complete schema, Gap Handling Policy (4-level), Anti-Pattern Detection (10 rules), Lifecycle rules. This is the single source of truth.
2. **`references/role-audience-model.md`** — 7 standard roles, role nature classification, recipe→role mapping, coverage rules.

Do not attempt extraction without loading both files. All extraction decisions must reference specific sections of the archetype.

**Circuit Breaker**: If either `process-archetype.md` or `role-audience-model.md` cannot be loaded (file missing, unreadable, or empty):
→ 🚫 **Halt immediately.** Do NOT attempt extraction with partial framework knowledge.
→ Inform the user: "Cannot proceed — `{filename}` is {missing/unreadable}. The meta-skill requires both core reference files."
→ Do NOT substitute with guesswork, memory, or general knowledge of process documentation.

### Step 2 — Extract L0 + L1 (Primary Extraction)

Apply C1 (Extract) to fill L0 and L1 from the input materials.

**Process**:
1. Map every piece of input material to its corresponding L0/L1 field
2. Apply C2 (Detect Gaps) simultaneously — do not defer gap detection to a later step
3. Mark every field with its provenance: `[explicit]`, `[inferred from {basis}]`, or `[GAP — {category}]`
4. If multiple sources conflict on a field, mark `[CONFLICT]` and present options at Step 3 checkpoint

**P0 Blocker Check** — halt extraction immediately if any of these are missing:
- `process_name` empty
- `purpose_one_liner` empty
- `trigger.source` empty or no-information ("开始"/"Start") or abstract-state-only ("到期"/"超时"/"完成"/"触发" without a concrete observable event — e.g. "报名截止日期到期" is concrete; "到期" alone is not)
- `process_owner.primary` empty
- `involved_roles` count < 2

Do not proceed to Step 3 if P0 blockers exist. Instead, prompt user to supply missing information via Interview or additional materials.

### Step 3 — Checkpoint: Present Gaps + Inferences to User

Before generating any output, present:

1. **P0 blockers** (if any were missed in Step 2 — should be zero by now)
2. **GAP-tagged fields** with source suggestions where known
3. **Inferred fields** with their basis — user must confirm or override each
4. **CONFLICT-tagged fields** — present both sources, ask user to resolve
5. **Anti-pattern warnings** triggered during extraction (AP-001, AP-002)

Format: structured table with Field / Current Value / Status / Action Required columns.

**Example Checkpoint Table**:

| Field | Current Value | Status | Action Required |
|---|---|---|---|
| `process_owner.primary` | (empty) | 🔴 P0 BLOCK | Interview process initiator to identify owner |
| `trigger.source` | "客户提交退款申请" | ✅ Explicit | — |
| `L1.8 SLA resolution time` | 4 business hours | 🟡 [inferred from step S3 duration] | Confirm: is 4h the actual SLA target? |
| `roles[3].name` | "张三" | ⚠️ AP-002 | Replace with role title, not person name |
| `L1.6 state_machine` | (empty) | 🔵 [GAP — state_machine, likely source: ticket system] | Ask system engineer for state definitions |

Do not proceed until user confirms or resolves all 🔴 and 🟡 items. If user wants to skip, mark unresolved items as `[UNCONFIRMED]` and note in generated Skill's CHANGELOG.

### Step 4 — Generate L1-L6 Content

With confirmed L0+L1 data, generate the remaining layers:

| Layer | Action | Key Instructions (from Archetype) |
|---|---|---|
| L1.1-.9 | Complete all 9 sub-sections with confirmed data | L1.1 trigger must be concrete event, not concept; L1.3 roles must be functions not persons; L1.4 every step has executor_role; L1.8 SLA numbers must be concrete (no "快速"/"尽快") |

**🛑 L1 Checkpoint**: After generating L1.1-.9, present the completed process-brief to the user before continuing to L2-L6. Confirm:
1. All 9 L1 sub-sections populated (no gaps deferred to later)
2. Trigger, roles, steps, SLA match the confirmed data from Step 3
3. C4 TTL markers applied to volatile fields (SLA numbers, tool URLs, contact names)
4. Cycle Time analysis (C5) computed and attached as `<!-- Cycle Time -->` comment on L1.4

If the user requests L1 corrections, apply them now — changing L1 after L2-L6 are generated causes cascading rework across all derivative layers. Proceed to L2-L6 only after L1 is confirmed.

| L2 | Extract foundational logic: purpose, tradeoffs, design principles, source attribution, role-language interface | Purpose ≠ L0 overview — explain WHY the process is designed this way. Source attribution must cite a real methodology (not "经验") |
| L3 | Generate output recipes matching involved roles (see Step 6 for full 14-recipe catalog + auto-generate rules) | Each recipe: structure section + writing tips + tone sample + anti-example. Generate in output-recipes.md |
| L4 | Index process artifacts (forms, checklists, templates, reports) | Every artifact: which step uses it + which role owns it + where it lives + when it expires |
| L5 | Define visualization spec (Mermaid conventions, color semantics) | Swimlane = role; diamond = decision; red = exception path |
| L6 | Create case library entry (at least 1 placeholder if no real cases) | Placeholder format: `[PLACEHOLDER]` + field description. Do NOT invent fake cases |

**C3 (Cross-Process)**: If L1.9 scope boundaries reference other processes, create handoff_event entries. If the referenced process has an existing Skill, link to it.

**C6 (Internal Handoff Detection)**: Scan L1.4 for role transitions within the same department:
- Every time `executor_role` changes between consecutive steps, mark an internal handoff
- If the handoff crosses team boundaries (e.g., 教学→财务), add a `[HANDOFF]` inline comment in L1.4
- Append an "Internal Handoff Summary" to L1.9: list of (from_step, from_role → to_step, to_role) with the nature of the handoff (information / escalation / approval)
- This prevents "throw-it-over-the-wall" process failures where a step says "移交至财务" but no one in finance knows they've been handed the baton

**C4 (Long-Lived)**: Apply TTL markers to volatile fields (SLA numbers, tool URLs, contact names). Set initial VERSION to 1.0.0. Write initial CHANGELOG entry.

**C5 (Cycle Time Analysis)**: After generating all L1.4 steps with durations, compute and append to the process-brief:

1. **Fastest path**: Sum durations of the shortest path from trigger to any END state (happy path, no exceptions)
2. **Slowest path**: Sum durations of the longest path including all exception loops (.E/.A) and secondary branches (.B)
3. **Bottleneck step**: The single step with the highest duration on the happy path — mark it in L1.4 as `**瓶颈步骤**`
4. **Total cycle time range**: "Fastest: {X} days/hours — Slowest: {Y} days/hours"

Append as a comment block at the end of L1.4: `<!-- Cycle Time: fastest=X, slowest=Y, bottleneck=S{N} -->`. This enables future Trace Mode to compare planned vs actual cycle times.

### Step 5 — Anti-Pattern Scan

Run all 10 anti-pattern checks (AP-001 through AP-010) against the generated content:

| Severity | Action |
|---|---|
| **Block** (AP-003, AP-008) | Halt. Must fix before delivering Skill. |
| **Warn-with-confirm** (AP-001, AP-002, AP-007) | Warn user. Require explicit confirmation to proceed. |
| **Warn-passive** (AP-004, AP-005, AP-006, AP-009, AP-010) | List in final report. Do not block. |

If any Block anti-pattern fires, return to Step 3 with the specific issue for resolution.

### Step 5.5 — Trace Check (Phase 3)

If trace data is available (Jira/Linear flow logs, SLA reports, or manual observation notes), run a drift analysis:

1. **Load trace data**: If `--trace-source` or `--sla-report` provided, parse CSV
2. **Compare** documented L1.4 steps against observed execution:
   - Classify each step as `matched` / `shadow` / `dead` / `drifted`
   - Calculate `drift_score = (shadow + dead + drifted) / total × 100%`
3. **Flag unhealthy drift**: If drift > 10%, present `[DRIFT WARNING]` and recommend review
4. **Add `trace_status`** to L1.4 steps that were compared

Reference: `references/trace-mode.md` for full methodology.

### Step 6 — Generate Output Recipes

Based on `involved_roles` and `default_recipe`, generate the output materials. The full recipe catalog:

| # | Recipe | Primary Role | Auto-Generate Rule |
|---|---|---|---|
| 1 | SOP | Operator + Auditor | Always (default) |
| 2 | Runbook | Operator | Always |
| 3 | Training Module | Trainee | If trainee/newcomer role present |
| 4 | Quick Reference Card | Operator | If operator role present |
| 5 | Process Map (Mermaid) | Analyst + Owner | Always |
| 6 | RACIO Matrix | Manager + PMO | Always |
| 7 | Compliance Memo | Auditor + Compliance | If auditor/compliance role |
| 8 | Stakeholder One-Pager | Executive + External | If executive/external role |
| 9 | FAQ | Operator + Stakeholder | If ≥ 1 operator or customer role |
| 10 | Exception Playbook | Operator + Owner | If ≥ 2 exception paths in L1.4 |
| 11 | Metrics Dashboard Spec | Owner + Engineer | If metrics/SLA data available |
| 12 | Change Announcement | All Roles | On MAJOR version bumps only |
| 13 | Onboarding Checklist | Trainee + Buddy | If trainee/newcomer role present |
| 14 | Post-Mortem Template | Owner + Engineer | If incident history exists |

Recipes 1-6 are high-frequency (Phase 1). Recipes 7-14 are extended (Phase 2). Each recipe must follow the structure in `references/process-archetype.md` §Recipe Schema (Recommended Structure / Writing Tips / Tone Sample / Anti-Example).

**Coverage check**: Verify ≥ `min(involved_roles_count, 3)` roles are covered by the generated recipes. For 2-role processes this means ≥ 2; for 3+ this means ≥ 3. If not, recommend additional recipes for uncovered roles.

### Step 6.5 — Checkpoint: Confirm Recipes Before Packaging

Before writing files to disk, present the generated recipes to the user:

1. **List all generated recipes** with their target roles and a one-line description
2. **Coverage summary**: "Generated {N} recipes covering {M}/{T} roles"
3. **Ask**: "Ready to package? Or would you like to adjust any recipe?"
4. **Wait for user confirmation** before proceeding to Step 7

This checkpoint prevents packaging a Skill with recipes the user hasn't seen.

### Step 7 — Package + Validate

**Package**:
1. Write all generated content to the `process-{name}/` directory following the standard structure
2. Write `generated_by_meta_skill_version: {current VERSION}` to the output SKILL.md frontmatter (enables downstream compatibility checks)
3. Include VERSION (1.0.0), CHANGELOG.md (initial entry with `valid_from` + `lifecycle_phase=draft`), LICENSE
4. Include all generated recipes as separate files or sections in `references/output-recipes.md`

**Validate**:
1. Structural completeness — all L0-L6 layers present
2. Content specificity — no "快速"/"around"/"typically" in durations; every step has executor; every decision has quality
3. Coverage test — ≥ min(involved_roles_count, 3) roles covered
4. Exception test — every happy-path step has ≥ 1 .E or .A sibling
5. Anti-pattern scan — zero Block-level issues

**Acceptance Test** (manual post-generation):
- Find someone unfamiliar with this process
- Give them SOP + Training Module (if generated) + Quick Reference Card
- Ask them to describe the process end-to-end
- If they can't, identify the gap and improve the Skill

### Step 8 — Cross-Process Sync (Phase 3)

After generating a new Skill, check and synchronize cross-process references:

1. **Scan for handoff references**: Parse this Skill's L1.9 `out_of_scope` section for references to other processes
2. **Resolve targets**: Check if referenced process Skills exist in the same workspace
3. **Detect missing backlinks**: For each resolved reference (A → B), check if B's L1.9 references A back
4. **Auto-suggest backlinks**: If a backlink is missing, generate a suggested `out_of_scope` entry for the target Skill
5. **Update network map**: Re-run `process-architect network --skills ./` to refresh the network visualization
6. **Flag orphans**: If this Skill has zero incoming references, flag as potentially needing discovery

Reference: `references/cross-process-network.md` for full network methodology.

### Step 8.5 — Session Integrity

If the user stops responding or the conversation is interrupted:

1. **Save immediately**: Write all generated content to `process-{name}/` directory before exiting
2. **Write STATUS.md**: Record which steps completed, which are pending, current turn count, and what the next action should be
3. **Mark incomplete layers**: Tag unfinished sections with `[UNFINISHED — resume from Step {N}]`
4. **Next session**: The agent reads STATUS.md and resumes from the incomplete step

This ensures that a 25-turn generation that gets interrupted doesn't lose all work — it becomes a checkpoint the next session can continue from.

---

## Constraints

### Hard Constraints (must always hold)

1. **No hallucination**: Never invent process details not present in materials. Mark gaps explicitly — do not guess.
2. **P0 blockers are absolute**: Do not skip or override the 5 P0 blocker checks.
3. **Role count ≥ 2**: A process with fewer than 2 roles is not a process.
4. **Source Attribution not empty**: L2 must cite a methodology or framework.
5. **≥ min(N, 3) roles covered**: Generated Skill must serve at least `min(involved_roles_count, 3)` of the 7 standard roles. For a 2-role process this means ≥ 2; for 3+ roles this means ≥ 3. If the process has only 1 role, P0 blocker fires.
6. **Plan is canonical**: If this SKILL.md conflicts with `meta-skill-process-architect-plan.md`, the plan wins. Update this file to match the plan.

### Soft Constraints (should hold, flag if violated)

7. **Every step has exception path**: Happy-path steps should have .E or .A siblings.
8. **No person names as role names**: Roles are functions, not individuals.
9. **Concrete durations only**: "5 minutes" not "快速". "2 business days" not "尽快".
10. **All inferred fields confirmed**: No inferred field enters final Skill without Step 3 user confirmation.

### Retry, Timeout & Escape Contract

11. **Max retries per generation step**: 2. On the 3rd failure of any layer (L1-L6), mark the layer as `[FAILED]`, present partial results, and ask the user: "Skip this layer, retry with different input, or abort?"
12. **Hard turn budget**: 30 conversation turns (see Execution Budget). When exceeded, deliver what exists, mark unfinished layers `[UNFINISHED]`.
13. **No unbounded loops**: If the same anti-pattern fires 3+ times after attempted fixes, stop and escalate to the user rather than looping indefinitely.

14. **Universal escape hatch**: Every process must have a generic fallback rule. The last item in L1.4 should be a catch-all step:
    ```
    S{N}.X — 未覆盖异常
    执行角色：process_owner
    动作：升级至流程负责人判断并记录。记录后决定：按最近似已知路径处理 / 暂停等待决策 / 创建新例外路径
    ```
    This ensures that when reality produces an exception not covered by .E/.A paths, the process doesn't silently break — it escalates to human judgment and captures the gap for future improvement.

---

## Validation Checklist

After generation, verify:

### Pre-Delivery

- [ ] All P0 blockers resolved
- [ ] All GAP fields either filled or explicitly marked `[UNCONFIRMED]`
- [ ] All inferred fields confirmed by user
- [ ] Anti-pattern scan: zero Block-level issues
- [ ] Warn-with-confirm issues acknowledged by user
- [ ] L1 all 9 sub-sections present
- [ ] L2 source_attribution not empty
- [ ] L3 ≥ min(involved_roles_count, 3) recipes targeting ≥ min(involved_roles_count, 3) roles
- [ ] No "快速"/"尽快"/"around" in durations or SLAs
- [ ] Every step has concrete executor_role
- [ ] CHANGELOG.md written with initial entry
- [ ] VERSION set to 1.0.0

### Post-Delivery (manual)

- [ ] Acceptance Test: unfamiliar person can describe process end-to-end
- [ ] Process owner reviews and signs off
- [ ] At least 1 operator confirms the steps match reality

---

## Output Skill Structure

```
process-{name}/
├── SKILL.md                               # Entry point (L0)
├── VERSION
├── CHANGELOG.md
├── agents/openai.yaml
├── references/
│   ├── process-brief.md                   # L1 — 9 sub-sections
│   ├── foundational-logic.md              # L2 — purpose, tradeoffs, source
│   ├── output-recipes.md                  # L3 — generated recipes
│   ├── artifacts-registry.md              # L4 — forms, templates, checklists
│   ├── visualization-spec.md              # L5 — diagram conventions
│   └── cases-library.md                   # L6 — cases & lessons
└── assets/
    ├── flowcharts/                        # Mermaid source files
    ├── forms/                             # Process forms
    └── templates/                         # Output templates
```

---

## References Map

| Reference | Content | When to Read |
|---|---|---|
| `references/process-archetype.md` | L0-L6 schema, Gap Handling, Anti-Patterns, Lifecycle | Step 1 — mandatory |
| `references/role-audience-model.md` | 7 roles, nature classification, recipe mapping | Step 1 — mandatory |
| `references/interview-mode.md` | 3-party interview scripts (Phase 2) | When using Interview Mode |
| `references/auto-scan-mode.md` | URL-driven extraction (Phase 2) | When using Auto-Scan Mode |
| `references/gap-survey-guide.md` | Role-specific questionnaires (Phase 2) | When using Gap Survey |
| `references/trace-mode.md` | Real vs documented drift analysis (Phase 3) | When using Trace Mode |
| `references/lifecycle-operations.md` | Version bump rules, TTL syntax, diff-aware update | When maintaining a Skill |
| `references/platform-adapters.md` | Cross-platform packaging | When packaging for distribution |
| `references/distribution-guidelines.md` | Distribution best practices | When publishing |
| `references/impact-analysis.md` | Process change impact analysis (Phase 5) | Before making process changes |

---

## Relationship to Plan

This SKILL.md is the **operational entry point** for the meta-skill. The **canonical design** is in `DESIGN.md` (standalone) and `../meta-skill-process-architect-plan.md` (full in monorepo). If this file conflicts with the design documents, the design documents win. All structural design decisions must reference DESIGN.md ADRs.

**Phase coverage**:
- Phase 1 (complete): BYO Materials mode, 6 high-frequency recipes, L0-L6 core, Gap Handling Levels 1-3, all 10 anti-patterns
- Phase 2 (complete): Interview/Auto-Scan/Survey modes, 8 remaining recipes, L4-L6 detailed templates
- Phase 3 (complete): Trace Mode (Step 5.5), lifecycle automation (bump/ttl-check/diff-plan CLI), Cross-Process Network (Step 8, network CLI)
- Phase 4 (complete): README v1.0.0, examples/, self-validation, git init — **published**
- Phase 5 (complete): Impact Analysis (`references/impact-analysis.md`), SLA cascade, cross-process ripple, risk 3-tier classification. **v1.2.0**: Temporal Validity — lifecycle phases (draft/trial/active/superseded/retired), `which-version` CLI, `generated_by_meta_skill_version` version tracking
