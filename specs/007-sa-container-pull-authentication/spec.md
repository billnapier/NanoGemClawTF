# Feature Specification: Compute Engine SA Container Pull & Image Verification

**Feature Branch**: `007-sa-container-pull-authentication`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 2.3 of NanoGemClawTF Roadmap: Integration of published GHCR image URI into Terraform variables, verification of Compute Engine service account image pull access, and live container deployment on GCE host.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative Terraform Container Image Variable Binding (Priority: P1)

As an Infrastructure Engineer, I want the Terraform variable `container_image` updated to default to the published GHCR package URI (`ghcr.io/<owner>/nanogemclaw:latest`), so that infrastructure deployments pull the live NanoGemClaw agent container by default.

**Why this priority**: Connects IaC configuration directly to the published container registry artifact (Roadmap Phase 2.3).

**Independent Test**: Can be tested independently by running `terraform plan` and verifying that `container_image` defaults to the GHCR package URI.

**Acceptance Scenarios**:

1. **Given** `terraform/variables.tf`, **When** `container_image` default is evaluated, **Then** it references `ghcr.io/<owner>/nanogemclaw:latest` (or configurable variable).
2. **Given** custom image override via `TF_VAR_container_image`, **When** specified, **Then** Terraform respects the override value cleanly.

---

### User Story 2 - GCE Service Account Registry Pull Access (Priority: P2)

As a Security Engineer, I want package access control for the GHCR package configured so that the Compute Engine runtime service account (`nanoclaw-agent-runtime-sa`) or VM host can pull the container image without manual authentication failures, so that host provisioning succeeds seamlessly.

**Why this priority**: Guarantees zero-friction automated image pulls during VM startup and systemd restart.

**Independent Test**: Can be tested independently by executing `docker pull <ghcr_image_uri>` on a test VM using host credentials or public package settings.

**Acceptance Scenarios**:

1. **Given** a Compute Engine VM executing `startup.sh`, **When** `docker pull ${container_image}` runs in `ExecStartPre`, **Then** the pull succeeds with 0 authorization errors.

---

### User Story 3 - Host Runtime Live Container Deployment Verification (Priority: P3)

As a Systems Operator, I want `nanoclaw-container.service` to start the live NanoGemClaw container daemon successfully on the GCE host, replacing the temporary fallback image (`alpine:latest`), so that Phase 2 milestone completion is validated end-to-end.

**Why this priority**: Validates host daemon startup with real agent software binaries.

**Independent Test**: Can be tested independently by checking host systemd status (`systemctl status nanoclaw-container.service`) and container logs (`docker logs nanogemclaw-agent`).

**Acceptance Scenarios**:

1. **Given** a deployed Compute Engine VM via Guardian `terraform apply`, **When** VM boots, **Then** `nanoclaw-container.service` is `active (running)` with the real GHCR image container running.

---

### Edge Cases

- What happens if the package visibility is set to private on GitHub?
  - Documentation and startup script provide configuration steps for GHCR read token authentication or setting package visibility to public for seamless pulling.
- How does system recover if an invalid container tag is passed to `TF_VAR_container_image`?
  - `ExecStartPre` fails to pull image, systemd logs descriptive pull failure, and previous running container (if present) is retained until valid image is supplied.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST update `terraform/variables.tf` default `container_image` value to reference GHCR URI `ghcr.io/<owner>/nanogemclaw:latest`.
- **FR-002**: System MUST document and enforce GHCR package pull access requirements for Compute Engine host service account.
- **FR-003**: System MUST update `terraform/scripts/startup.sh` if necessary to support seamless registry pull verification.
- **FR-004**: System MUST validate end-to-end container deployment via Guardian CI/CD `terraform apply`.

### Key Entities

- **Container Image Variable**: Terraform variable `container_image` in `terraform/variables.tf`.
- **Host Container Service**: Native systemd service unit `nanoclaw-container.service`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `terraform plan` confirms default `container_image` points to GHCR image URI.
- **SC-002**: Compute Engine VM pulls live GHCR image with 0 authorization or registry errors.
- **SC-003**: `nanoclaw-container.service` reports `active (running)` state in host serial console logs.
