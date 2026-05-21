# Process Archetype — L0-L6 Complete Definition

> **This file is the single source of truth for every process Skill's structure.**
> When generating a `process-{name}` Skill, follow this archetype exactly.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                   Cross-Cutting Capabilities (active in all layers) │
│  C1 Extract │ C2 Detect Gaps │ C3 Cross-Process │ C4 Long-Lived      │
├──────────────────────────────────────────────────────────────────────┤
│   L0 — Entry Layer (SKILL.md)                                       │
│   L1 — Process Brief (9 sub-sections, the heaviest layer)           │
│   L2 — Foundational Logic                                           │
│   L3 — Output Recipes (14 standard formats)                         │
│   L4 — Process Artifacts                                            │
│   L5 — Process Visualization                                        │
│   L6 — Cases & Learning Library                                     │
├──────────────────────────────────────────────────────────────────────┤
│  Anti-Patterns Detection │ Validation Framework │ Lifecycle Ops      │
└──────────────────────────────────────────────────────────────────────┘
```

**Progressive Loading Principle**: Layers ascend in cost-to-fill. L0 loads in seconds. L1 is the main work. L2-L6 add depth on demand. Do not skip layers — each is a prerequisite for the next.

---

## Cross-Cutting Capabilities (Active in ALL Layers)

These four capabilities are NOT layers. They are **runtime behaviors** that operate on every layer during generation.

### C1 — Extract

Map raw input materials to L0-L6 schema fields. Accept any format: SOP documents, flowcharts, Wiki pages, interview transcripts, Jira logs.

**Extraction rules**:
- Prefer explicit over inferred. Never "hallucinate" fields that aren't in the source.
- When multiple sources conflict, flag the conflict in a `[CONFLICT]` annotation and present to user at Step 2 Checkpoint.
- Accept zero: if a field has no material, don't force-fill it — let Gap Detection handle it (C2).

### C2 — Detect Gaps

Proactively identify missing information. See §Gap Handling Policy below for full 4-level response.

**Do this DURING extraction, not after.** Gap Detection is not a post-processing step — it's a companion to C1.

### C3 — Cross-Process

When a process references another process (in scope boundaries, handoffs, artifact handovers), explicitly model the connection:

- Record `handoff_event` in L1.10
- If the referenced process already has a Skill, link to it
- If not, create a placeholder entry with `[CROSS-PROCESS — needs separate generation]`

### C4 — Long-Lived

Every generated Skill must carry:
- `VERSION` file (semver)
- `CHANGELOG.md` (every change one line)
- TTL markers on volatile fields (SLA numbers, tool URLs, contact names, volume claims)
- Version bump rules per change type (see Lifecycle Operations § at end)

---

## L0 — Entry Layer (SKILL.md)

This is what a human reads first. It must be self-contained and answer "what is this process, who owns it, and what does it produce?" in under 60 seconds.

### Schema

```yaml
process_name: <string>                          # Official name, kebab-case for file naming
process_version: <semver>                       # Start at 1.0.0. Follows semver: MAJOR.MINOR.PATCH
version_valid_from: <date>                      # Date this version became effective. Empty during "draft" phase. Format: YYYY-MM-DD
version_valid_until: <date>                     # Date this version was superseded. Empty for current version. Format: YYYY-MM-DD
lifecycle_phase: <phase>                        # One of: draft | trial | active | superseded | retired
trial_until: <date>                             # Trial/grace period end date. Only relevant when lifecycle_phase=trial. Format: YYYY-MM-DD
purpose_one_liner: <string>                    # One sentence. Why does this process exist?
process_sponsor: <role>                         # Who decided this process should exist
process_owner:                                  # Who is accountable for results
  primary: <role>                               # Overall accountable person/role
  per_team:                                     # Optional: sub-owners for cross-team processes
    - team: <team_name>
      role: <role>
involved_roles: <list of role_id>              # References L1.3 detailed role definitions
trigger_summary: <string>                       # One sentence. What event starts this process.
outputs_summary: <list of string>              # What deliverables come out the other end.
invariants:                                     # Non-negotiable constraints
  - id: <string>                                # e.g. AP01
    rule: <string>                              # e.g. "Legal docs MUST be signed before equipment provisioning"
    enforcement: <enum: hard | soft>
