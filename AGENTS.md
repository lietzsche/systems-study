# AGENTS.md

## 프로젝트 목적

이 저장소는 코드를 많이 작성하는 것 자체가 아니라, 코드로 재현할 때 특히 잘 보이는 시스템 개념을 작은 실험으로 이해하기 위한 학습 프로젝트입니다.

각 실습은 다음 조건을 우선합니다.

- 대체로 100~300줄 이내에서 핵심 현상을 재현할 수 있다.
- 실행 결과, system call, process 상태, file 또는 trace로 동작을 관찰할 수 있다.
- 정상 동작만 구현하지 않고 의도적으로 실패시켜 원인을 추적할 수 있다.
- framework나 API 암기보다 설계가 필요한 이유가 코드에서 드러난다.
- 학습한 개념이 storage, database, distributed system, runtime 같은 다른 영역으로 이어진다.

코드로 구현하는 비용이 학습 가치보다 크다면 책, 공식 문서, diagram, `strace`, profiler 또는 기존 도구를 사용합니다. 모든 개념을 직접 구현하려 하지 않습니다.

## 대화 중심 학습 방식

학습자는 문서를 직접 순회하거나 진행 상황을 관리하지 않습니다.

- 에이전트가 작업 전에 `CURRICULUM.md`, `PROGRESS.md`, `README.md`를 읽고 현재 위치를 판단합니다.
- 에이전트가 문제 상황과 개념을 충분히 설명한 뒤 학습자와 mental model 및 설계를 함께 추론합니다.
- 코드는 설명을 대신하지 않으며, 추론을 검증하거나 보이지 않는 경계를 드러낼 때만 사용합니다.
- 처음 사용하는 언어 또는 API가 필요하면 실행 가능한 최소 문법과 boilerplate를 에이전트가 먼저 제공합니다.
- 학습자는 시스템 개념을 드러내는 핵심 로직을 작성하거나 설계 판단에 참여합니다.
- boilerplate, module README, 학습 기록, 검증과 Git 작업은 에이전트가 담당합니다.

명령을 복사해 실행하고 결과를 제출하는 과정을 반복 학습 방식으로 사용하지 않습니다. 실행 전 예측은 오해를 드러낼 가치가 있을 때만 요청하며, quiz처럼 정답 확인을 반복하지 않습니다.

환경 설정, shell redirection, API 문법 같은 보조 지식이 현재 핵심 질문보다 커지면 에이전트가 직접 처리하거나 필요한 만큼만 설명합니다. 새 API를 외워서 작성하도록 요구하지 않습니다.

## 실습 설계 원칙

각 모듈은 가능하면 다음 흐름을 따릅니다.

```text
질문 또는 문제 상황
-> 개념 설명과 기존 mental model 확인
-> 가능한 설계를 함께 추론
-> 코드가 필요한지 판단
-> 필요한 경우 가장 작은 baseline 구현
-> 의도적인 failure 또는 제약 추가
-> 관찰 가능한 증거로 원인 확인
-> 최소한의 설계 개선
-> 다른 시스템 영역과 연결
```

에이전트는 구현을 시작하기 전에 다음을 확인합니다.

1. 이 개념은 코드로 재현할 때 책이나 도구만 쓰는 것보다 더 잘 보이는가?
2. 실패나 trade-off를 실제로 관찰할 수 있는가?
3. 선택한 언어가 개념보다 더 큰 학습 비용을 만들지 않는가?
4. 더 작은 실험으로 같은 질문에 답할 수 있는가?

답이 부정적이면 구현 범위를 줄이거나 관찰 과제로 전환합니다.

환경 준비나 도구 사용법만 다루는 독립 모듈은 만들지 않는 것을 기본으로 합니다. 해당 지식은 실제 시스템 질문을 해결하는 과정에서 필요한 순간에 도입합니다.

## 언어 선택

하나의 언어로 전체 과정을 통일하지 않습니다. 각 개념을 가장 적은 비용으로 명확히 드러내는 언어를 선택합니다.

- Python: process, file descriptor, signal, `mmap`, system call 관찰
- Java: storage engine, database concurrency, distributed failure, thread와 virtual thread
- Node.js/TypeScript: stream, backpressure, event loop, 작은 compiler
- Rust: ownership이 buffer 또는 concurrency 동작을 실제로 설명하는 비교 실험

언어 선택은 기본값이며 학습자의 숙련도와 실험 목적에 따라 바꿀 수 있습니다. Rust 문법이나 framework 설정이 핵심 개념을 가리면 더 익숙한 언어를 사용합니다.

## 모듈 구조

각 모듈은 독립적으로 실행할 수 있게 구성합니다.

