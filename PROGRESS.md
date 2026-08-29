# 시스템 학습 진행 상황

## 현재 상태

**상태:** Module 00 시작 준비

**현재 단계:** Phase 0 — OS Mental Model

**현재 모듈:** Module 00 — File descriptor와 system call

## 완료한 모듈

아직 없음.

이전에 실행한 환경 확인과 stdout/stderr 실험은 준비 과정으로만 취급하며 정식 모듈 완료 이력에 포함하지 않습니다.

## 현재 핵심 질문

> Linux는 file, terminal, pipe와 socket처럼 다른 대상을 왜 정수형 file descriptor로 다룰 수 있는가?

## 다음 대화의 흐름

1. program, process, user space와 kernel의 관계를 개념적으로 설명합니다.
2. process별 file descriptor table이라는 mental model을 함께 구성합니다.
3. fd가 file 자체인지, process 내부의 참조 번호인지 사례로 추론합니다.
4. 이해를 확인할 가치가 있을 때만 짧은 Python process를 실행합니다.
5. 같은 대상을 `/proc/<pid>/fd`, `lsof`, `strace`에서 연결해 봅니다.

명령 실행이나 결과 제출 자체를 학습 목표로 삼지 않습니다.

## 현재 환경

- Ubuntu 24.04.4 LTS dev container
- OpenJDK 21.0.12
- Python 3.12.3
- `gcc`, `strace`, `lsof`, `ps`, `ss`, `tcpdump` 사용 가능
- Node.js와 Rust는 사용하는 phase에서 version을 정해 설치

## 아직 다루지 않은 개념

- process별 file descriptor table
- user space의 runtime API와 system call 경계
- open file description과 file offset 공유
- file, pipe와 socket에 공통 I/O interface를 적용하는 방식

## 학습 재개 방법

학습자는 문서를 먼저 읽을 필요 없이 Codex에게 계속 진행해 달라고 요청하면 됩니다. 에이전트가 개념을 먼저 설명하고 함께 추론한 뒤, 코드가 이해를 실제로 돕는 경우에만 최소 실험을 제안합니다.

## 저장소 관리 상태

- 시스템 실험 커리큘럼 전환 완료
- Ubuntu 설치·검증 script와 dev container 자동 구성 완료
- 개념 우선 학습 방식으로 문서 조정 완료
