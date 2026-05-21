# Mode Registry — 模式注册表

> 元技能所有输入模式的单一事实来源。当添加/修改模式时，优先更新此文件；SKILL.md 的 Intent Detection 和 Step 1.5 引用此注册表做路由。

---

## 模式总览

| mode_id | 模式名称 | spectrum | oversight_level | trigger_phrases (zh) | trigger_phrases (en) | expected_output_quality | min_input_requirements | estimated_turns | reference_file |
|---|---|---|---|---|---|---|---|---|---|
| `byo` | BYO Materials | Balanced | Low | 有文档/有SOP/有流程图/整理好的材料/按文档生成/已有材料/提供了文档 | have docs/SOP/flowcharts/gathered materials/provided documents | High —— 用户提供完整或部分材料 | process_name + trigger + owner + >=2 roles + step sequence + outputs | 18-25 | SKILL.md Required Inputs 表 |
| `interview` | Interview Mode | Fidelity | Very High | 没有文档/访谈/口头描述/聊一聊/流程负责人可以聊/让负责人讲讲/找人聊/采访 | no docs/interview/talk to/owner available/verbal description/let me describe | Medium-High —— 依赖访谈质量，三方对齐后准确度高 | 至少 1 方可访谈（Owner/Operator/Auditor） | 25-30 | references/interview-mode.md |
| `auto-scan` | Auto-Scan Mode | Fidelity | High | 有链接/有URL/Confluence/Notion/飞书文档/Jira/线上文档/抓取/爬取/自动提取 | Confluence/Notion/URL/Jira/scrape/online docs/auto extract | Medium —— 草稿级产出，需用户逐条确认 | >=1 可访问的文档 URL | 15-20 | references/auto-scan-mode.md |
| `gap-survey` | Gap Survey | Fidelity | Medium | 缺某层/补充问卷/发问卷/填补/有缺失/定向问卷/补信息/填坑 | missing layer/fill gaps/survey/questionnaire/missing info | Medium —— 定向补充，仅填缺口层 | 已有一份草稿（L0+L1 已生成）+ 明确缺失层 | 5-10 (追加) | references/gap-survey-guide.md |
| `hybrid` | Hybrid | Balanced | Very High | 混合模式/组合/先扫描再访谈/先生成再补/先用A再用B/综合采集/混合 | hybrid/combine/scan then interview/mixed approach/combine modes | Context-dependent —— 取决于组合的模式 | >=2 种模式均可用的条件（如同时有 URL + 可访谈人员） | 25-30 | All of the above |

---

## 字段说明

| 字段 | 说明 |
|------|------|
| `mode_id` | 模式标识符，用于内部路由和 Step 1.5 模式加载表 |
| `spectrum` | **Balanced**=文档驱动与用户交互平衡 / **Fidelity**=侧重保真采集原始信息 / **Originality**=侧重探索性发现（当前 meta-skill 无此类型） |
| `oversight_level` | **Very High**=每步需用户确认，agent 不能自主推进 / **High**=关键决策需确认，其他可按模板自主推进 / **Medium**=结构化格式有限决策点 / **Low**=模板驱动极少需人工介入 |
| `trigger_phrases (zh)` | 中文触发词，逗号分隔。Agent 对用户输入做子串匹配 |
| `trigger_phrases (en)` | 英文触发词，逗号分隔。Agent 对用户输入做子串匹配 |
| `expected_output_quality` | 该模式下预期产出质量说明，帮助用户理解 trade-off |
| `min_input_requirements` | 该模式的最低输入条件 —— 不满足则无法进入该模式 |
| `estimated_turns` | 该模式下预估消耗的对话轮数（基于历史数据估算） |
| `reference_file` | 对应参考文件路径（相对于 meta-skill 根目录），byo 模式无额外文件 |

---

## Oversight Level 定义

| Level | 含义 | Agent 行为 | 适用场景 |
|-------|------|-----------|---------|
| **Very High** | 每步需用户确认 | 不能自主推进到下一步，必须等用户回复后才继续 | 访谈模式、混合模式（信息来自用户口述，不可编造） |
| **High** | 关键决策需确认 | 可按模板自主完成准备步骤，但关键决策点（模式选择、内容确认）必须暂停 | 自动扫描模式（URL 抓取 → 草稿 → 用户确认后才算完成） |
| **Medium** | 结构化有限决策点 | 按固定格式执行，仅在结果汇总时请求确认 | 缺口问卷（定向有限题量，结果可控） |
| **Low** | 模板驱动 | 按已有模板自主推进，仅在最终交付时展示结果 | BYO 模式（用户已提供材料，agent 按模板处理） |

---

## 模式选择流程

```
用户输入 → 匹配 trigger_phrases（zh + en 子串匹配）
    │
    ├─ 命中 1 个模式 → 直接进入该模式（告知用户匹配结果）
    │
    ├─ 命中 >=2 个模式 → 展示候选模式（mode_id + 一句话描述），请用户选择
    │
    └─ 命中 0 个模式 → 默认 byo，提示用户："我默认使用 BYO Materials 模式（你已提供材料）。
        如果需要其他模式，可选：访谈模式（口头描述）、自动扫描（提供URL）、混合模式。"
```

## 降级规则

1. **有需求无材料**：用户描述需求但未提供任何文档/URL/口述内容 → 自动推荐模式：
   - 若提到人名/岗位/「可以聊」→ 推荐 **interview**
   - 若提供了链接/Confluence/Jira → 推荐 **auto-scan**
   - 均无 → 展示 5 种模式简介，引导选择

2. **材料稀疏**：`<3` 项 Required items 存在 → 在 Step 1.5 中触发 sparse input 阈值，推荐 interview 或 gap-survey

3. **通用降级**：无触发词匹配 → byo 为默认降级模式，但会主动提示用户可切换

---

## 与 SKILL.md 的耦合点

| 耦合点 | 位置 | 说明 |
|--------|------|------|
| Intent Detection | SKILL.md 顶部（frontmatter 后） | Agent 启动时先读此注册表做触发词匹配 |
| Step 1.5 — Select Input Mode | SKILL.md Step 1 和 Step 2 之间 | 使用 mode_id 做路由，加载对应 reference，应用 oversight 约束 |
| Before You Start — Material Acquisition Modes | SKILL.md 中部（保留） | 面向人类的模式概览表，与此注册表保持同步 |
| References Map | SKILL.md 底部 | 列出此文件为 Step 1.5 强制参考 |
