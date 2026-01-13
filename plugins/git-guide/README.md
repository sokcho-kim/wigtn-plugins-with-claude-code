# Git Guide Plugin

팀 Git 워크플로우 스타일을 선택하고, 해당 스타일에 맞게 안내합니다.

## 🎯 역할

Git 명령어는 이미 알고 있습니다.
이 플러그인은 **팀의 워크플로우 스타일에 맞는 프로세스**를 안내합니다.

## 워크플로우 스타일

| 스타일         | 특징                              | 적합한 팀               |
| -------------- | --------------------------------- | ----------------------- |
| 🌊 Git Flow    | develop, feature, release, hotfix | 정기 릴리즈, 대규모 팀  |
| 🚀 GitHub Flow | main + feature, PR 기반           | 수시 배포, 소규모 팀    |
| 🚂 Trunk Based | main only, 짧은 브랜치            | CI/CD 자동화, 시니어 팀 |

## 사용법

```
/git
"브랜치 전략", "워크플로우", "기능 개발 어떻게", "배포 어떻게"
```

## 사용 예시

```
User: /git

Claude:
"팀의 Git 워크플로우를 선택해 주세요:
[1] 🌊 Git Flow
[2] 🚀 GitHub Flow
[3] 🚂 Trunk Based"

User: 2

Claude:
"🚀 GitHub Flow 선택

**장점:** 단순한 구조, 빠른 피드백
**단점:** 버전 관리 어려움

무엇을 도와드릴까요?"

User: 기능 개발 시작

Claude:
"GitHub Flow에서 기능 개발:
1. git checkout main && git pull
2. git checkout -b feature/기능명
3. git push -u origin feature/기능명
4. GitHub에서 PR 생성"
```

## 주요 특징

- **스타일 선택**: 팀에 맞는 워크플로우 선택
- **장단점 설명**: 각 스타일의 장단점 반드시 표시
- **스타일에 맞는 안내**: 선택한 워크플로우 프로세스에 맞게 안내
- **설정 저장**: `.git-workflow` 파일에 선택 저장
