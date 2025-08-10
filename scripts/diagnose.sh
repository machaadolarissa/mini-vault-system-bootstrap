#!/usr/bin/env bash
set -euo pipefail

LOGFILE="system_report.log"
: > "$LOGFILE"

function log() {
  echo "$(date --utc +%Y-%m-%dT%H:%M:%SZ) - $*" | tee -a "$LOGFILE"
}

EXIT_CODE=0

log "Starting system diagnostics"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  log "OS: $NAME $VERSION"
else
  log "OS: unknown"
  EXIT_CODE=2
fi

KERNEL=$(uname -r || true)
log "Kernel: $KERNEL"

if command -v nvidia-smi >/dev/null 2>&1; then
  log "nvidia-smi found"
  SMI_OUT=$(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null || true)
  if [ -n "$SMI_OUT" ]; then
    log "GPU detected: $SMI_OUT"
  else
    log "nvidia-smi present but returned no GPUs"
    EXIT_CODE=3
  fi
else
  log "nvidia-smi not found — no NVIDIA GPU or driver not installed"
fi

if command -v nvidia-smi >/dev/null 2>&1; then
  DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || true)
  log "NVIDIA driver: ${DRIVER:-unknown}"
fi

if command -v nvcc >/dev/null 2>&1; then
  NVCC_VER=$(nvcc --version | tail -n1)
  log "nvcc: $NVCC_VER"
else
  if [ -d "/usr/local/cuda" ]; then
    if [ -f "/usr/local/cuda/version.txt" ]; then
      CUDA_VER=$(cat /usr/local/cuda/version.txt)
      log "CUDA (from /usr/local/cuda): $CUDA_VER"
    else
      log "CUDA directory exists but version file missing"
    fi
  else
    log "nvcc not found and /usr/local/cuda not present"
  fi
fi

if command -v docker >/dev/null 2>&1; then
  DOCKER_VER=$(docker --version 2>/dev/null || true)
  log "Docker: $DOCKER_VER"
  if docker info >/dev/null 2>&1; then
    log "Docker daemon: running"
  else
    log "Docker daemon: not accessible — check permissions"
    EXIT_CODE=4
  fi
else
  log "Docker: not installed"
  EXIT_CODE=4
fi

if command -v docker-compose >/dev/null 2>&1; then
  log "docker-compose: $(docker-compose --version)"
fi

log "Diagnostics completed"

exit "$EXIT_CODE"