default_recipe: <recipe_id>                     # What output format to generate when not specified
language: <enum: zh | en | other>
```

### Field Constraints

| Field | Required | Gap Level if Missing |
|---|---|---|
| `process_name` | **P0 BLOCK** | Level 3 |
| `purpose_one_liner` | **P0 BLOCK** | Level 3 |
| `process_owner.primary` | **P0 BLOCK** | Level 3 |
| `trigger_summary` | **P0 BLOCK** (must be specific, "开始/Start" is BLOCK) | Level 3 |
| `involved_roles` | **P0 BLOCK** if count < 2 | Level 3 |
| `process_sponsor` | Required | Level 2 |
| `outputs_summary` | Required | Level 2 |
| `invariants` | Optional (can be empty) | Level 1 |
| `process_version` | Auto-set to "1.0.0" on generation | — |
| `version_valid_from` | Auto-set to empty on generation (draft phase). Set on first publish | — |
| `version_valid_until` | Auto-set to empty on generation. Set when superseded by new version | — |
| `lifecycle_phase` | Auto-set to "draft" on generation | — |
| `trial_until` | Auto-set to empty on generation. Set when entering trial phase | — |
| `default_recipe` | Auto-set to "SOP" if not specified | — |
| `language` | Auto-detect from materials | — |

### Lifecycle Phase Definitions

| Phase | Meaning | valid_from | valid_until | Behavior |
|---|---|---|---|---|
| **draft** | Work in progress, not yet published for business use | empty | empty | Any number of edits; no version bump required on each save |
| **trial** | Published with a grace period where errors are corrected without penalty | filled (release date) | empty | Business-visible; audit uses trial standard (改正不惩罚) |
| **active** | Formal enforcement; errors trigger accountability per SLA | filled (trial end date or release date) | empty | Full SLA enforcement; audit uses strict standard |
| **superseded** | Replaced by a newer version; retained for historical audit only | filled (was active from) | filled (date new version took over) | Only used for retroactive audit (`which-version --at`) |
| **retired** | Process no longer in use | filled (was active from) | filled (retirement date) | Archived; not checked by `validate`

### Good Fill vs Bad Fill

**Bad Fill** (generic, unactionable):
```yaml
process_name: "Customer Support"
purpose_one_liner: "Handle customer issues"
trigger_summary: "Customer contacts us"
```

**Good Fill** (specific, actionable):
```yaml
process_name: "Customer Refund Processing"
purpose_one_liner: "Process a customer refund request from initial receipt to funds returned, with 4-hour SLA for P0 cases"
trigger_summary: "Customer submits refund request via in-app form, email, or phone"
```

---

## L1 — Process Brief

This is the deepest layer. It contains **9 mandatory sub-sections**. Together they form the complete operational definition of the process.

### L1.1 — Triggers

```yaml
trigger:
  type: <enum: event | schedule | request | continuous>
  source: <string>                              # Concrete event, e.g. "Customer submits refund request via in-app form"
  initial_state: <string>                       # What state does the process enter upon trigger
  preconditions: <list>                         # Must-be-true conditions before process can start
  post_conditions: <list>                       # Must-be-true conditions when process is triggered
```

**Gap Rule**: If `trigger.source` is empty, "开始", "Start", "N/A", or any other no-information word → **Level 3 BLOCK**. Cannot proceed.

**Examples**:

Good:
```yaml
trigger:
  type: event
  source: "Signed offer letter received in ATS (Greenhouse)"
  initial_state: "Pending-Background-Check"
  preconditions:
    - "Offer letter signed by both candidate and hiring manager"
    - "Start date confirmed (≥ 14 days from today)"
  post_conditions:
    - "Candidate record created in HRIS"
    - "Onboarding ticket auto-generated"
```

Bad (BLOCK):
```yaml
trigger:
  type: event
  source: "开始"  # ← Will trigger Level 3 BLOCK
```

### L1.2 — Inputs

```yaml
inputs:
  - name: <string>
    source: <string>                            # Who/what system provides this
    required: <bool>
    used_in_step: <list of step_id>            # Which steps consume this input
