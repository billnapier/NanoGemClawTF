# Research: Native Systemd Docker Service Orchestration

## Key Findings

1. **Systemd Service vs Direct Docker Execution**: Running Docker containers via systemd services using `ExecStartPre` cleanup and `ExecStart=docker run ...` provides native OS-level lifecycle management, process monitoring, auto-restart policies, and unified `journalctl` log aggregation.
2. **Dependency Ordering**: Using `Requires=opt-nanoclaw-data.mount docker.service` ensures systemd halts service startup if either storage or Docker runtime is unavailable.
