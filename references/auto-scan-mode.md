# Auto-Scan Mode — URL→草稿自动抽取

> **Phase 2**。当用户有在线文档（Confluence/Notion/飞书 Wiki/Jira）的 URL 时，自动生成 L0+L1 草稿。

---

## 核心原则

1. **只生成草稿**：所有输出标记 `[auto-scanned, needs confirmation]`
2. **不覆盖人工**：已有字段（如 BYO Materials 已填的）不覆盖
3. **宁可少填**：填 40% 都对 > 填 80% 一半错

---

## 支持的来源

| 来源 | 解析重点 | L0/L1 映射 |
|---|---|---|
| **Confluence / Notion / 飞书 Wiki** | 流程描述页、SOP 页、RACI 表 | 全文→L0+L1 |
| **Jira / Linear / Asana** | 工单流转日志 | 实际步骤序列 + SLA |
| **飞书表格 / Google Sheets** | RACI 矩阵、角色清单 | L1.3 + L1.7 |
| **BPMN / Visio / Lucidchart 导出** | 流程图结构 | L1.4 步骤序列 + L1.5 决策点 |

---

## 抽取规则

### Confluence / Notion / 飞书 Wiki

| 页面元素 | 抽取逻辑 | 映射到 |
|---|---|---|
| 页面标题 | → `process_name` | L0 |
| "目的"/"目标"/"适用范围" 段落 | → `purpose_one_liner`, `scope` | L0, L1.9 |
| "角色" 表格 | 列名含 "角色/职责" → `roles` (每行一个角色) | L1.3 |
| "步骤"/"流程" 编号列表 | 每项 → 一个 step | L1.4 |
| 决策分支（"如果...则..."） | → `decisions` | L1.5 |
| 时长/时间描述（"24小时"/"3个工作日"） | → `steps[].duration`, `metrics` | L1.4, L1.8 |
| "红线"/"禁止" 列表 | → `invariants` | L0 |
| 版本/修订记录 | → 填充 L6 历史修订 | L6 |

### Jira / Linear / Asana 工单日志

| 工单字段 | 抽取逻辑 | 映射到 |
|---|---|---|
| 状态流转记录 | 每个状态变更 → 一个 step（实际顺序，非文档顺序） | L1.4 |
| 经办人变更 | 每次变更 → handoff | L1.4 (handoff) |
| 各状态停留时长 | → `steps[].duration` (真实时长) | L1.4 |
| 评论中的异常处理 | "升级"/"加急"/"重新打开" → exception paths | L1.4 (.E/.A) |

### BPMN / Visio / Lucidchart

| 图形元素 | 抽取逻辑 | 映射到 |
|---|---|---|
| 泳道（swimlane） | → `roles` (每泳道一个角色) | L1.3 |
| 任务节点 | → `steps` (按箭头顺序) | L1.4 |
| 网关（菱形） | → `decisions` | L1.5 |
| 边界事件/异常流 | → exception paths (.E/.A) | L1.4 |
| 开始/结束事件 | → `trigger.source`, 终态 | L1.1, L1.6 |

---

## 冲突解决

当多个来源对同一字段给出不同信息时：

| 优先级 | 来源 | 理由 |
|---|---|---|
| 1 | 正式 SOP / Confluence 页面 | 权威来源 |
| 2 | BPMN / 流程图 | 可视化但可能过时 |
| 3 | Jira 流转日志 | 反映实际执行，可能与文档不一致 |

冲突标注：`[CONFLICT — Source A: "4 hours" / Source B: "2 hours"]`

---

## 使用方式

### CLI（Phase 2 新增）

```bash
process-architect scan --source confluence://wiki.internal.com/refund-process --output draft/
process-architect scan --source jira://jira.internal.com/projects/REF --output draft/
```

### Agent Workflow

在 SKILL.md Step 2 中，选择 Auto-Scan Mode → 提供 URL → 按抽取规则生成 draft → 进入 Step 3 Checkpoint（草稿确认）。

---

## 输出格式

Auto-Scan 生成的草稿放在 `draft/{process-name}/` 目录：

```
draft/process-customer-refund/
├── SKILL.md              # L0 draft, all fields marked [auto-scanned]
├── process-brief.md       # L1 draft, all fields marked [auto-scanned]
└── scan-report.md         # 抽取来源清单 + 覆盖率 + 冲突列表
```

`scan-report.md` 示例：

```markdown
# Auto-Scan Report — 客户退款流程

## Sources Scanned
- [Confluence: SP007 退款流程](https://wiki.example.com/...) — 45 fields extracted
- [Jira: REF project](https://jira.example.com/...) — 12 transitions extracted

## Coverage
- L0: 8/11 fields filled (73%)
- L1.1-L1.9: 6/9 sub-sections filled (67%)

## Conflicts
- `SLA resolution time`: Confluence says 4h, Jira average is 6.2h

## Needs Manual Confirmation
- All 53 auto-scanned fields marked [auto-scanned, needs confirmation]
```
