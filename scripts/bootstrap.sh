#!/bin/bash
# bootstrap.sh — 一键复制 jason 工作流到目标项目
# 借鉴 superpowers/using-git-worktrees "Step 0 detect" 范式
# 借鉴 finishing-a-development-branch 4 编号选项 + typed "proceed" 兜底
# 引入显式 .bak.<timestamp> 备份(superskills 缺口,本 skill 兜底)
# v8.1 TDD RED 后强化:Step 1a 业务文件探测 + Step 1c 差异表 + 8 项反模式防御

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:?Usage: bootstrap.sh <target-project-path>}"
BUSINESS_DOMAINS="${BUSINESS_DOMAINS:-meta}"

if [ ! -d "$TARGET" ]; then
  echo "❌ 目标目录不存在: $TARGET"
  exit 1
fi

echo "=== Bootstrap Workflow v8.1 ==="
echo "Skill 源: $SKILL_DIR"
echo "目标项目: $TARGET"
echo "业务域: $BUSINESS_DOMAINS"
echo ""

# Step 1a: 业务文件探测(NEW — 防 F1/F2)
echo "--- Step 1a: 业务文件探测(框架/linter/CI,本 skill 不装这些) ---"
BUSINESS_FILES_FOUND=0
for pattern in package.json .eslintrc .eslintrc.js .eslintrc.json .prettierrc .prettierrc.json vite.config.ts vite.config.js next.config.js next.config.ts tsconfig.json .github; do
  if [ -e "$TARGET/$pattern" ]; then
    echo "  ℹ️  已有业务文件: $pattern"
    BUSINESS_FILES_FOUND=$((BUSINESS_FILES_FOUND + 1))
  fi
done

if [ $BUSINESS_FILES_FOUND -gt 0 ]; then
  echo ""
  echo "⚠️  目标项目已有 $BUSINESS_FILES_FOUND 个业务文件(框架/linter/CI)。"
  echo "本 skill 只装工作流模板(CLAUDE.md + .claude/),不动这些文件。"
  read -p "Type 'proceed' to continue (not y/n): " business_continue
  if [ "$business_continue" != "proceed" ]; then
    echo "❌ 取消(未输入 'proceed')"
    exit 1
  fi
fi

# 空目录引导(防 REFACTOR F-3)
if [ $BUSINESS_FILES_FOUND -eq 0 ] && [ ! -e "$TARGET/package.json" ] && [ ! -e "$TARGET/Cargo.toml" ] && [ ! -e "$TARGET/go.mod" ] && [ ! -e "$TARGET/pyproject.toml" ]; then
  echo ""
  echo "💡 目标目录为空,提示:"
  echo "  本 skill 只装工作流模板,不动项目脚手架。"
  echo "  推荐流程: 1) 先用项目脚手架(vite create / next create / cargo new / go mod init)"
  echo "          2) 再跑本 skill 装工作流配置"
  echo "  继续? (输入 'proceed' 装工作流,或 Ctrl+C 退出先跑脚手架)"
fi

# Step 1b: 工作流配置探测 + Holistic 策略
echo ""
echo "--- Step 1b: 工作流配置探测 ---"
CONFLICTS=()
for f in CLAUDE.md .claude/rules/decision-method.mdc .claude/rules/commit-style.mdc .claude/rules/comment-style.mdc .claude/rules/task-directory.mdc .claude/skills/retrospective; do
  if [ -e "$TARGET/$f" ]; then
    CONFLICTS+=("$f")
    echo "  ⚠️  已存在: $f"
  fi
done

# Holistic 4 策略(整体一次性决策,避免逐文件问)
HOLISTIC=""
if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo ""
  echo "发现 ${#CONFLICTS[@]} 个冲突文件。整体覆盖策略:"
  echo "  1 = Add-only(默认)— 已有不碰不备份,只装缺"
  echo "  2 = Replace-all — 已有 .bak 备份后全部覆盖"
  echo "  3 = Skip-existing+backup — 已有 .bak 备份但保留,只装缺"
  echo "  4 = Per-file — 逐文件问 merge/replace/skip/abort"
  echo "  ⚠️  必须输入 1/2/3/4 之一"
  while true; do
    read -p "  选择 [1/2/3/4]: " holistic_choice
    case $holistic_choice in
      1) HOLISTIC="add-only"; break ;;
      2) HOLISTIC="replace-all"; break ;;
      3) HOLISTIC="skip-existing-backup"; break ;;
      4) HOLISTIC="per-file"; break ;;
      *) echo "    ⚠️  请输入 1/2/3/4 之一" ;;
    esac
  done
  echo "  → Holistic: $HOLISTIC"
