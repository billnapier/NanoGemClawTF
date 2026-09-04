# Research - Automated Daily Disk Snapshots

## Terraform google_compute_resource_policy
```hcl
resource "google_compute_resource_policy" "nanoclaw_snapshot_policy" {
  name   = "nanoclaw-snapshot-policy"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }

    retention_policy {
      max_retention_days    = 14
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      labels = {
        environment = "production"
        managed_by  = "terraform"
      }
    }
  }
}
```
- Attachment: `resource_policies = [google_compute_resource_policy.nanoclaw_snapshot_policy.name]` inside `google_compute_disk`.
