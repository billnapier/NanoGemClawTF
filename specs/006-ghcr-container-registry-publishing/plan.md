# Implementation Plan: GHCR Package Publication & Multi-Tagging Strategy

## Overview
Update `.github/workflows/build-container.yml` to authenticate with `ghcr.io`, extract multi-tag metadata via `docker/metadata-action`, and push built container images to GitHub Container Registry (`ghcr.io/${{ github.repository_owner }}/nanogemclaw`).

## Architecture & Workflow Changes
1. **Triggers & Permissions**:
   - Add `packages: write` to workflow permissions block.
   - Add `push: branches: [main]` trigger to workflow triggers.
2. **Metadata Extraction Step**:
   - Add `docker/metadata-action@v5` step before build & push step.
   - Configure image name `ghcr.io/${{ github.repository_owner }}/nanogemclaw`.
   - Configure tags for `latest`, `sha-<commit>`, and `YYYYMMDD`.
3. **Registry Authentication**:
   - Add `docker/login-action@v3` step using `ghcr.io`, `github.actor`, and `GITHUB_TOKEN`.
4. **Build and Push Step**:
   - Update `docker/build-push-action@v5` with `push: ${{ github.event_name != 'pull_request' }}`.
   - Bind tags and labels from `docker/metadata-action` outputs.

## Validation Plan
- Verify GHA workflow syntax using `gh workflow view` or action check syntax.
- Verify job execution on PR check and main merge.
