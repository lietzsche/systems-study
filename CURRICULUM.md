# 코드로 관찰하는 시스템 학습 커리큘럼

## 목표

이 커리큘럼은 시스템 분야를 모두 직접 구현하려는 로드맵이 아닙니다. 코드로 재현할 때 특히 잘 보이는 문제를 골라 작은 baseline을 만들고, 실패를 주입하고, 관찰 결과에서 다음 설계가 필요한 이유를 발견합니다.

각 실습의 기본 질문은 다음과 같습니다.

> 이 abstraction은 어떤 실제 문제 때문에 필요해졌으며, 그 문제가 발생했다는 증거를 어떻게 관찰할 수 있는가?

## 범위 선택 기준

코드 실습은 다음 조건을 많이 만족할수록 우선합니다.

- 100~300줄 정도로 핵심 현상을 재현할 수 있다.
- 성공과 실패를 terminal, trace, file 또는 metric으로 확인할 수 있다.
- 일부러 깨뜨린 뒤 원인을 추적할 수 있다.
- API 암기보다 설계 이유와 trade-off가 드러난다.
- 이후 module의 개념으로 자연스럽게 연결된다.

Ethernet, routing, ARP, DNS internals, NAT, TLS 구현, TCP congestion control처럼 직접 구현 비용이 큰 주제는 필요할 때 책과 전문 도구로 학습합니다.

---

# Phase 0 — 실험 환경과 관찰 방법

## Module 00. 재현 가능한 실험의 기준

**핵심 질문:** 실행 결과를 어떻게 관찰하고 다시 재현할 것인가?

**주제**

- process exit code, stdout, stderr
- 임시 작업 directory와 생성물 분리
- 고정 입력, seed, timeout
- `ps`, `/proc`, `strace`, `lsof`, profiler의 역할
- baseline과 failure scenario 기록 방법

**결과물:** 작은 environment probe와 실험 기록 template

---

# Phase 1 — Network가 아닌 I/O와 Stream 실험

네트워크 전체를 구현하지 않습니다. socket code로 해야 특히 잘 드러나는 I/O 문제만 다룹니다.

## Module 01. TCP stream과 message boundary

**핵심 질문:** 두 번의 `write()`가 왜 두 번의 `read()`로 보장되지 않는가?

**baseline:** 여러 논리 message를 TCP connection 하나로 전송

**failure:** message가 합쳐지거나 일부만 읽히는 조건 재현

**개선:** length-prefixed framing과 incremental parser

**관찰:** application log, buffer 크기 변화, `tcpdump` 보조 관찰

**기본 언어:** Node.js 또는 Java 중 더 간단한 쪽

## Module 02. Blocking과 concurrency model

**핵심 질문:** 느린 client 하나가 다른 client를 왜 기다리게 하는가?

**baseline:** single-thread server

**failure:** client A가 오래 점유하는 동안 client B의 응답 지연

**개선 순서:** thread per connection -> bounded thread pool

**관찰:** latency, thread 수, queue 길이

**기본 언어:** Java

## Module 03. Backpressure와 bounded buffer

**핵심 질문:** producer가 consumer보다 빠르면 초과 데이터는 어디에 쌓이는가?

**baseline:** 제한 없는 생산과 느린 소비

**failure:** memory 증가 또는 latency 누적

**개선:** bounded queue, pause/resume 또는 demand 조절

**연결 개념:** TCP send/receive buffer, Node stream, Reactive Streams, Kafka consumer

**기본 언어:** Node.js 또는 Java

---

# Phase 2 — OS Observation Lab

## Module 04. Process와 system call

**핵심 질문:** program 실행과 process 생성은 어떤 OS 동작으로 보이는가?

**실험:** parent/child PID, exit code, process tree 관찰

**도구:** `ps`, `/proc`, `strace`

**기본 언어:** Python

## Module 05. File descriptor와 I/O

