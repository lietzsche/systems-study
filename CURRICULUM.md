# 코드로 관찰하는 시스템 학습 커리큘럼

## 목표

이 과정은 시스템 분야를 모두 직접 구현하는 로드맵이 아닙니다. 먼저 개념과 문제 상황을 이해하고 함께 설계를 추론한 뒤, 코드가 실제로 이해를 돕는 지점에서만 작은 실험을 사용합니다.

기본 질문은 다음과 같습니다.

> 이 abstraction은 어떤 문제 때문에 필요하며, 그 문제와 해결 효과를 어떤 증거로 확인할 수 있는가?

## 학습 단위의 기준

코드 실습은 다음 조건을 많이 만족할수록 우선합니다.

- 100~300줄 이내에서 핵심 현상을 재현할 수 있다.
- 성공과 실패를 trace, process 상태, file 또는 metric으로 확인할 수 있다.
- 일부러 깨뜨린 뒤 원인을 추적할 수 있다.
- API 사용법보다 설계 이유와 trade-off가 드러난다.
- 이후 시스템 개념으로 자연스럽게 연결된다.

환경 설정, 명령어 연습, stdout/stderr 구분 같은 보조 지식은 필요한 순간에 설명하되 독립 학습 모듈로 늘리지 않습니다. Ethernet, routing, DNS internals, TLS 구현, TCP congestion control처럼 직접 구현 비용이 큰 주제는 책과 전문 도구를 사용합니다.

---

# Phase 0 — OS Mental Model

OS의 모든 기능을 훑지 않고, 이후 storage와 runtime을 이해하는 데 필요한 경계부터 짧고 깊게 다룹니다.

## Module 00. File descriptor와 system call

**핵심 질문:** Linux는 file, terminal, pipe와 socket처럼 다른 대상을 왜 정수형 file descriptor로 다룰 수 있는가?

**먼저 이해할 것**

- program, process와 kernel의 경계
- process별 file descriptor table
- fd `0`, `1`, `2`와 stdin/stdout/stderr
- fd와 실제 file/socket object의 차이
- language I/O API와 `open`, `read`, `write`, `close` system call의 관계

**최소 관찰:** 짧은 Python process의 fd를 `/proc/<pid>/fd`, `lsof`, `strace`에서 같은 대상으로 연결

**코드의 역할:** API 연습이 아니라 process 내부 번호와 kernel object의 관계를 증명

## Module 01. Process lifecycle과 signal

**핵심 질문:** 실행 중인 process는 어떻게 만들어지고 어떤 경로로 종료되는가?

**개념:** PID, parent/child, exit status, `SIGINT`, `SIGTERM`, `SIGKILL`, cleanup 가능 여부

**최소 관찰:** process tree와 종료 상태를 비교하고 signal handler가 개입할 수 있는 경계를 확인

## Module 02. `read()`와 `mmap()`

**핵심 질문:** 같은 file bytes를 읽는 두 방식은 address space와 kernel interaction에서 어떻게 다른가?

**최소 관찰:** access pattern을 고정하고 syscall과 page fault를 비교

**주의:** 짧은 timing 하나로 일반적인 성능 우열을 결론 내리지 않음

---

# Phase 1 — Storage Engine Lab

이 단계부터는 문제가 실제로 발생한 뒤 abstraction을 하나씩 추가합니다. 기본 언어는 Java입니다.

## Module 03. In-memory key-value baseline

**핵심 질문:** 가장 단순한 `PUT`과 `GET`은 어떤 상태 변화를 의미하는가?

**baseline:** `Map<String, byte[]>`

**다음 문제:** process가 종료되면 상태가 사라짐

## Module 04. Append-only log

**핵심 질문:** 변경 사항을 file 끝에만 기록하면 무엇을 얻고 잃는가?

**실험:** 같은 key를 여러 번 기록하고 재시작 후 최신 값 복구

**개념:** record format, serialization, offset, flush와 durability

## Module 05. Index와 compaction

**핵심 질문:** 전체 log scan과 stale record 증가는 어떻게 줄일 수 있는가?

**개선:** key에서 latest offset으로 가는 in-memory index

**다음 문제:** compaction 중 crash와 file 교체의 atomicity

## Module 06. Torn record와 recovery

**핵심 질문:** record 중간에서 process가 죽으면 어디까지 신뢰할 수 있는가?

**failure:** truncated length 또는 payload 생성

**개선:** length, checksum, valid-prefix recovery

## Module 07. WAL과 crash boundary

**핵심 질문:** 성공 응답과 durable write 사이의 순서를 어떻게 정해야 하는가?

**실험:** write, flush와 state 적용 지점마다 crash 주입

**개념:** WAL, `fsync`, atomicity와 durability의 경계

---

# Phase 2 — Database Internals Lab

## Module 08. Range query와 ordered index

**핵심 질문:** equality lookup에 좋은 hash index가 range query에는 왜 부족한가?

**비교:** linear scan, sorted array와 binary search, tree 기반 index

## Module 09. Page와 B-Tree의 필요성