```

**Rules**:
- `required: true/false` is mandatory.
- If material doesn't distinguish required vs optional, default all to `required: true` and mark `[inferred-required]` for user confirmation.

### L1.3 — Roles & Responsibilities

```yaml
roles:
  - id: <string>                                # Short identifier, e.g. "cs-agent"
    name: <string>                              # Human-readable, e.g. "Customer Service Agent"
    persona: <string>                           # One-sentence profile
    boundaries: <string>                        # Responsibility boundaries and decision authority
    nature: <enum: static | transient | conditional | external | oversight>
    home_team: <team_id>                        # Administrative home
    collaboration_context: <list of team_id>    # Teams where work actually happens (swimlane)
    binding_rule:                               # ONLY when nature == conditional
      - if: <expression>
        binds_to: <role_id>
      - elif: <expression>
        binds_to: <role_id>
      - else:
        binds_to: <role_id>
```

**5 Role Natures**:

| Nature | Meaning | Example |
|---|---|---|
| `static` | Fixed assignment, always the same person/team | "Finance Reviewer" |
| `transient` | Event-triggered temporary assignment | "First Responder" (whoever picks up the ticket first) |
| `conditional` | Role = function(context) | "Retention Owner" = f(honeymoon_period, transfer_status) |
| `external` | Outside the company | "Distributor", "Regulatory Agency" |
| `oversight` | Post-hoc audit/compliance, NOT in execution chain | "Quality Auditor", "SOC2 Reviewer" |

**Anti-Pattern Check** (applied at extraction time):
- AP-001: role.name length ≤ 2 characters AND not in allowlist → `[ANTI-PATTERN — possible person-name hardcoded]`
- AP-002: role.name matches known person name → `[ANTI-PATTERN — use role name, not person name]`

**Good Example**:
```yaml
roles:
  - id: "cs-agent"
    name: "Customer Service Agent"
    persona: "Front-line support, first point of contact for customer refund requests"
    boundaries: "Can approve refunds ≤ ¥200. Must escalate ≥ ¥200 to Team Lead."
    nature: static
    home_team: "customer-service"
    collaboration_context: ["customer-service"]
  - id: "retention-owner"
    name: "Retention Specialist"
    persona: "Handles at-risk students, decides whether to offer retention package"
    boundaries: "Can offer retention package within approved budget. Cannot override refund policy timelines."
    nature: conditional
    home_team: "retention"
    collaboration_context: ["retention", "customer-service"]
    binding_rule:
      - if: "student in honeymoon period AND not transferred"
        binds_to: "retention-senior"
      - else:
        binds_to: "retention-junior"
  - id: "qa-auditor"
    name: "Quality Auditor"
    persona: "Reviews closed refund cases for compliance and quality"
    boundaries: "Can flag cases for rework. Cannot modify cases directly."
    nature: oversight
    home_team: "quality-operations"
    collaboration_context: ["quality-operations"]
```

### L1.4 — Step Sequence

```yaml
steps:
  - id: <S\d+(\.[E|A|B]|\.\d+)?>                 # Step ID with naming convention
    name: <string>
    executor_role: <role_id>                       # Single, mandatory
    inputs: <list of {source_step_id, data_name}>
    actions: <list of string>                      # Verb-starting, executable descriptions
    outputs: <list of string>
    duration:
      type: <enum: instant | clock_hours | business_days | calendar_window>
      value: <number>                              # For instant/clock_hours/business_days
      window:                                      # For type == calendar_window
        start_day: <Mon-Sun>
        start_time: <HH:MM>
        end_day: <Mon-Sun>
        end_time: <HH:MM>
        bound_events: <list of named events>
    next:                                          # Explicit next-step pointer
      - condition: <expression>                    # Empty = default path
        goto: <step_id>
    loop_back_target: <step_id or null>            # Explicit loop-back
    related_invariant: <list of invariant_id>      # Which invariants apply to this step
