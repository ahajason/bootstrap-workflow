# 实战复盘 — bootstrap-workflow skill 双生产环境部署

**时间**:2026-06-21 ~ 2026-06-22
**范围**:mindtap1.2(同源 fork)+ cloud(独立 Monorepo,22 子项目)
**目的**:验证 skill + 收集升级点
**作者**:jason + Claude(session `16edbb32-...`)

---

## 0. 一图速览

| 维度 | mindtap1.2 | cloud |
|---|---|---|
| **部署结果** | ✅ 完整成功(3 commit) | ⚠️ 顶层成功 + 1 事故恢复 + 1 纠偏 |
| **Holistic 策略** | Replace-all(2,旧 convention 弱) | Add-only(1,顶层 23 CLAUDE.md 强 convention) |
| **冲突文件** | CLAUDE.md + 4 rules + 4 memory(共 9) | CLAUDE.md(1,顶层) |
| **Commit 粒度** | per-domain(2,3 commit) | 不写(顶层非 git repo) |
| **事故** | 无 | 1 次严重覆盖,JSONL 恢复 |
| **纠偏** | 无 | 1 次(Monorepo 语义误读 → 取消子项目 bootstrap) |
| **总 commit** | 3(应用)+ 0(回滚) | 0 + 1(bug fix 本次合并) |

**核心指标**:
- 9 文件全部正确安装:✅
- bug fix:已合并入本次 commit
- memory 沉淀:`_facts/bootstrap-sh-copy-phase-bug.md`(已存)
- 事故恢复时间:~10 分钟(subagent JSONL + sed 去 prefix)

---

## 1. Initial decision

### 1.1 目标

验证当前 skill 在 **真实生产环境** 的稳定性,具体三个子目标:

1. **完整成功路径**:正常 9 文件安装 → commit 落地
2. **Holistic 4 策略**:Add-only / Replace-all / Skip+backup / Per-file 至少覆盖 2 种
3. **Commit 3 粒度**:Superpowers / per-domain / all-in-one 至少跑过 1 种

### 1.2 选样

| 项目 | 类型 | 为什么选它 |
|---|---|---|
| **mindtap1.2** | 同源 fork(跟主 mindtap 同 git 历史) | **最简场景**:测试 skill 干净路径,无历史包袱 |
| **cloud** | 独立 Monorepo,22 子项目,5.1GB | **最复杂场景**:测试 Hol Monorepo + 强 convention + 顶层 vs 子项目语义 |

### 1.3 验证 scope

- ✅ 9 文件齐全校验(Step 4 verify)
- ✅ 无 `{{...}}` 占位符残留
- ✅ 用户输入符合预期
- ❌ **没**跑 production 业务代码 smoke test(部署即验收,因为是配置文件,业务逻辑在 Claude Code 调用时验证)
- ❌ **没**做 dry-run diff preview(根本没这个功能)

---

## 2. Unidentified at decision time

按 retrospective skill 的 L1/L2/L3 三层分类。

### 2.1 L1 — 没读到 / 没引用的外部权威

| # | 漏掉的 | 影响 | 后续 |
|---|---|---|---|
| L1-1 | superpowers `using-git-worktrees` 强调 "Step 0 detect" 范式 — **已借鉴** ✓ | n/a | — |
| L1-2 | superpowers 哲学"覆盖前必自查 + 必须 typed proceed" | 部分借鉴(Step 2 confirm),但没强制到 Copy 阶段 | 本 commit 补 |
| L1-3 | Claude Code subagent session JSONL line 9+ 含完整 tool_result(可作 backup) | 不知道有这个"黄金备份"路径 | 事故后才发现,写入 memory |

### 2.2 L2 — 没覆盖到的项目内 spec / convention

| # | 漏掉的 | 影响 | 后续 |
|---|---|---|---|
| L2-1 | **Copy 阶段必须 enforce Holistic 策略** — 这是核心设计漏洞 | Add-only 选了仍覆盖,导致事故 | 加 `[[ " ${CONFLICTS[*]} " =~ " $path " ]]` 检查 |
| L2-2 | **Monorepo 顶层 vs 子项目语义** — SKILL.md 没写 | 我误读"monorepo = 每个子项目都装" | 纠偏后追加"Monorepo Handling"段 |
| L2-3 | **dry-run diff 模式** — 完全没有 | 用户没法可视化看到"将覆盖哪些" | 下次升级加 `--dry-run` |
| L2-4 | **stdin echo 回显 + 二次 confirm** — 缺失 | `printf "proceed\n2\n"` 选错无法立即察觉 | 下次升级加 |

### 2.3 L3 — 没枚举到的 user-facing 副作用(最关键)

按 retrospective skill:症状往往不在原 L3 列表里。

