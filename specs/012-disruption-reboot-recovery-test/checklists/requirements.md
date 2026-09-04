# Requirements Quality Checklist: Disruption & Host Reboot Recovery Test

## Requirement Completeness & Clarity
- [ ] Spec specifies VM reboot trigger methods (`instances reset` or guest reboot).
- [ ] Spec details mount re-activation verification (`opt-nanoclaw-data.mount`).
- [ ] Spec details state survival validation using file checksum matching.
- [ ] Spec specifies logging targets (`journalctl`).

## User Scenarios & Acceptance Criteria
- [ ] User Story 1 specifies P1 priority for VM reboot disruption test.
- [ ] User Story 2 specifies P2 priority for mount re-activation.
- [ ] User Story 3 specifies P3 priority for state retention signoff.
- [ ] Edge cases for mount failure post-reboot and restart rate limiting covered.

## Success Criteria & Testability
- [ ] SLA (< 60 sec post-boot service recovery) defined.
- [ ] 100% checksum match criterion specified.
