# Trace Mode — Document vs Reality Drift Analysis

> **Phase 3 capability.** Trace Mode lets you compare the documented process against real execution data, revealing where documentation has drifted from reality.
>
> **Design basis**: Input sources per plan §9.1 (Jira/Linear/Asana flow logs, SLA reports, manual observation). Health thresholds per plan §15.2 Trace Test standard (drift ≤ 10% healthy).
>
> **Industry-agnostic**: Works with any process that has ticket/flow log data — CRM for sales, ITSM for IT, EHR for healthcare, WMS for logistics, ERP for manufacturing.

---

## Overview

Process documentation is a snapshot — it captures what was true at the time of writing. Over time, reality drifts: operators find shortcuts, tools change, SLA targets shift. Trace Mode systematically detects this drift.

**What Trace Mode does**:
1. **Observes** real execution traces from ticket systems, logs, or manual walkthroughs
2. **Compares** observed steps against documented L1.4 step sequence
3. **Classifies** each step as matched / shadow / dead / drifted
4. **Calculates** a drift score and flags unhealthy drift

**What Trace Mode does NOT do** (Phase 3 scope):
- Does NOT connect to live Jira/Linear APIs (Phase 4)
- Does NOT auto-fix drift — it only reports it
- Does NOT run continuously — it's triggered on demand

---

## 1. Drift Classification

Every L1.4 step in the process-brief gets a `trace_status` after comparison:

| Status | Meaning | Example |
|---|---|---|
| **matched** | Step exists in both document and reality, sequence and duration match | S3 "Verify payment" takes 15min in doc ≈ 12-18min in reality |
| **shadow** | Step exists in reality but NOT in document | Operators always call the warehouse before shipping, but doc says "ship immediately" |
| **dead** | Step exists in document but NEVER executed in reality | Doc says "Fill Form B-47" but Form B-47 was retired 6 months ago |
| **drifted** | Step exists in both but duration, executor, or sequence differs significantly | Doc says S4 takes 1h, reality shows 3.2h average |
| **unobserved** | Step is in document but no execution data available | Cannot determine if S8 is matched/shadow/dead without data |

### Drift Score Formula

```
drift_score = (shadow_count + dead_count + drifted_count) / total_steps × 100%
```

### Health Thresholds

| Drift Score | Status | Action |
|---|---|---|
| 0-10% | ✅ Healthy | No action needed |
| 11-25% | ⚠️ Warning | Schedule review within current quarter |
| 26-50% | 🔴 Unhealthy | Escalate to process owner, plan update |
| >50% | 🚨 Critical | Document is unreliable — treat as gap, trigger full re-extraction |

---

## 2. Trace Input Sources

### 2.1 Jira / Linear / Asana Flow Logs

**What to extract**:
- Ticket ID → Status transitions → Timestamps
- Actual step sequence from issue history
- Per-step duration (status_in_progress → status_resolved)
- Escalation events and exception paths

**Format** (CSV):
```csv
ticket_id,from_status,to_status,timestamp,duration_minutes,assignee_role
REF-2024,open,in_progress,2026-03-15T09:00,0,客服专员
REF-2024,in_progress,review,2026-03-15T09:45,45,退款专员
REF-2024,review,approved,2026-03-15T10:30,45,财务
REF-2024,approved,resolved,2026-03-15T11:00,30,客服专员
```

### 2.2 SLA Compliance Reports

**What to extract**:
- Step-level SLA targets vs actuals
- Which steps consistently breach SLA
- SLA trend over time (improving or degrading)

**Format** (CSV):
```csv
step_id,sla_target_hours,actual_median_hours,breach_rate_pct,n_samples
S3,4,3.8,12%,200
S5,2,4.5,45%,200
S7,24,22.1,8%,200
```

### 2.3 Manual Walkthrough (Observation)

When no system logs are available, trace via observation:
1. Shadow an operator through one full execution
2. Record actual step sequence and durations
3. Note any deviations from documented steps
4. Note any undocumented steps the operator performs
5. Ask: "Is there anything you do that's not in the document?"

### 2.4 Screen Recording / Session Replay

For digital processes, screen recordings capture the exact UI interactions. Extract:
- System screens visited (URLs)
- Form fields filled
- Clicks and navigation paths
- Time spent on each screen

---

## 3. Trace Comparison Algorithm

### Algorithm: align_and_classify

```
Input:  documented_steps[] from L1.4, observed_steps[] from trace source
Output: trace_report with classification per step

1. NORMALIZE:
   - Strip formatting, extract step IDs from both sources
   - Convert durations to common unit (minutes)

2. ALIGN:
   - Match observed steps to documented steps by:
     a. Step ID exact match (e.g. "S3" in both)
     b. Action keyword match (e.g. both contain "审核"/"approve")
     c. Role match (same executor role)
   - Unmatched observed steps → candidate shadow steps
   - Unmatched documented steps → candidate dead steps

3. CLASSIFY:
   For each documented step:
     - If aligned to observed step AND duration within ±30%: matched
     - If aligned to observed step AND duration differs >30%: drifted
     - If not aligned and no partial match in 2b/2c: dead (if data covers this step)
     - If no observation data: unobserved

4. SCORE:
   drift_score = (shadow + dead + drifted) / total_documented × 100%
```

### Duration Drift Threshold

| Documented Duration | Drift Flag if Reality |
|---|---|
| Minutes | > ±50% |
| Hours | > ±30% |
| Days | > ±25% |
| > 1 week | > ±20% |

