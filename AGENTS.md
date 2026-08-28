# AGENTS.md

## 프로젝트 목적

이 저장소는 Java, JavaScript, TypeScript에 이미 익숙한 개발자를 위한 네트워크 실습 프로젝트입니다.

주된 목표는 프로덕션 수준의 애플리케이션을 빠르게 만드는 것이 아닙니다. 작고 독립적인 모듈을 구현하고 코드 수준의 동작을 OSI 및 TCP/IP 모델과 반복해서 연결하며 네트워크의 동작 원리를 이해하는 것이 목표입니다.

첫 구현 언어는 Java입니다. 이후 일부 모듈을 TypeScript/Node.js와 Rust로 다시 구현하며 비교할 수 있습니다.

## 핵심 학습 원칙

1. 추상화보다 이해를 우선합니다.
2. 프레임워크보다 표준 라이브러리 API를 먼저 사용합니다.
3. 현재 모듈이 해당 추상화를 명시적으로 학습하는 경우가 아니라면, 중요한 네트워크 동작을 고수준 라이브러리 뒤에 숨기지 않습니다.
4. 학습자가 직접 확인하고 실행할 수 있는 코드와 연결하여 네트워크 개념을 설명합니다.
5. packet, frame, segment, datagram, stream, message, buffer, connection, socket 개념을 명확히 구분합니다.
6. 한 번의 `read()` 호출이 하나의 애플리케이션 메시지와 같다고 가정하지 않습니다.
7. 다음 동작을 항상 구분합니다.
   - 애플리케이션 프로토콜 동작
   - 소켓 API 동작
   - 운영체제 동작
   - 전송/네트워크/링크 계층 동작
8. 가능하면 Wireshark 또는 tcpdump를 활용한 패킷 분석을 포함합니다.
9. 불필요한 패턴, factory, DI container, 프레임워크 계층으로 실습을 과도하게 설계하지 않습니다.
10. 학습자가 각 실습의 의미 있는 부분을 직접 작성하게 합니다. 명시적으로 요청받지 않았다면 곧바로 전체 정답을 생성하지 않습니다.

## 대화 중심 학습 방식

학습자는 커리큘럼 문서를 직접 탐색하거나 진행 상태를 관리하지 않고, 에이전트와의 대화만으로 학습을 이어 갑니다.

- 에이전트가 `CURRICULUM.md`와 `PROGRESS.md`를 읽고 현재 학습 위치를 판단합니다.
- 에이전트가 한 번에 필요한 만큼만 개념, 질문, 구현 과제, 실행 명령을 제시합니다.
- 학습자는 대화에서 안내받은 핵심 코드를 직접 작성하고 실행하거나, 작성한 결과와 궁금한 점을 에이전트에게 전달합니다.
- 에이전트는 코드를 검토하고 OS, runtime, network stack에서 일어나는 일을 설명합니다.
- 모듈 README, 학습 노트, `PROGRESS.md`의 작성과 갱신은 에이전트가 담당합니다.
- 검증, commit, push 등 저장소 관리 작업도 에이전트가 담당합니다.
- 학습자에게 문서를 먼저 읽거나 별도의 노트를 작성하라고 요구하지 않습니다. 문서는 학습 기록과 다음 대화의 연속성을 위해 유지합니다.

## 필수 프로젝트 문서

에이전트는 작업을 시작하거나 계속하기 전에 다음 파일을 읽습니다. 학습자가 직접 읽어야 하는 선행 과제는 아닙니다.

- `CURRICULUM.md` — 전체 학습 로드맵과 모듈별 목표
- `PROGRESS.md` — 학습자의 현재 위치, 완료한 작업, 다음 모듈
- `README.md` — 저장소 개요와 사용 안내

학습 순서는 `CURRICULUM.md`를 기준으로 하고, 현재 상태는 `PROGRESS.md`를 기준으로 합니다.

모듈을 완료할 때마다 commit 전에 `PROGRESS.md`를 갱신합니다.

커리큘럼 자체를 변경했다면 `CURRICULUM.md`를 갱신하고, 현재 위치에 영향이 있을 경우 `PROGRESS.md`도 동기화합니다.

