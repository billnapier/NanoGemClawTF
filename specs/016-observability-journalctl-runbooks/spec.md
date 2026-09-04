# Feature Specification: Observability, Journalctl Logging & Operational Runbooks

**Feature Branch**: `016-observability-journalctl-runbooks`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 4.4 of NanoGemClawTF Roadmap: Host logging via `journalctl`, system monitoring CLI tools, and comprehensive operational runbooks.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Systemd & Container Log Observability (Priority: P1)

As an Operations Engineer, I want container and systemd mount unit stdout/stderr streams captured cleanly by `journalctl` with structured metadata, so that system events can be queried and audited.

**Why this priority**: Primary diagnostic tool for investigating service failures, unauthorized access attempts, and startup issues.

**Independent Test**: Verified by running `journalctl -u nanoclaw-container.service -n 50` on the GCE host VM.

**Acceptance Scenarios**:

1. **Given** running container and mount services, **When** logs are queried via `journalctl -u nanoclaw-container.service`, **Then** formatted application events and logs are displayed without truncation.

---

### User Story 2 - Host Runtime Health Inspection (Priority: P2)

As a Systems Administrator, I want a single health inspection command or helper script that reports status for disk mounts, Secret Manager configs, and container daemon health.

**Why this priority**: Enables rapid status assessment without needing to manually run multiple disparate commands.

**Independent Test**: Executing the status inspection tool and validating output against active VM state.

**Acceptance Scenarios**:

1. **Given** an operational host VM, **When** health check tool is executed, **Then** tool displays structured status report showing systemd units, disk usage, container status, and Secret Manager synchronization state.

---

### User Story 3 - Operational Runbooks Documentation (Priority: P3)

As a Site Reliability Engineer, I want operational runbooks documented in `docs/runbooks.md` covering VM reboot recovery, snapshot restoration, secret rotation, and troubleshooting steps.

**Why this priority**: Ensures standard operating procedures exist for incident response, disaster recovery, and maintenance tasks.

**Independent Test**: Verified by reviewing `docs/runbooks.md` and dry-running documented troubleshooting procedures.

**Acceptance Scenarios**:

1. **Given** an operational incident or maintenance task, **When** engineer follows steps in `docs/runbooks.md`, **Then** procedure completes successfully with copy-paste ready CLI commands.

---

### Edge Cases

- What happens if host disk space fills up due to log file retention?
  - `systemd-journald` configuration enforces `SystemMaxUse=500M` retention cap to prevent disk exhaustion.
- What happens if GCP Secret Manager API is temporarily unavailable during secret rotation?
  - Runbook details fallback verification steps using existing cached `/opt/nanoclaw/config/env.list` credentials.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST route container `stdout` and `stderr` streams directly to systemd journal.
- **FR-002**: System MUST configure journal log retention limits (`SystemMaxUse=500M`) on host VM.
- **FR-003**: System MUST provide a health check command/script reporting status of `opt-nanoclaw-data.mount`, `nanoclaw-container.service`, and disk usage.
- **FR-004**: System MUST publish comprehensive operational runbooks in `docs/runbooks.md` covering:
  - Incident 1: Host reboot & disk mount recovery procedure.
  - Incident 2: Restoring SQLite state from GCP disk snapshot.
  - Incident 3: Secret rotation for `TELEGRAM_BOT_TOKEN` & `GEMINI_API_KEY`.
  - Incident 4: Container daemon troubleshooting & log inspection.
- **FR-005**: Operational documentation MUST remain perfectly synchronized with project constitution and quickstart guides.

### Key Entities

- **Journald Logging Subsystem**: Systemd logging daemon capturing unit logs.
- **Operational Runbooks**: Markdown guide detailing emergency and maintenance procedures.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `journalctl -u nanoclaw-container.service` returns clean log output within < 1 second.
- **SC-002**: Health check tool correctly identifies active vs degraded state across all host components.
- **SC-003**: `docs/runbooks.md` created with 100% executable commands and zero broken references.
