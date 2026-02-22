#!/usr/bin/env bash
run_audio() {
  local msg

  if command -v systemctl &>/dev/null; then
    if systemctl -q is-active --user pipewire 2>/dev/null || systemctl -q is-active pipewire 2>/dev/null; then
      ok "pipewire" "PipeWire is running"
    else
      warn "pipewire" "PipeWire not running"
    fi
    if systemctl -q is-active --user wireplumber 2>/dev/null || systemctl -q is-active wireplumber 2>/dev/null; then
      ok "wireplumber" "WirePlumber is running"
    else
      info "wireplumber" "WirePlumber not running"
    fi
  else
    info "pipewire" "systemctl not available"
    info "wireplumber" "systemctl not available"
  fi

  if command -v pactl &>/dev/null; then
    msg=$(pactl get-default-sink 2>/dev/null) || msg=""
    if [[ -n "$msg" ]]; then
      ok "default_sink" "$msg"
    else
      warn "default_sink" "no default sink or pactl failed"
    fi
  else
    info "default_sink" "pactl not available"
  fi

  if command -v pw-cli &>/dev/null; then
    msg=$(pw-cli info all 2>/dev/null | grep -E 'rate|sample' | head -n1 || true)
    if [[ -n "$msg" ]]; then
      info "sample_rate" "$msg"
    else
      info "sample_rate" "pw-cli available but could not get sample rate"
    fi
  else
    info "sample_rate" "pw-cli not available"
  fi
}