---

## 4. Trace Report Format

```yaml
trace_report:
  process: "process-customer-refund"
  trace_source: "Jira export 2026-Q1 (n=200 tickets)"
  analysis_date: "2026-05-15"
  baseline_version: "1.0.0"

  summary:
    baseline_steps: 8
    matched: 6
    shadow_steps: 1
    dead_steps: 0
    drifted_steps: 1
    unobserved: 0
    drift_score: 12.5%
    health: warning

  steps:
    - id: S1
      name: "接收退款申请"
      documented_duration: "5min"
      observed_duration: "4.8min"
      status: matched
      delta: "-4%"

    - id: S2
      name: "验证订单信息"
      documented_duration: "10min"
      observed_duration: "9.2min"
      status: matched
      delta: "-8%"

    - id: S3
      name: "判断退款条件"
      documented_duration: "15min"
      observed_duration: "22.5min"
      status: drifted
      delta: "+50%"
      note: "Operators report additional manual check for fraud patterns"

    - id: S4
      name: "审批退款"
      documented_duration: "30min"
      observed_duration: "28min"
      status: matched
      delta: "-7%"

    - id: S5
      name: "执行退款"
      documented_duration: "5min"
      observed_duration: "6min"
      status: matched
      delta: "+20%"

    - id: S6
      name: "通知客户"
      documented_duration: "2min"
      observed_duration: "2.1min"
      status: matched
      delta: "+5%"

    - id: S7
      name: "关闭工单"
      documented_duration: "5min"
      observed_duration: "4.5min"
      status: matched
      delta: "-10%"

    # Shadow step — undocumented but observed in 85/200 tickets
    shadow:
      - name: "仓库库存确认（退款前）"
        observed_duration: "12min"
        frequency: "85/200 (42.5%)"
        note: "Operators call warehouse to confirm stock before refunding for physical goods"

  recommendations:
    - "S3: Update documented duration from 15min → 25min or add fraud check as explicit sub-step"
    - "Shadow: Add '仓库库存确认' as S3.5 or document as optional step for physical goods"
    - "Schedule review with refund team lead to validate shadow step"

  next_actions:
    - "Run diff-plan to assess impact of S3 duration change"
    - "Consider bump to MINOR if adding new step"
```

---

## 5. CLI Integration

Trace Mode is accessible via the CLI:

```bash
# Basic trace with manual observation data
process-architect validate --trace --skill ./process-customer-refund/ \
  --trace-source ./trace-observations.csv

# Trace with SLA report
process-architect validate --trace --skill ./process-customer-refund/ \
  --sla-report ./sla-q1-2026.csv

# Trace with Jira flow log
process-architect validate --trace --skill ./process-customer-refund/ \
  --trace-source ./jira-flow-log.csv --source-type jira
```

**Output**: Trace report printed to stdout + optional `--output trace-report.yaml`.

---

## 6. L1.4 Schema Extension: trace_status

To support Trace Mode, each step in L1.4 can carry a `trace_status` field:

```yaml
steps:
  - id: S3
    name: "判断退款条件"
    executor_role: "退款专员"
    duration:
      type: avg
      value: "15min"
    trace_status: drifted           # ← Phase 3 addition
    trace_last_check: "2026-Q2"
    trace_delta: "+50%"
    trace_note: "Fraud pattern check adds ~7min"
```

The `trace_status` field is optional — it's only populated after a trace run. Skills generated before Phase 3 will not have this field.

### trace_status Field Specification

| Field | Type | Required | Values |
|---|---|---|---|
| `trace_status` | string | No | `matched`, `shadow`, `dead`, `drifted`, `unobserved` |
| `trace_last_check` | string | No | `YYYY-Q#` of last trace run |
| `trace_delta` | string | No | Duration difference as percentage, e.g. `+50%`, `-8%` |
| `trace_note` | string | No | Free-text explanation of drift |

---

## 7. Periodic Trace Schedule

| Frequency | Scope | Trigger |
|---|---|---|
| **Quarterly** | Full trace on high-change processes | Calendar + `ttl-check` results |
| **On incident** | Targeted trace on affected process | Post-mortem action item |
| **On bump** | Validate post-update drift | After MAJOR/MINOR bump |
| **Ad-hoc** | Any process | When drift is suspected |

---

## 8. Limitations & Phase 4 Roadmap

| Limitation | Phase 3 Approach | Phase 4 Plan |
|---|---|---|
| No live Jira API | CSV import only | Jira/Linear MCP connector |
| No auto-fix | Report-only | Auto-suggest diff-plan |
| Manual alignment | `align_and_classify` algorithm with human confirmation | ML-based step matching |
| No continuous monitoring | On-demand CLI only | Scheduled trace + alert on drift > threshold |

---

## 9. Quick Reference

### CLI Commands

```bash
# Full trace with CSV input
process-architect validate --trace --skill ./process-xxx/ --trace-source ./flow-log.csv

# Trace with SLA report
process-architect validate --trace --skill ./process-xxx/ --sla-report ./sla.csv

# Output to file
process-architect validate --trace --skill ./process-xxx/ --trace-source ./log.csv --output trace-report.yaml
```

### Drift Health Quick Check

| Drift Score | Status |
|---|---|
| ≤ 10% | ✅ Healthy |
| 11-25% | ⚠️ Warning |
| 26-50% | 🔴 Unhealthy |
| > 50% | 🚨 Critical |
