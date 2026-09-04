# Implementation Plan - Automated Daily Disk Snapshots

**Feature**: `015-automated-daily-disk-snapshots`  
**Branch**: `015-automated-daily-disk-snapshots`  
**Status**: In Progress  

## Architecture & Design

### Overview
This feature adds a declarative GCP Compute Resource Policy (`google_compute_resource_policy.nanoclaw_snapshot_policy`) in Terraform (`terraform/main.tf`) that performs daily snapshots of `google_compute_disk.agent_data` at 04:00 UTC with a 14-day max retention policy.

### Components
1. **GCP Resource Policy**: `google_compute_resource_policy.nanoclaw_snapshot_policy` with `snapshot_schedule_policy`:
   - `schedule`: `daily_schedule` with `days_in_cycle = 1`, `start_time = "04:00"`
   - `retention_policy`: `max_retention_days = 14`, `on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"`
2. **Disk Resource Policy Attachment**: `resource_policies = [google_compute_resource_policy.nanoclaw_snapshot_policy.name]` added to `google_compute_disk.agent_data`.

## Technical Strategy
- Edit `terraform/main.tf` to define `google_compute_resource_policy.nanoclaw_snapshot_policy` and attach it to `google_compute_disk.agent_data`.
- Run `terraform validate` inside `terraform/` directory to verify HCL syntax.
- Implement unit/validation test script `tests/test_snapshot_policy.sh` or `tests/test_snapshot_policy.py`.

## File Changes
- `specs/015-automated-daily-disk-snapshots/plan.md`
- `specs/015-automated-daily-disk-snapshots/research.md`
- `specs/015-automated-daily-disk-snapshots/data-model.md`
- `specs/015-automated-daily-disk-snapshots/quickstart.md`
- `specs/015-automated-daily-disk-snapshots/tasks.md`
- `terraform/main.tf`
- `tests/test_snapshot_policy.py`
