# 네트워크 학습 커리큘럼

## 목표

먼저 Java로 작은 모듈을 구현하고, 이후 일부 모듈을 TypeScript/Node.js와 Rust로 다시 구현하며 네트워크에 대한 탄탄하고 실용적인 이해를 쌓습니다.

OSI를 개념적 지도로 사용하되, 모든 주제를 실제 TCP/IP stack과 관찰 가능한 socket 동작에 연결합니다.

---

## Phase 0 — 환경 및 관찰 도구

### Module 00. 저장소 및 패킷 분석 환경 설정

**목표**

- 재현 가능한 학습 환경을 준비합니다.
- Java 실행, 네트워크 유틸리티, 패킷 캡처 환경을 확인합니다.

**주제**

- localhost와 외부 interface의 차이
- loopback
- port
- `ss` / `netstat`
- `curl`
- `nc`
- `ping`
- `traceroute` / `tracert`
- `tcpdump` 또는 Wireshark

**OSI 초점**

- L1-L7 개요
- TCP/IP 모델과의 연결

**결과물**

- 간단한 환경 확인 기록
- 최초로 캡처한 TCP connection

---

# Phase 1 — Java Blocking I/O로 배우는 TCP 기초

## Module 01. TCP Echo Server

**목표**

socket, listen, connection accept, read, write, connection 종료를 이해합니다.

**Java API**

- `ServerSocket`
- `Socket`
- `InputStream`
- `OutputStream`

**주제**

- IP address와 port
- client/server
- listening socket과 connected socket의 차이
- TCP connection과 three-way handshake
- FIN / EOF
- RST 기초

**OSI 초점:** L4 TCP 및 L3 IP 관찰

**패킷 과제:** handshake, payload, connection 종료 과정을 캡처합니다.

---

## Module 02. TCP는 Byte Stream이다

**목표**

TCP가 애플리케이션 메시지의 경계를 보존한다는 오해를 없앱니다.

**주제**

- stream semantics
- partial read와 combined read
- buffer와 message boundary
- fragmentation과 application framing의 차이

**실습:** 논리적 메시지 여러 개를 전송하고 `read()` 경계와 메시지 경계가 어떻게 달라지는지 관찰합니다.

**OSI 초점:** application message와 TCP stream의 차이

---

## Module 03. 애플리케이션 수준 Framing

**목표**

TCP 위에 작은 프로토콜을 설계합니다.

**프로토콜 예시**

- delimiter 기반
- fixed-length
- length-prefixed

**최종 권장 형식**

```text
[length][type][payload]
```

**주제**

- framing
- serialization 기초
- byte order
- parsing
- malformed input

**OSI 초점:** L4 TCP 위에 만든 L7 protocol

---

## Module 04. 여러 Client와 Connection당 하나의 Thread

**목표**

blocking socket이 concurrency에 미치는 영향을 이해합니다.

**주제**

- blocking `accept()`와 `read()`
- client당 하나의 thread
- thread 비용
- shared state
- 필요한 곳에만 적용하는 synchronization

**OSI 초점:** 네트워크 계층은 같지만 server 실행 모델은 달라짐

---

# Phase 2 — UDP와 Network Layer 이해

## Module 05. UDP Echo

**목표**

TCP stream과 UDP datagram을 비교합니다.

**Java API:** `DatagramSocket`, `DatagramPacket`

**주제**

- connectionless communication
- datagram boundary
- loss, duplication, ordering
- size constraint

**OSI 초점:** L4 UDP

---

## Module 06. IP, Routing, ICMP 관찰

**목표**

IP stack을 직접 다시 구현하지 않고 TCP/UDP 아래에서 일어나는 일을 이해합니다.

**주제**

- IPv4 address
- subnet mask / prefix
- default gateway와 routing table
- TTL과 ICMP
- localhost, LAN, Internet routing의 차이

**도구:** `ip addr`, `ip route`, `ping`, `traceroute`

**OSI 초점:** L3

---

## Module 07. Ethernet, MAC, ARP 관찰

**목표**

