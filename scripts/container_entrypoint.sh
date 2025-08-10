#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="/data/input.json"
OUTPUT_FILE="/data/output.json"
LOG_FILE="/logs.jsonl"

log_json(){
  local ts level component message extra
  ts="$(date --utc +%Y-%m-%dT%H:%M:%SZ)"
  level="$1"; shift
  component="$1"; shift
  message="$1"; shift || true
  extra="$*"
  printf '{"timestamp":"%s","level":"%s","component":"%s","message":"%s"' "$ts" "$level" "$component" "$message" >> "$LOG_FILE"
  if [ -n "$extra" ]; then
    printf ',%s' "$extra" >> "$LOG_FILE"
  fi
  printf '}\n' >> "$LOG_FILE"
}

log_json "INFO" "inference" "Inference stub started"

if [ ! -f "$INPUT_FILE" ]; then
  log_json "ERROR" "inference" "Input file missing" "\"input_file\":\"$INPUT_FILE\""
  echo "Input file not found: $INPUT_FILE" >&2
  exit 2
fi

sleep 1

if command -v jq >/dev/null 2>&1; then
  MODEL=$(jq -r '.model // "unknown"' "$INPUT_FILE")
  PROMPT=$(jq -r '.prompt // ""' "$INPUT_FILE")
else
  MODEL="unknown"
  PROMPT=""
fi

cat > "$OUTPUT_FILE" <<EOF
{
  "model": "$MODEL",
  "input_prompt": "$PROMPT",
  "result": "This is a stubbed inference response",
  "timestamp": "$(date --utc +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

log_json "INFO" "inference" "Model processing completed" "\"model\":\"$MODEL\",\"duration_ms\":1000"

echo "Inference stub wrote $OUTPUT_FILE"