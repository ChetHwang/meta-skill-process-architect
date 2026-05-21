# Gap Survey Guide — 按角色定向问卷

> **Phase 2**。当已用其他模式（BYO / Interview / Auto-Scan）生成草稿但某层缺失时，按角色发问卷给非技术同事。

---

## 何时用

| 信号 | 发哪份问卷 |
|---|---|
| L1.4 步骤细节缺失、决策标准模糊 | `operator-survey` → 实际操作员 |
| L0 invariants 缺失、scope 不清 | `owner-survey` → 流程负责人 |
| L1 红线未定义、合规映射缺失 | `auditor-survey` → 合规/质检 |
| L2 原理缺失、新人角度看不懂 | `trainee-survey` → 最近入职的新人或未参与流程设计者 |

---

## 问卷设计原则

1. **最多 10 题**：超过 10 题没人填
2. **每个问题有 1 个 placeholder example**：降低回答门槛
3. **注明"你的回答会被直接用于生成 Skill"**：提高认真度
4. **选择题优先，开放题为辅**：选择题可快速统计

---

## 问卷模板位置

| 问卷 | 文件 |
|---|---|
| 操作员问卷 | `templates/gap-survey/operator-survey.md.template.{en,zh}` |
| 负责人问卷 | `templates/gap-survey/owner-survey.md.template.{en,zh}` |
| 审计员问卷 | `templates/gap-survey/auditor-survey.md.template.{en,zh}` |
| 新人问卷 | `templates/gap-survey/trainee-survey.md.template.{en,zh}` |

---

## 发送时机与跟进

1. 在 Step 3 Checkpoint 中，识别缺失字段归属哪类角色
2. 定向发送对应问卷（企业微信/邮件/飞书表单）
3. 跟进周期：发送后 2 天提醒一次，5 天未回复标记 `[GAP — unanswered survey]`

---

## 与 SKILL.md Workflow 集成

在 SKILL.md Step 2 中，Gap Survey 作为补充模式：

```
| Gap Survey | 特定层缺失时定向发问卷 | `references/gap-survey-guide.md` |
```

用法：做完 BYO/Interview/Auto-Scan 之后 → Step 3 Checkpoint 发现某角色覆盖缺失 → 发对应问卷 → 结果回填 → 继续生成。
