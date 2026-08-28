#!/usr/bin/env bash

set -Eeuo pipefail

readonly REQUIRED_UBUNTU_VERSION="24.04"
readonly PACKAGES=(
  ca-certificates
  curl
  dnsutils
  ethtool
  git
  iproute2
  iputils-ping
  lsof
  net-tools
  netcat-openbsd
  openjdk-21-jdk
  openssl
  procps
  tcpdump
  traceroute
)

log() {
  printf '[setup] %s\n' "$*"
}

fail() {
  printf '[setup] 오류: %s\n' "$*" >&2
  exit 1
}

if [[ ! -r /proc/sys/kernel/osrelease ]] ||
  ! grep -qi microsoft /proc/sys/kernel/osrelease; then
  fail '이 스크립트는 WSL 2의 Ubuntu에서 실행해야 합니다.'
fi

if ! grep -qi 'WSL2' /proc/sys/kernel/osrelease; then
  fail 'WSL 1이 감지되었습니다. PowerShell에서 해당 배포판을 WSL 2로 전환하세요.'
fi

if [[ ! -r /etc/os-release ]]; then
  fail '/etc/os-release를 읽을 수 없습니다.'
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != 'ubuntu' || "${VERSION_ID:-}" != "$REQUIRED_UBUNTU_VERSION" ]]; then
  fail "Ubuntu ${REQUIRED_UBUNTU_VERSION}가 필요합니다. 현재 환경: ${PRETTY_NAME:-알 수 없음}"
fi

if ! command -v sudo >/dev/null 2>&1; then
  fail 'sudo를 찾을 수 없습니다.'
fi

log '패키지 목록을 갱신합니다.'
sudo apt-get update

log 'Java 21과 네트워크 관찰 도구를 설치합니다.'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}"

architecture="$(dpkg --print-architecture)"
java_home="/usr/lib/jvm/java-21-openjdk-${architecture}"
if [[ ! -x "$java_home/bin/java" || ! -x "$java_home/bin/javac" ]]; then
  fail "Java 21 설치 경로를 찾을 수 없습니다: $java_home"
fi

log '활성 java와 javac를 OpenJDK 21로 맞춥니다.'
sudo update-alternatives --set java "$java_home/bin/java"
sudo update-alternatives --set javac "$java_home/bin/javac"

java_major="$(java -version 2>&1 | awk -F '[\".]' '/version/ { print $2; exit }')"
if [[ "$java_major" != '21' ]]; then
  fail "설치 후 활성 Java major version이 21이 아닙니다: ${java_major:-알 수 없음}"
fi

log '설치가 끝났습니다. 이어서 ./scripts/verify-environment.sh 를 실행하세요.'
