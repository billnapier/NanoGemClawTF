#!/usr/bin/env bash
set -euo pipefail

# NanoGemClaw VM Startup Script
# Template parameters injected by Terraform:
#   ${container_image}
#   ${persistent_disk_name}
#   ${allowed_user_ids}

ALLOWED_USER_IDS="${allowed_user_ids}"

echo "=== Initializing NanoGemClaw Host ==="

MOUNT_DIR="/opt/nanoclaw/data"
DISK_DEVICE="/dev/disk/by-id/google-${persistent_disk_name}"

# 1. Mount Persistent Data Disk via Systemd Unit
mkdir -p "$MOUNT_DIR"
chmod 0755 "$MOUNT_DIR"

echo "Waiting for block device $DISK_DEVICE..."
POLL_ATTEMPTS=0
until [ -b "$DISK_DEVICE" ] || [ $POLL_ATTEMPTS -ge 15 ]; do
  echo "Waiting for $DISK_DEVICE to enumerate..."
  sleep 2
  POLL_ATTEMPTS=$((POLL_ATTEMPTS + 1))
done

if [ -b "$DISK_DEVICE" ]; then
  echo "Found persistent disk device: $DISK_DEVICE"
  if ! blkid "$DISK_DEVICE" | grep -q "ext4"; then
    echo "Formatting $DISK_DEVICE as ext4..."
    mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0 "$DISK_DEVICE"
  fi

  cat <<UNIT > /etc/systemd/system/opt-nanoclaw-data.mount
[Unit]
Description=NanoGemClaw Persistent Data Mount
Before=local-fs.target

[Mount]
What=$DISK_DEVICE
Where=/opt/nanoclaw/data
Type=ext4
Options=discard,defaults,nofail

[Install]
WantedBy=local-fs.target
UNIT

  echo "Enabling and starting opt-nanoclaw-data.mount systemd unit..."
  systemctl daemon-reload
  systemctl enable --now opt-nanoclaw-data.mount || true
else
  echo "WARNING: Persistent disk $DISK_DEVICE not detected at boot."
fi

# 2. Fetch GCP Secret Manager Secrets & Provision Environment File
echo "Fetching GCP Project ID from compute metadata..."
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/project/project-id" || echo "")

GEMINI_API_KEY=""
TELEGRAM_BOT_TOKEN=""

if command -v gcloud &> /dev/null && [ -n "$PROJECT_ID" ]; then
  echo "Retrieving secrets from Secret Manager for project $PROJECT_ID..."
  GEMINI_API_KEY=$(gcloud secrets versions access latest --secret="gemini-api-key" --project="$PROJECT_ID" 2>/dev/null || echo "")
  TELEGRAM_BOT_TOKEN=$(gcloud secrets versions access latest --secret="telegram-bot-token" --project="$PROJECT_ID" 2>/dev/null || echo "")
fi

CONFIG_DIR="/opt/nanoclaw/config"
ENV_FILE="$CONFIG_DIR/env.list"

mkdir -p "$CONFIG_DIR"
chmod 0755 "$CONFIG_DIR"

echo "Generating environment file at $ENV_FILE..."
cat <<ENV > "$ENV_FILE"
GEMINI_API_KEY=$GEMINI_API_KEY
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ALLOWED_USER_IDS=$ALLOWED_USER_IDS
ADMIN_USER_ID=$ALLOWED_USER_IDS
DATA_DIR=/opt/nanoclaw/data
NODE_ENV=production
LOG_LEVEL=info
ENV

chmod 0600 "$ENV_FILE"
chown root:root "$ENV_FILE" 2>/dev/null || true
echo "Environment file successfully provisioned with hardened permissions 0600."

# 3. Verify Container Runtime Availability
if ! command -v docker &> /dev/null; then
  echo "Installing Docker engine..."
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# 4. Provision & Start Systemd Container Service Unit
IMAGE="${container_image}"
echo "Registering systemd container service for image: $IMAGE..."

cat <<SERVICE > /etc/systemd/system/nanoclaw-container.service
[Unit]
Description=NanoGemClaw Container Daemon
Requires=opt-nanoclaw-data.mount docker.service
After=opt-nanoclaw-data.mount docker.service

[Service]
Type=simple
Restart=always
RestartSec=10
ExecStartPre=-/usr/bin/docker stop nanogemclaw-agent
ExecStartPre=-/usr/bin/docker rm nanogemclaw-agent
ExecStartPre=/usr/bin/docker pull $IMAGE
ExecStart=/usr/bin/docker run --name nanogemclaw-agent --env-file /opt/nanoclaw/config/env.list -p 127.0.0.1:3000:3000 -v /opt/nanoclaw/data:/opt/nanoclaw/data -v /var/run/docker.sock:/var/run/docker.sock $IMAGE
ExecStop=/usr/bin/docker stop nanogemclaw-agent

[Install]
WantedBy=multi-user.target
SERVICE

echo "Enabling and starting nanoclaw-container.service systemd unit..."
systemctl daemon-reload
systemctl enable --now nanoclaw-container.service || true

# 5. Configure Systemd Journald Log Retention Limits
echo "Configuring systemd journald log retention limit SystemMaxUse=500M..."
mkdir -p /etc/systemd/journald.conf.d
cat <<JOURNAL > /etc/systemd/journald.conf.d/nanoclaw-journal.conf
[Journal]
SystemMaxUse=500M
JOURNAL
systemctl restart systemd-journald || true

echo "=== NanoGemClaw Startup Initialization Complete ==="

