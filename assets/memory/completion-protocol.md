---
name: completion-protocol
description: 完成内容 = 4 件事:Update(更新所有相关文件) / Reorganize(重组归位) / Adjust plan(调整 plan) / Adjust memory(调整 memory)
metadata:
  type: feedback
---

# 完成内容 = 4 件事 Meta-Protocol

**Why**: 大任务 / 阶段交付 / plan 完成时,如果只更新 primary deliverable 就停,会导致:(1) secondary 文件(spec / plan / retro / memory)失同步(2) 已完成 task 未标 done(3) 新洞察未沉淀 → 下次重复摸索。

**How to apply**: 任何"完成一个内容"事件后,显式跑这 4 件事 checklist。

## 4 件事 Checklist

| # | 动作 | 必做项 |
|---|---|---|
| 1 | **Update** | 更新所有相关文件(不只是 primary deliverable) — 引用此交付物的 spec / plan / CLAUDE.md / README 都同步 |
| 2 | **Reorganize** | 重组归位 — 文件路径符合 CLAUDE.md "文件归位"段;过期/作废文件移到 `_archive/YYYY-MM/` |
| 3 | **Adjust plan** | 调整 plan — 已完成 task 标 `done`;新增 task 加并标 dependency;作废 task 删并记"作废原因"避免重蹈 |
| 4 | **Adjust memory** | 调整 memory — 走 `memory-optimization-protocol`;新洞察沉淀(generic vs 项目专属分类);过程性/过期 memory 归档 |

## 触发"完成内容"事件

| # | 事件 | 何时 |
|---|---|---|
| 1 | 单个 task 标 done | task 真正完成后(不是声明 done) |
| 2 | 一个 phase 完成 | 例如 plan 中 Phase X 全部 done |
| 3 | 一个 milestone / 版本发布 | V0.1.X / V1.0 等 |
| 4 | 用户显式说"做完了" | — |
| 5 | 一次 AskUserQuestion 收口后 | 决策落档 |

## 反模式

| ❌ 别做 | ✅ 该做 |
|---|---|
| 只更新主文件,secondary 文件留旧 | 引用关系全更新 |
| 任务做完就忘,plan 不标 done | 任务 done 立刻更新 plan |
| 新洞察只口头说,不沉淀 | 立刻判断"generic / 项目专属 / 过程性"再写 memory |
| 完成即结束,不复盘 | 跑 `/retro` 闭环 |

## 完成内容 vs 阶段交付 区别

| 维度 | 完成内容(本 protocol) | 阶段交付(retro) |
|---|---|---|
| 颗粒度 | 1 个 task / 1 个 file | 1 个 phase / 1 个 version |
| 必做 | 4 件事(Update / Reorganize / Adjust plan / Adjust memory) | `/retro` 4 步(placeholder / consistency / scope / ambiguity) |
| 输出 | 同步更新 | 报告 + memory 沉淀 |
| 频率 | 高(每个 task) | 低(每 phase / version) |

## 关联

- [[root-goal-three-layer]] — 4 件事中"Reorganize"前先回归根本目标
- [[three-layer-decision-method]] — 判定 generic vs 项目专属时走三层法
- [[pre-flight-checklist]] — 完成内容**前**跑 pre-flight;完成后跑本 protocol
