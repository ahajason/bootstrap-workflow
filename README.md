# Bootstrap Workflow

> 把通用工作流方法论(三层决策 / 闭环复盘 / 4 件事协议)封装为可复用的 project bootstrap skill。

## 这是什么

`disable-model-invocation: true` 的 user-invocable skill:启动新项目时,一键复制通用工作流骨架(CLAUDE.md + 4 rules + 4 memory + 1 skill)。检测已有配置,不静默覆盖(superskills 缺口的兜底)。

## 怎么用

作为 Claude Code skill 安装(本 skill 必搭配 AI Agent,占位块由 Agent 询问后填入,不由用户手动输入):

```bash
# 克隆仓库
git clone https://github.com/ahajason/bootstrap-workflow.git \
  ~/.claude/skills/bootstrap-workflow

# 在 Claude Code 中
/bootstrap-workflow
```

## 安装到目标项目后会得到

```
<target-project>/
├── CLAUDE.md                              # jason 工作流骨架(填项目信息)
├── .claude/
│   ├── rules/
│   │   ├── decision-method.mdc           # 三层决策法 + 闭环复盘
│   │   ├── commit-style.mdc              # commit 写法
│   │   ├── comment-style.mdc             # 代码注释风格
│   │   └── task-directory.mdc            # 任务正式档
│   ├── memory/
│   │   ├── mechanism-layering.md         # 4 层机制分层
│   │   ├── root-goal-three-layer.md      # 根本目标视角
│   │   ├── parallel-subagent-research.md # 并行 subagent 调研
│   │   └── completion-protocol.md        # 完成内容 4 件事
│   └── skills/
│       └── retrospective/SKILL.md        # 闭环复盘 4 段模板
```

## 核心方法论(完整复制)

本 skill 完整复制 jason 工作流的核心 6 大特点:

| # | 特点 | 落地形式 |
|---|---|---|
| 1 | 三层决策 + 闭环复盘 | `decision-method.mdc` + `retrospective` skill |
| 2 | 根本目标视角 | `root-goal-three-layer.md` memory |
| 3 | 方法论沉淀机制 | 4 桶 memory 架构 + `mechanism-layering.md` |
| 4 | 极简 + 精准 | karpathy 4 原则(写在 CLAUDE.md 工作流铁律) |
| 5 | 持续 plan 调整 + 4 件事协议 | `completion-protocol.md` + `root-goal-three-layer.md`(Plan 调整 protocol 段) |
| 6 | Edge case 防御 + 安全操作 | Step 1 detect + typed `proceed` + `.bak.<timestamp>` 备份 |

**相对精简,不是绝对精简** — 重要方法论不删,根据场景调整。

## 流程(3 步)

1. **Step 1: Detect** — `ls -d .claude CLAUDE.md 2>/dev/null`,逐个冲突文件给 4 编号选项
2. **Step 2: Confirm + Execute** — typed `proceed` 兜底 + 自动 `.bak.<timestamp>` 备份
3. **Step 3: Verify** — 9 文件齐 + 无 `{{...}}` 占位符 + 项目 build/type-check/test 跑通

## 仓库结构

```
bootstrap-workflow/
├── SKILL.md                              # 入口,~200 字
├── assets/                               # 复制即用模板(9 文件)
│   ├── CLAUDE.md.template
│   ├── rules/  (4 mdc)
│   ├── memory/ (4 md)
│   └── skills/retrospective/SKILL.md
├── scripts/
│   └── bootstrap.sh                      # 一键复制
├── docs/                                 # 设计文档 + 贡献者参考
│   ├── contributing/                     # 完整 L1/L2/L3 评估 + 完整 memory/rules 集
│   └── design.md                         # 完整设计文档
├── README.md                             # 本文件
├── LICENSE                               # MIT
└── .gitignore
```

## 贡献者

详见 `docs/contributing/`:

- `L1-evaluation.md` — 5 个参考对象评估
- `L2-design.md` — 本 skill 结构设计
- `L3-specific.md` — 完整 41 项 L3 红线清单
- `edge-case-handling.md` — 4 编号选项 + .bak + 冲突 UX
- `claude-code-memory-official.md` — 官方 memory 机制 + 200 行上限
- `optional-memory.md` — 完整 14 个可选 generic memory
- `optional-rules.md` — 完整 9 个可选 generic rules

## License

MIT
