# Requirements Quality Checklist: GCP Secret Manager Fetching & Environment Config

## Requirement Completeness & Clarity
- [ ] Spec specifies metadata service endpoint for GCP Project ID lookup.
- [ ] Spec lists exact secret names (`gemini-api-key`, `telegram-bot-token`).
- [ ] Spec details output file path (`/opt/nanoclaw/config/env.list`).
- [ ] Spec details exact file mode (`chmod 600`).

## User Scenarios & Acceptance Criteria
- [ ] User Story 1 specifies P1 priority for dynamic secret fetching.
- [ ] User Story 2 specifies P2 priority for environment file generation.
- [ ] User Story 3 specifies P3 priority for security permission hardening.
- [ ] Edge cases for IAM propagation and special characters covered.

## Success Criteria & Testability
- [ ] Success criteria checkable via standard filesystem and permission tools.
- [ ] Timing SLA (< 5 sec) defined for secret fetch step.
