# wigtn Plugins for Claude Code

Claude Code를 위한 개발 워크플로우 플러그인 모음입니다.

## 플러그인 목록

| 플러그인 | 설명 |
|---------|------|
| **auto-commit** | 변경사항 분석 후 자동 커밋 메시지 생성 |
| **prd** | 모호한 기능 요청을 구조화된 PRD 문서로 변환 |
| **implement** | PRD 기반 기능 즉시 구현 |

## 설치 방법

### 방법 1: 마켓플레이스 (권장)

```bash
# Claude Code에 마켓플레이스 추가
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# 원하는 플러그인 설치
/plugin install auto-commit
/plugin install prd
/plugin install implement
```

### 방법 2: CLI 설치

```bash
# 스코프 지정 설치
claude plugin install auto-commit@wigtn-plugins --scope user      # 글로벌 (기본값)
claude plugin install auto-commit@wigtn-plugins --scope project   # 팀과 공유
claude plugin install auto-commit@wigtn-plugins --scope local     # 로컬 전용 (gitignored)
```

### 방법 3: 수동 설치 (심볼릭 링크)

```bash
# 1. 글로벌 위치에 클론
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn

# 2. Claude skills 폴더에 심볼릭 링크 생성
mkdir -p ~/.claude/skills
ln -s ~/.claude-plugins/wigtn/plugins/auto-commit/skills/auto-commit ~/.claude/skills/
ln -s ~/.claude-plugins/wigtn/plugins/prd/skills/prd ~/.claude/skills/
ln -s ~/.claude-plugins/wigtn/plugins/implement/skills/implement ~/.claude/skills/

# 업데이트
git -C ~/.claude-plugins/wigtn pull
```

## 사용법

### auto-commit

```bash
/auto-commit                      # 자동 커밋 메시지 생성 + 푸시
/auto-commit --no-push            # 커밋만, 푸시 안함
/auto-commit --message "메시지"   # 수동 커밋 메시지
```

### prd

```bash
/prd 사용자-인증                   # 기능에 대한 PRD 생성
/prd 플러그인-마켓플레이스 --detail=full
```

### implement

```bash
/implement 사용자-인증             # 기능명으로 구현
/implement FR-006                  # 요구사항 ID로 구현
```

## 설치 스코프

| 스코프 | 설정 파일 | 용도 |
|--------|----------|------|
| `user` | `~/.claude/settings.json` | 모든 프로젝트에서 사용 (기본값) |
| `project` | `.claude/settings.json` | 팀과 공유 (git 포함) |
| `local` | `.claude/settings.local.json` | 로컬 전용 (gitignored) |

## 플러그인 구조

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/
│   ├── plugin.json              # 마켓플레이스 메타데이터
│   └── marketplace.json         # 플러그인 목록
└── plugins/
    └── <플러그인명>/
        ├── .claude-plugin/
        │   └── plugin.json      # 플러그인 메타데이터
        ├── skills/
        │   └── <스킬명>/
        │       └── SKILL.md     # 스킬 정의
        └── README.md
```

## 기여하기

1. 저장소 포크
2. 기능 브랜치 생성 (`git checkout -b feature/amazing-plugin`)
3. 변경사항 커밋 (`git commit -m 'feat: 멋진 플러그인 추가'`)
4. 브랜치에 푸시 (`git push origin feature/amazing-plugin`)
5. Pull Request 생성

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE)를 참조하세요.
