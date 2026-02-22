#!/usr/bin/env bash
run_graphics() {
  local msg

  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    ok "session_type" "Wayland (WAYLAND_DISPLAY=${WAYLAND_DISPLAY})"
  elif [[ -n "${XDG_SESSION_TYPE:-}" ]]; then
    ok "session_type" "session type: ${XDG_SESSION_TYPE}"
  else
    info "session_type" "WAYLAND_DISPLAY and XDG_SESSION_TYPE unset"
  fi

  if [[ -r /proc/modules ]]; then
    msg=$(awk '{ print $1 }' /proc/modules | grep -E '^nvidia|^amdgpu|^i915|^radeon|^nouveau' | head -n5 | tr '\n' ' ')
    if [[ -n "$msg" ]]; then
      ok "gpu_driver" "loaded: ${msg}"
    else
      info "gpu_driver" "no common GPU driver module found in lsmod"
    fi
  else
    info "gpu_driver" "cannot read /proc/modules"
  fi

  if [[ -r /proc/modules ]] && grep -q '^llvmpipe' /proc/modules; then
    warn "llvmpipe" "llvmpipe (software rasterizer) is loaded"
  else
    ok "llvmpipe" "llvmpipe not loaded"
  fi

  if [[ -r /proc/modules ]]; then
    if grep -q '^nvidia' /proc/modules; then
      if grep -q 'nvidia_drm' /proc/modules && [[ -d /sys/module/nvidia_drm/parameters ]] && [[ -r /sys/module/nvidia_drm/parameters/modeset ]]; then
        local modeset
        modeset=$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || true)
        if [[ "$modeset" == "Y" ]]; then
          ok "nvidia_modeset" "nvidia-drm modeset enabled"
        else
          warn "nvidia_modeset" "nvidia-drm modeset disabled"
        fi
      else
        info "nvidia_modeset" "NVIDIA loaded; modeset status unknown"
      fi
    else
      info "nvidia_modeset" "NVIDIA not loaded"
    fi
  fi
}
