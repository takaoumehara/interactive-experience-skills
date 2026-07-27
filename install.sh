#!/usr/bin/env bash
# _extracted/ を正本として、スキルとコマンドを ~/.claude へ配置し、配布用 .skill を再パッケージする。
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(embodied-product-director interactive-experience-collective movement-learning-system-designer)

for d in "${SKILLS[@]}"; do
  [ -f "$SRC/_extracted/$d/SKILL.md" ] || { echo "欠落: _extracted/$d/SKILL.md"; exit 1; }
done

mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"

for d in "${SKILLS[@]}"; do
  rm -rf "$HOME/.claude/skills/$d"
  cp -R "$SRC/_extracted/$d" "$HOME/.claude/skills/$d"
  rm -f "$SRC/$d.skill"
  ( cd "$SRC/_extracted" && zip -q -r -X "$SRC/$d.skill" "$d" -x '.*' -x '__MACOSX/*' )
  echo "配置: $d"
done

cp "$SRC/motion-idea.md" "$HOME/.claude/commands/motion-idea.md"
echo "配置: /motion-idea"
echo "完了。新しいセッションから有効になる。"