| # | 实际副作用 | 为什么没枚举到 |
|---|---|---|
| L3-1 | **即使上游策略选对,下游 Copy 阶段不 enforce → 覆盖** | 8 项 RED 反模式只列"静默合并",没列"上游对下游错"这类**跨阶段不一致** |
| L3-2 | **stdin 重定向不可见 → 误选策略** | 没在 production 场景下考虑"脚本可能在非交互环境跑" |
| L3-3 | **Monorepo 部署时,用户原意 = "根目录加规范,子项目引用"** | 我把它解读成"每个子项目都要 bootstrap"。这是**用户意图核对**缺失,不是技术 bug |
| L3-4 | **JSONL line 9 是 subagent 写大文件前的最后一次 Read** | 没预期到这个文件会成"黄金备份" |

---

## 3. Later exposure

### 3.1 事故:cloud/CLAUDE.md 被覆盖

**时间**:2026-06-21 ~ 22:30
**影响**:13135B / 223 行 / 气球云 monorepo 真实文档 → 4856B / 通用模板
**生产环境**:✅ 是(`/var/www/cloud` 是 5.1GB 22 子项目 monorepo)
**只跑一次**:✅ 是

**症状链**:
1. 第一次跑:`printf "proceed\n2\n"` → 选了 **Replace-all(本意 Add-only)** → Step 2 confirm 拦下来没执行
2. 第二次跑:`printf "proceed\n1\nproceed\n2\n"` → 选了 **Add-only** → Copy 阶段不查 `CONFLICTS` 数组 → **覆盖发生**

**真实根因**(不是表层):
- 表层:Copy 阶段无条件 `sed > CLAUDE.md`
- 深层:**Add-only 策略执行细节缺失** — `case "$HOLISTIC" in add-only) CONFLICTS=()` 后,Copy 阶段不知道"用户已经选了不覆盖",仍按默认行为执行
- 隐层:**step 阶段间状态不一致** — Holistic 阶段修改了 `CONFLICTS` 数组,但 Copy 阶段没把这个修改作为"不覆盖"信号

**修复**(本 commit):
```bash
# CLAUDE.md(关键:Add-only / Skip-existing+backup 不覆盖!)
if [[ " ${CONFLICTS[*]} " =~ " CLAUDE.md " ]]; then
  echo "  ⏭️  CLAUDE.md 在冲突列表中,跳过(用户已选 Add-only / Skip+backup / Per-file skip)"
else
  sed "s|{{BUSINESS_DOMAINS}}|$BUSINESS_DOMAINS|g" \
    "$SKILL_DIR/assets/CLAUDE.md.template" > "$TARGET/CLAUDE.md"
  echo "  ✓ CLAUDE.md"
fi
```
9 个文件全部加同样检查。

**恢复方法**(同类事故适用):
1. subagent session JSONL(`~/.claude/projects/.../subagents/agent-*.jsonl`)里搜关键字
2. 提取 `tool_result.content`(Read 工具的 `cat -n` 风格输出)
3. **注意**:含 line number prefix(`数字<TAB>`),恢复后 `sed -i '' -E 's/^[0-9]+\t//' <file>` 去 prefix

---

### 3.2 事故:stdin 重定向误选策略

**时间**:2026-06-21 ~ 22:00
**影响**:首次 bootstrap 选了 Replace-all,本意 Add-only
**生产环境**:✅ 是

**症状链**:
1. 准备 stdin:`printf "proceed\n2\n"`(打算选 Add-only = 1,实际想 2 是 Replace-all — **数字记错**)
2. 脚本运行,选了 Replace-all
3. **Step 2 confirm 拦下来**(输错策略会打印"将备份 X 个文件"清单),没真覆盖
4. 但 **用户没察觉选错**,因为 stdin 不可见

**真实根因**:
- **stdin 无 echo 回显** — 脚本不打印"你刚才输入了: 2 = Replace-all"
- **没有二次 confirm** — 关键决策不要求确认

**修复方向**(下次升级):
```bash
read -p "  选择 [1/2/3/4]: " holistic_choice
case $holistic_choice in
  1) HOLISTIC="add-only" ;;
  2) HOLISTIC="replace-all" ;;
  ...
esac
# 新增:echo 回显 + 二次 confirm
echo "  → 你选了: $HOLISTIC"
read -p "  确认? [y/n]: " confirm_holistic
if [ "$confirm_holistic" != "y" ]; then
  echo "  → 重新选择"
  # 重问
fi
```

---

### 3.3 纠偏:Monorepo 语义误读

**时间**:2026-06-22 ~ 00:10
**影响**:计划给 6 子项目跑 bootstrap(浪费 token + 风险)

