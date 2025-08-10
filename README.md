
# MiniVault System Bootstrap

## Overview

This repo contains a minimal prototype to bootstrap a local ModelVault appliance. It includes system diagnostics, a minimal inference container stub, structured JSONL logs, and a simple GPU health monitor.

### Files
- `diagnose.sh` — System diagnostic script that writes `system_report.log`.
- `run_inference_stub.sh` — Builds and runs a Docker container that simulates a model inference.
- `Dockerfile` + `container_entrypoint.sh` — Model container implementation.
- `input.json` — Sample input payload.
- `logs.jsonl` — Example JSONL log with an inference event.
- `gpu_health.sh` — (optional) outputs GPU metrics as JSON.

## Setup (Ubuntu 22.04 LTS)

1. Install dependencies:

```bash
sudo apt update && sudo apt install -y docker.io jq curl
sudo usermod -aG docker $USER
# Log out and back in or run newgrp docker to use docker without sudo
```

2. Run diagnostics:

```bash
chmod +x scripts/diagnose.sh
./scripts/diagnose.sh
# Check system_report.log
cat system_report.log
```

3. Build and run the inference stub container:

```bash
chmod +x scripts/run_inference_stub.sh
# Ensure input.json is present in the data/ directory
sudo ./scripts/run_inference_stub.sh
# Check output.json and logs.jsonl
cat data/output.json
cat logs.jsonl
```

4. GPU health monitor (optional):

```bash
chmod +x scripts/gpu_health.sh
./scripts/gpu_health.sh
```

## Notes

- If running in a VM without GPU passthrough, `nvidia-smi` will not be available — the scripts handle this gracefully.
- Docker may require user permission updates; consult Docker docs for post-installation steps.