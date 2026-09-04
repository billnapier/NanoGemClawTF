# Data Model: Systemd Container Daemon Unit Entity

## Entities

### Service Unit: `/etc/systemd/system/nanoclaw-container.service`
- **Requires**: `opt-nanoclaw-data.mount docker.service`
- **After**: `opt-nanoclaw-data.mount docker.service`
- **ExecStartPre**: `-docker stop nanogemclaw-agent`, `-docker rm nanogemclaw-agent`, `docker pull ${container_image}`
- **ExecStart**: `docker run --name nanogemclaw-agent --env-file /opt/nanoclaw/config/env.list -v /opt/nanoclaw/data:/opt/nanoclaw/data -v /var/run/docker.sock:/var/run/docker.sock ${container_image}`
- **Restart**: `always`
- **RestartSec**: `10`
- **WantedBy**: `multi-user.target`
