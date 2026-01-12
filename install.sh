#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PLUGIN_DIR="${HOME}/.claude-plugins/wigtn"
REPO_URL="https://github.com/wigtn/wigtn-plugins-with-claude-code.git"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  wigtn Plugins for Claude Code - Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Clone or update
if [ -d "$PLUGIN_DIR" ]; then
    echo -e "${YELLOW}Updating existing installation...${NC}"
    git -C "$PLUGIN_DIR" pull --quiet
else
    echo -e "${GREEN}Installing plugins...${NC}"
    mkdir -p "$(dirname "$PLUGIN_DIR")"
    git clone --quiet "$REPO_URL" "$PLUGIN_DIR"
fi

echo
echo -e "${GREEN}✓ Installation complete!${NC}"
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Available Plugins${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo "  - auto-commit : 변경사항 분석 후 자동 커밋"
echo "  - prd         : PRD 문서 자동 생성"
echo "  - implement   : PRD 기반 즉시 구현"
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Usage${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo "  프로젝트에서 플러그인을 사용하려면:"
echo
echo -e "  ${YELLOW}# 프로젝트 폴더로 이동${NC}"
echo "  cd your-project"
echo
echo -e "  ${YELLOW}# skills 폴더 생성${NC}"
echo "  mkdir -p .claude/skills"
echo
echo -e "  ${YELLOW}# 원하는 플러그인 연결 (심볼릭 링크)${NC}"
echo "  ln -s $PLUGIN_DIR/plugins/auto-commit/skills/auto-commit .claude/skills/"
echo "  ln -s $PLUGIN_DIR/plugins/prd/skills/prd .claude/skills/"
echo "  ln -s $PLUGIN_DIR/plugins/implement/skills/implement .claude/skills/"
echo
echo -e "  ${YELLOW}# 또는 한 번에 모두 연결${NC}"
echo "  for p in auto-commit prd implement; do"
echo "    ln -s $PLUGIN_DIR/plugins/\$p/skills/\$p .claude/skills/"
echo "  done"
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Update${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo "  플러그인 업데이트:"
echo "  git -C $PLUGIN_DIR pull"
echo
echo "  또는 이 스크립트 재실행:"
echo "  curl -fsSL https://raw.githubusercontent.com/wigtn/wigtn-plugins-with-claude-code/main/install.sh | bash"
echo
