# Role-Audience Model — 7 Standard Roles

> **Purpose**: Define the 7 standard roles that every process Skill must address. This model drives both extraction (what to look for in materials) and generation (which output recipes to produce for whom).

---

## The 7 Roles

Every business process involves some subset of these 7 roles. A generated Skill MUST cover at least 3.

| # | Role | Core Concern | Output Emphasis |
|---|---|---|---|
| 1 | **Operator** | 怎么做 / 在哪做 / 出错怎么办 | Step-by-step, exception branches, tool entry points |
| 2 | **Process Owner / Manager** | 健康度、瓶颈、SLA 达成 | Metrics, RACIO, change control, escalation paths |
| 3 | **Trainee / New Hire** | 为什么这样做（不仅是怎么做） | Concepts → mechanisms → practice → self-test |
| 4 | **Auditor / Compliance** | 是否合规、证据链是否完整 | Compliance mapping, evidence checkpoints, exception approvals |
| 5 | **Customer / External Party** | 我会经历什么、要等多久 | Timeline, milestone feedback, contact points |
| 6 | **Executive Sponsor** | 风险、成本、战略影响 | Summary, ROI, key risks, decision points |
| 7 | **Tool Engineer / Automation Builder** | 数据流、集成点、可自动化边界 | API, data schema, state machine, observability |

---

## Role Details

### 1. Operator (执行者)

**Who**: The person actually executing the process steps day-to-day.

**What they need**:
- Precise, numbered steps with concrete actions
- Tool URLs, form IDs, system entry points
- Exception handling: what to do when things go wrong
- Decision criteria: when to escalate vs when to resolve

**Preferred recipes**: SOP, Runbook, Quick Reference Card, FAQ, Exception Playbook

**Bad for Operator**:
- High-level strategy discussion ("本次流程优化了跨部门协同效率")
- Vague steps ("联系相关部门")
- Missing tool links ("在系统中操作")

---

### 2. Process Owner / Manager (流程负责人)

**Who**: Accountable for the process outcome. May or may not execute steps themselves.

**What they need**:
- Process health metrics (throughput, SLA compliance, error rate)
- RACIO matrix showing accountability distribution
- Escalation paths and decision authority boundaries
- Change control procedures

**Preferred recipes**: RACIO Matrix, Metrics Dashboard Spec, Stakeholder One-Pager, Exception Playbook

**Bad for Owner**:
- Missing SLA data ("尽快处理")
- No accountability assignment ("团队负责")
- No metrics at all (can't manage what isn't measured)

---

### 3. Trainee / New Hire (新人)

**Who**: Someone who has never done this process before.

**What they need**:
- Why this process exists (purpose and principles)
- Mental model before procedural steps
- Practice exercises with self-check
- Common mistakes and how to avoid them

**Preferred recipes**: Training Module, Onboarding Checklist, Quick Reference Card

**Critical for Acceptance Test**: A trainee must be able to execute the process end-to-end using only the Skill's trainee-oriented outputs.

**Bad for Trainee**:
- Jumping straight to steps without context
- Assuming prior knowledge ("和往常一样操作")
- No self-test to confirm understanding

---

### 4. Auditor / Compliance (审计/合规)

**Who**: Reviews process execution for compliance, quality, and risk. NOT in the execution chain.

**What they need**:
- Process → regulation/standard mapping
- Evidence checkpoints (where are audit trails generated?)
- Exception handling documentation (what happens when compliance is breached?)
- Historical compliance performance

**Preferred recipes**: Compliance Memo, RACIO Matrix (O column), Exception Playbook, SOP

**Role Nature**: Always `oversight` in the L1.3 role classification.

**Bad for Auditor**:
- Missing evidence checkpoints
- Undocumented exception handling ("特殊情况特殊处理")

---

### 5. Customer / External Party (外部相关方)

**Who**: The person or entity the process serves. May be an actual customer, a partner, a vendor, or a regulatory body.

**What they need**:
- What will happen to me, in what order?
- How long will each step take?
- When and how will I be notified of progress?
- Who do I contact if something goes wrong?

**Preferred recipes**: Stakeholder One-Pager, FAQ, Change Announcement

**Role Nature**: Always `external` in the L1.3 role classification.

**Bad for Customer**:
- Internal jargon
- No timeline visibility
- No escalation contact

---

### 6. Executive Sponsor (高管赞助人)

**Who**: The senior leader who authorized this process to exist. Needs top-level visibility, not operational detail.

**What they need**:
- What is this process's strategic purpose?
- What are the key risks and mitigation measures?
- What is the cost/resource footprint?
- What are the critical decision points?

