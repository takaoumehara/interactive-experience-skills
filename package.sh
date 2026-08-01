#!/usr/bin/env bash
# 配布用の ZIP を dist/ に作る。_extracted/ が正本。
#   dist/<skill>.zip                          claude.ai などへ1本ずつアップロードする用
#   dist/interactive-experience-skills-all.zip 3スキル + コマンド + README 一式
# install.sh とは独立。~/.claude/ には何も書き込まない。
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(embodied-product-director interactive-experience-collective movement-learning-system-designer)
NAME="interactive-experience-skills"

for d in "${SKILLS[@]}"; do
  [ -f "$SRC/_extracted/$d/SKILL.md" ] || { echo "欠落: _extracted/$d/SKILL.md"; exit 1; }
done

rm -rf "$SRC/dist"; mkdir -p "$SRC/dist"

# ① スキル1本ずつ（SKILL.md はスキル名フォルダ直下に入る）
for d in "${SKILLS[@]}"; do
  ( cd "$SRC/_extracted" && zip -q -r -X "$SRC/dist/$d.zip" "$d" -x '.*' -x '__MACOSX/*' -x '*/.DS_Store' )
  echo "作成: dist/$d.zip"
done

# ② 一式
STAGE="$(mktemp -d)/$NAME"
mkdir -p "$STAGE"
cp -R "$SRC/_extracted" "$STAGE/_extracted"
cp "$SRC"/motion-idea.md "$SRC"/refresh-skills.md "$SRC"/scout-skills.md "$SRC"/CANDIDATES.md "$SRC"/install.sh "$SRC"/LICENSE "$SRC"/README*.md "$STAGE/"
find "$STAGE" -name '.DS_Store' -delete
( cd "$(dirname "$STAGE")" && zip -q -r -X "$SRC/dist/$NAME-all.zip" "$NAME" -x '.*' -x '__MACOSX/*' )
rm -rf "$(dirname "$STAGE")"
echo "作成: dist/$NAME-all.zip"

for f in "$SRC"/dist/*.zip; do
  unzip -t "$f" >/dev/null 2>&1 || { echo "破損: $f"; exit 1; }
done
echo "全ZIPの破損チェック: OK"
