# Tasks: Secret Manager Fetching & Environment Config

- [x] Task 1: Retrieve GCP Project ID via Compute Engine Metadata Service in `scripts/startup.sh`
- [x] Task 2: Fetch latest secret values for `gemini-api-key` and `telegram-bot-token` using `gcloud secrets versions access` in `scripts/startup.sh`
- [x] Task 3: Create directory `/opt/nanoclaw/config` in `scripts/startup.sh`
- [x] Task 4: Write environment file `/opt/nanoclaw/config/env.list` containing all required keys in `scripts/startup.sh`
- [x] Task 5: Enforce `chmod 600 /opt/nanoclaw/config/env.list` in `scripts/startup.sh`
- [x] Task 6: Verify bash syntax and terraform HCL validation