**Preferred recipes**: Stakeholder One-Pager, Metrics Dashboard Spec

**Bad for Executive**:
- Too much operational detail (Step S3.2.1 sub-details)
- No risk/cost summary
- No connection to business objectives

---

### 7. Tool Engineer / Automation Builder (工具工程师)

**Who**: Builds or integrates the systems that support or automate this process.

**What they need**:
- Data flow: what data enters/exits each step?
- State machine: what are the valid states and transitions?
- Integration points: APIs, webhooks, database schemas
- Observability: what to log, what to alert on

**Preferred recipes**: Metrics Dashboard Spec, visualization (Mermaid state diagram), data schema artifacts

**Bad for Engineer**:
- Missing data schema
- Undocumented API endpoints
- No state machine definition

---

## Role Nature Classification

Every role in L1.3 carries a `nature` attribute from one of 5 categories:

| Nature | Meaning | Examples | Key Implication |
|---|---|---|---|
| `static` | Fixed assignment, always the same | Finance Reviewer, CS Agent | Can hardcode in tooling |
| `transient` | Temporary, event-triggered | First Responder (whoever picks up ticket) | Must be resolved at runtime |
| `conditional` | Role = function(context) | Retention Owner = f(honeymoon, transfer) | Requires `binding_rule` logic |
| `external` | Outside the organization | Distributor, Regulatory Agency | Different SLA expectations |
| `oversight` | Post-hoc, not in execution chain | QA Auditor, SOC2 Reviewer | Consumes evidence, doesn't produce it |

### Conditional Role Binding

When `nature == conditional`, the role MUST include `binding_rule`:

```yaml
binding_rule:
  - if: "student in honeymoon period AND not transferred"
    binds_to: "retention-senior"
  - elif: "student in honeymoon period AND transferred"
    binds_to: "retention-junior"
  - else:
    binds_to: "cs-agent"  # default fallback
```

The `else` branch is mandatory — every conditional role must have a default assignment.

---

## Role-Team Dual Address

Each role carries two team-related fields:

| Field | Meaning | Example |
|---|---|---|
| `home_team` | Administrative home (org chart) | `customer-service` |
| `collaboration_context` | Teams where work actually happens (swimlane) | `["customer-service", "retention", "finance"]` |

**Why two fields?** In cross-functional processes, a person's admin home may differ from where they collaborate. The QA Auditor might belong to `quality-operations` but participate in `customer-service` swimlanes during refund reviews.

---

## Recipe → Role Mapping

Which recipe serves which role:

| Recipe | Operator | Owner | Trainee | Auditor | Customer | Executive | Engineer |
|---|---|---|---|---|---|---|---|
| SOP | ● | ○ | ○ | ● | | | |
| Runbook | ● | | ○ | | | | |
| Training Module | | | ● | | | | |
| Quick Reference Card | ● | | ● | | | | |
| Process Map | ○ | ● | ○ | ○ | | | ● |
| RACIO Matrix | ○ | ● | | ● | | ○ | |
| Compliance Memo | | | | ● | | | |
| Stakeholder One-Pager | | ● | | | ● | ● | |
| FAQ | ● | | | | ● | | |
| Exception Playbook | ● | ● | | ○ | | | |
| Metrics Dashboard Spec | | ● | | | | ● | ● |
| Change Announcement | ● | ● | ● | ● | ● | ● | ● |
| Onboarding Checklist | | | ● | | | | |
| Post-Mortem Template | ○ | ● | | ○ | | | ● |

● = Primary audience  
○ = Secondary audience

---

## Coverage Rule

**Every generated process Skill MUST cover at least 3 roles.** This is a hard validation gate. A Skill covering only Operator and Owner (2 roles) fails validation.

When generating, check:
1. Does L0 `involved_roles` list ≥ 3 roles?
2. Does L3 have recipes targeting ≥ 3 distinct roles?
3. Are recipes matched to the right roles per the mapping table above?

If coverage < 3:
- Identify which roles are missing
- Suggest Gap Survey for the missing role(s)
- Recommend additional recipe generation

---

## Anti-Patterns Related to Roles

These are checked during extraction and validation:

| ID | Check | Fix |
|---|---|---|
| AP-001 | Role name ≤ 2 chars ("清华", "小李") | Replace with role title, not person name |
| AP-002 | Role name matches known person | Replace with role title |
| AP-003 | No process owner defined | Assign `process_owner.primary` |

---

## Relationship to Plan

This model is derived from plan §6.4 (Roles & Responsibilities) and §8 (Role Audience Model). The plan is canonical. Any structural change to this model must be accompanied by an ADR in the plan.