```

**Step ID Naming Convention**:

| Suffix | Meaning | Visual Indicator |
|---|---|---|
| `S{n}` | Main step | — |
| `S{n}.E` | Exception path — true exception, should be rare | ⚠️ |
| `S{n}.A` | Alternative path — another expected branch | ↪️ |
| `S{n}.B` | Branch — condition-triggered equivalent path | ⇆ |
| `S{n}.{m}` | Sub-step — refinement within same execution chain | — |

**Rules**:
- `executor_role` is mandatory and singular — no "team/系统" vague assignments
- Every step must have `inputs` and `outputs` defined (even if `[]`)
- `duration` must be concrete: "5 minutes", "2 business days", "Mon 09:00 to Wed 17:00"
- Never accept "快速", "around", "typically" — demand concrete numbers or mark as `[GAP — SLA unquantified]`
- Every happy-path step must have at least one `.E` or `.A` sibling (checked by Exception Test)
- `loop_back_target` is required when a step can loop back to an earlier step

**Key Design Insight** (spike-01 A1): SP007's "挽单失败→退款" is NOT an exception — it's an alternative expected path. Use `S{n}.A`, not `S{n}.E`.

### L1.5 — Decision Points

```yaml
decisions:
  - id: <D\d+>
    description: <string>
    type: <enum: binary | nested | decision_table | timing | attribute>
    condition_quality: <enum: executable | discretionary | undocumented | delegated>
    # type-specific structure:
    nested_logic: <if/elif/else, max 3 levels>   # type == nested
    decision_table:                               # type == decision_table
      inputs: <list of variables>
      rules: <list of rule rows>
    affects: <enum: branch | timing | attribute>  # What does this decision affect?
```

**5 Decision Types**:

| Type | When to Use | Example |
|---|---|---|
| `binary` | Simple yes/no split | "Is refund amount ≥ ¥200?" |
| `nested` | if/elif/else chain (max 3 levels) | "Student type → retention eligibility" |
| `decision_table` | Multi-variable orthogonal | "Payment time window = f(payment_method, amount, currency)" |
| `timing` | Decision affects time, not branch | "Calculate settlement date" |
| `attribute` | Decision determines output property | "Determine refund amount" |

**Condition Quality**:

| Quality | Meaning | Action |
|---|---|---|
| `executable` | Can be evaluated by code/rule | No action needed |
| `discretionary` | Human judgment call | Document decision criteria if any exist |
| `undocumented` | No criteria documented | **Must be filled** at Step 2 Checkpoint |
| `delegated` | Criteria defined by another role/system | Reference that role/system |

**Rule**: If ≥ 50% of decisions in a process have `condition_quality == undocumented` → **AP-007 triggers** (Warn-with-confirm, block if unresolved).

### L1.6 — State Machine

```yaml
state_machine:
  extraction_status: <enum: explicit | inferred | gap_needs_system>
  states:
    - id: <string>
      name: <string>
      terminal: <bool>
      failure_type: <enum: success | failed | cancelled | escalated | null>
  transitions:
    - from: <state_id>
      to: <state_id>
      triggered_by: <step_id or event>
```

**Gap Disposal Rule** (spike-02 finding): State machines are the most commonly missing element in flowchart-type materials.

If `extraction_status == gap_needs_system`:
1. Infer a minimal state set from step sequence
2. Mark ALL inferred states with `[inferred]`
3. At Step 2 Checkpoint, prompt: "状态机需要访问系统/工程师补全"
4. Do NOT block — states can be inferred, but must be confirmed before Skill v1.0 release

**Anti-Pattern Check**:
- AP-004: State with zero inbound transitions → `[ANTI-PATTERN — zombie state]`
- AP-004: State with zero outbound transitions AND not terminal → `[ANTI-PATTERN — dead-end state]`

### L1.7 — RACIO Matrix

```yaml
raci:
  matrix:                                         # rows = steps, cols = roles
    - step_id: <step_id>
      role_assignments:
        - role: <role_id>
          designation: <enum: R | A | C | I | O>
```

**RACIO Definitions**:

| Letter | Meaning | One Person? |
|---|---|---|
| **R** | Responsible — does the work | Many (per step) |
| **A** | Accountable — answers for the result | **Exactly one per step** |
| **C** | Consulted — asked before action | Many |
| **I** | Informed — told after action | Many |
| **O** | Oversight — post-hoc audit, NOT in execution chain | Many |

The **O** column is the key addition over standard RACI. It specifically accommodates QA/Compliance/Audit roles that consume evidence but do NOT participate in execution.

### L1.8 — SLAs & Metrics

```yaml
metrics:
  - name: <string>
    type: <enum: rate | duration | threshold | count>
    target: <value with unit>
    source: <enum: explicit | inferred_from_rule | inferred_from_sla | inferred_from_step | inferred_from_artifact>
    threshold:                                    # type == threshold
      operator: <enum: gte | lte | between>
      value: <number>
      unit: <string>
      monitoring_frequency: <enum: continuous | daily | weekly>
    related_invariant: <list of invariant_id>
