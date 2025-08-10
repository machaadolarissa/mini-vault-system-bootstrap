#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "{\"error\": \"nvidia-smi not available\"}"
  exit 1
fi

nvidia-smi --query-gpu=index,name,temperature.gpu,memory.total,memory.used --format=csv,noheader,nounits | \
  awk -F', ' '{printf "{\"index\":%s, \"name\":\"%s\", \"temperature_c\":%s, \"memory_total_mb\":%s, \"memory_used_mb\":%s}\n", $1,$2,$3,$4,$5}'