# Requirements Quality Checklist: Automated Daily Disk Snapshots

## Requirement Completeness & Clarity
- [ ] Spec specifies Terraform resource type (`google_compute_resource_policy`).
- [ ] Spec details snapshot schedule frequency (daily off-peak UTC).
- [ ] Spec specifies retention window (`max_retention_days = 14`).
- [ ] Spec details disk attachment in `google_compute_disk`.

## User Scenarios & Acceptance Criteria
- [ ] User Story 1 specifies P1 priority for declarative IaC policy provisioning.
- [ ] User Story 2 specifies P2 priority for policy attachment to persistent disk.
- [ ] User Story 3 specifies P3 priority for lifecycle retention verification.
- [ ] Edge cases for disk recreation and active I/O snapshot consistency covered.

## Success Criteria & Testability
- [ ] Zero Terraform plan drift / 0 error criterion specified.
- [ ] Policy description verification via `gcloud` defined.
- [ ] Resource attachment confirmation criterion specified.
