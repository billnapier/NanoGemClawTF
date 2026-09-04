# Data Model: Systemd Mount Unit Infrastructure Entities

## Entities

### Systemd Mount Unit File
- **Path**: `/etc/systemd/system/opt-nanoclaw-data.mount`
- **What**: `/dev/disk/by-id/google-${persistent_disk_name}`
- **Where**: `/opt/nanoclaw/data`
- **Type**: `ext4`
- **Options**: `discard,defaults,nofail`

### Host Mount Directory
- **Path**: `/opt/nanoclaw/data`
- **Permissions**: `0755`
