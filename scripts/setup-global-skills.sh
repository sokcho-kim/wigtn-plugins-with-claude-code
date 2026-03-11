#!/bin/bash
# 글로벌 Claude Code 스킬 설치 스크립트
# 사용법: bash scripts/setup-global-skills.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_DIR/plugins/wigtn-coding/skills"
SKILLS_DST="$HOME/.claude/skills"

GLOBAL_SKILLS=(
  "git-convention"
  "naming-convention"
)

echo "=== Claude Code 글로벌 스킬 설치 ==="
echo ""

for skill in "${GLOBAL_SKILLS[@]}"; do
  if [ -d "$SKILLS_SRC/$skill" ]; then
    mkdir -p "$SKILLS_DST/$skill"
    cp -r "$SKILLS_SRC/$skill/"* "$SKILLS_DST/$skill/"
    echo "[OK] $skill"
  else
    echo "[SKIP] $skill (소스 없음)"
  fi
done

echo ""
echo "설치 완료: $SKILLS_DST"
echo "새 Claude Code 세션에서 사용 가능합니다."
