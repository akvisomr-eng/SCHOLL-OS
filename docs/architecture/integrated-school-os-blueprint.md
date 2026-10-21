# School OS — Integrated School Operations Blueprint

Status: product and implementation specification; not a claim that every module is implemented.
Target: Indonesian schools from KB/TK through SMA/SMK, with optional international-school capabilities.
Architecture constraints: one platform, one tenant-aware data model, Neon PostgreSQL as the system of record, GitHub for source control/CI, and independently deployable school website connected through a controlled API. Keep the core Rp0/free-tier-first where feasible.

## Product principles

1. One canonical record per person, school, academic year, class/group, employee, asset, invoice, and transaction. Reuse data across modules; do not create duplicate module-specific master records.
2. School-specific forms and reports must have domain-specific fields, validation, approval states, and audit history. No generic CRUD-only forms for core workflows.
3. Configure behavior by education level and academic year. Do not force a KB/TK developmental report into a secondary-school subject-score template.
4. Dapodik alignment is not equivalent to official integration. Support documented exports/imports and validation; claim an official connection only after approved access, documented interfaces, and successful tests exist.
5. Security is a core capability, never a premium feature. Enforce tenant/school scope server-side on every operation, least privilege, private-by-default records, auditability, backups, and incident response.
6. AI may explain, classify, draft, detect anomalies, propose fixes, and run approved read-only checks. High-impact actions require human approval and a verifiable audit record.
7. Do not put secrets, payroll data, student PII, or sensitive records in public client bundles, prompts sent to unapproved providers, logs, or public website APIs.

## Core shared foundation

- Organizations/yayasan, schools/campuses, academic years/terms, school memberships, roles/permissions, user profiles, audit events.
- Person registry with separate student, parent/guardian, employee/PTK, applicant, and alumni profiles linked to the same person where appropriate.
- School-scoped IDs, effective dates, record status, source/provenance, change history, soft-archive where legally appropriate, and controlled exports.
- Authentication/session lifecycle, MFA-ready design, account recovery, server-side authorization, tenant isolation tests, rate limits, and security event alerts.
- Integration registry for website/API credentials, webhooks, delivery retries, idempotency, health status, and revocation/rotation.

## Module A — Academic and Dapodik-aligned operations

### Master data and domain forms
- School identity: NPSN and official identifiers only where verified; address, contacts, facilities, operating status, leadership and effective dates.
- Student: local student number, NISN when supplied/verified, identity, birth details, address, guardian links, enrollment status, entry/exit reason and date, supporting documents, consent and data-source metadata.
- Employee/PTK: local employee number, NUPTK when applicable and verified, employment type, role, assignment, education/qualification, certificates, effective dates and supporting documents.
- Academic year/term: start/end dates, active status, calendar, holidays and reporting periods.
- Class/rombel: grade/level, name, homeroom teacher, capacity, academic year, membership effective dates and validation.
- Learning: curriculum configuration, subjects or development areas by level, learning plans, schedules, attendance, assessment items, rubrics, evidence/portfolio, moderation, approval, report-card generation and revision history.
- KB/TK reporting emphasizes child development and evidence aligned to the configured framework; older levels may use subject/competency structures. Templates must be versioned and approved by school management.

### Operational workflow
PPDB/applicant -> verify documents -> accept/reject/waitlist -> create or link student record -> enroll in academic year -> assign class/group -> attendance and learning evidence -> assessment/review -> approve report -> distribute to authorized guardians -> archive/export.

### Reports
- Student master list; enrollment, transfers, withdrawals and status changes.
- Class/rombel membership and capacity; teacher assignments; timetable.
- Daily/monthly attendance and absence reasons.
- Assessment evidence, progress and approved report cards by configured level.
- Student/teacher data completeness and validation exceptions for Dapodik preparation.
- Import/export logs, rejected rows and reconciliation report.
- Academic calendar and activity implementation reports.
Reports must show period, filters, generation time, creator, data cut-off, approval status and source where applicable.

## Module B — ERP and school resource management

### Master data/forms
- Organization/campus, departments, cost centers and responsibility owners.
- Inventory item: code, category, unit, specification, serial/batch, quantity, minimum stock, storage location, custodian, funding/source, purchase date/cost, condition, warranty, useful life and attachments.
- Asset register: asset tag, acquisition/receipt record, location, responsible employee, depreciation policy if applicable, maintenance history, transfer, stocktake, impairment/disposal approval and evidence.
- Procurement request: requester, purpose, budget line, item/service details, quantities, quotations, evaluation, approvals, purchase order, receiving/inspection and invoice match.
- Maintenance ticket: asset/location, issue, priority, photo/evidence, assignee, costs, work log, downtime and closure confirmation.
- Facilities/rooms: capacity, usage schedule, safety/maintenance inspections and issue register.
- Vendors: verified business/contact data, contract, tax/payment fields with restricted access and performance history.

### Reports
Stock card and balance; low-stock/reorder; asset register by location/custodian/condition; stocktake differences; asset movement; maintenance due/overdue and costs; procurement pipeline; purchase order versus receipt/invoice reconciliation; budget commitment by cost center.

