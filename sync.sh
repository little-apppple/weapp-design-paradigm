#!/usr/bin/env bash
# 把 WorkBuddy 技能目录的内容同步到本仓库，保留仓库自身的 README 与 git 元数据。
# 用法：./sync.sh [源目录]
set -euo pipefail

SRC="${1:-D:/data/.workbuddy/skills/weapp-design-paradigm}"
DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SRC/SKILL.md" ]; then
  echo "源头缺少 SKILL.md: $SRC" >&2
  exit 1
fi

cp "$SRC/SKILL.md" "$DEST/SKILL.md"
rm -rf "$DEST/references"
cp -r "$SRC/references" "$DEST/references"

echo "同步完成，来源: $SRC"
grep -m1 '^version:' "$DEST/SKILL.md"
echo "待提交变更:"
git -C "$DEST" status --short
