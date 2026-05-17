# Design Reference — meta-skill-process-architect

> 精简自 `../meta-skill-process-architect-plan.md` v1.0.3。Skill 独立发布时，本文件是权威设计来源。
> 完整 plan 见父目录（monorepo 中）或 GitHub 仓库。

---

## Architecture Decision Records

### ADR-001: L0-L6 分层架构
**决策**：流程 Skill 采用渐进式 7 层加载架构（L0-L6），每层独立文件。  
**理由**：不同角色/场景需要不同深度；一次性加载全部文档浪费 token 且降低可读性。  
**约束**：L0 始终加载；L1-L6 按需加载。

### ADR-002: 角色 ≥ 2 为 P0 阻断
**决策**：生成流程 Skill 时，涉及角色 < 2 是 P0 阻断。  
**理由**：角色 < 2 的不是"流程"而是"操作说明"。  
**例外**：Solo Mode（v1.1 规划中）将允许角色 = 1。

### ADR-003: Mermaid 为主图式
**决策**：流程图使用 Mermaid，不使用 BPMN。  
**理由**：Mermaid 纯文本、版本可控、可在 Markdown 中直接渲染。BPMN 学习成本高、工具依赖重。  
**评估时点**：v2.0 重新评估是否需要 BPMN 导出。

### ADR-004: 反模式检测分层
**决策**：10 条反模式分三级——Block（阻断生成）、Warn-confirm（警告需确认）、Warn-passive（警告不阻断）。  
**理由**：不能一刀切。角色名太短是警告，没有流程负责人是阻断。

### ADR-005: BYO Materials 为默认输入模式
**决策**：用户自带材料（SOP/流程图/Wiki）为默认输入模式。Interview/Auto-Scan/Survey 为补充。  
**理由**：Phase 1 快速验证核心价值；Phase 2 扩展输入方式。

### ADR-006: 中英双语模板
**决策**：所有模板同时提供 EN 和 ZH 版本。  
**理由**：国内市场为主、英文为国际化准备。

### ADR-007: TTL 标记语法 `@valid_until=YYYY-Q#`
**决策**：易变字段用 `@valid_until=YYYY-Q#` 注释标注有效期。  
**理由**：可视化的过期提醒，不依赖外部数据库。

### ADR-008: Trace Mode 仅文档化
**决策**：Phase 3 Trace Mode 只提供方法 + CLI 骨架，不接入真实 Jira API。  
**理由**：API 接入依赖具体工具栈，过早实现会过度绑定。

### ADR-009: Cross-Process 网络用 L1.9 out_of_scope 驱动
**决策**：跨流程引用通过解析 L1.9 的 `out_of_scope` 自动检测，不手动维护关系表。  
**理由**：信息源头单一，新增流程自动入网。

### ADR-010: CLI 用 Python stdlib only
**决策**：CLI 仅依赖 Python 标准库（argparse/json/os/re/shutil/pathlib/tarfile/subprocess/csv）。  
**理由**：零安装门槛、跨平台（Mac/Windows/Linux）开箱即用。

### ADR-011: Plan 是权威来源
**决策**：若 SKILL.md 与 plan.md 冲突，plan 为准。  
**理由**：SKILL.md 是操作入口，plan.md 是设计真相。本 DESIGN.md 是 plan 的独立发布精简版。

---

## 生成 Skill 的结构

```
process-{name}/
├── SKILL.md                         # L0 入口
├── VERSION / CHANGELOG.md / LICENSE
├── agents/                          # 平台配置
├── references/
│   ├── process-brief.md             # L1 流程总纲（9 子节）
│   ├── foundational-logic.md        # L2 设计逻辑
│   ├── output-recipes.md            # L3 产出配方
│   ├── artifacts-registry.md        # L4 产物索引
│   ├── visualization-spec.md        # L5 可视化规范
│   └── cases-library.md             # L6 案例库
└── assets/
    ├── flowcharts/ / forms/ / templates/
```

## L0-L6 层级速览

| 层 | 内容 | 加载时机 |
|---|---|---|
| L0 | 概述 + 速查表 + 如何用 | 始终 |
| L1 | 触发/输入/角色/步骤/决策/状态机/RACIO/SLA/边界 | 理解流程时 |
| L2 | 目的/权衡/设计原则/方法论来源 | 理解 WHY 时 |
| L3 | 14 种产出配方（SOP/Runbook/RACIO/FAQ...） | 生成产出时 |
| L4 | 表单/模板/检查清单索引 | 找具体物件时 |
| L5 | Mermaid 绘制约定 | 渲染/修改流程图时 |
| L6 | 案例与经验库 | 学习经验时 |

---

## 7 种标准角色

| ID | 角色 | 关心什么 |
|---|---|---|
| operator | 操作者 | 我这一步怎么做 |
| owner | 流程负责人 | 全链路状态 |
| auditor | 审计者 | 哪里不合规 |
| trainee | 新人 | 整体是什么、先学哪 |
| customer | 客户 | 我该做什么、什么时候好 |
| compliance | 合规官 | 法律/监管风险 |
| executive | 管理层 | 投入产出、关键数字 |

---

## 版本历史

| 版本 | 对应 plan | 说明 |
|---|---|---|
| v1.0 | plan v1.0.3 | Phase 1-4 完整实现 |

本文件是 `meta-skill-process-architect-plan.md` 的精简独立版。完整设计讨论和 Phase 历史见完整 plan。
