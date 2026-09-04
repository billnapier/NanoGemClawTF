# Feature Specification: GHCR Package Publication & Multi-Tagging Strategy

**Feature Branch**: `006-ghcr-container-registry-publishing`  
**Created**: 2026-09-04  
**Status**: Draft  
**Input**: Phase 2.2 of NanoGemClawTF Roadmap: Publication of built container images to GitHub Container Registry (GHCR) with multi-tagging (`latest`, commit SHA, date timestamp) and metadata provenance.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automated Image Publishing to GHCR (Priority: P1)

As a Maintainer, I want compiled container images published automatically to GitHub Container Registry (`ghcr.io`), so that host Compute Engine instances can pull immutable package artifacts.

**Why this priority**: Enables artifact storage and image availability for host VM deployment (Roadmap Phase 2.2).

**Independent Test**: Can be tested independently by running the publish workflow and checking GitHub Package Registry for the newly created package artifact.

**Acceptance Scenarios**:

1. **Given** a successful container build on `main` or via scheduled workflow, **When** publishing executes, **Then** the image is pushed to `ghcr.io/${{ github.repository_owner }}/nanogemclaw`.
2. **Given** workflow execution, **When** authenticating to GHCR, **Then** it authenticates using dynamic `GITHUB_TOKEN` with `packages: write` permissions.

---

### User Story 2 - Multi-Tagging Strategy (Priority: P2)

As a DevOps Engineer, I want published container images tagged with `latest`, the Git commit SHA (`sha-xxxxxxx`), and build date (`YYYYMMDD`), so that specific software revisions can be targeted or rolled back deterministically.

**Why this priority**: Guarantees traceability, versioning, and rollback capability across image releases.

**Independent Test**: Can be tested independently by inspecting the published image tags in GHCR package UI or via `docker pull`.

**Acceptance Scenarios**:

1. **Given** a completed publish step, **When** package tags are inspected, **Then** tags for `latest`, commit SHA, and date timestamp exist for the published container digest.

---

### User Story 3 - Image Provenance & Metadata Annotations (Priority: P3)

As a Security Officer, I want published container images enriched with standard OIDC metadata annotations and build provenance, so that container artifacts pass security audits.

**Why this priority**: Ensures zero-trust artifact traceability and compliance with repository security standards.

**Independent Test**: Can be tested independently by inspecting image OIDC annotations using `docker buildx imagetools inspect`.

**Acceptance Scenarios**:

1. **Given** published GHCR images, **When** image annotations are inspected, **Then** repository source URL, commit SHA, and OIDC provenance metadata are present.

---

### Edge Cases

- What happens if the package name collides with an existing restricted package?
  - Package publishing step uses standard lowercased repository owner scope `ghcr.io/${{ github.repository_owner }}/nanogemclaw`.
- How are permission issues handled if `GITHUB_TOKEN` lacks `packages: write` permission?
  - Workflow explicit `permissions` block defines `packages: write` to ensure workflow authorization.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST publish built container images to `ghcr.io/${{ github.repository_owner }}/nanogemclaw`.
- **FR-002**: System MUST apply tags `latest`, `${{ github.sha }}`, and timestamp `YYYYMMDD` using `docker/metadata-action`.
- **FR-003**: System MUST authenticate to GHCR using automatic `GITHUB_TOKEN` with `packages: write` and `contents: read` permissions.
- **FR-004**: System MUST attach standard OIDC build annotations and metadata to published package digests.
- **FR-005**: System MUST support lowercase conversion for registry image naming to comply with Docker URI standards.

### Key Entities

- **GHCR Package**: Published container package residing in `ghcr.io`.
- **Metadata Action**: Docker metadata configuration step (`docker/metadata-action`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of container build releases successfully push immutable package digests to GHCR.
- **SC-002**: Every published release includes `latest`, Git SHA, and date tags.
- **SC-003**: Zero hardcoded credentials or external registry tokens required for GHCR publishing.