```

**Source field** (mandatory for every metric):

| Source | Meaning |
|---|---|
| `explicit` | Stated verbatim in source material |
| `inferred_from_rule` | Back-derived from an invariant/red-line |
| `inferred_from_sla` | Back-derived from SLA commitment |
| `inferred_from_step` | Back-derived from step description |
| `inferred_from_artifact` | Implied by L4 artifact of type "report/dashboard/qa" (spike-02 N12) |

**Rule**: ALL `inferred_*` metrics MUST be confirmed by user at Step 2 Checkpoint before entering final Skill.

**Anti-Pattern Check**:
- AP-010: All metrics have `inferred_*` source → `[ANTI-PATTERN — all metrics inferred, recommend Interview Mode]`

### L1.9 — Scope Boundaries

```yaml
scope:
  in_scope: <list of description>
  out_of_scope:
    - description: <string>
      reference:
        type: <enum: tool | rule_doc | upstream_process | downstream_process | parallel_process>
        target: <process_name or doc_link>
        handoff_event:                           # ONLY when type is a process type
          from_step: <step_id in current process>
          to_step: <step_id in other process>
          mechanism: <enum: doc | system_event | meeting | notification | ticket>
          sla: <duration>
          failure_recovery: <description>
```

**Anti-Pattern Check**:
- AP-009: `out_of_scope` entry has type = process but `handoff_event` is empty → `[ANTI-PATTERN — cross-process reference without handoff event]`

---

## L2 — Foundational Logic

Answer "why" not just "what".

```yaml
foundational_logic:
  core_purpose: <string>                         # What does this process optimize? Speed/Quality/Compliance/Cost/Scalability
  explicit_tradeoffs: <list of string>           # What did we deliberately give up?
  design_principles: <list of string>            # Core principles this process follows
  source_attribution: <string>                   # Methodology reference. NEVER empty.
  role_language_interface:                       # Same concept, different role language
    - concept: <string>
      translations:
        operator: <string>
        owner: <string>
        auditor: <string>
        customer: <string>
  usage_boundaries: <list of string>             # When NOT to use this process
```

**Source Attribution** must NOT be empty. Acceptable values:
- "ITIL v4 Service Operation"
- "Lean methodology"
- "SOC 2 Type II compliance framework"
- "Internal methodology ({Company} Operations Handbook v2)"
- "ISO 9001:2015"

---

## L3 — Output Recipes

14 standard output formats. Each recipe specifies: recommended structure, writing tips, tone sample, and at least 1 anti-example.

Default recipe when user doesn't specify: **SOP**.

### Recipe Catalog

| # | Recipe | Primary Role | Format |
|---|---|---|---|
| 1 | SOP | Operator + Auditor | Formally numbered steps |
| 2 | Runbook | Operator | Executable + exception branches + troubleshooting |
| 3 | Training Module | Trainee | Concept → Steps → Practice → Self-test |
| 4 | Quick Reference Card | Operator | 1-page high-density |
| 5 | Process Map (Mermaid) | Analyst + Owner | Standard swimlane/flowchart |
| 6 | RACIO Matrix | Manager + PMO | Step × Role grid |
| 7 | Compliance Memo | Auditor + Compliance | Process → regulation mapping |
| 8 | Stakeholder One-Pager | Executive + External | Purpose + Scope + SLA + Metrics |
| 9 | FAQ | Operator + Stakeholder | High-frequency Q&A |
| 10 | Exception Playbook | Operator + Owner | Exception × Handling step |
| 11 | Metrics Dashboard Spec | Owner + Engineer | KPI + Thresholds + Alerts |
| 12 | Change Announcement | All Roles | Change summary + Impact |
| 13 | Onboarding Checklist | Trainee + Buddy | Learning objectives checklist |
| 14 | Post-Mortem Template | Owner + Engineer | Incident + Timeline + Root Cause |

**Phase 1 implements recipes 1-6 (high-frequency). Phase 2 implements 7-14.**

### Recipe Schema

Each recipe in the template must contain:

```yaml
recipe:
  id: <string>
  name: <string>
  primary_role: <role_id>
  recommended_structure: <list of sections>
  writing_tips: <list of string>
  tone_sample: <string>                          # A paragraph showing the right tone
  anti_example: <string>                         # A paragraph showing what NOT to do
  generation_rule: <string>                      # When should this recipe be auto-generated?
