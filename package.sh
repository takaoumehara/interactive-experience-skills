#!/usr/bin/env bash
# 配布用の ZIP を dist/ に作る。_extracted/ が正本。
#   dist/<skill>.zip                          claude.ai などへ1本ずつアップロードする用
#   dist/interactive-experience-skills-all.zip 3スキル + コマンド + README 一式
# install.sh とは独立。~/.claude/ には何も書き込まない。
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(embodied-product-director interactive-experience-collective movement-learning-system-designer)
NAME="interactive-experience-skills"

fail=0
for d in "${SKILLS[@]}"; do
  skill="$SRC/_extracted/$d/SKILL.md"
  [ -f "$skill" ] || { echo "欠落: _extracted/$d/SKILL.md"; fail=1; continue; }

# frontmatter の description 長（claude.ai の上限 1024 文字）
  python3 - "$skill" <<'PYEOF' || fail=1
import re,sys
s=open(sys.argv[1],encoding='utf-8').read()
m=re.search(r'^description:[ ]*(.*?)(?=\n[a-z_]+:)', s, re.S|re.M)
if not m:
    print(f"description が無い: {sys.argv[1]}"); sys.exit(1)
n=len(m.group(1).strip())
if n>1024:
    print(f"description が長すぎる: {sys.argv[1]} は {n} 文字（上限 1024、{n-1024} 超過）")
    print("  claude.ai へのアップロードが拒否される。トリガーを削って詰めること。")
    sys.exit(1)
PYEOF
done
[ "$fail" -eq 0 ] || { echo "事前検証に失敗。パッケージを中止する。"; exit 1; }

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
cp "$SRC"/motion-idea.md "$SRC"/refresh-skills.md "$SRC"/scout-skills.md "$SRC"/skills-routine.md "$SRC"/CANDIDATES.md "$SRC"/ROUTINE.md "$SRC"/install.sh "$SRC"/LICENSE "$SRC"/README*.md "$STAGE/"
find "$STAGE" -name '.DS_Store' -delete
( cd "$(dirname "$STAGE")" && zip -q -r -X "$SRC/dist/$NAME-all.zip" "$NAME" -x '.*' -x '__MACOSX/*' )
rm -rf "$(dirname "$STAGE")"
echo "作成: dist/$NAME-all.zip"

for f in "$SRC"/dist/*.zip; do
  unzip -t "$f" >/dev/null 2>&1 || { echo "破損: $f"; exit 1; }
done
echo "全ZIPの破損チェック: OK"
