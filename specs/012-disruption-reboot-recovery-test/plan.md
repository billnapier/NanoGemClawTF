# Implementation Plan: Disruption & Host Reboot Recovery Test

## Technical Approach

Create a verification script `scripts/test_reboot_recovery.sh` that validates:
1. Active status of `opt-nanoclaw-data.mount` and `nanoclaw-container.service`.
2. Storage persistence by writing pre-reboot marker files with checksums and verifying post-reboot integrity.
3. Systemd dependency graph ordering and automatic recovery readiness.

## Proposed Changes

### `scripts/test_reboot_recovery.sh`
- Create test script to simulate pre-reboot marker writing and post-reboot data integrity check.

## Verification Plan

1. Verify `scripts/test_reboot_recovery.sh` syntax via `bash -n scripts/test_reboot_recovery.sh`.
2. Run `cd terraform && terraform validate`.
