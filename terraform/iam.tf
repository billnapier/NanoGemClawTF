# Runtime Service Account for NanoGemClaw Agent Host
resource "google_service_account" "agent_runtime_sa" {
  account_id   = var.runtime_service_account_id
  display_name = "NanoGemClaw Agent Runtime Service Account"
  description  = "Least-privilege service account assigned to the Compute Engine VM host."
}

# Secret Accessor IAM Member Binding for Gemini API Key Secret
resource "google_secret_manager_secret_iam_member" "gemini_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.gemini_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent_runtime_sa.email}"
}

# Secret Accessor IAM Member Binding for Telegram Bot Token Secret
resource "google_secret_manager_secret_iam_member" "telegram_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.telegram_bot_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent_runtime_sa.email}"
}
