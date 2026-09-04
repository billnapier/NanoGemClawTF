output "project_id" {
  description = "The GCP Project ID."
  value       = var.project_id
}

output "region" {
  description = "The GCP Region."
  value       = var.region
}

output "zone" {
  description = "The GCP Zone."
  value       = var.zone
}

output "runtime_service_account_email" {
  description = "Email address of NanoGemClaw agent runtime service account."
  value       = google_service_account.agent_runtime_sa.email
}

output "gemini_api_key_secret_id" {
  description = "Secret ID for Gemini API key in Secret Manager."
  value       = google_secret_manager_secret.gemini_api_key.secret_id
}

output "telegram_bot_token_secret_id" {
  description = "Secret ID for Telegram Bot token in Secret Manager."
  value       = google_secret_manager_secret.telegram_bot_token.secret_id
}

output "instance_name" {
  description = "Compute Engine instance name."
  value       = google_compute_instance.nanoclaw_vm.name
}

output "persistent_disk_name" {
  description = "Persistent data disk name."
  value       = google_compute_disk.agent_data.name
}
