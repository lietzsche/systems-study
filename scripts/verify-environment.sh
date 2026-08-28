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

check_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    pass "command: $command_name"
  else
    fail "command를 찾을 수 없습니다: $command_name"
  fi
}

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

for command_name in \
  curl gcc git ip jq lsof nc ps python3 ss strace tcpdump; do
  check_command "$command_name"
done

if command -v python3 >/dev/null 2>&1; then
  pass "Python: $(python3 --version 2>&1)"
fi

printf '\n--- process와 resource limit 요약 ---\n'
printf 'pid=%s shell=%s\n' "$$" "${SHELL:-알 수 없음}"
printf 'open-files-limit=%s\n' "$(ulimit -n)"

if ((failures > 0)); then
  printf '\n환경 검증 실패: %d개 항목을 확인하세요.\n' "$failures" >&2
  exit 1
fi

printf '\n시스템 실험 환경 검증을 통과했습니다.\n'
