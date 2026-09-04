# Feature Specification: Systemd Persistent Disk Mount Unit

**Feature Branch**: `009-systemd-persistent-disk-mount`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 3.2 of NanoGemClawTF Roadmap: Automatic formatting of 20GB persistent block device (`ext4`), provision of native systemd mount unit (`opt-nanoclaw-data.mount`), and mount enabling prior to daemon execution.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Block Device Formatting & Mount Directory Initialization (Priority: P1)

As a Systems Engineer, I want `startup.sh` to wait for block device `/dev/disk/by-id/google-agent-data` and format it with `ext4` if unformatted, so that storage is ready for mount registration without corrupting existing filesystems.

**Why this priority**: Core requirement for disk initialization and persistent storage readiness (Roadmap Phase 3.2).

**Independent Test**: Can be tested independently by running `blkid /dev/disk/by-id/google-agent-data` on initial boot and verifying `ext4` filesystem.

**Acceptance Scenarios**:

1. **Given** an unformatted persistent disk, **When** `startup.sh` runs, **Then** it executes `mkfs.ext4` safely.
2. **Given** an existing formatted persistent disk, **When** `startup.sh` runs, **Then** `blkid` detects the filesystem and skips re-formatting.

---

### User Story 2 - Systemd Mount Unit Registration (Priority: P2)

As a Systems Administrator, I want a native systemd mount unit `/etc/systemd/system/opt-nanoclaw-data.mount` registered and enabled, so that systemd manages disk mounting standardly across host reboots.

**Why this priority**: Replaces manual `fstab` edits with declarative systemd unit dependencies.

**Independent Test**: Can be tested independently by checking `systemctl status opt-nanoclaw-data.mount`.

**Acceptance Scenarios**:

1. **Given** `/etc/systemd/system/opt-nanoclaw-data.mount`, **When** `systemctl enable --now opt-nanoclaw-data.mount` executes, **Then** `/opt/nanoclaw/data` is mounted to `/dev/disk/by-id/google-agent-data`.

---

### User Story 3 - Storage Mount Isolation Guarantee (Priority: P3)

As a DevOps Engineer, I want host directory `/opt/nanoclaw/data` guaranteed to be a mount point before any agent daemon starts, so that SQLite databases are never accidentally written to root disk data overlay.

**Why this priority**: Protects against root disk bloat and data loss if disk fails to mount.

**Independent Test**: Can be tested independently by verifying `findmnt /opt/nanoclaw/data` returns non-empty output.

**Acceptance Scenarios**:

1. **Given** host boot process, **When** mount unit initializes, **Then** `findmnt /opt/nanoclaw/data` succeeds prior to docker daemon initialization.

---

### Edge Cases

- What happens if the block device enumeration takes more than 10 seconds?
  - `startup.sh` executes `until [ -b "$DISK_DEV" ]; do sleep 2; done` polling loop.
- What happens if host experiences ungraceful shutdown?
  - `ext4` filesystem options `discard,defaults,nofail` ensure journal recovery at boot.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST check `/dev/disk/by-id/google-agent-data` and format `ext4` with lazy journal initialization if unformatted.
- **FR-002**: System MUST register `/etc/systemd/system/opt-nanoclaw-data.mount` with `What=$DISK_DEV` and `Where=/opt/nanoclaw/data`.
- **FR-003**: System MUST set mount unit options `discard,defaults,nofail` and target `local-fs.target`.
- **FR-004**: System MUST reload systemd daemon (`systemctl daemon-reload`) and enable mount unit (`systemctl enable --now opt-nanoclaw-data.mount`).
- **FR-005**: System MUST ensure directory `/opt/nanoclaw/data` exists with `0755` permissions prior to mounting.

### Key Entities

- **Systemd Mount Unit**: File `/etc/systemd/system/opt-nanoclaw-data.mount`.
- **Persistent Storage Directory**: Directory `/opt/nanoclaw/data`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `systemctl is-active opt-nanoclaw-data.mount` returns `active`.
- **SC-002**: `findmnt /opt/nanoclaw/data` confirms block device is mounted as `ext4`.
- **SC-003**: Unformatted persistent disks format cleanly on first VM launch in under 15 seconds.
