#!/usr/bin/env bash
# install.sh — AI 个人形象管理顾问（Personal Stylist）一键部署
#
# 把仓库里的 preset + 数据目录骨架 部署到目标机器的 ~/.dsh。
#
# 用法:
#   ./install/install.sh                    # 默认：工作目录 /Users/mac/Desktop/个人形象管理
#   ./install/install.sh --workdir /path    # 自定义工作目录
#   ./install/install.sh --preset-only      # 只部署 preset（3080 GUI 用，跳过数据目录骨架）
#
# 部署目标:
#   ~/.dsh/.agent-presets/personal-stylist/  ← preset/（3080 GUI 的"个人形象管理顾问"预设）
#   <workdir>/data/customers/                 ← 顾客档案
#   <workdir>/data/plans/                     ← 搭配方案
#   <workdir>/data/feedback/                  ← 反馈闭环
#   <workdir>/data/garments/                  ← 服装档案（CAO 写）
#
# 注意: 插件里的 WORKSPACE 路径是写死的绝对路径。安装到非默认工作目录时，
#       本脚本会用 sed 替换 preset/plugins 里的 WORKSPACE 常量。

set -euo pipefail

# ── 默认值 ──────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_WORKDIR="/Users/mac/Desktop/个人形象管理"
WORKDIR="${DEFAULT_WORKDIR}"
PRESET_ONLY=0

# ── 参数解析 ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workdir) WORKDIR="$2"; shift 2 ;;
    --preset-only) PRESET_ONLY=1; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,2\}//' | head -20
      exit 0 ;;
    *) echo "⚠️ 未知参数: $1"; exit 1 ;;
  esac
done

DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
PRESET_DST="$DSH_HOME/.agent-presets/personal-stylist"

echo "═══════════════════════════════════════════"
echo " AI 个人形象管理顾问 · 部署"
echo "   仓库:      $REPO_ROOT"
echo "   工作目录:  $WORKDIR"
echo "   preset →   $PRESET_DST"
echo "═══════════════════════════════════════════"

# ── 1. 部署 preset ─────────────────────────────────────────────────────
echo ""
echo "[1/2] 部署 preset → $PRESET_DST"
mkdir -p "$PRESET_DST"
cp -R "$REPO_ROOT/preset"/. "$PRESET_DST"/

if [[ "$WORKDIR" != "$DEFAULT_WORKDIR" ]]; then
  # 用 sed 把插件里写死的 WORKSPACE 默认值替换为新 WORKDIR
  find "$PRESET_DST" -name '*.js' -type f | while read -r f; do
    sed -i.bak -e "s|const WORKSPACE = .*|const WORKSPACE = '$WORKDIR'|g" "$f"
    rm -f "$f.bak"
  done
  echo "   ↳ WORKSPACE 路径已重写为: $WORKDIR"
fi
echo "   ✅ preset 已部署（3080 GUI 新建会话选\"个人形象管理顾问\"）"

# ── 2. 数据目录骨架（非 preset-only）──────────────────────────────────
if [[ $PRESET_ONLY -eq 0 ]]; then
  echo ""
  echo "[2/2] 部署数据目录骨架 → $WORKDIR/data"
  mkdir -p "$WORKDIR"/data/{customers,plans,feedback,garments}
  echo "   ✅ 数据目录骨架已部署（customers/plans/feedback/garments）"
fi

# ── 验证 ───────────────────────────────────────────────────────────────
echo ""
echo "验证…"
VERIFY_OK=1
for f in agent.cordis.yml preset.yml skills/stylist-kb/SKILL.md plugins/stylist-core/index.js; do
  [[ -f "$PRESET_DST/$f" ]] || { echo "   ❌ 缺失: preset/$f"; VERIFY_OK=0; }
done
if node --check "$PRESET_DST/plugins/stylist-core/index.js" 2>/dev/null; then
  echo "   ✅ stylist-core 语法 OK"
else
  echo "   ❌ stylist-core 语法错误"; VERIFY_OK=0
fi

echo ""
if [[ $VERIFY_OK -eq 1 ]]; then
  echo "═══════════════════════════════════════════"
  echo " ✅ 部署完成"
  echo "═══════════════════════════════════════════"
  echo ""
  echo " 下一步:"
  echo "  · 3080 GUI: 新建会话选\"个人形象管理顾问\""
else
  echo " ⚠️ 部署完成但有缺失项，请检查上方 ❌"
fi
