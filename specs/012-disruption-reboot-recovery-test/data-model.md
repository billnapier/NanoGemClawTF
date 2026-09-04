# Data Model: Reboot Recovery Test Entity

## Entities

### Test Verification Script
- **Path**: `scripts/test_reboot_recovery.sh`
- **Actions**:
  - `pre-reboot`: Writes `/opt/nanoclaw/data/.reboot_marker` with timestamp and sha256 checksum.
  - `post-reboot`: Verifies `/opt/nanoclaw/data/.reboot_marker` checksum, systemd mount status, and container service status.