fi

# 应用 Holistic(非 per-file 时直接批量处理)
case "$HOLISTIC" in
  add-only)
    echo "  📌 Add-only:已有 ${#CONFLICTS[@]} 个冲突全部跳过(不备份)"
    CONFLICTS=()
    ;;
  replace-all)
    echo "  📌 Replace-all:已有 ${#CONFLICTS[@]} 个冲突全部 .bak 后覆盖"
    # 保留 conflicts 列表,Step 3 备份+覆盖
    ;;
  skip-existing-backup)
    echo "  📌 Skip-existing+backup:已有 ${#CONFLICTS[@]} 个冲突 .bak 后保留,只装缺"
    # 先备份,但后续 Step 3 不覆盖
    for f in "${CONFLICTS[@]}"; do
      if [ -e "$TARGET/$f" ]; then
        mkdir -p "$TARGET/.claude/_backups/pending/$(dirname "$f")" 2>/dev/null
        cp -r "$TARGET/$f" "$TARGET/.claude/_backups/pending/$f" 2>/dev/null
      fi
    done
    CONFLICTS=()
    ;;
esac

# 只在 Per-file 时才逐文件问
if [ "$HOLISTIC" = "per-file" ] && [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo ""
  echo "--- Per-file:逐个问 ---"
  echo "  1 = merge(智能合并,已有文件跳过)"
  echo "  2 = replace with backup(.bak.<timestamp> 备份后覆盖)"
  echo "  3 = skip(跳过此文件)"
  echo "  4 = abort(终止整个 bootstrap)"
  echo "  ⚠️  必须输入 1/2/3/4 之一"
  for f in "${CONFLICTS[@]}"; do
    while true; do
      read -p "  $f: [1/2/3/4] " choice
      case $choice in
        1) echo "    → merge"; break ;;
        2) echo "    → replace with backup"; break ;;
        3) echo "    → skip"; CONFLICTS=("${CONFLICTS[@]/$f}"); break ;;
        4) echo "    → abort"; exit 1 ;;
        *) echo "    ⚠️  请输入 1/2/3/4 之一" ;;
      esac
    done
  done
fi

