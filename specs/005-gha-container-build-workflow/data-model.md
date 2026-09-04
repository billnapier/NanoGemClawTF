# Data Model & Workflow Entities: GitHub Actions Container Build Pipeline

**Feature Branch**: `005-gha-container-build-workflow`  
**Date**: 2026-09-04  
**Spec**: [spec.md](./spec.md)

---

## Key Entities & Schemas

### 1. Workflow Triggers (`ContainerBuildTriggers`)
- **Type**: YAML Configuration (`.github/workflows/build-container.yml`)
- **Triggers**:
  - `schedule`: Cron daily at UTC midnight (`0 0 * * *`)
  - `workflow_dispatch`: Manual execution trigger from GitHub UI / GitHub CLI (`gh workflow run`)
  - `pull_request`: Automated dry-run validation on PRs modifying `.github/workflows/build-container.yml`

### 2. Build Engine Configuration (`DockerBuildxConfig`)
- **Actions**:
  - `actions/checkout@v4`: Source retrieval step
  - `docker/setup-buildx-action@v3`: BuildKit setup step
  - `docker/build-push-action@v5`: Execution step
- **Build Parameters**:
  - `context`: Upstream checkout directory (`./NanoGemClaw` or root)
  - `push`: `false` (dry-run build verification step for spec 005 prior to GHCR publishing in spec 006)
  - `cache-from`: `type=gha`
  - `cache-to`: `type=gha,mode=max`

### 3. Workflow Validation State (`BuildValidationState`)
- **Success Criteria**:
  - Zero syntax/dependency errors
  - Execution runtime < 10 minutes
  - Exit code 0 on all trigger types
