# Feature Specification: Disruption & Host Reboot Recovery Test

**Feature Branch**: `012-disruption-reboot-recovery-test`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 3.5 of NanoGemClawTF Roadmap: Forced VM reboot test, persistent storage state survival verification, systemd mount re-activation, and container daemon recovery signoff.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Forced VM Reboot Disruption Test (Priority: P1)

As a Site Reliability Engineer, I want host VM forced reboot (`sudo reboot` or GCP instance reset) executed during active state, so that system restart resilience can be evaluated under ungraceful conditions.

**Why this priority**: Core requirement for proving host reboot recovery and system robustness (Roadmap Phase 3.5).

**Independent Test**: Can be tested independently by issuing `gcloud compute instances reset` or `sudo reboot` on the host VM.

**Acceptance Scenarios**:

1. **Given** a running host VM instance, **When** instance is forcibly rebooted, **Then** host completes boot sequence within 60 seconds.

---

### User Story 2 - Persistent Mount Automatic Re-activation (Priority: P2)

As a Systems Administrator, I want `/opt/nanoclaw/data` mounted automatically post-reboot via `opt-nanoclaw-data.mount` without requiring manual SSH intervention or repair script execution.

**Why this priority**: Guarantees zero-touch mount recovery following hypervisor maintenance or VM reboot.

**Independent Test**: Can be tested independently by executing `findmnt /opt/nanoclaw/data` immediately following VM reboot.

**Acceptance Scenarios**:

1. **Given** host boot completion post-reboot, **When** systemd initializes targets, **Then** `opt-nanoclaw-data.mount` is active and storage directory is mounted.

---

### User Story 3 - SQLite Database State Retention Signoff (Priority: P3)

As a Database Administrator, I want state written to persistent disk (e.g. SQLite database files or test marker files) before reboot verified post-reboot with 100% data integrity and zero data loss.

**Why this priority**: Validates that agent memories, SQLite task queues, and user session state survive VM lifecycle disruptions.

**Independent Test**: Can be tested independently by writing a checksummed test file to `/opt/nanoclaw/data/test_marker.txt` pre-reboot and verifying its hash post-reboot.

**Acceptance Scenarios**:

1. **Given** a file written to `/opt/nanoclaw/data` prior to reboot, **When** checked post-reboot, **Then** file checksum matches 100%.

---

### Edge Cases

- What happens if disk mount unit fails during boot sequence post-reboot?
  - `Requires` dependency prevents container start; host serial log logs mount error for troubleshooting.
- What happens if container daemon is restarted multiple times quickly post-boot?
  - Systemd `RestartSec=10` rate limits restarts to prevent boot loop.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support automated or scripted host reboot testing via `gcloud compute instances reset` or guest OS reboot.
- **FR-002**: System MUST automatically re-mount `/opt/nanoclaw/data` via systemd `opt-nanoclaw-data.mount` upon boot.
- **FR-003**: System MUST automatically resume `nanoclaw-container.service` within 60 seconds post-boot.
- **FR-004**: System MUST preserve 100% of files and SQLite database state in `/opt/nanoclaw/data` across host resets.
- **FR-005**: System MUST log boot and mount status cleanly to `journalctl -u opt-nanoclaw-data.mount` and `journalctl -u nanoclaw-container.service`.

### Key Entities

- **Reboot Test Suite**: Script or manual test steps executing reboot and verifying checksums.
- **Data Retention Checksum**: Hash validation file stored on persistent disk.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Host VM completes boot and reports `nanoclaw-container.service` `active (running)` in under 60 seconds post-reboot.
- **SC-002**: Pre-reboot test data written to `/opt/nanoclaw/data` matches post-reboot checksum 100%.
- **SC-003**: Zero manual SSH commands required to bring storage or container daemon online after reboot.