## Module C — HRD, attendance, payroll and payslips

### Employee and HR forms
- Employee profile, employment status/type, job/position, department, school assignment, supervisor, start/end dates, contract, qualifications, bank/tax data in restricted fields, emergency contact and required documents.
- Work schedule, attendance source, check-in/out, leave, permission, sick leave, overtime/extra duty, substitutions, correction request and approval.
- Compensation assignment: effective date, salary basis, allowance/benefit, deduction, tax/social contribution configuration, school policy and approver. Store historical versions; never overwrite a prior closed payroll period.
- Payroll run: period, eligible employees, attendance cut-off, approved leave/overtime, component calculation, exception list, preview, review, approval, locked/posted state and payment reconciliation.

### Payslip requirements
Each employee can access only their own payslips; authorized HR/payroll roles access within their school scope. Slip should state employer/school, employee identifier, position, payroll period, attendance days/scheduled days, present/absent/leave counts as applicable, approved overtime/extra duties, base salary, each allowance, each deduction with human-readable reason and calculation basis, gross pay, net pay, payment date/status, generated timestamp and revision/correction reference. Sensitive bank/tax identifiers should be masked. A payslip is a private document; never publish it in a public website route.

### Payroll controls and reports
- Payroll preview and exception report before approval.
- Attendance-to-payroll reconciliation.
- Payslip PDF with secure, expiring/authorized access.
- Payroll register, allowance/deduction detail, employer cost, payment reconciliation and period close report.
- Leave balances, overtime, attendance, contract expiry, staffing/headcount and training reports.
- Two-person approval for payroll finalization and payment file generation where feasible.
- Tax and statutory calculations must be configured against current applicable rules and reviewed by a qualified operator; do not hardcode assumed rates without effective dates and tests.

## Module D — Accounting and finance

### Domain forms
- Chart of accounts with account code/name/type, reporting group, active dates and posting rules.
- Annual budget by school, program/activity, account/cost center, source of funds, period and approver.
- Student billing/tuition/fees: billing item, student/payer, academic period, due date, discount/aid approval, invoice number, payment allocations, outstanding balance and receipt.
- Receipts/disbursements: counterparty, date, amount, account, payment method/reference, attachments, category, approver and reconciliation status.
- Vendor invoice, purchase/receipt matching, expense claim, petty cash, bank/cash accounts and bank reconciliation.
- Journal entry: source document, balanced debit/credit lines, period, preparer, reviewer, posting/void reversal, immutable reference to correction.
- Payroll journal generated only from an approved payroll run.

### Reports and safeguards
Cash/bank book; general ledger; trial balance; journal; income/expense by period and cost center; budget versus actual; receivables aging; student billing/collection and arrears; vendor payables aging; cash-flow summary; asset register/depreciation where configured; payroll expense reconciliation; period close checklist.
Posted entries must not be silently edited or deleted. Corrections use reversals/adjusting entries and preserve audit trail. Financial reports must state whether they are cash-basis or accrual-basis according to the configured accounting policy.

## Module E — CRM, admissions and family services

- Lead/applicant record with source/campaign, desired entry level/year, contact permission, communication history and assigned admissions officer.
- Admissions pipeline: new inquiry -> contacted -> visit/consultation -> application -> document review -> selection -> offer/waitlist -> accepted -> registration complete -> enrolled/lost with reason.
- Follow-up tasks, school visit appointments, consent-aware messages, family communication log, service tickets, complaint/feedback category, SLA, assignment, resolution and satisfaction follow-up.
- Website forms use server-validated APIs, spam/rate protection, explicit consent and minimum necessary data. Public visitors never receive access to internal CRM records.
- Reports: inquiry conversion by source, funnel aging, PPDB capacity, application completeness, response time, service-ticket SLA, complaints and family engagement.

## Module F — reports and school governance

A central Report Center must contain domain-specific reports for academics, student services, HR, payroll, inventory, procurement, accounting, admissions, website activity, audit/security, and leadership. Each report has:
- explicit filters and date/academic-period semantics;
- school/role authorization;
- validated totals and reconciliation checks;
- print/PDF and CSV/XLSX export where appropriate;
- report version, generated timestamp, creator, data cut-off and approval state;
- saved views only within permitted school scope;
- data minimization and masking for sensitive exports.
Keep a registry of current official report/form requirements and their version/effective date. Validate templates against the then-current official documents before claiming compliance.

## Module G — separate website integration

Website remains independently deployable. School OS exposes a versioned API and scoped service credentials:
- Public read-only endpoints for approved school profile, news, announcements, calendar and published admission information.
- Private authenticated endpoints for PPDB application status, family services and guardian portal.
- Webhooks with signatures, idempotency keys, retries, delivery logs and replay protection.
- No direct database connection from public website/browser; no broad admin token in the client.
- Draft/pending content is never public. Publishing requires authorized approval. Provide integration health checks, revocation and key rotation.

## Module H — AI Companion and multi-agent operations

