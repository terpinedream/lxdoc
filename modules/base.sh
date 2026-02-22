#!/usr/bin/env bash
run_base() {
  local msg

  msg=$(uname -r)
  ok "kernel" "$msg"

  if [[ -f /etc/os-release ]]; then
    msg=$(grep -E '^PRETTY_NAME=' /etc/os-release | sed "s/^PRETTY_NAME=//;s/^[\"']//;s/[\"']$//")
    ok "os_release" "${msg:-unknown}"
  else
    warn "os_release" "/etc/os-release not found"
  fi

  if [[ -r /proc/uptime ]]; then
    local sec_float sec
    read -r sec_float _ < /proc/uptime
    sec=${sec_float%%.*}
    local d=$((sec / 86400)) h=$((sec % 86400 / 3600)) m=$((sec % 3600 / 60))
    if [[ $d -gt 0 ]]; then
      msg="${d}d ${h}h ${m}m"
    elif [[ $h -gt 0 ]]; then
      msg="${h}h ${m}m"
    else
      msg="${m}m"
    fi
    ok "uptime" "$msg"
  else
    warn "uptime" "cannot read /proc/uptime"
  fi

  if df -P / &>/dev/null; then
    local pct
    pct=$(df -P / | awk 'NR==2 { gsub(/%/,""); print $5 }')
    if [[ -n "$pct" ]]; then
      if [[ "$pct" -ge 90 ]]; then
        warn "root_fs_usage" "root filesystem ${pct}% used"
      else
        ok "root_fs_usage" "root filesystem ${pct}% used"
      fi
    else
      info "root_fs_usage" "could not parse df output"
    fi
  else
    warn "root_fs_usage" "df failed"
  fi

  if [[ -r /proc/meminfo ]]; then
    local mem_total mem_avail swap_total swap_free
    mem_total=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
    mem_avail=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)
    swap_total=$(awk '/^SwapTotal:/ { print $2 }' /proc/meminfo)
    swap_free=$(awk '/^SwapFree:/ { print $2 }' /proc/meminfo)
    [[ -z "$mem_total" ]] && mem_total=0
    [[ -z "$mem_avail" ]] && mem_avail=0
    [[ -z "$swap_total" ]] && swap_total=0
    [[ -z "$swap_free" ]] && swap_free=0
    msg="Mem: $((mem_total / 1024))Mi total, $((mem_avail / 1024))Mi available; Swap: $((swap_total / 1024))Mi total, $((swap_free / 1024))Mi free"
    ok "memory_swap" "$msg"
  else
    warn "memory_swap" "cannot read /proc/meminfo"
  fi

  if command -v systemctl &>/dev/null; then
    local failed
    failed=$(systemctl --failed --no-legend --no-pager 2>/dev/null | wc -l) || failed=0
    if [[ "${failed:-0}" -gt 0 ]]; then
      warn "failed_units" "${failed} failed systemd unit(s)"
    else
      ok "failed_units" "no failed systemd units"
    fi
  else
    info "failed_units" "systemctl not available"
  fi

  if command -v journalctl &>/dev/null; then
    local err_count
    err_count=$(journalctl -b -p 3 --no-pager 2>/dev/null | wc -l) || err_count=0
    if [[ "${err_count:-0}" -gt 0 ]]; then
      info "journal_errors" "${err_count} priority 3 (error) lines since boot"
    else
      ok "journal_errors" "no priority 3 journal entries this boot"
    fi
  else
    info "journal_errors" "journalctl not available"
  fi
}
