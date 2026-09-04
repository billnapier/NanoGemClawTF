# Quickstart Guide: GHCR Container Registry Publishing

## Overview
This guide documents how to trigger and verify automated container image publishing to GitHub Container Registry (GHCR).

## Automated Execution
Container publishing runs automatically on:
- **Push to `main`**: Publishes image with `latest`, `sha-<commit>`, and `YYYYMMDD` tags.
- **Nightly Schedule**: Runs at 00:00 UTC daily.
- **Workflow Dispatch**: Can be triggered manually via GitHub UI or GitHub CLI:
  ```bash
  gh workflow run "Build NanoGemClaw Container"
  ```

## Package Verification
To view published packages:
1. Navigate to `https://github.com/billnapier?tab=packages` or repository packages page.
2. Select `nanogemclaw` container image.
3. Verify tags `latest`, `sha-<commit>`, and `YYYYMMDD` are active.

To pull locally:
```bash
docker pull ghcr.io/billnapier/nanogemclaw:latest
```
