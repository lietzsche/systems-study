# Module 00 — WSL 네트워크 학습 환경

## 학습 목표

- WSL 2와 Ubuntu 24.04를 학습 환경의 기준으로 사용합니다.
- Java 21 코드를 컴파일하고 실행할 수 있는지 확인합니다.
- socket, interface, route와 packet을 관찰할 도구를 준비합니다.
- Windows, WSL, loopback interface의 경계를 구분할 준비를 합니다.

## 관련 계층

이 모듈은 OSI L1-L7 전체를 구현하지 않고, 이후 실습에서 각 계층을 관찰할 환경을 준비합니다. `tcpdump`가 보여 주는 packet, `ss`가 보여 주는 OS socket 상태, Java socket API가 서로 다른 관찰 지점이라는 점이 중요합니다.

## 기준 환경과 도구

- WSL 2
- Ubuntu 24.04 LTS
- OpenJDK 21 (`java`, `javac`)
- `ip`, `ss`, `netstat`, `ping`, `traceroute`
- `curl`, `nc`, `dig`, `openssl`
- `tcpdump`, `ethtool`, `lsof`

Node.js와 Rust는 해당 비교 단계에서 버전을 정해 추가합니다. 지금 설치하지 않아 Java 네트워크 학습 환경을 작고 명확하게 유지합니다.

## 처음 설치하기

WSL이나 Ubuntu가 없다면 관리자 권한 PowerShell에서 다음 명령을 실행합니다.

```powershell
wsl --install -d Ubuntu-24.04
```

재부팅과 Ubuntu 사용자 생성이 끝나면 PowerShell에서 WSL 버전을 확인합니다.

```powershell
wsl --list --verbose
```

Ubuntu 배포판의 `VERSION` 열이 `2`여야 합니다. WSL 1이라면 `<배포판 이름>`을 위 명령에 표시된 정확한 이름으로 바꾸어 실행합니다.

```powershell
wsl --set-version <배포판 이름> 2
```

이후 WSL Ubuntu 터미널에서 저장소 루트로 이동하여 실행합니다.

```bash
./scripts/setup-ubuntu.sh
./scripts/verify-environment.sh
```

설치 스크립트는 여러 번 실행해도 됩니다. Ubuntu 공식 저장소의 최신 보안 업데이트를 사용하되, 운영체제는 24.04, Java major version은 21인지 검사합니다.

## VS Code에서 열기

Windows VS Code에 **WSL** 확장을 설치한 뒤 WSL 터미널의 저장소 루트에서 실행합니다.

```bash
code .
```

VS Code 왼쪽 아래에 `WSL: Ubuntu-24.04`와 같은 원격 표시가 나타나야 합니다. 이때 VS Code UI는 Windows에서 실행되지만 터미널, Java compiler와 네트워크 명령은 WSL에서 실행됩니다.

## 예상 관찰 결과

- `java -version`과 `javac -version`의 major version이 21입니다.
- `ip -brief address`에 loopback인 `lo`와 WSL의 Ethernet interface가 보입니다.
- `ip route`에 WSL의 default route가 보입니다.
- `ss`는 WSL Linux kernel이 관리하는 socket을 보여 줍니다.
- `sudo tcpdump -i lo`는 WSL loopback을 지나는 packet을 캡처합니다.

## Java 환경 확인

`EnvironmentCheck`는 Java가 제공하는 loopback 주소를 출력하는 가장 작은 환경 확인 코드입니다.

```bash
build_dir="$(mktemp -d)"
javac -d "$build_dir" modules/00-environment/src/EnvironmentCheck.java
java -cp "$build_dir" EnvironmentCheck
rm -r "$build_dir"
```

확인한 출력은 `result: localhost/127.0.0.1`입니다. dev container에서 실행했으므로 이 주소는 Windows 전체나 WSL 배포판 전체가 아니라 현재 Java process가 속한 network namespace의 loopback을 가리킵니다.

## TCP 관찰 결과

OpenBSD `nc`로 `127.0.0.1:45678`에 listening socket을 만들고 다른 terminal에서 연결했습니다. client에는 ephemeral port `35166`이 할당되었습니다.

```text
127.0.0.1:35166 -> 127.0.0.1:45678 SYN
127.0.0.1:45678 -> 127.0.0.1:35166 SYN-ACK
127.0.0.1:35166 -> 127.0.0.1:45678 ACK
```

`hello`와 newline은 합계 6 bytes였고, TCP segment의 `length 6`과 다음 ACK에서 확인했습니다. client를 종료하자 양쪽에서 FIN을 보내고 마지막 ACK로 연결을 닫았습니다.

listening socket이 없는 port에 연결한 경우에는 대상 OS가 RST-ACK를 보내 즉시 거절하는 동작도 관찰했습니다. VS Code/dev container의 port 자동 감지가 흔히 쓰는 port에 먼저 연결할 수 있으므로, 실습에서는 `ss -lntp`로 실제 socket과 process를 함께 확인합니다.

## 패킷 캡처 명령

작은 TCP 연결을 만들고 별도 terminal에서 loopback traffic을 캡처할 때 사용합니다.

```bash
sudo tcpdump -i lo -nn 'tcp port 45678'
```

캡처에서 출발지/목적지 IP와 port, SYN, SYN-ACK, ACK, payload, FIN을 식별합니다.

## 회고 질문

- Windows의 `localhost`와 WSL의 `lo`는 항상 같은 network namespace를 의미하는가?
- `ss`가 보여 주는 socket과 `tcpdump`가 보여 주는 TCP segment는 어떻게 다른가?
- 애플리케이션이 `localhost`에 연결할 때 물리적 Ethernet frame이 반드시 만들어지는가?
