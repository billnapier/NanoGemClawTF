# Implementation Plan: Systemd Container Daemon Orchestration

## Technical Approach

Update `scripts/startup.sh` to generate native systemd service `/etc/systemd/system/nanoclaw-container.service` that enforces strict dependencies on `opt-nanoclaw-data.mount` and `docker.service`, pulls the container image on pre-start, binds `--env-file /opt/nanoclaw/config/env.list` and volumes (`/opt/nanoclaw/data` and `/var/run/docker.sock`), and enables auto-restart (`Restart=always`, `RestartSec=10`).

## Proposed Changes

### `scripts/startup.sh`
- Create systemd service unit `/etc/systemd/system/nanoclaw-container.service`.
- Enable and start `nanoclaw-container.service` (`systemctl daemon-reload && systemctl enable --now nanoclaw-container.service`).

## Verification Plan

1. Verify `scripts/startup.sh` bash syntax via `bash -n scripts/startup.sh`.
2. Run `cd terraform && terraform validate` to ensure template compatibility.
