# Research - Access Control & Security Enforcement

## Security Best Practices
- Zero-Trust Authorization: Parse allowed user IDs into integer set; fail closed if empty.
- Security Audit Trails: Format security alerts with standard prefix `[SECURITY_ALERT]` for SIEM / journalctl parsing.
- Prevention of Prompt Injection & API Waste: Reject unauthorized messages before invoking LLM or Telegram reply APIs.