IP 아래에서 이루어지는 local network 전송을 이해합니다.

**주제**

- frame과 MAC address
- ARP와 broadcast
- switch 기초
- Ethernet과 Wi-Fi의 개념적 연결

**도구:** `ip neigh` / `arp`, Wireshark/tcpdump

**OSI 초점:** L2

---

# Phase 3 — 애플리케이션 프로토콜

## Module 08. 순수 Java Socket으로 구현하는 HTTP/1.1

**목표**

HTTP가 TCP로 운반되는 byte라는 사실을 이해합니다.

**제약:** Spring, embedded web server, Netty를 사용하지 않습니다.

**주제**

- request line, header, blank line, body
- status line
- `Content-Length`
- connection reuse 기초

**실습:** 몇 개의 고정 endpoint를 제공할 수 있을 정도의 HTTP를 구현합니다.

**OSI 초점:** L4 TCP 위의 L7 HTTP

---

## Module 09. 순수 Socket으로 구현하는 HTTP Client

**목표**

client 측에서 HTTP를 관찰합니다.

**주제**

- DNS dependency
- TCP connection establishment
- request encoding과 response parsing
- content length
- chunked transfer encoding 개념

---

## Module 10. DNS Client

**목표**

name resolution과 binary application protocol을 이해합니다.

**주제**

- DNS hierarchy와 resolver
- recursive query
- UDP transport
- query/response 구조
- A / AAAA record
- transaction ID

**실습:** 최소 DNS query를 만들거나, 선택한 field를 구현하기 전에 DNS query 하나를 깊이 분석합니다.

**OSI 초점:** L4 UDP(경우에 따라 TCP) 위의 L7 DNS

---

# Phase 4 — TLS와 안전한 전송

## Module 11. TLS의 위치와 Handshake 관찰

**목표**

TLS가 어디에 위치하며 HTTPS가 HTTP-over-TCP에 무엇을 추가하는지 이해합니다.

**주제**

- 먼저 TCP, 다음 TLS, 그 안에 HTTP
- certificate와 server authentication
- symmetric session key
- handshake 개요
- encrypted application data

**실습:** HTTP와 HTTPS packet trace를 비교합니다.

**OSI 참고:** TLS는 전통적인 OSI presentation/session layer와 일부 개념이 겹치지만, 하나의 OSI 계층에 억지로 끼워 맞추지 않고 실제 현대 stack 안에서 이해합니다.

---

## Module 12. Java API를 사용하는 TLS

**목표**

기반 TCP connection에 대한 이해를 유지하면서 Java TLS API를 사용합니다.

**주제:** `SSLSocket`, trust store 기초, handshake timing, certificate inspection

---

# Phase 5 — Non-Blocking I/O와 Multiplexing

## Module 13. Java NIO 기초

**목표**

stream 기반 blocking API에서 channel과 buffer로 이동합니다.

**Java API:** `ByteBuffer`, `SocketChannel`, `ServerSocketChannel`

**주제**

- buffer의 position/limit/capacity
- flip/clear/compact
- partial read/write
- non-blocking mode

---

## Module 14. Selector 기반 Server

**목표**

readiness 기반 I/O multiplexing을 이해합니다.

**Java API:** `Selector`, `SelectionKey`

**주제**

- accept/read/write readiness
- 하나의 thread로 여러 connection 관리
- readiness model과 completion model의 차이

**개념 연결:** Java NIO를 epoll/kqueue 같은 OS 기능과 개념적으로 연결합니다.

---

## Module 15. Backpressure와 출력 Buffering

**목표**

producer가 consumer보다 빠를 때 어떤 일이 발생하는지 이해합니다.

**주제**

- socket send buffer
- application output queue
- partial write
- 느린 client
- memory growth
- backpressure

---

# Phase 6 — 네트워크 유틸리티와 Proxy

## Module 16. TCP Proxy

**목표**

단순한 양방향 TCP proxy를 만들고 투명한 byte forwarding을 관찰합니다.

**주제:** 두 TCP connection, bidirectional copy, half-close, buffering, latency

---

