# Secret Container for Gemini API Key
resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = var.gemini_api_key_secret_id

  replication {
    auto {}
  }
}

# Initial Version Payload for Gemini API Key
resource "google_secret_manager_secret_version" "gemini_api_key_version" {
  secret      = google_secret_manager_secret.gemini_api_key.id
  secret_data = var.gemini_api_key_initial_value
}

# Secret Container for Telegram Bot Token
resource "google_secret_manager_secret" "telegram_bot_token" {
  secret_id = var.telegram_bot_token_secret_id

  replication {
    auto {}
  }
}

# Initial Version Payload for Telegram Bot Token
resource "google_secret_manager_secret_version" "telegram_bot_token_version" {
  secret      = google_secret_manager_secret.telegram_bot_token.id
  secret_data = var.telegram_bot_token_initial_value
}
