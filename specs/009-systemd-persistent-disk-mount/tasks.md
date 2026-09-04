# Tasks: Systemd Persistent Disk Mount Unit

- [x] Task 1: Update mount directory path to `/opt/nanoclaw/data` with `0755` permissions in `scripts/startup.sh`
- [x] Task 2: Implement block device polling loop (`until [ -b "$DISK_DEVICE" ]...`) and `ext4` formatting check in `scripts/startup.sh`
- [x] Task 3: Provision `/etc/systemd/system/opt-nanoclaw-data.mount` systemd unit file in `scripts/startup.sh`
- [x] Task 4: Execute `systemctl daemon-reload` and `systemctl enable --now opt-nanoclaw-data.mount` in `scripts/startup.sh`
- [x] Task 5: Verify bash syntax and terraform HCL validation
