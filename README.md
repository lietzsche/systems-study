# Systems Study

코드로 재현할 때 특히 잘 보이는 시스템 개념을 작은 실험으로 학습하는 저장소입니다.

목표는 여러 분야의 production application을 완성하거나 특정 언어의 API를 암기하는 것이 아닙니다. 정상적인 baseline을 만든 뒤 의도적으로 실패시키고, terminal 출력, system call, process 상태, file 내용과 metric을 관찰하여 다음 abstraction이 왜 필요한지 이해합니다.

## 학습 기준

다음 질문을 기준으로 실습 범위를 정합니다.

> 이 개념은 코드로 직접 재현할 때 책이나 기존 도구만 사용하는 것보다 더 잘 보이는가?

좋은 실습은 대체로 다음 성질을 가집니다.

- 작은 코드로 현상을 재현할 수 있습니다.
- 결과와 실패가 눈에 보입니다.
- 원인을 추적할 관찰 수단이 있습니다.
- 문제를 겪은 뒤 설계가 필요한 이유가 드러납니다.
- framework 설정과 API 암기가 중심이 아닙니다.

직접 구현의 가치가 낮은 주제는 책, 공식 문서, Wireshark, `strace`, profiler 같은 더 적합한 수단을 사용합니다.

## 학습 영역

```text
file descriptor, process, signal과 mmap
-> append-only log, index, recovery와 WAL
-> database index, transaction, isolation과 MVCC
-> timeout, retry, idempotency와 replication failure
-> I/O, TCP stream, framing과 backpressure
-> Java, Node.js, Rust, Python runtime 비교
```

Compiler, Performance, ML/LLM Systems는 선택 심화 track으로 둡니다.

상세한 module 순서와 질문은 `CURRICULUM.md`에 기록합니다. 현재 위치와 실제 관찰 결과는 `PROGRESS.md`에서 에이전트가 관리합니다.

## 환경 준비

기준 환경은 Ubuntu 24.04 dev container입니다. VS Code에서 저장소를 dev container로 처음 열면 `postCreateCommand`가 다음 스크립트를 자동으로 실행합니다.

```bash
bash scripts/setup-ubuntu.sh
bash scripts/verify-environment.sh
```

Ubuntu 24.04 host에서 직접 실행할 수도 있습니다. 설치 스크립트는 여러 번 실행할 수 있으며 공통 환경인 Python, OpenJDK 21, `strace`, `lsof`, C compiler 및 기본 네트워크 관찰 도구를 설치합니다. 실제 version과 사용 가능한 명령은 검증 스크립트가 확인합니다.

Node.js와 Rust toolchain은 처음 사용하는 phase에서 version을 정해 별도 setup으로 추가합니다. 각 lab의 추가 dependency도 해당 lab 안에서 관리하며, 전역 설치 스크립트에는 전체 선택 track의 언어, library와 framework를 미리 넣지 않습니다.

## 진행 방식

이 저장소는 문서를 혼자 순서대로 읽는 교재가 아니라 Codex와 대화하며 진행하는 실험 과정입니다.

1. 에이전트가 문제 상황과 관련 시스템 개념을 먼저 설명합니다.
2. 학습자와 mental model 및 가능한 설계를 함께 추론합니다.
3. 코드가 이해를 실제로 돕는지 판단합니다.
4. 필요한 경우에만 최소 코드를 구현하고 관찰 가능한 증거와 연결합니다.
5. failure를 통해 기존 설계의 한계를 확인하고 개선의 trade-off를 논의합니다.
6. 에이전트가 module 기록, boilerplate, 검증, commit과 push를 담당합니다.

명령을 복사하고 결과를 제출하는 과정을 반복하지 않습니다. 실행 전 예측은 오해를 확인할 가치가 있을 때만 사용합니다. 새 언어나 API를 처음 사용할 때는 에이전트가 실행 가능한 최소 문법과 boilerplate를 제공하고, 학습자가 직접 작성하는 부분은 현재 시스템 개념을 드러내는 핵심 로직으로 제한합니다.

## 언어 선택

하나의 언어를 모든 문제에 강제하지 않습니다.

| 영역 | 기본 언어 | 선택 이유 |
| --- | --- | --- |
| Network/I/O | Node.js 또는 Java | stream, blocking과 concurrency 관찰 |
| OS | Python | OS API와 system call을 적은 코드로 연결 |
| Storage/Database | Java | file format, index와 concurrency를 명시적으로 구현 |
| Distributed failure | Java 또는 Python | failure injection과 state 관찰 |
| Runtime 비교 | Java, Node.js, Rust, Python | 실행 모델 자체가 비교 대상 |
| Compiler | TypeScript | 작은 AST와 parser 표현이 간결함 |
| ML/LLM | Python | NumPy/PyTorch와 수학적 연산 연결 |

언어는 기본값일 뿐이며, 문법 학습 비용이 핵심 개념을 가리면 더 적합한 언어로 바꿉니다.

## 저장소 구조

모듈은 작고 독립적인 실험으로 만듭니다.

```text
.
├── AGENTS.md
├── CURRICULUM.md
├── PROGRESS.md
├── README.md
└── labs/
    ├── 00-os-file-descriptor/
    ├── 01-os-process-signal/
    ├── 02-os-mmap/
    ├── 03-storage-in-memory/
    └── ...
```

각 module은 핵심 질문, baseline, failure scenario, 실행 명령, 관찰 결과와 설계 변화를 기록합니다. module 사이에 불필요한 code dependency를 만들지 않습니다.

## 현재 상태

기존 네트워크 구현 중심 커리큘럼을 종료하고 개념 설명과 설계 추론을 우선하는 시스템 학습 과정으로 처음부터 시작합니다. 첫 주제는 OS의 file descriptor이며, 이후 Storage Engine으로 이어집니다.
