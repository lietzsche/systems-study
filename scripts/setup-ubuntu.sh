#!/usr/bin/env bash

set -Eeuo pipefail

readonly REQUIRED_UBUNTU_VERSION="24.04"
readonly PACKAGES=(
  build-essential
  ca-certificates
  curl
  git
  iproute2
  jq
  lsof
  netcat-openbsd
  openjdk-21-jdk
  procps
  python3
  python3-pip
  python3-venv
  strace
  tcpdump
  time
)

log() {
  printf '[setup] %s\n' "$*"
}

fail() {
  printf '[setup] 오류: %s\n' "$*" >&2
  exit 1
}

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

log 'Ubuntu package 목록을 갱신합니다.'
sudo apt-get update

log '공통 언어와 시스템 관찰 도구를 설치합니다.'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}"

architecture="$(dpkg --print-architecture)"
java_home="/usr/lib/jvm/java-21-openjdk-${architecture}"
if [[ ! -x "$java_home/bin/java" || ! -x "$java_home/bin/javac" ]]; then
  fail "Java 21 설치 경로를 찾을 수 없습니다: $java_home"
fi

log '활성 java와 javac를 OpenJDK 21로 맞춥니다.'
sudo update-alternatives --set java "$java_home/bin/java"
sudo update-alternatives --set javac "$java_home/bin/javac"

log '기본 환경 설치가 끝났습니다. scripts/verify-environment.sh로 검증합니다.'
