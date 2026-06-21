---
name: parallel-subagent-research
description: 调研 ≥3 参考对象或长原始文档时,派并行 subagent 启发式提取(≤150 字 each),主线程专注总结构,避免 context 膨胀
metadata:
  type: feedback
---

# 并行 Subagent 调研法

**Why**: 大任务开始时,如果主线程逐个 Read 5+ 参考对象,会(1) context 膨胀(2) 早陷入细节而忘记总结构(3) 反复读同一对象变体浪费时间。Subagent 用启发式提取(≤150 字/对象)成本低、聚焦"启示"不复读。

**How to apply**: 调研 ≥ 3 个参考对象 / 设计文档 / 长文件时,按以下模式:

## Subagent Prompt 模板

```markdown
你是调研 subagent。读取以下 <对象列表> 的完整内容,每条 1 段(≤150 字)提取"对 <当前主任务> 的启示":

1. <path 1>
2. <path 2>
...

完成后输出 markdown 表格,<N> 行,列:`skill/对象` / `核心方法` / `对 <主任务> 的启示` / `直接复用度`(高/中/低)

禁止:
- 不要复述原文段落
- 不要做"全文 summary"
- 不要把整个文件 cat 出来
- 不要引用任务之外的资料
```

## 主线程应该做的事

1. **先想总结构**(L1/L2/L3 / 阶段 / 决策点)
2. **派 2-3 subagent 并行**(各自独立领域)
3. **等结果,合成启发式**
4. **写入 findings.md**(避免下次重读)

## 反模式

- ❌ 主线程 Read 大文件全文 → context 爆
- ❌ Subagent prompt 让"复述全文" → 跟主线程 Read 没区别
- ❌ 派 subagent 后主线程空等 → 应该同时想总结构
- ❌ 不写 findings.md → 下次重调研

## 触发场景

- 设计 meta-skill / meta-rule(需要研究 3+ 参考对象)
- 设计 spec 前的现状摸底
- 任何"先调研再设计"的工作

## 关联

- [[three-layer-decision-method]] — L1 评估可派 subagent
- [[pre-flight-checklist]] — 调研前先跑 pre-flight
- bootstrap-workflow 设计: `docs/superpowers/specs/2026-06-21-bootstrap-workflow-design.md`