```text
labs/
  00-os-file-descriptor/
  01-os-process-signal/
  02-os-mmap/
  03-storage-in-memory/
  ...
```

각 module README에는 필요한 범위에서 다음을 기록합니다.

- 핵심 질문
- 코드로 실험할 가치가 있는 이유
- 핵심 mental model과 함께 검토한 설계
- 필요한 경우 baseline과 failure scenario
- 실행 및 관찰 명령
- 관찰 증거와 해석
- 설계가 바뀐 이유
- 회고 질문

모듈 사이의 code dependency는 만들지 않는 것을 기본으로 합니다. 이전 실험의 개념은 이어갈 수 있지만, 복사 없이 실행하기 어려운 거대한 단일 application으로 합치지 않습니다.

## 구현 규칙

- 표준 라이브러리를 먼저 사용합니다.
- framework는 framework 자체가 학습 대상일 때만 도입합니다.
- abstraction은 반복이나 설계 문제를 실제로 관찰한 뒤 도입합니다.
- failure를 감추는 retry, fallback 또는 catch-all 예외 처리를 미리 추가하지 않습니다.
- 실험 결과에 영향을 주는 buffer size, timeout, concurrency level과 file format은 명시합니다.
- benchmark에는 warm-up, 입력 크기, 반복 횟수와 환경을 기록합니다.
- 무작위 failure에는 seed를 기록하거나 재현 가능한 주입 지점을 둡니다.
- secret, 실제 개인정보, 운영 credential과 민감한 packet capture를 저장하지 않습니다.

## 설명 규칙

설명은 다음 경계를 구분합니다.

- application code가 요청한 일
- language runtime 또는 standard library가 한 일
- operating system과 kernel이 한 일
- storage/network 같은 외부 시스템이 보장한 일

새 개념은 가능하면 다음 순서로 설명합니다.

```text
문제 상황
-> 개념과 시스템 경계
-> 함께 구성한 mental model
-> 가능한 설계와 예상 trade-off
-> 필요한 경우 관찰 가능한 증거
-> 왜 기존 설계가 실패하는가
-> 개선된 설계와 trade-off
```

## 필수 프로젝트 문서

작업을 시작하거나 계속하기 전에 다음 파일을 읽습니다.

- `CURRICULUM.md`: 전체 학습 순서와 module 목표
- `PROGRESS.md`: 현재 위치, 관찰 결과와 다음 작업
- `README.md`: 저장소 목적과 실행 방식

커리큘럼을 바꾸면 `CURRICULUM.md`를 갱신하고 현재 위치에 영향이 있으면 `PROGRESS.md`도 동기화합니다. 모듈을 완료할 때 module README와 `PROGRESS.md`를 commit 전에 갱신합니다.

## Git 작업 방식

다음 조건을 만족하면 완료한 모듈을 하나의 논리적 commit으로 만들고 현재 branch를 설정된 remote에 push합니다.

1. 핵심 질문에 코드와 관찰 결과로 답했다.
2. failure scenario와 개선 이유를 설명할 수 있다.
3. 관련 실행 또는 test가 성공했다.
4. module README와 `PROGRESS.md`를 갱신했다.
5. 관련 없는 변경과 생성물을 포함하지 않았다.

commit 제목과 본문은 한글로 작성하되 API, protocol, file 이름 등의 기술 식별자는 원문을 유지할 수 있습니다.

예시:

```text
학습(스토리지): append-only log와 recovery 실험 완료
학습(분산): retry 중복과 idempotency key 실험 완료
```

commit 전에는 `git status`, diff, 생성물과 secret 포함 여부를 확인하고 관련 검증 명령을 실행합니다. 인증, 권한, remote 또는 network 문제로 push가 실패하면 정확한 오류를 알리고 중단합니다.

미완성 모듈은 명시적으로 요청받지 않았다면 commit하지 않습니다. force push, history 재작성, branch 삭제, `git reset --hard` 같은 파괴적인 Git 작업은 자동 실행하지 않습니다.

## 전체 프로젝트 성공 기준

학습자는 완성된 application의 기능 수가 아니라 다음 능력으로 프로젝트를 평가합니다.

- 관찰 결과를 application, runtime, OS와 외부 시스템의 동작으로 나누어 설명한다.
- 정상 실행만 보고 보장을 추측하지 않고 failure를 만들어 검증한다.
- buffer, concurrency, persistence와 partial failure가 설계에 주는 제약을 설명한다.
- append log, index, recovery, transaction, retry, idempotency와 replication이 왜 필요한지 재현 사례로 설명한다.
- 같은 문제에서 언어와 runtime에 따른 실행 모델의 차이를 비교한다.
- 구현 비용이 큰 주제는 직접 구현하지 않을 이유와 더 적절한 관찰 방법을 선택한다.
