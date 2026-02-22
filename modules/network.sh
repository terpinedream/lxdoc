#!/usr/bin/env bash
run_network() {
  local msg

  if command -v systemctl &>/dev/null; then
    if systemctl -q is-active NetworkManager 2>/dev/null; then
      ok "networkmanager" "NetworkManager is active"
    else
      info "networkmanager" "NetworkManager not active"
    fi
    if systemctl -q is-active systemd-networkd 2>/dev/null; then
      ok "systemd_networkd" "systemd-networkd is active"
    else
      info "systemd_networkd" "systemd-networkd not active"
    fi
  else
    info "networkmanager" "systemctl not available"
    info "systemd_networkd" "systemctl not available"
  fi

  if ip route get 1.1.1.1 &>/dev/null || ip route show default &>/dev/null; then
    msg=$(ip route show default 2>/dev/null | head -n1)
    ok "default_route" "${msg:-default route present}"
  else
    fail "default_route" "no default route"
  fi

  msg=$(ip -o -4 addr show scope global 2>/dev/null | awk '{ print $2 ": " $4 }' | head -n1) || msg=""
  if [[ -n "$msg" ]]; then
    ok "global_ip" "$msg"
  else
    warn "global_ip" "no interface with global IPv4"
  fi

  if command -v getent &>/dev/null; then
    if getent hosts example.com &>/dev/null; then
      ok "dns_resolution" "example.com resolves"
    else
      fail "dns_resolution" "example.com did not resolve"
    fi
  else
    info "dns_resolution" "getent not available"
  fi

  if command -v ping &>/dev/null; then
    if ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
      ok "icmp_test" "ICMP to 1.1.1.1 succeeded"
    else
      warn "icmp_test" "ICMP to 1.1.1.1 failed or timed out"
    fi
  else
    info "icmp_test" "ping not available"
  fi
}