**핵심 질문:** file과 socket이 Linux에서 같은 정수형 handle로 보이는 이유는 무엇인가?

**실험:** `open`, `read`, `write`, `close`, stdin/stdout/stderr와 socket fd 비교

**도구:** `strace`, `lsof`, `/proc/<pid>/fd`

**기본 언어:** Python

## Module 06. Signal과 process lifecycle

**핵심 질문:** `SIGINT`, `SIGTERM`, `SIGKILL`은 종료 과정에서 무엇이 다른가?

**실험:** handler, cleanup, exit status와 강제 종료 비교

**기본 언어:** Python

## Module 07. `read()`와 `mmap()`

**핵심 질문:** 같은 file bytes를 읽는 두 방식은 address space와 system call 관점에서 어떻게 다른가?

**실험:** access pattern과 file size를 바꾸며 syscall과 page fault 관찰

**주의:** 단순 실행 시간을 근거로 일반적인 성능 우열을 결론 내리지 않습니다.

---

# Phase 3 — Storage Engine Lab

이 단계부터는 Java를 기본 언어로 사용하되 언어 문법이 실험을 방해하면 조정합니다.

## Module 08. In-memory key-value store

**핵심 질문:** 가장 단순한 `PUT`과 `GET`의 의미는 무엇인가?

**baseline:** `Map<String, byte[]>`

**관찰:** overwrite, missing key, byte serialization

## Module 09. Append-only log

**핵심 질문:** overwrite 없이 변경 사항을 file 끝에만 기록하면 무엇을 얻고 잃는가?

**실험:** 같은 key를 여러 번 기록하고 재시작 후 최신 값 찾기

**개념:** record format, offset, durability와 flush

## Module 10. In-memory index와 compaction

**핵심 질문:** 전체 log scan을 피하려면 어떤 metadata가 필요한가?

**개선:** key -> latest offset index

**failure:** stale record와 file 크기 증가

**다음 설계:** compaction과 atomic replacement

## Module 11. Torn record와 recovery

**핵심 질문:** record 중간에서 process가 죽으면 다음 시작 때 어디까지 신뢰할 수 있는가?

**failure:** truncated length 또는 payload를 의도적으로 생성

**개선:** length, checksum, valid-prefix recovery

## Module 12. WAL과 crash boundary

**핵심 질문:** 성공 응답과 durable write 사이의 순서를 어떻게 정해야 하는가?

**실험:** write, flush, state 적용 지점마다 crash 주입

**개념:** WAL, fsync, atomicity와 durability의 경계

---

# Phase 4 — Database Internals Lab

## Module 13. Range query와 ordered index

**핵심 질문:** equality lookup에 좋은 hash index가 range query에는 왜 부족한가?

**비교:** linear scan, sorted array와 binary search, tree 기반 index

**관찰:** 입력 크기와 query 분포에 따른 비교 횟수

## Module 14. Page와 B-Tree의 필요성

**핵심 질문:** disk/page 단위 I/O에서는 왜 넓고 낮은 tree가 유리한가?

**실험:** 작은 page model에서 split과 lookup path 관찰

**주의:** production database 전체를 구현하지 않습니다.

## Module 15. Lost update

**핵심 질문:** 각 transaction이 정상적으로 실행돼도 최종 값이 틀릴 수 있는 이유는 무엇인가?

**failure:** 두 worker가 같은 값을 읽고 서로 다른 값을 저장

**개선:** lock과 optimistic version check 비교

## Module 16. Isolation과 visibility

**핵심 질문:** 동시에 실행되는 작업이 서로의 중간 상태를 어디까지 볼 수 있어야 하는가?

**실험:** dirty read, non-repeatable read 또는 phantom 중 작은 사례 선택

**개념:** isolation level과 concurrency trade-off

## Module 17. MVCC 최소 모델

**핵심 질문:** reader와 writer를 무조건 서로 막지 않으려면 version을 어떻게 관리할 수 있는가?