# 强 convention 跳整 — 全部 skip 提示
if [ ${#CONFLICTS[@]} -eq 0 ] && [ -e "$TARGET/CLAUDE.md" ]; then
  echo "💡 目标项目 CLAUDE.md 已存在但无其他冲突(可能你已选全部 skip)"
  echo "  强 convention 项目,本 skill 可只装缺的部分或全部跳过"
  echo "  当前状态: 静默通过,如有需求请手动调整"
fi

# Step 1c: 差异表(NEW — 防 F4/F7)
echo ""
echo "--- Step 1c: 差异表(完整文件清单,不全不能 proceed) ---"
echo "📋 将要创建的文件:"
FILES_TO_COPY=(
  "CLAUDE.md"
  ".claude/rules/decision-method.mdc"
  ".claude/rules/commit-style.mdc"
  ".claude/rules/comment-style.mdc"
  ".claude/rules/task-directory.mdc"
  ".claude/memory/mechanism-layering.md"
  ".claude/memory/root-goal-three-layer.md"
  ".claude/memory/parallel-subagent-research.md"
  ".claude/memory/completion-protocol.md"
  ".claude/skills/retrospective/SKILL.md"
)
for f in "${FILES_TO_COPY[@]}"; do
  if [ -e "$TARGET/$f" ]; then
    echo "  [overwrite] $f"
  else
    echo "  [new]      $f"
  fi
done
echo ""
echo "📋 显式不装(避免越界):"
echo "  - package.json / vite.config / next.config / tsconfig.json(用 Vite/Next 自带脚手架)"
echo "  - .eslintrc / .prettierrc / husky / lint-staged(用户自己配)"
echo "  - .github/workflows(CI 用户自己配)"
echo "  - README.md(用户自己写)"
echo "  - 业务代码 / src/ / 测试样例"

# Step 2: Confirm
echo ""
read -p "Type 'proceed' to continue (not y/n): " confirm
if [ "$confirm" != "proceed" ]; then
  echo "❌ 取消(未输入 'proceed')"
  exit 1
fi

# Step 3: Execute + backup
echo ""
echo "--- Step 3: Execute ---"
BACKUP_DIR="$TARGET/.claude/_backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
MANIFEST="$BACKUP_DIR/MANIFEST.md"
echo "# Backup Manifest" > "$MANIFEST"
echo "Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$MANIFEST"
echo "" >> "$MANIFEST"

# Backup files marked for replace
for f in "${CONFLICTS[@]}"; do
  if [ -e "$TARGET/$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp -r "$TARGET/$f" "$BACKUP_DIR/$f"
    SHA=$(shasum -a 256 "$TARGET/$f" | awk '{print $1}')
    echo "$f $SHA" >> "$MANIFEST"
    echo "  📦 备份: $f"
  fi
done

# Copy files
mkdir -p "$TARGET/.claude/rules" "$TARGET/.claude/memory" "$TARGET/.claude/skills/retrospective"

# CLAUDE.md
sed "s|{{BUSINESS_DOMAINS}}|$BUSINESS_DOMAINS|g" \
  "$SKILL_DIR/assets/CLAUDE.md.template" > "$TARGET/CLAUDE.md"
echo "  ✓ CLAUDE.md"

# Rules
for rule in decision-method commit-style comment-style task-directory; do
  if [ -f "$SKILL_DIR/assets/rules/$rule.mdc" ]; then
    sed "s|{{BUSINESS_DOMAINS}}|$BUSINESS_DOMAINS|g" \
      "$SKILL_DIR/assets/rules/$rule.mdc" > "$TARGET/.claude/rules/$rule.mdc"
    echo "  ✓ .claude/rules/$rule.mdc"
  fi
done

# Memory
for mem in mechanism-layering root-goal-three-layer parallel-subagent-research completion-protocol; do
  if [ -f "$SKILL_DIR/assets/memory/$mem.md" ]; then
    cp "$SKILL_DIR/assets/memory/$mem.md" "$TARGET/.claude/memory/$mem.md"
    echo "  ✓ .claude/memory/$mem.md"
  fi
done

# Retrospective skill
cp "$SKILL_DIR/assets/skills/retrospective/SKILL.md" "$TARGET/.claude/skills/retrospective/SKILL.md"
echo "  ✓ .claude/skills/retrospective/SKILL.md"

# Step 4: Verify
echo ""
echo "--- Step 4: Verify ---"
ERRORS=0
# 校验 9 文件齐(CLAUDE.md + 4 rules + 4 memory + 1 skill)— 防 REFACTOR F-4
for f in CLAUDE.md \
         .claude/rules/decision-method.mdc \
         .claude/rules/commit-style.mdc \
         .claude/rules/comment-style.mdc \
         .claude/rules/task-directory.mdc \
         .claude/memory/mechanism-layering.md \
         .claude/memory/root-goal-three-layer.md \
         .claude/memory/parallel-subagent-research.md \
         .claude/memory/completion-protocol.md \
         .claude/skills/retrospective/SKILL.md; do
  if [ ! -e "$TARGET/$f" ]; then
    echo "  ❌ 缺失: $f"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check for unreplaced placeholders(只匹配 {{NAME}} 形式,大写字母+下划线,排除描述性文字)
if grep -rEn "\{\{[A-Z_]+\}\}" "$TARGET/CLAUDE.md" "$TARGET/.claude/" 2>/dev/null; then
  echo "  ❌ 占位符残留"
  ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "❌ 验证失败:$ERRORS 个错误"
  exit 1
fi

echo ""
echo "✅ Bootstrap 完成!"
echo "  备份位置: $BACKUP_DIR"
echo "  业务域: $BUSINESS_DOMAINS"
echo "  下一步: 编辑 CLAUDE.md 填入项目名 / 技术栈 / Quick Start"
echo "  ⚠️  提醒: 本 skill 不装 package.json / ESLint / 业务代码,用 vite/next 自带脚手架"

# Step 5: Commit 策略(3 选项:Superpowers / per-domain / all-in-one)+ 项目级记忆
echo ""
echo "--- Step 5: Commit 策略 ---"
PROJECT_CFG="$TARGET/.bootstrap-workflow.json"
COMMIT_GRANULARITY=""
if [ -f "$PROJECT_CFG" ]; then
  SAVED=$(grep -oP '"commit_granularity":\s*"\K[^"]+' "$PROJECT_CFG" 2>/dev/null)
  if [ -n "$SAVED" ]; then
    echo "  💡 项目配置: commit_granularity = $SAVED(来自 .bootstrap-workflow.json)"
    while true; do
      read -p "  用项目配置 / 改? [y/n/1/2/3]: " use_saved
      case $use_saved in
        y|Y) COMMIT_GRANULARITY="$SAVED"; break ;;
        n|N) echo "  → 跳过 commit(变更在 working tree)"; exit 0 ;;
        1) COMMIT_GRANULARITY="superpowers"; break ;;
        2) COMMIT_GRANULARITY="per-domain"; break ;;
        3) COMMIT_GRANULARITY="all-in-one"; break ;;
        *) echo "    ⚠️  请输入 y/n/1/2/3" ;;
      esac
    done
  fi
