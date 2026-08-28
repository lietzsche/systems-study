#!/usr/bin/env bash

set -uo pipefail

failures=0

pass() {
  printf '[PASS] %s\n' "$*"
}

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  failures=$((failures + 1))
}

if [[ -r /proc/sys/kernel/osrelease ]] && grep -qi 'WSL2' /proc/sys/kernel/osrelease; then
  pass "WSL 2: $(< /proc/sys/kernel/osrelease)"
else
  fail 'WSL 2 환경이 아닙니다.'
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" == 'ubuntu' && "${VERSION_ID:-}" == '24.04' ]]; then
    pass "운영체제: ${PRETTY_NAME}"
  else
    fail "Ubuntu 24.04가 아닙니다: ${PRETTY_NAME:-알 수 없음}"
  fi
else
  fail '/etc/os-release를 읽을 수 없습니다.'
fi

if command -v java >/dev/null 2>&1 && command -v javac >/dev/null 2>&1; then
  java_major="$(java -version 2>&1 | awk -F '[\".]' '/version/ { print $2; exit }')"
  if [[ "$java_major" == '21' ]]; then
    pass "Java: $(java -version 2>&1 | head -n 1)"
    pass "javac: $(javac -version 2>&1)"
  else
    fail "활성 Java major version이 21이 아닙니다: ${java_major:-알 수 없음}"
  fi
else
  fail 'java 또는 javac를 찾을 수 없습니다.'
fi

required_commands=(curl dig ethtool git ip lsof nc netstat openssl ping ps ss tcpdump traceroute)
missing_commands=()
for command_name in "${required_commands[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    missing_commands+=("$command_name")
  fi
done

if ((${#missing_commands[@]} == 0)); then
  pass '필수 네트워크 및 시스템 명령을 모두 찾았습니다.'
else
  fail "찾을 수 없는 명령: ${missing_commands[*]}"
fi

if command -v ip >/dev/null 2>&1; then
  printf '\n--- interface 요약 ---\n'
  ip -brief address || fail '`ip -brief address` 실행에 실패했습니다.'
  printf '\n--- routing table ---\n'
  ip route || fail '`ip route` 실행에 실패했습니다.'
fi

if ((failures > 0)); then
  printf '\n환경 검증 실패: %d개 항목을 확인하세요.\n' "$failures" >&2
  exit 1
fi

printf '\n환경 검증을 통과했습니다. tcpdump 캡처에는 sudo 권한이 필요합니다.\n'
