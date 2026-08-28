# 네트워크 학습 진행 상황

## 현재 상태

**상태:** 계획 단계 / 시작 전

**현재 단계:** Phase 0 — 환경 및 관찰 도구

**현재 모듈:** Module 00 — 저장소 및 패킷 분석 환경 설정

**주 구현 언어:** Java

**추후 비교 언어:** TypeScript/Node.js, Rust 순서

---

## Java로 시작하는 이유

Rust 네트워크 실습은 기본 문법, 소유권, 빌림, trait, generic, slice, collection, `Result`에 충분히 익숙해져 언어 문법이 네트워크 개념의 이해를 방해하지 않을 때까지 미룹니다.

따라서 당장은 익숙한 Java로 네트워크 학습을 시작합니다. 낯선 언어 문법과 씨름하지 않고 소켓, 버퍼, I/O, TCP/IP, 패킷 추적, 프로토콜 동작에 집중하기 위함입니다.

---

## 완료한 모듈

아직 없음.

---

## 현재 모듈: 00

### 학습 목표

저장소를 준비하고 현재 환경에서 다음 작업을 할 수 있는지 확인합니다.

- Java 코드를 컴파일하고 실행한다.
- 로컬의 listening/connected socket을 확인한다.
- `curl`이나 `nc` 같은 기본 네트워크 클라이언트를 사용한다.
- Wireshark 또는 tcpdump로 트래픽을 캡처한다.
- loopback 트래픽과 외부 인터페이스 트래픽을 구분한다.

### 필수 작업

- [ ] 저장소 및 모듈 디렉터리 구조 생성
- [ ] Java 버전과 컴파일/실행 절차 확인
- [ ] Git 원격 저장소와 브랜치 확인
- [ ] `curl` 및/또는 `nc` 사용 가능 여부 확인
- [ ] `ss`/`netstat` 사용 가능 여부 확인
- [ ] Wireshark 또는 tcpdump 사용 가능 여부 확인
- [ ] 간단한 TCP 연결 하나 캡처
- [ ] 출발지 IP, 목적지 IP, 출발지 port, 목적지 port 식별
- [ ] 캡처에서 SYN, SYN-ACK, ACK 식별
- [ ] 아래에 관찰 결과 기록
- [ ] Module 00 완료 표시
- [ ] 완료한 모듈 커밋 및 push

### 관찰 결과

_모듈을 진행하며 여기에 내용을 기록합니다._

---

## 다음 모듈

**Module 01 — TCP Echo Server**

주요 학습 내용:

- `ServerSocket`
- `Socket`
- `accept()`
- `read()` / `write()`
- TCP handshake
- EOF / FIN
- 패킷 캡처

---

## 주의 깊게 볼 개념

프로젝트 전반에서 중요하게 다룰 개념입니다.

- socket과 connection의 차이
- port와 socket의 차이
- application message와 TCP stream의 차이
- buffer 내용과 protocol boundary의 차이
- blocking과 non-blocking의 차이
- OS socket buffer와 application buffer의 차이
- packet, TCP segment, Ethernet frame의 차이
- runtime 동작과 network 동작의 차이

---

## 학습 재개 체크리스트

학습자는 Codex에게 학습을 계속 진행해 달라고 요청하면 됩니다. 다음 항목은 Codex가 확인하고 수행합니다.

1. `AGENTS.md`를 읽는다.
2. `CURRICULUM.md`에서 관련 부분을 읽는다.
3. 이 파일에서 현재 모듈을 확인한다.
4. 파일을 수정하기 전에 `git status`를 확인한다.
5. 커리큘럼 변경을 명시적으로 요청받지 않았다면 현재 모듈만 계속 진행한다.
6. 학습자에게 다음 개념 또는 과제를 대화로 제시한다.
7. 모듈을 마치면 commit/push 전에 이 파일을 갱신한다.
