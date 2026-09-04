# NanoGemClawTF Operational Runbooks

This document provides standardized operating procedures for host operations, incident handling, secret rotation, data recovery, and system diagnostics.

---

## Runbook 1: Host Reboot & Disk Mount Recovery

### Scenario
GCE VM host undergoes reboot or hardware maintenance causing persistent disk `/opt/nanoclaw/data` to require verification.

### Recovery Procedure
1. SSH into the GCE VM host instance:
   ```bash
   gcloud compute ssh nanoclaw-gemini-agent --zone=us-central1-a
   ```
2. Inspect `opt-nanoclaw-data.mount` systemd unit status:
   ```bash
   systemctl status opt-nanoclaw-data.mount
   ```
3. If unit is inactive, trigger manual mount start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start opt-nanoclaw-data.mount
   ```
4. Verify filesystem mount point and disk usage:
   ```bash
   df -h /opt/nanoclaw/data
   ```

---

## Runbook 2: Restoring SQLite State from GCP Disk Snapshot

### Scenario
Data corruption or accidental deletion occurs on `/opt/nanoclaw/data/state.db`.

### Recovery Procedure
1. List available daily disk snapshots:
   ```bash
   gcloud compute snapshots list --filter="sourceDisk~nanoclaw-data-disk"
   ```
2. Stop active container daemon to prevent database writes:
   ```bash
   sudo systemctl stop nanoclaw-container.service
   ```
3. Create a new disk from target snapshot:
   ```bash
   gcloud compute disks create nanoclaw-data-disk-restored \
     --source-snapshot=<SNAPSHOT_NAME> \
     --zone=us-central1-a
   ```
4. Unmount current disk and attach restored disk in Terraform or via CLI:
   ```bash
   sudo systemctl stop opt-nanoclaw-data.mount
   gcloud compute instances detach-disk nanoclaw-gemini-agent --disk=nanoclaw-data-disk --zone=us-central1-a
   gcloud compute instances attach-disk nanoclaw-gemini-agent --disk=nanoclaw-data-disk-restored --device-name=agent-data --zone=us-central1-a
   ```
5. Mount restored disk and restart container daemon:
   ```bash
   sudo systemctl start opt-nanoclaw-data.mount
   sudo systemctl start nanoclaw-container.service
   ```

---

## Runbook 3: Secret Rotation for TELEGRAM_BOT_TOKEN & GEMINI_API_KEY

### Scenario
API credentials need to be rotated due to security policy or compromise.

### Rotation Procedure
1. Update secret value in GCP Secret Manager:
   ```bash
   echo -n "<NEW_TELEGRAM_BOT_TOKEN>" | gcloud secrets versions add telegram-bot-token --data-file=-
   echo -n "<NEW_GEMINI_API_KEY>" | gcloud secrets versions add gemini-api-key --data-file=-
   ```
2. Re-trigger Secret Manager fetching on host:
   ```bash
   PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/project/project-id")
   sudo gcloud secrets versions access latest --secret="telegram-bot-token" --project="$PROJECT_ID" > /tmp/tg_token
   sudo gcloud secrets versions access latest --secret="gemini-api-key" --project="$PROJECT_ID" > /tmp/gem_key
   ```
3. Update `/opt/nanoclaw/config/env.list` and set permissions `0600`:
   ```bash
   sudo sed -i "s/^TELEGRAM_BOT_TOKEN=.*/TELEGRAM_BOT_TOKEN=$(cat /tmp/tg_token)/" /opt/nanoclaw/config/env.list
   sudo sed -i "s/^GEMINI_API_KEY=.*/GEMINI_API_KEY=$(cat /tmp/gem_key)/" /opt/nanoclaw/config/env.list
   sudo chmod 0600 /opt/nanoclaw/config/env.list
   sudo rm /tmp/tg_token /tmp/gem_key
   ```
4. Restart container daemon to load updated environment variables:
   ```bash
   sudo systemctl restart nanoclaw-container.service
   ```

---

## Runbook 4: Container Daemon Troubleshooting & Journalctl Inspection

### Scenario
Container daemon fails to start, crashes repeatedly, or responds with errors.

### Troubleshooting Procedure
1. Query systemd unit status and last 50 log lines:
   ```bash
   sudo systemctl status nanoclaw-container.service
   sudo journalctl -u nanoclaw-container.service -n 50 --no-pager
   ```
2. Filter for security alerts or unauthorized access attempts:
   ```bash
   sudo journalctl -u nanoclaw-container.service | grep "SECURITY_ALERT"
   ```
3. Execute host health check tool:
   ```bash
   /opt/nanoclaw/scripts/health_check.sh || ./scripts/health_check.sh
   ```
4. Perform container state cleanup and force restart if required:
   ```bash
   sudo docker stop nanogemclaw-agent || true
   sudo docker rm nanogemclaw-agent || true
   sudo systemctl restart nanoclaw-container.service
   ```
