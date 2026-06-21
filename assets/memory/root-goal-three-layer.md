---
name: root-goal-three-layer
description: 任何复杂任务前显式记录根本目标/根本问题;用户会调整目标,需 plan 调整 protocol + 偏差提醒;Self-review 升级到根本问题视角
metadata:
  type: feedback
---

# 根本目标视角(三层决策法的核心)

**Why**: 三层决策法是用户工作流的核心目标 — 它定义了 L1 原始权威 / L2 统一设计 / L3 具体问题的方法论。Agent 在执行复杂任务时,容易"陷入细节纠结"(格式、字数、frontmatter 字段、语法),**忘了根本目标**,导致做的是"看起来对"但"偏离根目标"的事。

**How to apply**: 任何复杂任务 / 设计 / plan 执行中,定期(每 3-5 步或 self-review 时)回归三个问题:

## 三个根本问题

1. **根本目标是什么?** — 用户真正想要达成的事,不是任务的字面交付物
2. **根本问题是什么?** — 阻碍目标达成的真问题,不是表面症状
3. **当前动作是否服务根本目标?** — 如果只是"格式 / 协议 / 字数"完美,可能跑偏

## 反模式

- ❌ "SKILL.md 字数控制在 ≤ 500" — 但忘记问"用户用这个 skill 的根本场景是什么"
- ❌ "frontmatter 字段集跟 superpowers 对齐" — 但忘记问"用户真正需要哪些字段"
- ❌ "bootstrap.sh 语法完美" — 但忘记问"用户实际怎么调用"

## Self-review 视角

借鉴 superpowers/brainstorming 的 self-review,但**根目标化**:

| 普通视角 | 根目标视角 |
|---|---|
| Placeholder scan: TBD/TODO 有没有 | 根本问题列清楚没?有没有"未识别的根问题" |
| Internal consistency: 章节是否矛盾 | 各章是否服务同一个根目标?有没有"看似一致但偏离"的章节 |
| Scope check: 范围是否聚焦 | 根问题是否对焦?有没有"范围对但根问题错" |
| Ambiguity check: 歧义 | 根问题描述是否多义?用户描述错了能不能纠正 |

## 用户偏差纠正

用户描述可能有偏差 / 错(打字错 / 中途改主意 / 拼写),此时:
- 不直接按字面执行
- 用根本目标反推: 用户最可能是指什么?
- 提示: "你说的是 X 还是 Y?我猜是 Y 因为..."
- 避免 agent 纠结"是不是要问用户" — 大多数情况下能反推就用反推

## Plan 调整 protocol

用户会**不间断**调整计划。应对:

| 调整类型 | 应对 |
|---|---|
| 重新排序 | 重排 task,标 "已在 in_progress 的继续" |
| 之前产物作废 | 删除 + 在 findings.md 记"作废原因"避免重蹈 |
| 新增 task | 在 plan 末尾追加,dependency 链可能断 |
| 修改已有 task | 先核对"已完成产物是否仍 valid",再决定 amend or redo |

每次 plan 调整后,**先跑 pre-flight**:核对已完成产物是否需要 amend。

## 触发场景

- 任何 meta-skill / meta-rule / meta-plan 设计
- 用户描述模糊时
- Agent 陷入"完美主义"细节时
- Self-review 时

## 关联

- [[three-layer-decision-method]] — 三层法是根目标的方法论
- [[parallel-subagent-research]] — subagent 调研时也要根目标化
- [[pre-flight-checklist]] — plan 调整后跑 pre-flight 核对已完成产物
- bootstrap-workflow 设计: `docs/superpowers/specs/2026-06-21-bootstrap-workflow-design.md`
