---
name: bootstrap-workflow
description: Use when starting a new project (or bootstrapping an existing one) with the user's standard workflow — three-layer decision method, commit style, comment style, retrospective. ONLY installs workflow templates (CLAUDE.md + .claude/rules + .claude/memory + 1 skill). NOT framework, linter, formatter, CI, README, or business code — use vite/next/cargo create for that. Skip for projects with strong existing conventions.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Write, Bash
---

# Bootstrap Workflow

> **Tradeoff**: 谨慎而非速度。琐碎项目用 judgment,不强塞。

## 这个 skill 只装什么(显式边界)

| ✅ 装 | ❌ 不装 |
|---|---|
| CLAUDE.md(工作流骨架) | package.json / vite.config / 框架脚手架 |
| `.claude/rules/*.mdc`(4 个 generic rule) | .eslintrc / .prettierrc / husky / lint-staged |
| `.claude/memory/*.md`(4 个 generic memory) | .github/workflows / CI 配置 |
| `.claude/skills/retrospective/`(1 个 skill) | README.md(用户自己写) |
| | 业务代码 / src/ 目录 / 测试样例 |

**用错了的征兆**:你在装 `package.json` 或 `vite.config` → 错了,那是 vite/next 的事。

## 流程(3 步)

**Step 1: Detect**(edge case 必走,扫描 4 类)

1. **业务文件探测**(Step 1a): `ls -d package.json .eslintrc* .prettierrc* vite.config* next.config* tsconfig.json .github 2>/dev/null`
   - 若有 → "目标项目已有框架/工具配置,本 skill 只装工作流模板,不动这些"
   - 询问 "继续 / abort"
2. **工作流配置探测**(Step 1b): `ls -d .claude CLAUDE.md 2>/dev/null`
   - 报告"目标项目已有 X / Y / Z"
   - **每个冲突文件单独问** 4 编号选项:
     1. **merge** — 智能合并(规则追加 / 业务域占位补 / 已有文件跳过)
     2. **replace with backup** — 覆盖前 `.bak.<timestamp>` 写到 `.claude/_backups/`
     3. **skip** — 跳过此文件
     4. **abort** — 终止整个 bootstrap
3. **生成差异表**(Step 1c):
   - 列出"skill 建议装 vs 项目已有"差异
   - 列完整文件清单(不全不能 proceed)

**Step 2: Confirm + Execute**
- Dry-run 输出"将创建/覆盖的所有文件 + 备份状态"
- 用户 typed `proceed`(不是 y/n)才继续
- 自动 `.bak.<timestamp>` 备份 + 写 `.claude/_backups/MANIFEST.md`(时间戳 + 路径 + sha256)

**Step 3: Verify**
- 1. 9 文件齐(CLAUDE.md + 4 rules + 4 memory + 1 skill)
- 2. 无 `{{...}}` 占位符残留
- 3. 项目自带的 `build` / `type-check` / `test` 跑通(已有就跳)

## What Gets Copied

9 个核心文件:`CLAUDE.md.template` + 4 rules(decision / commit / comment / task-directory)+ 4 memory(mechanism-layering / root-goal / parallel-subagent / completion-protocol)+ 1 skill(retrospective)。全部 generic,不含项目业务域。

## What Stays Out

- **5 项 L3 高频红线** + 完整 41 项清单放仓库 `docs/contributing/L3-specific.md`
- **业务域**(玻璃 / Tauri / macOS / etc)— 项目专属,本 skill 不假设
- **完整可选 memory/rules**(14 个)— 放仓库 `docs/contributing/optional-*.md`,用户按需手动复制

## Common Mistakes(8 项 RED + 5 项 REFACTOR 反模式)

### RED 阶段(8 项)
- ❌ **F1**:把"配工作流"误读成"从零铺",装 package.json / vite.config / src/ → 错,那是 vite/next 的事
- ❌ **F2**:盲装 ESLint/Prettier/husky/lint-staged → 错,本 skill 不装 linter
- ❌ **F3**:把"已有但简"当"缺"重写,丢内容 → detect 必区分"已有 vs 缺 vs 冲突"
- ❌ **F4**:缺文件清单凭印象漏列 → dry-run 必须列完整清单,不全不能 proceed
- ❌ **F5**:跳过读现有 convention 直接 invoke → Step 1 detect 必走,列差异表
- ❌ **F6**:静默合并策略(不询问) → 每个冲突必 AskUserQuestion
- ❌ **F7**:没列冲突清单就执行 → dry-run 列差异表,用户必看
- ❌ **F8**:写 README → WHAT STAYS OUT 显式,用户自己写

### REFACTOR 阶段(5 项)
- ❌ **F-1**:`case *)` fallback 默认 merge → 改为重问,不接受无效输入
- ❌ **F-2**:Step 1a "继续?" 用 y/n → 统一 typed `proceed`(与 Step 2 一致)
- ❌ **F-3**:空目录场景无引导 → 显式提示"先用 vite create 再 bootstrap"
- ❌ **F-4**:verify 只校验 6 文件 → 改为 9 文件齐(CLAUDE.md + 4 rules + 4 memory + 1 skill)
- ❌ **F-5**:SKILL.md 承诺 skip 但脚本没实现 → 强 convention 项目通过 Step 1b 用户选 `3 skip` 实现

### 应用层
- ❌ 在已有强 convention 项目强行 bootstrap → 应 skip 或仅补缺
- ❌ 静默接受无效输入(回车 / 数字 5+)→ 必须重问,不能默认 merge

## 装完后能用啥

- 三层决策 → `.claude/rules/decision-method.mdc`
- commit 风格 → `.claude/rules/commit-style.mdc`(含粒度建议)
- 注释原则 → `.claude/rules/comment-style.mdc`
- 任务正式档 → `.claude/rules/task-directory.mdc`
- 闭环复盘 → 跑 `/retro` 自动沉淀
- 根本目标视角 → `.claude/memory/root-goal-three-layer.md`

## 配置记忆

跑过一次后,commit 粒度会写到 `<目标项目>/.bootstrap-workflow.json`(项目级),后续运行直接读取,不重复问。每次仍可临时覆盖。
