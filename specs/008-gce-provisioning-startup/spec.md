# Feature Specification: Compute Engine Provisioning & Startup Harness

**Feature Branch**: `008-gce-provisioning-startup`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 3.1 of NanoGemClawTF Roadmap: Provisioning GCE `e2-small` VM instance, attaching persistent data disk, associating runtime service account, and linking `startup.sh` execution template.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative GCE VM Provisioning (Priority: P1)

As an Infrastructure Engineer, I want Terraform to declaratively provision an `e2-small` Compute Engine VM instance (`nanoclaw-gemini-agent`) with Debian 12 boot disk and runtime SA bindings, so that agent hosting infrastructure is created automatically during Guardian `terraform apply`.

**Why this priority**: Core requirement for hosting the agent daemon on GCP (Roadmap Phase 3.1).

**Independent Test**: Can be tested independently by running `terraform plan` and `terraform apply` to verify VM provisioning in GCP Console.

**Acceptance Scenarios**:

1. **Given** `terraform/main.tf`, **When** `google_compute_instance.nanoclaw_vm` is applied, **Then** an `e2-small` instance is created running Debian 12.
2. **Given** the VM configuration, **When** inspected, **Then** it binds the runtime service account (`nanoclaw-agent-runtime-sa`) with `cloud-platform` access scope.

---

### User Story 2 - Persistent Disk Attachment (Priority: P2)

As a DevOps Engineer, I want the 20GB persistent disk (`nanoclaw-data-disk`) attached to the Compute Engine VM as block device `agent-data`, so that host startup scripts can mount persistent agent state.

**Why this priority**: Ensures persistent disk device is available to the OS block device enumeration at boot.

**Independent Test**: Can be tested independently by inspecting `attached_disk` block in Terraform plan and verifying `/dev/disk/by-id/google-agent-data` on the running instance.

**Acceptance Scenarios**:

1. **Given** `google_compute_instance.nanoclaw_vm`, **When** disk block is provisioned, **Then** `attached_disk` specifies device name `agent-data` in `READ_WRITE` mode.

---

### User Story 3 - Startup Script Template Injection (Priority: P3)

As a Systems Administrator, I want `metadata_startup_script` configured using `templatefile("${path.module}/scripts/startup.sh", ...)` passing `allowed_user_ids` and `container_image`, so that host boot script receives dynamic Terraform variables.

**Why this priority**: Enables dynamic variable injection into host OS initialization without hardcoded script values.

**Independent Test**: Can be tested independently by inspecting instance metadata in GCP to verify rendered startup script content.

**Acceptance Scenarios**:

1. **Given** instance metadata startup script, **When** VM boots, **Then** template parameters `${allowed_user_ids}` and `${container_image}` are fully rendered.

---

### Edge Cases

- What happens if the `e2-small` machine type is unavailable in the target zone?
  - Terraform variable `zone` allows override to an alternate zone in the same GCP region.
- What happens if disk device enumeration is delayed during VM boot?
  - `startup.sh` includes retry polling loop waiting for block device presence.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provision GCE instance `nanoclaw-gemini-agent` with machine type `e2-small` in `terraform/main.tf`.
- **FR-002**: System MUST attach `google_compute_disk.agent_data` to the VM with device name `agent-data`.
- **FR-003**: System MUST bind `google_service_account.agent_sa` to the instance with `cloud-platform` scopes.
- **FR-004**: System MUST inject `terraform/scripts/startup.sh` via `templatefile` supplying `allowed_user_ids` and `container_image`.
- **FR-005**: System MUST configure outbound public IP interface for Gemini API calling and bot polling.

### Key Entities

- **Compute Instance**: Terraform resource `google_compute_instance.nanoclaw_vm`.
- **Startup Script**: Shell script `terraform/scripts/startup.sh`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `terraform plan` confirms zero errors for VM resource provisioning.
- **SC-002**: VM instance reaches `RUNNING` status within 120 seconds of apply.
- **SC-003**: Startup script metadata is correctly populated with dynamic Terraform variables.
