#!/usr/bin/env bash
run_dev() {
  local msg

  if command -v gcc &>/dev/null; then
    msg=$(gcc --version 2>/dev/null | head -n1)
    ok "gcc" "$msg"
  else
    info "gcc" "gcc not found"
  fi

  if command -v clang &>/dev/null; then
    msg=$(clang --version 2>/dev/null | head -n1)
    ok "clang" "$msg"
  else
    info "clang" "clang not found"
  fi

  if [[ -r /usr/lib/libc.so.6 ]] || command -v ldconfig &>/dev/null; then
    msg=$(/usr/lib/libc.so.6 2>/dev/null | head -n1) || msg=""
    if [[ -z "$msg" ]] && command -v ldd &>/dev/null; then
      msg=$(ldd --version 2>/dev/null | head -n1)
    fi
    if [[ -n "$msg" ]]; then
      ok "glibc" "$msg"
    else
      info "glibc" "glibc version unknown"
    fi
  else
    info "glibc" "cannot determine glibc version"
  fi

  if command -v pkg-config &>/dev/null; then
    msg=$(pkg-config --version 2>/dev/null)
    ok "pkg_config" "pkg-config ${msg}"
  else
    info "pkg_config" "pkg-config not found"
  fi

  if [[ -d /usr/lib ]]; then
    local broken
    broken=$(find /usr/lib -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l) || broken=0
    if [[ "${broken:-0}" -gt 0 ]]; then
      warn "broken_symlinks_usr_lib" "${broken} broken symlink(s) under /usr/lib"
    else
      ok "broken_symlinks_usr_lib" "no broken symlinks under /usr/lib"
    fi
  else
    info "broken_symlinks_usr_lib" "/usr/lib not found or not readable"
  fi
}
