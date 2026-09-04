# Data Model - Observability & Runbooks

## Health Check Report Schema
- `timestamp`: UTC ISO string
- `mount_status`: `active` | `inactive`
- `container_service_status`: `active` | `inactive`
- `env_config_status`: `present` | `missing`
- `disk_space_free`: String
- `overall_health`: `HEALTHY` | `DEGRADED`
