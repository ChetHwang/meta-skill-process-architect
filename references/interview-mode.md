# Interview Mode — 三方访谈采集

> **Phase 2**。当流程负责人没有整理好的素材时，通过结构化访谈从零生成 L0+L1 数据。
> 业务流程几乎不可能由一个人完整描述——Owner 知道 invariants 但不知道实际 shortcut，Operator 知道 shortcut 但不知道为什么有 invariants，Auditor 知道红线但不知道步骤顺序。

---

## 访谈架构

三方分别访谈，各自 15-20 分钟。三方合并后约 50 分钟含 quick wins。

| 受访者 | 核心采集 | 时长 | 脚本模板 |
|---|---|---|---|
| **Owner**（流程负责人） | trigger、invariants、scope、Source Attribution、角色清单 | 15-20 min | `templates/interview-scripts/owner-script.md.template` |
| **Operator**（实际操作者） | step sequence（真实顺序）、decision conditions、handoffs、实际时长、shadow steps | 15-20 min | `templates/interview-scripts/operator-script.md.template` |
| **Auditor**（合规/质检） | 红线、合规映射、历史违规案例、监控指标 | 15-20 min | `templates/interview-scripts/auditor-script.md.template` |

---

## 采集→映射表

### Owner 采集 → L0/L1 映射

| 访谈问题域 | 映射到 | L 层 |
|---|---|---|
| 流程叫什么、为什么要存在 | `process_name`, `purpose_one_liner` | L0 |
| 谁是最终负责人 | `process_owner.primary` | L0 |
| 什么事件启动流程 | `trigger.source`, `trigger.type` | L1.1 |
| 有哪些不可妥协的红线 | `invariants` | L0 |
| 涉及哪些角色、各自职责 | `roles` (name, persona, boundaries) | L1.3 |
| 流程的边界——什么不属于本流程 | `scope.in_scope`, `scope.out_of_scope` | L1.9 |
| 借鉴了什么方法论 | `source_attribution` | L2 |
| SLA 目标是什么 | `metrics` (target values) | L1.8 |

### Operator 采集 → L1 映射

| 访谈问题域 | 映射到 | L 层 |
|---|---|---|
| 实际执行步骤（按顺序） | `steps` (id, name, actions) | L1.4 |
| 每一步谁在做 | `steps[].executor_role` | L1.4 |
| 每一步输入什么、产出什么 | `steps[].inputs`, `steps[].outputs` | L1.4 |
| 哪一步做判断、判断标准是什么 | `decisions` (condition, criteria) | L1.5 |
| 实际要花多长时间 | `steps[].duration` | L1.4 |
| 有哪些非官方的 shortcut | shadow steps（标注与 Trace Mode 联动） | L1.4 |
| 什么时候交接给谁 | `handoff_event` (if cross-role) | L1.9 |
| 实际有哪些异常、怎么处理 | exception paths → `.E` / `.A` steps | L1.4 |

### Auditor 采集 → 红线/合规映射

| 访谈问题域 | 映射到 | L 层 |
|---|---|---|
| 有哪些质检红线 | `invariants` (补充/验证) | L0 |
| 每条红线对应哪些步骤 | `steps[].related_invariant` | L1.4 |
| 哪些步骤必须留痕 | evidence checkpoints | L4 (artifacts) |
| 历史违规集中在哪 | 补充到 L6 cases-library | L6 |
| 有哪些监控指标 | `metrics`（补充来源） | L1.8 |

---

## 合并算法

三方访谈独立采集后，合并时遵循以下规则：

### 冲突解决优先级

| 冲突域 | 优先信源 | 理由 |
|---|---|---|
| **步骤顺序与细节** | Operator > Owner | 执行者知道真实顺序 |
| **红线与不可变约束** | Auditor > Owner | 审计方最清楚红线 |
| **SLA/指标目标值** | Owner > Operator | 负责人设定目标，操作者知道实际值（两者都录，冲突标注） |
| **角色职责边界** | Owner > Operator | 职责由负责人定义 |
| **决策标准（实际）** | Operator > Owner | 操作者知道真实的判断条件 |
| **流程目的与原理** | Owner > Operator | 负责人知道设计意图 |

### 冲突标注格式

合并时发现三方信息不一致，在字段中标注：

```
[CONFLICT]
  Owner says: "SLA 目标是 4 小时"
  Operator says: "实际上平均 6 小时，高峰期 12 小时"
  Resolution: _____（用户确认时填写）
```

### 对齐验证清单

合并完成后，给 Owner 发一份简短的验证清单：

- [ ] trigger 描述是否准确
- [ ] 步骤顺序是否与实际一致
- [ ] 角色职责边界是否清晰
- [ ] SLA 目标是否与实际有差距
- [ ] 红线清单是否完整

---

## 与 SKILL.md Workflow 集成

在 SKILL.md Step 2（Choose Input Mode）中，Interview Mode 作为选项之一：

```
### Step 2 — Choose Input Mode + Extract

| Mode | When | Reference |
|---|---|---|
| BYO Materials (default) | User has docs | This file's Required Inputs |
| **Interview Mode** | Process owner + 1-2 operators available | `references/interview-mode.md` |
| Auto-Scan Mode | URLs available | `references/auto-scan-mode.md` |
| Gap Survey | Specific layers missing | `references/gap-survey-guide.md` |
```

选择 Interview Mode 时：
1. 加载对应脚本模板
2. 分别访谈三方（或同时）
3. 按采集→映射表填充 L0+L1
4. 按合并算法处理冲突
5. 对齐验证清单发给 Owner
6. 进入 Step 3 Checkpoint

---

## 何时用 Interview Mode

- 流程没有正式 SOP 文档
- 流程有文档但严重过时（文档与现实 drift 大）
- 流程涉及多个团队、各方信息需要交叉验证
- 已有 BYO 素材但 L2（设计原理）或 L1 某些子节缺失

**不建议用 Interview Mode 的情况**：
- 已有完整 SOP 且确认是最新版（直接用 BYO Materials）
- 流程非常标准化、单一角色（访谈收益低）
