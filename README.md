# skills

Claude Code와 Codex에서 쓰는 개인 스킬 모음.

| 디렉터리 | 설치 위치 | 스킬 |
|---|---|---|
| `claude/` | `${CLAUDE_CONFIG_DIR:-~/.claude}/skills` | `reviewing-with-codex`: Codex에게 리뷰받고 고치기 |
| `codex/` | `${CODEX_HOME:-~/.codex}/skills` | `reviewing-with-claude`: Claude에게 리뷰받고 고치기 |
| `shared/` | 각 스킬 디렉터리에 심볼릭 링크로 들어감 | 리뷰 루프 규칙(`loop.md`), 리뷰어 프롬프트, 실행 스크립트 |

## 설치

```sh
./install.sh
```

스킬 디렉터리를 심볼릭 링크로 걸기 때문에, 저장소를 고치면 바로 반영된다. 설정 디렉터리를 바꿔 쓰는 환경이면 `CLAUDE_CONFIG_DIR`, `CODEX_HOME`을 지정해서 실행한다.

## 리뷰어 명령

`run-review.sh`는 기본으로 `codex`, `claude`를 실행한다. 프로필이나 별도 설정 디렉터리가 필요하면 `CODEX_CMD`, `CLAUDE_CMD`로 덮어쓴다. 셸 프로필에서 export하거나 에이전트 지침(CLAUDE.md, AGENTS.md)에 적어 두면 된다.

```sh
export CODEX_CMD='CODEX_HOME=~/.codex-alt command codex --profile work'
```
