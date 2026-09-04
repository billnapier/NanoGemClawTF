# Implementation Plan - Observability, Journalctl Logging & Operational Runbooks

**Feature**: `016-observability-journalctl-runbooks`  
**Branch**: `016-observability-journalctl-runbooks`  
**Status**: In Progress  

## Architecture & Design

### Overview
This feature completes system observability, journald log retention configuration (`SystemMaxUse=500M`), unified host health check tooling (`scripts/health_check.sh`), and detailed operational runbooks (`docs/runbooks.md`).

### Components
1. **Journald Retention Policy**: Host configuration setting `SystemMaxUse=500M` in systemd journal config during VM startup (`scripts/startup.sh`).
2. **Host Health Check Tool**: `scripts/health_check.sh` inspecting status of `opt-nanoclaw-data.mount`, `nanoclaw-container.service`, disk space, and Secret Manager env configuration.
3. **Operational Runbooks**: `docs/runbooks.md` with step-by-step incident response procedures for reboot recovery, snapshot restore, secret rotation, and journalctl log inspection.

## Technical Strategy
- Update `scripts/startup.sh` to write `/etc/systemd/journald.conf.d/nanoclaw-journal.conf` with `SystemMaxUse=500M`.
- Implement `scripts/health_check.sh`.
- Create `docs/runbooks.md`.
- Add test harness `tests/test_observability_and_runbooks.py` verifying health check script execution and runbook documentation integrity.

## File Changes
- `specs/016-observability-journalctl-runbooks/plan.md`
- `specs/016-observability-journalctl-runbooks/research.md`
- `specs/016-observability-journalctl-runbooks/data-model.md`
- `specs/016-observability-journalctl-runbooks/quickstart.md`
- `specs/016-observability-journalctl-runbooks/tasks.md`
- `scripts/startup.sh`
- `scripts/health_check.sh`
- `docs/runbooks.md`
- `tests/test_observability_and_runbooks.py`