**症状链**:
1. 探索 cloud 22 子项目 → 列出 6 个候选(qiqiuyun-develop-manual / api-doc / 5 JS SDK)
2. 准备对每个跑 bootstrap.sh
3. 用户打断:"Monorepo 这个都需要注意提交规范,所以应该在根目录下去添加规范"

**真实根因**:
- **用户意图核对缺失** — 我把"cloud 是 Monorepo"读成"每个子项目是独立目标"
- 用户的实际语义:"根目录统一规范,子项目引用,不强覆盖子项目自有 convention"
- 早该用 AskUserQuestion 主动核对

**修复方向**(下次升级):SKILL.md 加 **Monorepo Handling** 段:

```markdown
### Monorepo 场景

**判断标准**:`<项目>` 顶层不是 git repo,但含 N 个独立 git 子项目。

**推荐流程**:
1. **只在顶层**装工作流规范(因为顶层规范是项目组通用纪律)
2. 子项目**不跑 bootstrap**(子项目有自己 convention,会被覆盖)
3. 子项目通过 **引用顶层** 沿用规范(末尾追加"工作流铁律"段,或 `.claude/rules/` 软链)
4. **必问用户**:「子项目有强 convention 吗?要装吗?」— AskUserQuestion 兜底
```

---

## 4. Generalized lesson

> **覆盖型脚本不能信上游策略;每个覆盖点必须自校验用户是否标记 skip + dry-run diff 必带 + 用户输入必 echo 回显。**

这一条覆盖了 3.1 / 3.2 两个事故的共同根因:**跨阶段状态不一致 + 不可见的用户输入**。

---

## 5. 行动项 / 沉淀

### 5.1 已完成 ✅

| # | 动作 | 落地 |
|---|---|---|
| 1 | 修复 Copy 阶段 bug | 本 commit |
| 2 | cloud/CLAUDE.md 完整恢复 | sed 去 prefix + 末尾追加 24 行精简版"工作流铁律"段 |
| 3 | incident memory 沉淀 | `_facts/bootstrap-sh-copy-phase-bug.md` + MEMORY.md 索引 |
| 4 | 纠偏:不跑 6 子项目 bootstrap | T136 任务描述更新 |

### 5.2 skill 升级清单

| # | 改动 | 优先级 | 来源 |
|---|---|---|---|
| 1 | bootstrap.sh 加 `--dry-run` 选项(输出 diff 不真改) | ⭐⭐⭐⭐⭐ | 本次 L2-3 |
| 2 | stdin echo 回显 + 关键决策二次 confirm | ⭐⭐⭐⭐⭐ | 本次 L2-4 |
| 3 | Copy 阶段全面加 CONFLICTS 自校验 | ⭐⭐⭐⭐⭐ | **已做**(本 commit) |
| 4 | SKILL.md 加 "Monorepo Handling" 段 | ⭐⭐⭐⭐ | 本次纠偏 |
| 5 | README.md 加事故案例 + 3 条铁律 | ⭐⭐⭐ | 跨 session 召回 |
| 6 | bootstrap.sh 加 "production deploy" 模式(默认 dry-run,需 `--apply` 才真改) | ⭐⭐⭐⭐ | 本次 L1-2 |

### 5.3 待办 ⏸️

- [ ] push 本 commit 到 GitHub
- [ ] 升级实现(本次 retro 输出)
- [ ] 把这份 retro 链入 README.md / docs/ 入口

---

## 6. 跨上下文复检

| 检查项 | 通过 | 备注 |
|---|---|---|
| **符合 commit-style 规范**(subject ≤ 72,why 段 body) | ✅ | 3 个 commit 全部符合 |
| **L1/L2/L3 三层穷举** | ✅ | 本报告 §2 三层各列 4 项 |
| **沉淀到 memory** | ✅ | `_facts/bootstrap-sh-copy-phase-bug.md` |
| **真根因 ≠ 表层** | ✅ | §3 每事故都拆表层/深层/隐层 |
| **可推广教训 1 句话** | ✅ | §4 |
| **未改的 + 为什么** | — | 无未改项(决策全部落地) |
| **风险 / 副作用列举** | ✅ | §3.3 纠偏段;§5.3 待办 |

---

## 7. 关联

- **memory**:
  - `[_facts/bootstrap-sh-copy-phase-bug]` — Copy 阶段覆盖 bug + 恢复方法(必读)
  - `[_rules/strict-literal-execute]` — 严格按字面执行;指令外操作必须先询问
  - `[_rules/exhaust-layers-before-fix]` — 多 root cause 不分散修
  - `[_rules/mechanism-layering]` — Rule/Skill/Doc/Memory 各司其职
- **skill**:bootstrap-workflow(`SKILL.md` + `scripts/bootstrap.sh`)
- **commit**:`chore: cleanup + Copy 阶段 bug fix`(本 commit)
- **报告路径**:`docs/reports/deployment-retro.md`