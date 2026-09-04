# Data Model: Environment Configuration File

## File Specification

### Path: `/opt/nanoclaw/config/env.list`
- **Owner**: `root:root`
- **Mode**: `0600` (`-rw-------`)

### Keys
- `GEMINI_API_KEY`: Extracted from GCP Secret Manager (`gemini-api-key`)
- `TELEGRAM_BOT_TOKEN`: Extracted from GCP Secret Manager (`telegram-bot-token`)
- `ALLOWED_USER_IDS`: Injected from Terraform variable `allowed_user_ids`
- `DATA_DIR`: `/opt/nanoclaw/data`
- `NODE_ENV`: `production`
- `LOG_LEVEL`: `info`
