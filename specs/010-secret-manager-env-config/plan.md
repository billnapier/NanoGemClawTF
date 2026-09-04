# Implementation Plan: GCP Secret Manager Fetching & Environment Config

## Technical Approach

Update `scripts/startup.sh` to dynamically query GCP Secret Manager for `gemini-api-key` and `telegram-bot-token` using GCE instance metadata for Project ID resolution. Render all runtime variables into `/opt/nanoclaw/config/env.list` and set strict `0600` file permissions.

## Proposed Changes

### `scripts/startup.sh`
- Query GCP Compute metadata service for `PROJECT_ID`.
- Fetch `gemini-api-key` and `telegram-bot-token` using `gcloud secrets versions access latest`.
- Create host config directory `/opt/nanoclaw/config`.
- Write environment variable file `/opt/nanoclaw/config/env.list`.
- Apply permissions `chmod 600 /opt/nanoclaw/config/env.list`.

## Verification Plan

1. Verify `scripts/startup.sh` bash syntax via `bash -n scripts/startup.sh`.
2. Run `cd terraform && terraform validate` to ensure template compatibility.
