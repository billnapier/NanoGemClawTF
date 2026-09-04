#!/usr/bin/env bash
set -euo pipefail

# NanoGemClaw VM Startup Script
# Template parameters injected by Terraform:
#   ${container_image}
#   ${persistent_disk_name}

echo "=== Initializing NanoGemClaw Host ==="

MOUNT_DIR="/var/lib/nanoclaw-data"
DISK_DEVICE="/dev/disk/by-id/google-${persistent_disk_name}"

# 1. Mount Persistent Data Disk
mkdir -p "$MOUNT_DIR"

if [ -b "$DISK_DEVICE" ]; then
  echo "Found persistent disk device: $DISK_DEVICE"
  if ! blkid "$DISK_DEVICE" | grep -q "ext4"; then
    echo "Formatting $DISK_DEVICE as ext4..."
    mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0 "$DISK_DEVICE"
  fi

  if ! mountpoint -q "$MOUNT_DIR"; then
    echo "Mounting $DISK_DEVICE to $MOUNT_DIR..."
    mount -o discard,defaults "$DISK_DEVICE" "$MOUNT_DIR"
  fi
else
  echo "WARNING: Persistent disk $DISK_DEVICE not detected at boot."
fi

# 2. Verify Container Runtime Availability
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

# 3. Pull & Initialize Agent Container (Fallback: alpine:latest)
IMAGE="${container_image}"
echo "Pulling container image: $IMAGE..."
docker pull "$IMAGE" || echo "Warning: Failed to pull $IMAGE, using local cache if present."

echo "=== NanoGemClaw Startup Initialization Complete ==="
