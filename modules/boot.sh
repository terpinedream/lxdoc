#!/usr/bin/env bash
run_boot() {
  local msg

  if command -v systemd-analyze &>/dev/null; then
    msg=$(systemd-analyze time 2>/dev/null) || msg=""
    if [[ -n "$msg" ]]; then
      ok "boot_time" "$msg"
    else
      warn "boot_time" "systemd-analyze time failed"
    fi
  else
    info "boot_time" "systemd-analyze not available"
  fi

  if command -v systemd-analyze &>/dev/null; then
    msg=$(systemd-analyze blame --no-pager 2>/dev/null | head -n5) || msg=""
    if [[ -n "$msg" ]]; then
      info "slowest_services" "top 5 slowest units (excerpt):"$'\n'"$msg"
    else
      info "slowest_services" "could not get blame output"
    fi
  else
    info "slowest_services" "systemd-analyze not available"
  fi

  if command -v systemctl &>/dev/null; then
    local failed
    failed=$(systemctl --failed --no-legend --no-pager 2>/dev/null | wc -l) || failed=0
    if [[ "${failed:-0}" -gt 0 ]]; then
      warn "failed_units" "${failed} failed unit(s)"
    else
      ok "failed_units" "no failed units"
    fi
  else
    info "failed_units" "systemctl not available"
  fi
}