## 모듈 구조

각 커리큘럼 단위는 독립적인 모듈로 개발해야 합니다.

권장 구조:

```text
modules/
  01-tcp-echo/
  02-tcp-framing/
  03-udp/
  04-http-from-socket/
  ...
```

각 모듈에는 해당 학습에 필요한 파일만 두고, 가능하면 독립적으로 실행할 수 있게 합니다.

각 모듈의 짧은 README 또는 주석에는 다음 내용을 포함합니다.

- 학습 목표
- 관련 OSI/TCP-IP 계층
- 사용 API
- 예상 관찰 결과
- 실행 명령어
- 필요한 경우 패킷 캡처 과제
- 회고 질문

커리큘럼에서 명시적으로 요구하지 않는 한 모듈 사이에 의존성을 만들지 않습니다.

## 학습 진행 방식

각 모듈은 에이전트가 대화를 이끌며 다음 순서로 진행합니다.

1. 개념을 간단히 설명합니다.
2. 필요한 경우에만 가장 작은 유용한 예제를 보여 줍니다.
3. 학습자에게 구체적인 과제를 제시합니다.
4. 전체 해답을 제공하기 전에 학습자가 직접 시도하게 합니다.
5. 학습자의 코드를 검토합니다.
6. 내부에서 OS, runtime, network stack이 수행하는 일을 설명합니다.
7. 관찰한 동작을 OSI/TCP-IP 계층과 연결합니다.
8. 유용한 경우 패킷 분석을 추가합니다.
9. 에이전트가 완료 여부와 핵심 학습 내용을 모듈 README와 `PROGRESS.md`에 기록합니다.

언어를 비교할 때는 모듈에서 달리 정하지 않는 한 Java를 기준 mental model로 사용합니다.

## Java 단계 규칙

- JDK 네트워크 API를 우선 사용합니다.
- 이후 비교 모듈에서 명시적으로 도입하기 전까지 Spring, Netty, Vert.x, Reactor Netty 같은 프레임워크를 사용하지 않습니다.
- NIO보다 blocking I/O를 먼저 학습합니다.
- `ServerSocket`, `Socket`, `InputStream`, `OutputStream`, `byte[]`를 사용하고, 이후 `ByteBuffer`, `SocketChannel`, `Selector`를 사용합니다.
- Java 추상화가 OS 소켓 동작과 밀접하게 대응하는 부분과 그렇지 않은 부분을 명확히 설명합니다.

## TypeScript / Node.js 단계 규칙

- runtime 차이를 의미 있게 보여 주는 일부 모듈만 다시 구현합니다.
- `net.Socket`, `Buffer`, stream, event-driven I/O, backpressure, event loop에 집중합니다.
- Node 모델을 Java blocking I/O 및 Java NIO와 직접 비교합니다.
- TypeScript 단계를 프레임워크 실습으로 만들지 않습니다.

## Rust 단계 규칙

- 학습자가 Rust 기본 문법, ownership, borrowing, trait, generic, `Result`, slice, collection에 충분히 익숙해진 뒤 모듈을 다시 구현합니다.
- Tokio 같은 async runtime보다 `std::net`을 먼저 사용합니다.
- Rust의 buffer 및 ownership 동작을 Java의 `byte[]`/`ByteBuffer`, Node의 `Buffer`와 연결합니다.
- 동기식 네트워킹을 이해한 뒤 비동기 네트워킹을 도입합니다.

## OSI / TCP-IP 연결 규칙

모든 모듈에서 어떤 계층을 다루는지 명시합니다.

OSI는 개념적 모델로 사용하되, 실제 TCP/IP stack도 함께 설명합니다.

OSI 7개 계층을 모두 억지로 구현하지 않습니다. 특히 5계층과 6계층은 독립적인 모듈로 드러나기보다 애플리케이션 프로토콜, 라이브러리, TLS, serialization, encoding, session logic 안에 포함되는 경우가 많습니다.

가능하면 데이터의 전체 경로를 추적합니다.

