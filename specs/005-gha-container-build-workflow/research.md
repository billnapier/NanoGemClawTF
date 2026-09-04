# Research Document: GitHub Actions Container Build Pipeline

**Feature Branch**: `005-gha-container-build-workflow`  
**Date**: 2026-09-04  
**Spec**: [spec.md](./spec.md)

---

## 1. Research Overview & Key Decisions

### Decision 1: Build Automation via GitHub Actions & Docker Buildx
- **Decision**: Implement `.github/workflows/build-container.yml` using `docker/setup-buildx-action@v3` and `docker/build-push-action@v5`.
- **Rationale**: standardizing on Buildx unlocks multi-stage build optimizations, parallel layer compilation, and standard GitHub Actions layer caching (`type=gha`).
- **Alternatives Considered**: Direct `docker build` command execution in runner bash scripts (rejected due to lack of standard layer cache persistence across GHA runner invocations).

### Decision 2: Upstream Source Checkout Strategy
- **Decision**: Use `actions/checkout@v4` to check out `https://github.com/Rlin1027/NanoGemClaw` (with configurable repo parameter defaulting to `Rlin1027/NanoGemClaw`).
- **Rationale**: Ensures the latest official NanoGemClaw codebase is retrieved continuously for container compilation without hardcoding internal paths.
- **Alternatives Considered**: Bundling NanoGemClaw inline within this terraform repo (rejected to preserve separation of IaC repository and application repository).

### Decision 3: Layer Cache Optimization Strategy
- **Decision**: Configure `cache-from: type=gha` and `cache-to: type=gha,mode=max`.
- **Rationale**: Reuses unchanged base and dependency layers across scheduled and manual runs, reducing compilation overhead and runtime below the 10-minute target (SC-001, SC-003).
- **Alternatives Considered**: In-line registry caching (rejected for build-only workflows that do not push to registry in step 005).

### Decision 4: Automated PR Validation Triggers
- **Decision**: Include `pull_request` trigger watching changes to `.github/workflows/build-container.yml`.
- **Rationale**: Validates that changes to the workflow or build configuration do not break container compilation prior to merging into `main`.
- **Alternatives Considered**: Running container build on every PR for all files (rejected to save CI runtime when only terraform files or markdown docs are changed).
