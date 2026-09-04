# Data Model - Automated Daily Disk Snapshots

## Compute Resource Policy Schema
- `name`: `nanoclaw-snapshot-policy`
- `schedule`: Daily at `04:00` UTC
- `max_retention_days`: 14
- `on_source_disk_delete`: `KEEP_AUTO_SNAPSHOTS`
- `target_disk`: `google_compute_disk.agent_data` (`nanoclaw-data-disk`)
