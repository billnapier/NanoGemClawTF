variable "project_id" {
  description = "The GCP Project ID where resources will be provisioned."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for compute resources."
  type        = string
  default     = "us-central1-a"
}

variable "github_repo" {
  description = "The target GitHub repository in org/repo format (e.g. billnapier/NanoGemClawTF)."
  type        = string
  default     = "billnapier/NanoGemClawTF"
}

variable "state_bucket_name" {
  description = "The GCS storage bucket name for Terraform remote state."
  type        = string
  default     = ""
}

variable "runtime_service_account_id" {
  description = "Service account ID for NanoGemClaw runtime instance."
  type        = string
  default     = "nanoclaw-agent-runtime-sa"
}

variable "container_image" {
  description = "Container image tag for NanoGemClaw runner. Defaults to published GHCR package image."
  type        = string
  default     = "ghcr.io/billnapier/nanogemclaw:latest"
}

variable "vm_machine_type" {
  description = "Compute Engine machine type for agent host."
  type        = string
  default     = "e2-small"
}

variable "persistent_disk_size_gb" {
  description = "Size of persistent data disk in GB."
  type        = number
  default     = 20
}

variable "gemini_api_key_secret_id" {
  description = "Secret Manager secret ID for Gemini API key."
  type        = string
  default     = "gemini-api-key"
}

variable "gemini_api_key" {
  description = "Gemini API key."
  type        = string
  sensitive   = true
  default     = ""
}

variable "gemini_api_key_initial_value" {
  description = "Initial secret value for Gemini API key. Defaults to placeholder."
  type        = string
  sensitive   = true
  default     = "placeholder-gemini-key"
}

variable "telegram_bot_token_secret_id" {
  description = "Secret Manager secret ID for Telegram bot token."
  type        = string
  default     = "telegram-bot-token"
}

variable "telegram_bot_token" {
  description = "Telegram bot token."
  type        = string
  sensitive   = true
  default     = ""
}

variable "telegram_bot_token_initial_value" {
  description = "Initial secret value for Telegram bot token. Defaults to placeholder."
  type        = string
  sensitive   = true
  default     = "placeholder-telegram-token"
}

variable "allowed_user_ids" {
  description = "Comma-separated list of allowed Telegram user IDs."
  type        = string
  default     = ""
}


