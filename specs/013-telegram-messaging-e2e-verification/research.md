# Research - Telegram Messaging Gateway E2E Verification

## Telegram Bot API Integration
- Long Polling vs Webhooks: Long polling (`getUpdates`) allows running without public ingress port opening, perfect for GCE compute instances with private network posture or default egress.
- Secret loading: Environment variables are injected from `/opt/nanoclaw/config/env.list`.
- Commands supported: `/start`, `/status`.
- Latency target: < 5 seconds round-trip response time.