## Module 17. 최소 HTTP Proxy

**목표**

application-layer intermediary와 순수 TCP proxy의 차이를 관찰합니다.

**주제:** HTTP request parsing, forwarding, Host header, connection handling

---

# Phase 7 — TypeScript / Node.js 비교

의미 있는 일부 모듈만 다시 구현합니다.

## Module 18. Node TCP Echo와 Custom Framing

**목표**

Java blocking socket과 Node event-driven socket을 비교합니다.

**API:** `net.createServer`, `net.Socket`, `Buffer`

**주제:** `data` event, stream, chunk boundary, event loop

---

## Module 19. Node Backpressure

**목표**

stream backpressure를 Java NIO에서 이미 배운 개념과 연결합니다.

**주제:** `write()` 반환값, `drain`, readable/writable stream, buffering

---

## Module 20. Node TCP Proxy

**목표**

event-driven proxy 구현을 Java 구현과 비교합니다.

---

# Phase 8 — Rust 비교

Rust 문법이 네트워크 학습을 방해하지 않을 만큼 기초에 익숙해진 뒤 시작합니다.

## Module 21. `std::net`을 사용하는 Rust TCP Echo

**주제:** `TcpListener`, `TcpStream`, `Read` / `Write`, slice, buffer ownership, `Result`

**비교**

- Java `Socket` / `byte[]`
- Node `net.Socket` / `Buffer`
- Rust `TcpStream` / `&mut [u8]`

---

## Module 22. Rust Framing Protocol

length-prefixed protocol을 다시 구현하며 ownership, borrowing, parsing에 집중합니다.

---

## Module 23. Rust Concurrent Server

async보다 thread를 먼저 사용합니다.

---

## Module 24. Rust Async Networking

**사용 가능한 runtime:** Tokio

**목표:** 이 단계에서 futures, async task, reactor 개념, readiness 기반 I/O를 Java NIO 및 Node.js와 연결합니다.

---

# Phase 9 — 통합 및 복습

## Module 25. 전체 Packet 흐름 추적

하나의 request가 application에서 wire로 갔다가 돌아오는 과정을 설명합니다.

권장 시나리오:

```text
Browser / custom client
-> DNS
-> TCP handshake
-> TLS handshake
-> HTTP request
-> HTTP response
-> TCP close 또는 reuse
```

각 단계에서 다음을 식별합니다.

- application data
- protocol header
- TCP segment
- IP packet
- Ethernet/Wi-Fi frame
- 담당 OS component
- 관련 user-space API

---

## Module 26. 언어 간 비교

Java, Node.js, Rust를 최종 비교합니다.

**비교 항목**

- socket API와 buffer type
- blocking model과 concurrency model
- event-driven model
- error handling과 resource lifetime
- backpressure
- framing 구현
- TLS API

---

# 완료 기준

학습자가 다음 질문에 답하고 직접 시연할 수 있으면 커리큘럼을 완료한 것입니다.

- socket이 정확히 무엇인가?
- listening socket과 connected socket은 어떻게 다른가?
- TCP는 왜 message protocol이 아니라 stream인가?
- 한 번의 write가 여러 read로 수신되거나 여러 write가 한 번의 read로 수신될 수 있는 이유는 무엇인가?
- application protocol에 framing이 필요한 이유는 무엇인가?
- API와 transport 계층에서 UDP는 TCP와 어떻게 다른가?
- TCP/UDP 아래에서 IP와 routing은 어떤 역할을 하는가?
- LAN에서 Ethernet frame, MAC address, ARP는 무엇을 하는가?
- HTTP는 wire에서 어떤 형태로 표현되는가?
- TCP 및 HTTP를 기준으로 TLS는 어디에 위치하는가?
- non-blocking I/O와 selector가 필요한 이유는 무엇인가?
- backpressure란 무엇인가?
- Java NIO, Node.js, Rust async networking은 개념적으로 어떻게 연결되는가?
- packet trace에서 어떤 OSI/TCP-IP 계층을 볼 수 있으며 각 계층의 책임은 무엇인가?