**실험:** snapshot visibility와 오래된 version 정리

---

# Phase 5 — Distributed Failure Lab

분산 알고리즘 전체보다, 부분 실패가 만드는 모호함을 작고 결정적으로 재현합니다.

## Module 18. Timeout은 결과를 말해주지 않는다

**핵심 질문:** client timeout은 server 작업 실패를 의미하는가?

**failure:** server는 처리했지만 response를 잃는 상황

**관찰:** client 결과와 server state의 불일치

## Module 19. Retry와 idempotency

**핵심 질문:** 결과를 모르는 client가 retry하면 중복 side effect를 어떻게 막는가?

**failure:** 같은 payment command 두 번 처리

**개선:** idempotency key, 결과 저장과 request identity

## Module 20. Replication의 부분 실패

**핵심 질문:** primary write는 성공하고 replica 반영은 실패하면 어떤 값이 진짜인가?

**실험:** 복제 단계 사이에 failure 주입

**개념:** acknowledgement policy, consistency와 availability

## Module 21. Leader와 quorum 최소 실험

**핵심 질문:** 여러 node의 상태가 다를 때 누가 write를 결정할 수 있는가?

**범위:** 작은 state machine과 결정 규칙만 구현

**주의:** 완전한 Raft 구현을 목표로 하지 않습니다.

---

# Phase 6 — Runtime / Concurrency 비교

동일한 I/O-bound workload를 여러 runtime에서 실행합니다. 이 단계에서만 다중 언어 구현을 적극적으로 사용합니다.

## Module 22. 실험 workload와 측정 기준

**문제:** 다수 작업이 계산보다 대기에 대부분의 시간을 사용

**측정:** wall time, throughput, thread 수, memory와 scheduling overhead

## Module 23. Java execution model

**비교:** platform thread, `ExecutorService`, virtual thread

## Module 24. Node.js execution model

**비교:** event loop, callback/Promise, libuv가 처리하는 I/O

## Module 25. Rust execution model

**비교:** `std::thread`, `Future`, Tokio executor

## Module 26. Python execution model

**비교:** threading, multiprocessing, `asyncio`

## Module 27. Cross-runtime 분석

**핵심 질문:** 같은 source-level `await` 또는 blocking call이 각 runtime에서 어떤 실행 모델로 이어지는가?

**결과물:** API 표가 아니라 scheduling, waiting과 resource cost 중심의 비교 기록

---

# 선택 심화

## Track A. Compiler

작은 expression language를 lexer, parser, AST, evaluator 순서로 구현합니다. 변수, scope, function 또는 bytecode VM은 관찰할 새 문제가 있을 때만 추가합니다. 기본 언어는 TypeScript입니다.

## Track B. Performance

같은 동작의 구현을 benchmark하고 profiler로 병목을 찾습니다. 측정 오류, warm-up, allocation, cache locality와 최적화 trade-off를 다룹니다. 기본 언어는 Java 또는 Rust입니다.

## Track C. ML/LLM Systems

NumPy로 matrix multiplication, softmax, embedding과 작은 attention을 구현하고 PyTorch 결과와 비교합니다. sequence length와 batch size 변화가 memory와 실행 시간에 미치는 영향을 관찰합니다. 기본 언어는 Python입니다.

---

# 완료 기준

전체 module을 모두 구현하는 것이 완료 조건은 아닙니다. 핵심 track을 진행한 뒤 학습자는 다음을 할 수 있어야 합니다.

- 관찰 가능한 증거로 abstraction의 필요성을 설명한다.
- partial read, blocked worker, unbounded buffer, partial write와 timeout 같은 실패를 재현한다.
- index, recovery, WAL, transaction, idempotency와 replication의 trade-off를 설명한다.
- application, runtime, OS와 외부 시스템의 책임을 구분한다.
- 같은 문제에 적합한 언어와 관찰 도구를 선택하고 그 이유를 설명한다.
