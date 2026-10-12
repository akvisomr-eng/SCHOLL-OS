# School OS roadmap

## Phase 0 — Repository and architecture foundation
- [x] Initialize repository, app shell, baseline design, and PostgreSQL schema draft.
- [x] Document Neon branch safety and Dapodik integration boundary.
- [ ] Verify Neon branch/database and apply migration in a development branch.
- [ ] Confirm CI result and resolve any build failures.

## Phase 1 — Identity and tenant isolation
- [ ] Choose authentication strategy and establish user lifecycle.
- [ ] Implement organization, school, and membership authorization.
- [ ] Add tests for cross-tenant and cross-school access denial.
- [ ] Add audit event writer and safe logging rules.

## Phase 2 — School master data
- [ ] Organizations, school profile, education levels, academic years, classes/rombel.
- [ ] Student and guardian records with field-level validation and consent-aware access.
- [ ] Import/export preview and reconciliation framework.

## Phase 3 — Core education operations
- [ ] PPDB/SPMB CRM and family communication inbox.
- [ ] Attendance and academic observation workflows configured by level.
- [ ] Finance and payment ledger with idempotency and audit trail.
- [ ] HR, attendance, and payroll with approval and restricted access.
- [ ] Transport/pickup module only where required by the school.

## Phase 4 — Dapodik interoperability
- [ ] Confirm authorized official export/API and release compatibility.
- [ ] Implement staged import, dry run, mapping, deduplication, approvals, and reconciliation.
- [ ] Validate official report requirements with the relevant education authority.

## Phase 5 — Controlled rollout
- [ ] Synthetic-data test, security review, backup/restore test, and operational runbook.
- [ ] Pilot with a limited school and authorized users.
- [ ] Go-live only after CI, migrations, authorization tests, and user acceptance are green.
