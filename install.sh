#!/bin/bash
# HK Cinema Style 一键安装
# 用法: curl -fsSL https://raw.githubusercontent.com/senlib/hk-cinema-style/main/install.sh | bash
#   或: ./install.sh [目标技能目录]
set -e

REPO_ZIP="https://github.com/senlib/hk-cinema-style/archive/refs/heads/main.zip"
NAME="hk-cinema-style"

echo "🎬 安装 HK Cinema Style（港片导演视觉风格参考技能）"

# 1. 确定目标目录：参数 > 自动探测已有 Agent 技能目录 > 兜底
if [ -n "${1:-}" ]; then
  DEST="$1"
elif [ -d "$HOME/.hermes/skills" ]; then
  DEST="$HOME/.hermes/skills"
elif [ -d "$HOME/.claude/skills" ]; then
  DEST="$HOME/.claude/skills"
elif [ -d "$HOME/.codex/skills" ]; then
  DEST="$HOME/.codex/skills"
else
  DEST="$HOME/.agents/skills"
fi
mkdir -p "$DEST"
TARGET="$DEST/$NAME"

# 2. 获取源码：本地仓库运行则直接复制；否则下载 zip
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if [ -f "$(dirname "$0")/SKILL.md" ]; then
  SRC="$(cd "$(dirname "$0")" && pwd)"
  echo "📦 从本地仓库安装: $SRC"
  mkdir -p "$TARGET"
  cp "$SRC/SKILL.md" "$SRC/README.md" "$SRC/AGENTS.md" "$SRC/LICENSE" "$TARGET/"
  mkdir -p "$TARGET/references"
  cp "$SRC/references/hk-director-styles.md" "$TARGET/references/"
else
  echo "⬇️  下载仓库 zip（无需 git）..."
  curl -fsSL "$REPO_ZIP" -o "$TMP/repo.zip"
  unzip -q "$TMP/repo.zip" -d "$TMP"
  mkdir -p "$TARGET"
  cp "$TMP/$NAME-main/SKILL.md" "$TMP/$NAME-main/README.md" "$TMP/$NAME-main/AGENTS.md" "$TMP/$NAME-main/LICENSE" "$TARGET/"
  mkdir -p "$TARGET/references"
  cp "$TMP/$NAME-main/references/hk-director-styles.md" "$TARGET/references/"
fi

# 3. 校验
for f in SKILL.md references/hk-director-styles.md; do
  [ -f "$TARGET/$f" ] || { echo "❌ 缺少 $TARGET/$f"; exit 1; }
done

echo ""
echo "✅ 已安装到: $TARGET"
echo ""
echo "━━━ 把下面这段贴给你的 Agent 即完成接入 ━━━"
cat <<'EOF'
你现在接入「HK Cinema Style」技能（路径见上方安装目录）。
规则：
1. 任何港风/导演风格的图片或视频任务，先读 SKILL.md 全文和 references/hk-director-styles.md 里目标导演的语法块，再动手；禁止凭印象写提示词。
2. 你只做视觉风格：题材/构图/文案/叙事归我，不扩写不改编。
3. 五种模式：A 文生图 / B 改图 / C 局部精修 / D 系列批量 / E 视频，按 SKILL.md 对应流程走。
4. 系列出图只用冻结语法，同导演同系列同一套；按画面内容选景别语法造句，禁止雷同清单。
5. 改图必须先建保护清单（逐字文字/主体/构图），产出逐字核对；视频必须带运动语法行。
6. 风格要克制：暗部不死黑、偏色轻微、细节活着；风格色只落在光与氛围上。
生成引擎用我环境里已有的（如 Seedream/Seedance/gpt-image/ComfyUI 任一）。
EOF