```

---

## L4 — Process Artifacts

Tangible objects consumed or produced by the process.

```yaml
artifacts:
  - id: <string>
    name: <string>
    type: <enum: form | checklist | template | ticket_template | data_schema | report>
    used_in_step: <list of step_id>
    produced_in_step: <list of step_id>
    owner_role: <role_id>
    storage_location: <string>
    expires: <date or null>                      # Triggers TTL check
    implies_metric: <bool>                       # Auto-true for report/dashboard/qa types
```

**Rule**: When `implies_metric: true`, auto-create a placeholder metric in L1.8 and prompt user to fill actual KPI.

---

## L5 — Process Visualization

```yaml
visualization:
  vibe_keywords: <list>                          # e.g. ["operator-first", "compliance-emphasis"]
  primary_diagram_type: <enum: swimlane | flowchart | value_stream_map>
  color_semantics:
    manual_step: <color>
    automated_step: <color>
    decision: <color>
    exception: <color>
    handoff: <color>
  naming_convention:
    step_name_prefix: <enum: verb | noun | id>
    max_chars: <int>
  visual_no_gos: <list>                          # Arrows backward, orphan nodes, unclosed branches
```

**Phase 1 uses Mermaid exclusively** (OQ-001 decided). BPMN as advanced option deferred to Phase 3.

---

## L6 — Cases & Learning Library

```yaml
cases:
  - id: <YYYY-MM-DD-slug>
    type: <enum: success | failure | edge | incident>
    summary: <string>
    timeline: <markdown>
    root_cause: <string>
    lesson: <string>
    how_to_avoid: <string>
    related_steps: <list of step_id>
    related_invariants: <list of invariant_id>
```

---

## Gap Handling Policy

This is a **first-class capability** (C2), not an afterthought. Apply during extraction, simultaneously with C1.

### 4-Level Response

| Level | Trigger | Action |
|---|---|---|
| **1 — Detect** | Field is empty or has no-information values ("开始", "略", "N/A") | Mark as `[GAP — {category}]` |
| **2 — Tag with Source Suggestion** | Know where missing info likely exists | Mark as `[GAP — {category}, likely source: {Y}]` |
| **3 — Block** | Missing field is P0 blocker | **Halt** L2-L6 extraction. Force Interview/Survey completion. |
| **4 — Inferred with Confirmation** | Field can be reasonably inferred from other fields | Fill with `[inferred from {basis}]`. Require user confirmation at Step 2 Checkpoint. |

### P0 Blocker List

These fields **MUST block** L2-L6 extraction when missing:

1. `process_name`
2. `purpose_one_liner`
3. `trigger.source` (must be concrete event, "开始"/"Start" = BLOCK)
4. `process_owner.primary`
5. `involved_roles` count < 2

### Gap → Source Suggestion Map

| Gap Category | Typical Source |
|---|---|
| Process Owner / Sponsor | Process owner themselves, org chart |
| Trigger | Interview owner / process initiator |
| Invariants (red lines) | QA team, compliance docs, Interview owner |
| State Machine | System engineer, ticket system fields |
| Explicit SLA numbers | Historical data, OKRs, Interview owner |
| Decision condition standards | Interview operator (operators know the real criteria) |
| RACIO assignments | Owner + each role representative |

### Inferred Field Conventions

Always mark inferred fields with the basis:
- `[inferred from step S3 description]`
- `[inferred from SLA commitment of 4 hours]`
- `[inferred from artifact "monthly-quality-report"]`
- `[inferred-required]` — assumed required because material didn't distinguish

At Step 2 Checkpoint, present ALL inferred fields to user for confirmation. Do NOT silently accept inferences into the final Skill.

---

## Anti-Pattern Detection

Separate scanning channel, independent of L0-L6 layers. Active during `validate` command.

### 10 Anti-Patterns

| ID | Anti-Pattern | Detection Rule | Severity | Action |
|---|---|---|---|---|
| **AP-001** | Single-char/short-name role | `role.name.length ≤ 2` AND not in allowlist | Warn-with-confirm | Ask user to replace with role name |
| **AP-002** | Person-name hardcoded | `role.name` matches known person name | Warn-with-confirm | Ask user to replace with role name |
| **AP-003** | No owner | `process_owner.primary` empty AND `per_team` empty | **Block** | Must designate owner |
| **AP-004** | Zombie state | State with zero inbound OR (zero outbound AND not terminal) | Warn-passive | List and suggest fix |
| **AP-005** | Unclosed branch | `step.next` has conditions but no default branch | Warn-passive | Add default/else branch |
| **AP-006** | No exception path for critical step | Step has `related_invariant` non-empty but no `.E`/`.A` sibling | Warn-passive | Add exception/alternative path |
| **AP-007** | Undocumented decisions ≥ 50% | ≥ 50% of decisions have `condition_quality == undocumented` | Warn-with-confirm | Block until supplemented |
| **AP-008** | No-information trigger | `trigger.source` matches "开始"/"Start"/"启动"/"N/A" | **Block** | Same as P0 blocker |
| **AP-009** | Cross-process ref without handoff | `out_of_scope` type = process but `handoff_event` empty | Warn-passive | Add handoff event details |
| **AP-010** | All metrics inferred | All metrics have `inferred_*` source | Warn-passive | Recommend Interview Mode |

### Severity Legend

| Severity | Behavior |
|---|---|
| **Block** | Halts generation. Must be fixed before proceeding. |
| **Warn-with-confirm** | Warns user. Requires explicit confirmation to continue. |
| **Warn-passive** | Lists in Step 2 Checkpoint. Does not block. |

---

## Lifecycle Operations

Every generated Skill inherits lifecycle management.

### Version Bump Rules

| Trigger | Bump | Affected Layers |
|---|---|---|
| Regulatory change | MINOR or MAJOR | L1 compliance + L2 source + L4 forms |
| Tool migration | MINOR | L1 steps + L4 artifacts |
| Org change (role rename) | MINOR or MAJOR (rename = [BREAKING]) | L1 RACIO + L0 roles + L3 recipes |
| Volume change (10x) | MINOR | L1 steps + L2 tradeoffs + L5 visualization |
| Incident-driven change | PATCH or MINOR | L1 specific steps + L6 new case + L2 tradeoffs |
| Optimization project | MINOR | L1 step refinement + L6 case comparison |
| Process retirement | MAJOR + RETIRED | Entire Skill deprecated |

### TTL Application

**Apply TTL to** (`@valid_until=YYYY-Q#`):
- SLA numbers ("avg 4 hours")
- Tool URLs (systems migrate)
- Compliance clause references (regulations change)
- Contact names / role assignments (people move)
- Volume claims ("currently 200 cases/day")