Use a policy-enforced orchestrator with narrowly scoped specialist agents:
1. School Knowledge Agent: answers from versioned local school policy, approved SOPs, official Dapodik references and curriculum documents; cites source title/version/date and says when knowledge is missing.
2. Dapodik/Data Quality Agent: checks required fields, cross-field consistency, duplicates, date/ID formats and export validation; proposes corrections, does not invent official values.
3. Academic Reporting Agent: drafts summaries and reports from authorized records; teachers/authorized leaders approve before official publication.
4. Finance/Accounting Agent: explains variances, detects duplicate invoices/unusual transactions and reconciliation gaps; cannot initiate transfers or post unapproved journals.
5. HR/Payroll Agent: checks attendance-payroll mismatches and explains payslip components; cannot alter salary, attendance or payroll approval.
6. Inventory/Procurement Agent: flags low stock, overdue maintenance, unusual prices and missing receipt/invoice matching; purchases require approval.
7. CRM/Family Service Agent: drafts responses and classifies service tickets using approved knowledge; respects consent and access boundaries.
8. Security/SRE Agent: reads health metrics, errors, dependency/CI status, security alerts and audit signals; may run safe diagnostics and open an incident/PR, but not disable controls or self-grant access.
9. Report QA Agent: checks arithmetic, required columns, missing data, totals and inconsistencies before reports are released.
10. Coordinator/Policy Gate: authenticates the actor, checks tool permissions, classifies risk, obtains approval for sensitive actions, records evidence and prevents agents from bypassing policy.

### Local knowledge and autonomy
- Store school-approved documents and references in a versioned knowledge library with source, effective date, jurisdiction/level, owner and review date.
- Retrieval must be scoped by school and role; student/employee confidential documents are not mixed into general knowledge.
- "Self-development" means proposing improvements, evaluating feedback, updating a staging knowledge index or opening reviewed pull requests. It does not mean silently rewriting its own rules, changing production schema, or learning confidential data into globally shared knowledge.
- Provide answer citations, confidence/uncertainty indicators, source freshness checks, user feedback, evaluation datasets and regression tests.
- Model provider must be configurable. Keep secrets server-side. Use approved local or external inference depending on cost, latency, privacy and available compute; do not promise fully local AI without actual deployment resources.

### Host/live operations agent
- Health checks, latency/error monitoring, logs with PII redaction, DB connection/pool metrics, scheduled backup verification, migration drift checks, dependency/security scan and CI/deployment checks.
- Safe autonomous actions: restart/retry a failed idempotent job, clear a known disposable cache, rate-limit abusive traffic, quarantine suspicious upload, create an incident and propose a patch.
- Approval required: production migration, deletion/restoration of business records, permission changes, payroll/finance posting, public content publication, credential rotation with outage risk, and deployment that changes data/security behavior.
- Emergency containment may revoke a compromised token or temporarily block a malicious request only under explicit pre-approved policy; notify operators and log every action.
- Require rollback plan, tested backup/restore, staging verification, canary/smoke tests and post-deployment health checks. Never claim production monitoring/repair is active until instrumentation and deployment are actually configured.

## Security, privacy and audit baseline

- Tenant isolation enforced in server-side queries and DB policies/constraints; never trust school_id supplied by the client without verifying membership.
- Role and permission matrix: platform operator, foundation/yayasan admin, school owner/leader, academic admin, teacher, HR, payroll, accountant, procurement, librarian/lab/facility staff, guardian, student and auditor as appropriate.
- Separate sensitive permissions for viewing salary/bank/tax data, approving payroll, posting accounting entries, exporting PII and changing roles.
- Append-only audit events for sensitive changes; avoid logging secrets and unnecessary personal data.
- Encryption in transit, secure secret storage, secure cookies/session expiry, rate limiting, CSRF/XSS protections, file type/size scanning and private file access.
- Retention, correction, export, consent and deletion workflows must be reviewed against applicable Indonesian privacy and education rules.
- Test unauthenticated access, cross-school access, role escalation, direct object references, report export leakage, payroll isolation, API key misuse, replay/idempotency and backup restoration.

## Suggested implementation sequence

Phase 0 — verify the existing app, migration state, CI and deployment; preserve production data.
Phase 1 — authentication, authorization, tenant isolation, audit and automated security tests.
Phase 2 — master data, academic year, student/PTK, guardians, classes/rombel, and data-quality/official-format validation.
Phase 3 — attendance, learning, assessments, report cards and central Report Center.
Phase 4 — website integration API, admissions CRM, guardian services and AI companion grounded in approved knowledge.
Phase 5 — HRD, attendance, payroll, private payslips and approval/reconciliation controls.
Phase 6 — inventory/procurement/asset ERP and accounting ledger/finance workflows.
Phase 7 — specialist AI agents, monitoring, incident workflows, staged remediation and safe automation.
Phase 8 — international configuration, bilingual reporting, selected framework mapping and integration pilots.

Every phase requires migrations, typed domain models, domain-specific forms, server-side validation, role-based tests, audit coverage, CI and documented acceptance criteria. Do not mark a module complete merely because its menu or form renders.
