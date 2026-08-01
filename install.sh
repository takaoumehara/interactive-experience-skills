#!/usr/bin/env bash
# _extracted/ を正本として、スキルとコマンドを ~/.claude へ配置し、配布用 .skill を再パッケージする。
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(embodied-product-director interactive-experience-collective movement-learning-system-designer)

# --- 事前検証 -----------------------------------------------------------------
# SKILL.md が名指しするリファレンス／アセットが実在するかを確認する。
# 参照先が欠けたまま配置すると、スキルは実行時に「必読」ファイルを開けず、
# 一般論を書き始める。壊れた状態で入れるより、ここで止める方がよい。
fail=0
for d in "${SKILLS[@]}"; do
  skill="$SRC/_extracted/$d/SKILL.md"
  [ -f "$skill" ] || { echo "欠落: _extracted/$d/SKILL.md"; fail=1; continue; }

  while IFS= read -r ref; do
    [ -f "$SRC/_extracted/$d/$ref" ] || { echo "参照切れ: $d/SKILL.md → $ref"; fail=1; }
  done < <(grep -oE '(references|assets)/[A-Za-z0-9._-]+\.md' "$skill" | sort -u)

  # frontmatter の name とディレクトリ名の一致（Agent Skills 標準の必須要件）
  nm="$(sed -n 's/^name:[[:space:]]*//p' "$skill" | head -1)"
  [ "$nm" = "$d" ] || { echo "name不一致: $d/SKILL.md の name='$nm'"; fail=1; }
done
[ "$fail" -eq 0 ] || { echo "事前検証に失敗。配置を中止する。"; exit 1; }

# --- 配置とパッケージ ---------------------------------------------------------
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"

for d in "${SKILLS[@]}"; do
  rm -rf "$HOME/.claude/skills/$d"
  cp -R "$SRC/_extracted/$d" "$HOME/.claude/skills/$d"
  rm -f "$SRC/$d.skill"
  ( cd "$SRC/_extracted" && zip -q -r -X "$SRC/$d.skill" "$d" -x '.*' -x '__MACOSX/*' )
  echo "配置: $d"
done

for c in motion-idea refresh-skills scout-skills; do
  cp "$SRC/$c.md" "$HOME/.claude/commands/$c.md"
  echo "配置: /$c"
done
echo "完了。新しいセッションから有効になる。"
