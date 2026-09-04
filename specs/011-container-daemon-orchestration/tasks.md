# Tasks: Systemd Container Daemon Orchestration

- [x] Task 1: Update `scripts/startup.sh` to generate `/etc/systemd/system/nanoclaw-container.service` with strict systemd dependencies
- [x] Task 2: Configure `ExecStartPre` docker pull and container cleanup in `nanoclaw-container.service`
- [x] Task 3: Configure `ExecStart` volume mounts (`/opt/nanoclaw/data` and `/var/run/docker.sock`) and `--env-file` binding
- [x] Task 4: Configure `Restart=always` and `RestartSec=10` auto-restart policy
- [x] Task 5: Execute `systemctl daemon-reload` and `systemctl enable --now nanoclaw-container.service` in `scripts/startup.sh`
- [x] Task 6: Verify bash syntax and terraform HCL validation
