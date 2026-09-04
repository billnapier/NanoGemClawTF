# Feature Specification: Native Systemd Container Daemon Orchestration

**Feature Branch**: `011-container-daemon-orchestration`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 3.4 of NanoGemClawTF Roadmap: Registration of native systemd service unit `nanoclaw-container.service` with strict `Requires=opt-nanoclaw-data.mount docker.service`, docker volume mounts, restart policies, and pre-start image pull.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Systemd Service Registration & Dependency Ordering (Priority: P1)

As a Systems Engineer, I want native systemd unit `/etc/systemd/system/nanoclaw-container.service` registered with `Requires=opt-nanoclaw-data.mount docker.service` and `After=opt-nanoclaw-data.mount docker.service`, so that the agent daemon only starts after storage and Docker engine are fully initialized.

**Why this priority**: Guarantees storage mount dependency enforcement before container runtime startup (Roadmap Phase 3.4).

**Independent Test**: Can be tested independently by running `systemctl show nanoclaw-container.service -p Requires` and inspecting dependencies.

**Acceptance Scenarios**:

1. **Given** `/etc/systemd/system/nanoclaw-container.service`, **When** `systemctl daemon-reload` and `systemctl enable --now nanoclaw-container.service` execute, **Then** systemd verifies mount and docker dependencies before launching container.

---

### User Story 2 - Container Runtime Execution & Volume Bindings (Priority: P2)

As a DevOps Operator, I want `ExecStart` to execute `docker run --rm --name nanogemclaw-agent` binding `--env-file /opt/nanoclaw/config/env.list`, `-v /opt/nanoclaw/data:/opt/nanoclaw/data`, and `-v /var/run/docker.sock:/var/run/docker.sock`, so that the agent harness accesses persistent state and tool execution capabilities.

**Why this priority**: Ensures container daemon has required volume access and socket binding for agent capabilities.

**Independent Test**: Can be tested independently by running `docker ps` and inspecting mounted volumes on running container `nanogemclaw-agent`.

**Acceptance Scenarios**:

1. **Given** active `nanoclaw-container.service`, **When** container runs, **Then** persistent data directory and docker socket are properly bound.

---

### User Story 3 - Pre-Start Image Pull & Auto-Restart Recovery (Priority: P3)

As a Systems Administrator, I want `ExecStartPre=/usr/bin/docker pull ${container_image}` and `Restart=always` with `RestartSec=10` configured in systemd service, so that daemon restarts automatically on failure and pulls the latest container image on service startup.

**Why this priority**: Implements automatic recovery and self-healing for container process crashes.

**Independent Test**: Can be tested independently by killing the container process (`docker kill nanogemclaw-agent`) and verifying systemd restarts it automatically within 10 seconds.

**Acceptance Scenarios**:

1. **Given** a killed or crashed agent container process, **When** container exits, **Then** systemd detects failure and automatically restarts daemon after 10 seconds.

---

### Edge Cases

- What happens if `opt-nanoclaw-data.mount` fails to mount?
  - `Requires=opt-nanoclaw-data.mount` causes systemd to refuse starting `nanoclaw-container.service`, protecting root storage.
- What happens if docker pull fails due to transient network error during service restart?
  - `ExecStartPre` fails, systemd retries service start according to `RestartSec=10` policy.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create unit file `/etc/systemd/system/nanoclaw-container.service`.
- **FR-002**: System MUST enforce unit directives `Requires=opt-nanoclaw-data.mount docker.service` and `After=opt-nanoclaw-data.mount docker.service`.
- **FR-003**: System MUST set `ExecStartPre=/usr/bin/docker pull ${container_image}`.
- **FR-004**: System MUST set `ExecStart` with `--env-file /opt/nanoclaw/config/env.list`, `-v /opt/nanoclaw/data:/opt/nanoclaw/data`, and `-v /var/run/docker.sock:/var/run/docker.sock`.
- **FR-005**: System MUST configure `Restart=always`, `RestartSec=10`, and enable unit on boot (`WantedBy=multi-user.target`).

### Key Entities

- **Systemd Service Unit**: File `/etc/systemd/system/nanoclaw-container.service`.
- **Docker Agent Container**: Container name `nanogemclaw-agent`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `systemctl is-active nanoclaw-container.service` returns `active`.
- **SC-002**: `docker ps` confirms container `nanogemclaw-agent` status is `Up`.
- **SC-003**: Simulated container termination results in automatic recovery within 15 seconds.
