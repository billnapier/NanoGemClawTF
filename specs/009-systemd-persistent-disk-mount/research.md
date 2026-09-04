# Research: Systemd Mount Units vs Fstab

## Key Findings

1. **Naming Standard**: Systemd requires `.mount` files to match the destination path. Path `/opt/nanoclaw/data` requires filename `opt-nanoclaw-data.mount`.
2. **Systemd Integration**: Using systemd `.mount` unit files provides explicit dependency tracking (`Before=local-fs.target`, `WantedBy=local-fs.target`) ensuring storage mounts cleanly on boot before dependent services start.
