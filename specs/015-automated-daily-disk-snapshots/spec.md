# Feature Specification: Automated Daily Disk Snapshots

**Feature Branch**: `015-automated-daily-disk-snapshots`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 4.3 of NanoGemClawTF Roadmap: Declarative Terraform IaC configuration of GCP Compute Resource Policy for automated daily snapshots of persistent disk with 14-day retention.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative Resource Policy IaC Provisioning (Priority: P1)

As a DevOps Engineer, I want a GCP Compute Resource Policy defined in Terraform (`main.tf`) that specifies an automated daily snapshot schedule for host storage, so that disk backup policies are managed as infrastructure code.

**Why this priority**: Core requirement for automated disaster recovery and data durability guarantees.

**Independent Test**: Verified by running `terraform plan` and `terraform apply` to provision `google_compute_resource_policy`.

**Acceptance Scenarios**:

1. **Given** Terraform configuration with `google_compute_resource_policy`, **When** `terraform apply` is executed, **Then** GCP resource policy is created with daily backup schedule and 14-day retention.

---

### User Story 2 - Policy Attachment to Persistent Data Disk (Priority: P2)

As a Systems Administrator, I want the automated snapshot policy attached to the persistent data disk (`nanoclaw-data-disk`) in Terraform configuration.

**Why this priority**: Connects the schedule policy to the actual physical storage volume hosting SQLite state and container data.

**Independent Test**: Verified by checking `gcloud compute disks describe` for `resourcePolicies` list containing the snapshot policy name.

**Acceptance Scenarios**:

1. **Given** provisioned resource policy and data disk, **When** attached via `resource_policies` attribute in `google_compute_disk`, **Then** disk description lists active snapshot schedule policy.

---

### User Story 3 - Snapshot Lifecycle & Retention Policy Verification (Priority: P3)

As a Cloud Architect, I want snapshots generated according to the daily schedule and automatically pruned after 14 days to prevent storage cost inflation.

**Why this priority**: Ensures data retention compliance while maintaining automated cleanup and predictable GCP storage costs.

**Independent Test**: Can be tested by describing snapshot policy details via `gcloud compute resource-policies describe <policy-name>`.

**Acceptance Scenarios**:

1. **Given** configured snapshot policy, **When** policy details are queried, **Then** retention policy specifies `maxRetentionDays: 14` and `onSourceDiskDelete: KEEP_AUTO_SNAPSHOTS`.

---

### Edge Cases

- What happens if the disk is recreated during infrastructure changes?
  - Terraform lifecycle rules maintain resource policy association upon disk recreation.
- What happens if disk I/O occurs during snapshot execution?
  - GCP persistent disk snapshotting is crash-consistent and executes asynchronously in the background without locking filesystem access.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Terraform configuration MUST define `google_compute_resource_policy` resource named `nanoclaw_snapshot_policy`.
- **FR-002**: Snapshot schedule MUST execute daily (`daily_schedule`) at off-peak UTC hours (e.g. 04:00 UTC).
- **FR-003**: Snapshot retention policy MUST retain snapshots for exactly 14 days (`max_retention_days = 14`).
- **FR-004**: Terraform configuration MUST attach `nanoclaw_snapshot_policy` to `google_compute_disk.nanoclaw_data_disk`.
- **FR-005**: Infrastructure changes MUST be fully compatible with `abcxyz/guardian` GitOps plan/apply pipeline.

### Key Entities

- **Compute Resource Policy**: GCP resource defining snapshot frequency and retention rule.
- **Persistent Disk Binding**: Terraform linkage connecting resource policy to persistent data volume.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `terraform plan` produces clean execution plan adding snapshot policy with 0 errors.
- **SC-002**: `gcloud compute resource-policies describe` confirms 14-day retention schedule active on GCP.
- **SC-003**: Persistent disk status shows attached resource policy in GCP console / CLI output.
