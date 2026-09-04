# Feature Specification: GCP Secret Manager Fetching & Host Environment Configuration

**Feature Branch**: `010-secret-manager-env-config`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 3.3 of NanoGemClawTF Roadmap: Host runtime GCP Secret Manager secret fetching via `gcloud` / VM service account, dynamic generation of `/opt/nanoclaw/config/env.list`, and strict permissions hardening (`chmod 600`).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Dynamic Secret Retrieval at Host Boot (Priority: P1)

As a Security Administrator, I want host startup script `startup.sh` to query GCP Secret Manager dynamically for `gemini-api-key` and `telegram-bot-token` using the VM service account identity, so that no secrets are baked into container images or terraform state files.

**Why this priority**: Core requirement for secure, keyless runtime secret injection (Roadmap Phase 3.3).

**Independent Test**: Can be tested independently by running `gcloud secrets versions access latest` on the host VM using VM service account identity.

**Acceptance Scenarios**:

1. **Given** GCP Secret Manager secrets `gemini-api-key` and `telegram-bot-token`, **When** `startup.sh` executes on boot, **Then** secret values are retrieved via metadata project ID lookup and `gcloud secrets versions access`.

---

### User Story 2 - Host Environment File Generation (Priority: P2)

As a Container Operator, I want secrets and host settings written to environment file `/opt/nanoclaw/config/env.list`, so that Docker container daemon can read configuration parameters via `--env-file`.

**Why this priority**: Formats runtime environment variables for clean Docker container binding.

**Independent Test**: Can be tested independently by inspecting `/opt/nanoclaw/config/env.list` contents on the VM host.

**Acceptance Scenarios**:

1. **Given** retrieved secrets and rendered Terraform variables, **When** written to `/opt/nanoclaw/config/env.list`, **Then** keys `GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`, `ALLOWED_USER_IDS`, `DATA_DIR`, `NODE_ENV`, and `LOG_LEVEL` are present.

---

### User Story 3 - Environment File Security Hardening (Priority: P3)

As a Systems Auditor, I want file permissions on `/opt/nanoclaw/config/env.list` locked to `chmod 600` owned by `root:root`, so that unprivileged local users or processes cannot read active API keys.

**Why this priority**: Enforces zero-trust file permissions on sensitive credentials storage.

**Independent Test**: Can be tested independently by running `ls -l /opt/nanoclaw/config/env.list` and confirming `-rw-------` permissions.

**Acceptance Scenarios**:

1. **Given** generated `/opt/nanoclaw/config/env.list`, **When** created by `startup.sh`, **Then** file mode is strictly set to `600` (`-rw-------`).

---

### Edge Cases

- What happens if Secret Manager access fails due to IAM propagation delay?
  - `gcloud secrets` call retries or script fails fast with set `-euo pipefail` alerting GCP Cloud Logging.
- What happens if secret content contains special characters like `$` or `"`?
  - Environment list writing uses unquoted EOF block or escapes special characters safely.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch GCP Project ID dynamically via compute metadata service (`http://metadata.google.internal/computeMetadata/v1/project/project-id`).
- **FR-002**: System MUST retrieve latest secret versions for `gemini-api-key` and `telegram-bot-token` using `gcloud secrets versions access latest`.
- **FR-003**: System MUST create directory `/opt/nanoclaw/config` if it does not exist.
- **FR-004**: System MUST write `/opt/nanoclaw/config/env.list` containing all required container environment variables.
- **FR-005**: System MUST enforce `chmod 600 /opt/nanoclaw/config/env.list`.

### Key Entities

- **Environment Config File**: Target file `/opt/nanoclaw/config/env.list`.
- **Secret Version Fetcher**: `gcloud secrets versions access` commands.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: File `/opt/nanoclaw/config/env.list` exists and contains non-empty API keys.
- **SC-002**: File permission is verified as `0600` (`-rw-------`).
- **SC-003**: Secret fetching executes successfully in under 5 seconds during VM boot.
