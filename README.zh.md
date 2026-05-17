# meta-skill-process-architect

> 🏗️ 将任意业务流程的原始资料转化为结构化、多角色、可执行、可维护的流程 Skill。

[![版本](https://img.shields.io/badge/version-1.0.0-blue)](VERSION)
[![阶段](https://img.shields.io/badge/phase-4%2F4%20complete-brightgreen)]()
[![许可](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.9%2B-blue)]()

---

## 30 秒理解

你有一堆流程资料（SOP 文档、流程图、Wiki 页面、访谈记录、Jira 日志），想变成一套结构化的流程 Skill。这套 Skill 要给 3-7 种角色用（执行者、审计者、新人、管理者……），要能跨平台跑（WorkBuddy / OpenClaw / Claude Code / 独立使用）。

**这个元技能就是做这件事的。**

它会产出 `process-{name}/` 目录，包含：
- **SKILL.md** — 入口（L0）
- **process-brief.md** — 完整流程定义：9 个子节（L1）
- **foundational-logic.md** — 为什么这样设计（L2）
- **output-recipes.md** — 14 种产出格式，面向不同角色（L3）
- **artifacts-registry.md** — 表单/模板/检查清单索引（L4）
- **visualization-spec.md** — Mermaid 图规范（L5）
- **cases-library.md** — 案例与经验库（L6）

---

## 快速上手

```bash
# 1. 初始化 —— 给流程起个名字，指定原始资料目录
python cli/meta-skill-process-architect.py init \
  --name "客户退款" \
  --materials ./退款流程文档/

# 2. 生成 —— CLI 搭好骨架，内容由 agent 工作流填充（见 SKILL.md）
python cli/meta-skill-process-architect.py generate \
  --output ./process-customer-refund/

# 3. 验证 —— 18 项结构检查 + 10 条反模式扫描
python cli/meta-skill-process-architect.py validate \
  --skill ./process-customer-refund/

# 4. 打包 —— 生成 .tar.gz，可直接导入 WorkBuddy 或 OpenClaw
python cli/meta-skill-process-architect.py package \
  --format workbuddy \
  --skill ./process-customer-refund/
```

> 💡 **只想看一个完整例子？** 打开 `examples/sp007-customer-refund/`，里面是一个已经通过全部验证的退课退款流程 Skill。

---

## 架构

```mermaid
graph TB
    subgraph "输入采集"
        BYO[自带材料]
        INTERVIEW[访谈模式]
        AUTOSCAN[自动扫描]
        SURVEY[缺口问卷]
    end

    BYO --> EXTRACT
    INTERVIEW --> EXTRACT
    AUTOSCAN --> EXTRACT
    SURVEY --> EXTRACT

    EXTRACT[提取 L0+L1<br/>+ 检测缺口] --> CHECK[检查点<br/>呈现缺口与推断]
    CHECK --> GEN[生成 L2-L6<br/>+ 跨流程引用]
    GEN --> SCAN[反模式扫描<br/>10 条规则]
    SCAN --> TRACE[轨迹检查<br/>文档 vs 现实]
    TRACE --> RECIPES[产出配方<br/>14 种格式, 7 种角色]
    RECIPES --> PACK[打包 + 验证<br/>18 项检查清单]
    PACK --> NETWORK[跨流程同步<br/>双向链接]

    style EXTRACT fill:#4a9,stroke:#272
    style CHECK fill:#da3,stroke:#860
    style GEN fill:#4a9,stroke:#272
    style SCAN fill:#c44,stroke:#800
    style PACK fill:#48b,stroke:#248
```

---

## 文档地图

| 文件 | 内容 | 给谁看 |
|---|---|---|
| `SKILL.md` | 元技能入口 — 前置条件、Workflow Step 0-8、约束条件、验证清单 | **所有人先看这个** |
| `references/process-archetype.md` | L0-L6 完整 schema + Gap Handling + 反模式检测 + 生命周期规则 | 想理解"为什么这样设计" |
| `references/role-audience-model.md` | 7 种标准角色 + 5 种角色性质 + recipe→角色映射 | 设计 recipe 时 |
| `references/lifecycle-operations.md` | 版本 bump、TTL 管理、diff-aware 更新、生命周期状态机 | 维护生成的 Skill 时 |
| `references/trace-mode.md` | 文档 vs 现实 drift 分析、步骤分类、健康阈值 | 怀疑文档过时时 |
| `references/cross-process-network.md` | 跨流程引用检测、双向链接同步、网络可视化 | 多个流程互联时 |
| `references/interview-mode.md` | 三方访谈脚本 + 合并算法 + 冲突解决 | 用访谈模式采集时 |
| `references/auto-scan-mode.md` | URL→draft 提取规则（Confluence/Notion/Jira）| 用自动扫描模式时 |
| `references/gap-survey-guide.md` | 按角色分发问卷 | 有信息缺口时 |
| `cli/meta-skill-process-architect.py` | Python CLI 工具（仅依赖标准库）| 命令行操作 |
| `templates/` | 30 个中英双语模板 | 生成 Skill 时自动使用 |
| `examples/sp007-customer-refund/` | 完整示例 | 想看成品长什么样 |

---

## CLI 命令速查

```bash
# 生命周期
process-architect init       --name "流程名" --materials ./资料目录/
process-architect generate   --output ./process-xxx/
process-architect validate   --skill ./process-xxx/
process-architect package    --format workbuddy --skill ./process-xxx/

# 维护（Phase 3）
process-architect bump       --skill ./process-xxx/ --type minor "描述变更内容"
process-architect ttl-check  --skill ./process-xxx/                  # 单个 Skill
process-architect ttl-check  --skills ./dir1,./dir2                  # 批量检查
process-architect diff-plan  --skill ./process-xxx/ --since 1.0.0

# 网络（Phase 3）
process-architect network    --skills ./全部流程目录/                # 全部流程
process-architect network    --skill ./process-xxx/ --skills-dir ./  # 单流程焦点

# 高级验证（Phase 3）
process-architect validate   --skill ./process-xxx/ --trace --trace-source flow.csv
process-architect validate   --skill ./process-xxx/ --coverage
process-architect validate   --skill ./process-xxx/ --trace --sla-report sla.csv
```

---

## 生成的 Skill 结构

```
process-{name}/
├── SKILL.md                         # L0 — 入口 + 速查表
├── VERSION                          # 语义化版本
├── CHANGELOG.md                     # 变更记录
├── LICENSE                          # MIT
├── agents/openai.yaml
├── references/
│   ├── process-brief.md             # L1 — 触发/输入/角色/步骤/决策/状态机/RACIO/SLA/边界
│   ├── foundational-logic.md        # L2 — 目的/权衡/设计原则/方法论来源
│   ├── output-recipes.md            # L3 — 14 种产出格式
│   ├── artifacts-registry.md        # L4 — 表单/模板/检查清单索引
│   ├── visualization-spec.md        # L5 — 流程图绘制约定
│   └── cases-library.md             # L6 — 案例与经验库
└── assets/
    ├── flowcharts/
    ├── forms/
    └── templates/
```

---

## 版本历史

| 版本 | 日期 | 内容 |
|---|---|---|
| **1.0.0** | 2026-05 | Phase 4 发布 — README 完整化、examples/、自验证、git init |
| **0.9.0** | 2026-05 | Phase 3 — 生命周期运维、轨迹模式、跨流程网络 |
| **0.5.0** | 2026-05 | Phase 2 — 4 种输入模式、14 种产出配方、L4-L6 模板 |
| **0.1.0** | 2026-05 | Phase 1 — L0-L6 框架、6 种核心配方、CLI 工具、反模式检测 |

详见 `CHANGELOG.md`。

---

## 设计权威来源

本实现源自 `DESIGN.md`（独立发布）和 `../meta-skill-process-architect-plan.md`（monorepo 完整版）。DESIGN.md 是本 Skill 的权威设计参考。任何冲突 → DESIGN.md 为准。

---

## 许可

MIT — 详见 `LICENSE`。