**핵심 질문:** page 단위 I/O에서는 왜 넓고 낮은 tree가 유리한가?

**범위:** 작은 page model의 split과 lookup path만 관찰하며 production database 전체를 만들지 않음

## Module 10. Lost update

**핵심 질문:** 각 작업이 정상 실행돼도 최종 값이 틀릴 수 있는 이유는 무엇인가?

**failure:** 두 worker가 같은 값을 읽고 서로 다른 값을 저장

**비교:** lock과 optimistic version check

## Module 11. Isolation과 visibility

**핵심 질문:** 동시에 실행되는 transaction은 서로의 상태를 어디까지 볼 수 있어야 하는가?

**실험:** dirty read, non-repeatable read 또는 phantom 중 작은 사례를 선택

## Module 12. MVCC 최소 모델

**핵심 질문:** reader와 writer를 무조건 서로 막지 않으려면 version을 어떻게 관리하는가?

**실험:** snapshot visibility와 오래된 version 정리

---

# Phase 3 — Distributed Failure Lab

분산 알고리즘 전체보다 부분 실패가 만드는 모호함을 결정적으로 재현합니다.

## Module 13. Timeout은 결과를 말해주지 않는다

**핵심 질문:** client timeout은 server 작업 실패를 의미하는가?

**failure:** server는 처리했지만 response를 잃은 상황

## Module 14. Retry와 idempotency

**핵심 질문:** 결과를 모르는 client가 retry할 때 중복 side effect를 어떻게 막는가?

**failure:** 같은 payment command 두 번 처리

**개선:** idempotency key와 처리 결과 저장

## Module 15. Replication의 부분 실패

**핵심 질문:** primary write는 성공하고 replica 반영은 실패하면 어떤 상태를 성공으로 볼 것인가?

**개념:** acknowledgement policy, consistency와 availability

## Module 16. Leader와 quorum 최소 실험

**핵심 질문:** 여러 node의 상태가 다를 때 누가 write를 결정할 수 있는가?

**범위:** 작은 state machine과 결정 규칙만 다루며 완전한 Raft 구현을 목표로 하지 않음

---

# Phase 4 — I/O와 Stream Lab

네트워크 전체가 아니라 socket code로 해야 특히 잘 보이는 문제만 다룹니다.

## Module 17. TCP stream과 message boundary

**핵심 질문:** 두 번의 `write()`가 왜 두 번의 `read()`로 보장되지 않는가?

**failure:** 논리 message가 합쳐지거나 일부만 읽히는 조건 재현

**개선:** length-prefixed framing과 incremental parser

## Module 18. Blocking과 concurrency model

**핵심 질문:** 느린 client 하나가 다른 client를 왜 기다리게 하는가?

**비교:** single thread, thread per connection, bounded thread pool

## Module 19. Backpressure와 bounded buffer

**핵심 질문:** producer가 consumer보다 빠르면 초과 데이터는 어디에 쌓이는가?

**failure:** memory 증가 또는 latency 누적

**개선:** bounded queue, pause/resume 또는 demand 조절

---

# Phase 5 — Runtime / Concurrency 비교

동일한 I/O-bound workload를 여러 runtime에서 실행합니다. 이 단계에서만 다중 언어 구현을 적극적으로 사용합니다.

## Module 20. 비교 workload와 측정 기준

**문제:** 다수 작업이 계산보다 대기에 대부분의 시간을 사용

**측정:** wall time, throughput, thread 수, memory와 scheduling overhead

## Module 21. Java execution model

**비교:** platform thread, `ExecutorService`, virtual thread

## Module 22. Node.js execution model

**비교:** event loop, callback/Promise, libuv가 처리하는 I/O

## Module 23. Rust execution model

**비교:** `std::thread`, `Future`, Tokio executor

## Module 24. Python execution model

**비교:** threading, multiprocessing, `asyncio`

## Module 25. Cross-runtime 분석

**핵심 질문:** 같은 source-level `await` 또는 blocking call이 각 runtime에서 어떤 scheduling과 resource cost로 이어지는가?

---

# 선택 심화

## Track A. Compiler

TypeScript로 작은 expression language를 lexer, parser, AST와 evaluator 순서로 구현합니다. 새 개념을 보여주지 않는 기능 확장은 하지 않습니다.

## Track B. Performance

Java 또는 Rust로 benchmark와 profiler를 사용해 warm-up, allocation, cache locality와 측정 오류를 다룹니다.

## Track C. ML/LLM Systems

Python과 NumPy로 matrix multiplication, softmax, embedding과 작은 attention을 구현하고 PyTorch와 비교합니다.

---

# 완료 기준

모든 module을 끝내는 것보다 다음 능력을 갖추는 것이 중요합니다.

- 코드에 앞서 문제와 mental model을 설명한다.
- 관찰 가능한 증거로 abstraction의 필요성을 설명한다.
- partial write, lost update, timeout과 unbounded buffer 같은 실패를 재현한다.
- application, runtime, OS와 외부 시스템의 책임을 구분한다.
- 구현하지 않는 편이 나은 주제와 더 적절한 학습 수단을 선택한다.
