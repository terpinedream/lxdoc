#!/usr/bin/env bash
run_fs() {
  local pct

  if df -P / &>/dev/null; then
    pct=$(df -P / | awk 'NR==2 { gsub(/%/,""); print $5 }')
    if [[ -n "$pct" ]] && [[ "$pct" =~ ^[0-9]+$ ]]; then
      if [[ "$pct" -ge 90 ]]; then
        warn "disk_usage" "root filesystem ${pct}% used (>= 90%)"
      else
        ok "disk_usage" "root filesystem ${pct}% used"
      fi
    else
      info "disk_usage" "could not parse df output for /"
    fi
  else
    info "disk_usage" "df failed"
  fi

  if [[ -d /usr ]] && [[ -r /usr ]]; then
    local inodes_total inodes_used
    inodes_total=$(df -i / 2>/dev/null | awk 'NR==2 { print $2 }')
    inodes_used=$(df -i / 2>/dev/null | awk 'NR==2 { print $3 }')
    if [[ -n "$inodes_total" ]] && [[ -n "$inodes_used" ]] && [[ "$inodes_total" -gt 0 ]]; then
      local pct_i=$((inodes_used * 100 / inodes_total))
      if [[ $pct_i -ge 90 ]]; then
        warn "inode_exhaustion" "inode use ${pct_i}% on /"
      else
        ok "inode_exhaustion" "inode use ${pct_i}% on /"
      fi
    else
      info "inode_exhaustion" "could not get inode usage"
    fi
  fi

  if command -v pacman &>/dev/null; then
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null | wc -l) || orphans=0
    if [[ "${orphans:-0}" -gt 0 ]]; then
      info "orphaned_pacman" "${orphans} orphaned package(s)"
    else
      ok "orphaned_pacman" "no orphaned pacman packages"
    fi
  else
    info "orphaned_pacman" "pacman not available"
  fi

  if [[ -d /etc ]]; then
    local ww
    ww=$(find /etc -type f -perm -0002 2>/dev/null | wc -l) || ww=0
    if [[ "${ww:-0}" -gt 0 ]]; then
      warn "world_writable_etc" "${ww} world-writable file(s) in /etc"
    else
      ok "world_writable_etc" "no world-writable files in /etc"
    fi
  else
    info "world_writable_etc" "/etc not found"
  fi
}
