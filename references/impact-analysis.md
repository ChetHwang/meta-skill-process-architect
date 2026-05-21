# Impact Analysis — Process Change Impact Engine

> **Phase 5 capability.** When a process changes, the Impact Analysis Engine identifies every downstream effect — within the process, across the process network, on SLAs, on roles, and on tools.
>
> **Industry-agnostic**: Change-impact patterns (SLA cascade, role rename ripples, handoff dependency chains) are identical across all industries. Examples below use a customer service process, but the same logic applies to manufacturing change orders, healthcare protocol updates, or financial compliance changes.

---

## Overview

Processes don't exist in isolation. Changing S3's SLA from 4h to 2h in the refund process might cascade into:
- The supply chain handoff now has a tighter deadline
- The QA audit schedule needs recalibration
- The customer-facing FAQ must update its timeline

The Impact Analysis Engine systematically detects these cascading effects before the change is made.

---

## 1. Change Types

| Type | CLI Flag | Example |
|---|---|---|
| **SLA** | `--change-type sla` | S3 processing time: 4h → 2h |
| **Role** | `--change-type role` | "客服专员" renamed to "客户成功经理" |
| **Tool** | `--change-type tool` | CRM URL: old-crm.com → new-crm.com |
| **Step** | `--change-type step` | New step S2.5 added between S2 and S3 |
| **Step removed** | `--change-type step-remove` | S4 removed from sequence |
| **Regulatory** | `--change-type regulatory` | New compliance requirement added |
| **Auto-detect** | `--change-type auto` | Scan two versions and auto-detect all changes |

---

## 2. Impact Dimensions

For any change, the engine evaluates four dimensions:

### D1: Direct Impact (Within Process)

| Change Type | What to Check |
|---|---|
| SLA change | Are there dependent steps that assume the old SLA? Does the .E path timing still hold? |
| Role rename | All L1.4 steps referencing the old role name. All RACI entries. |
| Tool URL | All L1.4 steps containing the old URL. All L1.2 input entries referencing the system. |
| New step | Does it create a new handoff? Does it break step numbering (.E/.A suffixes)? |
| Step removed | Are there .E/.A paths that reference the removed step? Are there loop_back targets? |

### D2: Cross-Process Impact (Network)

For each process P2 that references the changed process P1 via L1.9:
- Does P2's handoff step name/handoff SLA reference the changed element?
- Is P2's timing assumption affected by P1's SLA change?
- If P1 removes a step that P2 expects as a handoff → broken link

### D3: SLA Cascade

If the total cycle time of P1 changes:
- Sum new durations along the handoff path
- Check if P2's SLA deadline is still achievable given P1's new timing
- Flag if P1.end_time + P2.sla_deadline > regulatory requirement

### D4: Role/Tool Ripple

- Which processes (outside the network) reference the renamed role in their own L1.9 or RACI?
- Which processes use the same tool URL that's changing?

---

## 3. Impact Report Format

```yaml
impact_report:
  change:
    type: sla
    process: "process-customer-refund"
    description: "S3 审批时间 4h → 2h"
    
  direct_impacts:
    - dimension: l1.4_step
      step: S3
      effect: "Duration shortened from 4h to 2h"
      affected_elements:
        - "S3.E 超时阈值需要同步调整"
        - "S3 SLA 标注需要更新"
        
    - dimension: l1.8_sla
      metric: "退款审批SLA"
      effect: "Target changed from 4h to 2h"
      affected_elements:
        - "TTL marker @valid_until must be updated"
        
    - dimension: cycle_time
      effect: "Happy path total: 3.5天 → 3.4天 (-0.1天)"
      bottleneck: "S2 挽单 (2天) remains bottleneck"

  cross_process_impacts:
    - target: "process-supply-chain"
      handoff_step: "receive_return"
      effect: "Receives handoff 2h earlier on average"
      risk: low
      note: "Supply chain SLA is 24h, 2h earlier has no material impact"
      
    - target: "process-qa-audit"
      handoff_step: "audit_schedule"
      effect: "QA receives refund completion signal 2h earlier"
      risk: low

  sla_cascade:
    upstream_total: "3.4 days"
    downstream_sla: "7 days (regulatory)"
    margin: "3.6 days"
    risk: low
    note: "Ample margin remains"

  role_tool_ripple:
    - type: none
      note: "No role or tool changes in this SLA-only change"

  suggested_bump: MINOR
  affected_skills_to_review:
    - "process-customer-refund (bump)"
    - "process-supply-chain (review handoff timing, no bump needed)"
    - "process-qa-audit (review, no bump needed)"
```

---

## 4. Risk Classification

| Risk | Criteria | Action |
|---|---|---|
| 🔴 High | Downstream SLA margin < 10% of deadline; broken handoff link; regulatory violation | Block until resolved |
| 🟡 Medium | Downstream SLA margin reduced; new handoff introduced; role rename affecting > 3 processes | Review before proceeding |
| 🟢 Low | Timing shift < 20%; no downstream SLA impact; isolated change | Auto-approve with notification |

---

## 5. CLI Integration

```bash
# SLA change
process-architect impact --skill ./process-customer-refund/ \
  --change-type sla --step S3 --old "4h" --new "2h"

# Role rename (searches all Skills in directory)
process-architect impact --skills-dir ./all-processes/ \
  --change-type role --old-name "客服专员" --new-name "客户成功经理"

# Tool URL change
process-architect impact --skill ./process-customer-refund/ \
  --change-type tool --old-url "https://old-crm.com" --new-url "https://new-crm.com"

# Auto-detect from two versions
process-architect impact --skill ./process-customer-refund/ \
  --change-type auto --since 1.0.0

# Output to file
process-architect impact --skill ./process-customer-refund/ \
  --change-type sla --step S3 --old "4h" --new "2h" --output impact.yaml
```

---

## 6. Integration with Other Capabilities

| Phase | Integration |
|---|---|
| **Phase 3 (Lifecycle)** | Impact analysis output feeds directly into `diff-plan` → suggests bump type |
| **Phase 3 (Cross-Process)** | Reuses `network` command's L1.9 parsing for cross-process detection |
| **Phase 3 (Trace)** | If trace data shows actual SLA vs documented, impact analysis uses actuals |
| **Future (SLA Monitor)** | Live SLA data would enable real-time impact prediction before changes |