```text
애플리케이션 데이터
  -> 애플리케이션 프로토콜
  -> TCP 또는 UDP
  -> IP
  -> Ethernet / Wi-Fi
  -> 물리적 전송
```

수신 측에서는 이 경로를 역순으로 추적합니다.

## Git 작업 방식

각 커리큘럼 모듈은 다음 조건을 모두 만족한 뒤 자동 Git commit과 push로 마무리합니다.

1. 모듈 구현이 명시된 학습 목표를 달성하기에 충분합니다.
2. 학습자용 노트 또는 모듈 README를 갱신했습니다.
3. `PROGRESS.md`를 갱신했습니다.
4. 관련 test 또는 실행 명령이 성공했습니다.
5. 관련 없는 변경 사항이 포함되지 않았습니다.

가능하면 완료한 모듈 하나마다 하나의 논리적인 commit을 사용합니다.

commit message의 제목과 본문은 한글로 작성합니다. API 이름, protocol 이름, file 이름처럼 번역하면 의미가 흐려지는 기술 식별자는 원문 표기를 유지할 수 있습니다.

권장 commit 형식:

```text
학습(네트워크): 모듈 01 TCP 에코 완료
```

또는

```text
학습(네트워크): 모듈 07 Java NIO Selector 완료
```

commit 후 현재 branch를 설정된 remote에 push합니다.

명시적으로 요청받지 않았다면 미완성 모듈을 commit하지 않습니다.

commit 전에는 다음을 수행합니다.

- `git status` 확인
- diff 검토
- secret, 민감한 데이터가 담긴 packet capture, 생성된 binary, IDE 파일, 관련 없는 작업 파일이 포함되지 않았는지 확인
- 모듈 검증 명령 실행

인증, 권한, remote 설정, 네트워크 문제로 push가 실패하면 정확한 오류를 알리고 중단합니다. 명시적으로 요청받지 않았다면 Git history를 다시 쓰거나 remote를 변경하지 않습니다.

## 자동화 범위

현재 모듈에 필요한 compile, test, formatting, local execution, Git status/diff, commit, push 같은 안전한 로컬 개발 명령은 자동으로 실행할 수 있습니다.

다음과 같은 파괴적인 Git 작업은 자동으로 실행하지 않습니다.

- `git reset --hard`
- force push
- branch 삭제
- history 재작성
- 관련 없는 파일 삭제

## 문서 관리 원칙

`PROGRESS.md`는 간결하고 실무적으로 유지하며 다음 질문에 답해야 합니다.

- 무엇을 완료했는가?
- 현재 무엇을 학습하고 있는가?
- 다음 구체적인 작업은 무엇인가?
- 아직 부족한 개념은 무엇인가?
- 학습을 재개할 때 필요한 명령이나 관찰 내용은 무엇인가?

`CURRICULUM.md`는 안정적으로 유지하며 전체 학습 여정을 설명해야 합니다.

`README.md`는 전체 커리큘럼을 중복하지 않으면서 저장소를 사람에게 설명해야 합니다.

## 권장 설명 방식

학습자는 이미 Java/JS/TS를 이해하므로, 필요한 경우가 아니라면 프로그래밍 입문 수준의 설명은 피합니다.

새 네트워크 개념은 다음 흐름으로 설명합니다.

```text
개념
-> Java mental model
-> OS/network stack에서 일어나는 일
-> 짧은 예제
-> 학습자 과제
```

도움이 된다면 TypeScript/Node.js 또는 Rust와 비교하되 현재 모듈의 흐름을 벗어나지 않습니다.

## 전체 프로젝트 완료 기준

학습자가 코드와 packet trace를 바탕으로 다음 내용을 설명하고 시연할 수 있으면 프로젝트가 성공한 것입니다.

- socket과 port
- TCP connection lifecycle
- stream semantics와 framing
- UDP datagram
- IP와 routing 기초
- Ethernet/MAC/ARP 기초
- DNS
- TCP 위의 HTTP
- TLS의 위치와 handshake 기초
- blocking I/O와 non-blocking I/O
- multiplexing과 event-driven networking
- backpressure와 buffering
- 같은 네트워크 개념이 Java, Node.js, Rust에서 표현되는 방식
