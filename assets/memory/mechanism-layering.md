---
name: mechanism-layering
description: Rule / Skill / Doc / Memory 各司其职 — 纪律 / 流程 / 实例 / recall 事实。Bootstrap 时复制 generic 部分,项目专属不进。
metadata:
  type: feedback
---

# Mechanism Layering — 4 层机制分层

**Why**: 不同的内容应该用不同的 Claude Code 机制承载,不要混层。混层会导致 always-load 污染 / 重复维护 / recall 失效。

**How to apply**: 写新方法论前,先判定归类。

## 4 层分工

| 机制 | 承载什么 | 加载方式 | 例子 |
|---|---|---|---|
| **Rule** (.mdc) | 行为纪律 / 必走流程 | alwaysApply / paths 匹配 | `decision-method.mdc`(三层决策) / `comment-style.mdc`(注释规则) |
| **Skill** (SKILL.md) | 流程调用 / 工具(可手动 `/xxx` 触发) | 触发式 / 描述匹配 | `retrospective`(闭环复盘 4 段模板) / `bootstrap-workflow`(项目启动) |
| **Doc** (docs/) | 项目实例 / 业务 spec / plan / report | on-demand Read / 路径自解释 | `docs/specs/2026-06-19-floating-design.md` |
| **Memory** (~/.claude/projects/.../memory/) | recall 事实 / 跨 session 经验 | 全量装载(200 行上限) / topic on-demand Read | `three-layer-decision-method.md` / `parallel-subagent-research.md` |

## 判定规则

| 内容 | 归到 |
|---|---|
| "X 时应该做 Y" (必走流程) | Rule |
| "/xxx 触发后走 4 步流程" (可调用工具) | Skill |
| "本项目 X 是 Y" (项目实例) | Doc |
| "跨 session 召回的事实" (经验) | Memory |

## 反模式

- ❌ 把"流程模板"塞进 Rule → always-load 污染 context
- ❌ 把"必走纪律"塞进 Skill → 必须主动调,容易忘
- ❌ 把"项目实例"塞进 Memory → 不该跨项目召回
- ❌ 把"跨 session 经验"塞进 Doc → 不沉淀易丢

## Bootstrap 时

- **Rule**: generic 必装 + 项目专属可加 paths
- **Skill**: 1-2 个最核心(bootstrap-workflow 装 retrospective)
- **Doc**: 不复制(项目自己填)
- **Memory**: 3 桶(mechanism-layering / root-goal / parallel-subagent)走 `MEMORY.md` 索引 + topic 文件

## 关联

- [[three-layer-decision-method]] — 三层法(也是 Rule)
- [[root-goal-three-layer]] — 根目标视角
- [[parallel-subagent-research]] — 并行 subagent 调研
- bootstrap-workflow 设计: `docs/superpowers/specs/2026-06-21-bootstrap-workflow-design.md`
