#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="minivault-inference-stub:latest"
INPUT_FILE="data/input.json"
OUTPUT_FILE="data/output.json"
CONTAINER_NAME="minivault_inference_stub"

if [ ! -f Dockerfile ]; then
  echo "Dockerfile not found in current directory" >&2
  exit 1
fi

echo "Building container image..."
docker build -t "$IMAGE_NAME" .

if [ ! -f "$INPUT_FILE" ]; then
  echo "Input file '$INPUT_FILE' not found" >&2
  exit 2
fi

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Removing previous container instance..."
  docker rm -f "$CONTAINER_NAME" || true
fi

echo "Mounting input file: $(pwd)/data/input.json"

echo "Running container..."

docker run --rm --name "$CONTAINER_NAME" \
  -v "$(pwd)/data/input.json:/data/input.json:ro" \
  -v "$(pwd)/data/output.json:/data/output.json" \
  -v "$(pwd)/logs.jsonl:/logs.jsonl" \
  "$IMAGE_NAME"

if [ ! -f "$OUTPUT_FILE" ]; then
  echo "Container did not produce $OUTPUT_FILE" >&2
  exit 3
fi

echo "Inference stub completed, output at $OUTPUT_FILE"