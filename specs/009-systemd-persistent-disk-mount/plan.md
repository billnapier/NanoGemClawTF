# Implementation Plan: Systemd Persistent Disk Mount Unit

## Technical Approach

Update `scripts/startup.sh` to initialize persistent block storage under `/opt/nanoclaw/data` using a native systemd mount unit (`/etc/systemd/system/opt-nanoclaw-data.mount`).

The script will:
1. Poll for device readiness at `/dev/disk/by-id/google-${persistent_disk_name}`.
2. Format `ext4` if unformatted (`mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0`).
3. Ensure `/opt/nanoclaw/data` directory exists with `0755` permissions.
4. Generate `/etc/systemd/system/opt-nanoclaw-data.mount`.
5. Run `systemctl daemon-reload` and `systemctl enable --now opt-nanoclaw-data.mount`.

## Proposed Changes

### `scripts/startup.sh`
- Update mount path to `/opt/nanoclaw/data`.
- Implement polling loop waiting for block device.
- Write systemd mount unit `/etc/systemd/system/opt-nanoclaw-data.mount`.
- Enable and start systemd mount unit.

## Verification Plan

1. Verify `startup.sh` shell syntax using `bash -n scripts/startup.sh`.
2. Run `cd terraform && terraform validate` to ensure `templatefile` rendering validity.