**Do NOT apply TTL to**:
- Process purpose
- Design principles
- Invariants (they are, by definition, invariant)
- Decision authority matrix structure (not the people in it)

---

## Validation Framework

### Structure Completeness
- [ ] All L0 fields present and non-trivial
- [ ] L1 all 9 sub-sections present
- [ ] L2 all 6 sub-sections present
- [ ] L3 at least 3 recipes defined
- [ ] L4 at least 1 artifact
- [ ] L5 visualization spec present
- [ ] L6 at least 1 case (can be placeholder)

### Content Specificity
- [ ] No "快速"/"around"/"typically" in durations
- [ ] Every step has concrete executor_role
- [ ] Every decision has condition_quality marked
- [ ] All metrics have source field filled
- [ ] Source Attribution is not empty

### Process-Specific Tests
- [ ] **Acceptance Test**: New hire can execute end-to-end from Skill alone
- [ ] **Coverage Test**: ≥ 3 roles covered; every step has executor; every step has input+output
- [ ] **Exception Test**: Every happy-path step has ≥ 1 .E or .A sibling
- [ ] **Trace Test**: Documented vs actual drift ≤ 10% (Phase 3)

---

## Phase 1 Implementation Notes

This archetype is implemented in Phase 1 as `references/process-archetype.md`.
Phase 1 covers: L0-L6 schema, Gap Handling (Level 1-3 fully; Level 4 limited to simple property-level inferences like `[inferred-required]`), Anti-Pattern Detection (all 10 defined, 6 auto-detectable in CLI), Lifecycle rules.
Phase 2 adds: Full Gap Handling Level 4 (cross-field inference, artifact→metric derivation, interview-driven gap filling), L3 recipes 7-14, L4-L6 detailed templates, 3 additional input modes (Interview/Auto-Scan/Survey).
Phase 3 adds: Trace test automation, BPMN integration, cross-process network rendering.
