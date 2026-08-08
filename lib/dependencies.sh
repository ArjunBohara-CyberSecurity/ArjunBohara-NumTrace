#!/usr/bin/env bash

numtrace_detect_pkg_manager() {
  if numtrace_have_cmd apt; then printf 'apt'; return 0; fi
  if numtrace_have_cmd pkg; then printf 'pkg'; return 0; fi
  if numtrace_have_cmd pacman; then printf 'pacman'; return 0; fi
  if numtrace_have_cmd dnf; then printf 'dnf'; return 0; fi
  if numtrace_have_cmd apk; then printf 'apk'; return 0; fi
  if numtrace_have_cmd brew; then printf 'brew'; return 0; fi
  printf 'unknown'
}

numtrace_dependency_line() {
  name=$1
  if numtrace_have_cmd "$name"; then
    printf '  %-10s ✓\n' "$name"
  else
    printf '  %-10s ✗\n' "$name"
  fi
}

numtrace_check_dependencies() {
  cat <<EOF
## Dependency Check
EOF
  numtrace_dependency_line curl
  numtrace_dependency_line jq
  numtrace_dependency_line openssl
  numtrace_dependency_line grep
  numtrace_dependency_line sed
  printf '\nOptional:\n'
  printf '  search provider: duckduckgo (default) ✓\n'
  printf '\nPackage manager: %s\n' "$(numtrace_detect_pkg_manager)"
  printf '\nInstall hints:\n'
  printf '  apt   : apt install curl jq openssl\n'
  printf '  pkg   : pkg install curl jq openssl\n'
  printf '  pacman: pacman -S curl jq openssl\n'
  printf '  dnf   : dnf install curl jq openssl\n'
  printf '  apk   : apk add curl jq openssl\n'
  printf '  brew  : brew install curl jq openssl\n'
}