fi

if [ -z "$COMMIT_GRANULARITY" ]; then
  echo "  提交粒度:"
  echo "    1 = Superpowers(每个新文件 1 commit)— 9 commit"
  echo "    2 = per-domain(按业务域分组)— 3 commit"
  echo "    3 = all-in-one — 1 commit"
  while true; do
    read -p "  选择 [1/2/3]: " commit_choice
    case $commit_choice in
      1) COMMIT_GRANULARITY="superpowers"; break ;;
      2) COMMIT_GRANULARITY="per-domain"; break ;;
      3) COMMIT_GRANULARITY="all-in-one"; break ;;
      *) echo "    ⚠️  请输入 1/2/3 之一" ;;
    esac
  done
fi

echo "  → Commit 粒度: $COMMIT_GRANULARITY"

# 写到项目级 config
cat > "$PROJECT_CFG" <<CFGEOF
{
  "commit_granularity": "$COMMIT_GRANULARITY",
  "holistic_strategy": "$HOLISTIC",
  "saved_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
CFGEOF
echo "  📝 配置已写到 $PROJECT_CFG(项目级,gitignored 类似 settings.local.json)"

# 实际 commit(只对 git 仓库)
if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  case "$COMMIT_GRANULARITY" in
    superpowers)
      for f in "${FILES_TO_COPY[@]}"; do
        if [ -e "$TARGET/$f" ]; then
          git -C "$TARGET" add "$f" 2>/dev/null && \
            git -C "$TARGET" commit -m "chore(bootstrap): add $f" 2>/dev/null && \
            echo "  ✓ commit: $f"
        fi
      done
      ;;
    per-domain)
      # 规则组(.claude/rules/*)
      if [ -d "$TARGET/.claude/rules" ]; then
        git -C "$TARGET" add .claude/rules/ 2>/dev/null && \
          git -C "$TARGET" commit -m "chore(bootstrap): apply workflow rules

- decision-method: 三层决策法
- commit-style: commit 风格 + 粒度建议
- comment-style: 注释原则
- task-directory: 任务正式档模板" 2>/dev/null && \
          echo "  ✓ commit: rules"
      fi
      # memory 组
      if [ -d "$TARGET/.claude/memory" ]; then
        git -C "$TARGET" add .claude/memory/ 2>/dev/null && \
          git -C "$TARGET" commit -m "chore(bootstrap): apply workflow memory

- mechanism-layering
- root-goal-three-layer
- parallel-subagent-research
- completion-protocol" 2>/dev/null && \
          echo "  ✓ commit: memory"
      fi
      # skills + CLAUDE.md
      if [ -d "$TARGET/.claude/skills" ]; then
        git -C "$TARGET" add .claude/skills/ 2>/dev/null
      fi
      git -C "$TARGET" add CLAUDE.md 2>/dev/null && \
        git -C "$TARGET" commit -m "chore(bootstrap): apply CLAUDE.md + retrospective skill" 2>/dev/null && \
        echo "  ✓ commit: CLAUDE.md + skills"
      ;;
    all-in-one)
      git -C "$TARGET" add CLAUDE.md .claude/ 2>/dev/null && \
        git -C "$TARGET" commit -m "chore(bootstrap): apply jason workflow templates

通用工作流:三层决策 / commit 风格 / 注释原则 / 任务档 / 复盘 / 根本目标视角" 2>/dev/null && \
        echo "  ✓ commit: all-in-one"
      ;;
  esac
else
  echo "  💡 目标目录不是 git repo,跳过 commit(变更在 working tree)"
fi
