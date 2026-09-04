# Research - Observability, Journalctl Logging & Operational Runbooks

## Journald Log Retention
- Drop-in configuration: `/etc/systemd/journald.conf.d/nanoclaw-journal.conf`
- Content:
  ```ini
  [Journal]
  SystemMaxUse=500M
  ```
- Command to reload journald: `systemctl restart systemd-journald`

## Health Check Requirements
- Check `systemctl is-active opt-nanoclaw-data.mount`
- Check `systemctl is-active nanoclaw-container.service`
- Check `/opt/nanoclaw/config/env.list` existence
- Check disk space on `/opt/nanoclaw/data`
