# School OS — AI Agent Operating Policy

## Purpose
AI agents assist authorized school personnel and platform operators. They are not an independent authority over student outcomes, employment, payroll, money movement, legal compliance, or production access.

## Agents and least-privilege tools
- Knowledge agent: read approved, versioned policy documents; answer with source title/version/date.
- Dapodik/data-quality agent: read permitted records, validate mappings, report gaps and propose corrections.
- Academic agent: draft learning summaries and reports; never finalize marks or publish official reports.
- HR/payroll agent: reconcile attendance and approved payroll inputs; no salary changes, payroll approval or payment initiation.
- Finance agent: detect duplicate invoices, outliers and reconciliation differences; no posting or transfers.
- ERP agent: monitor stock/maintenance and draft purchase requests; no purchase authorization.
- CRM/family agent: draft replies from approved public/role-scoped knowledge; enforce guardian authorization and consent.
- Report QA agent: validate totals, completeness, report version and permission boundaries.
- Security/SRE agent: read health/CI/error/security signals and run allowlisted diagnostics; open incident and propose a patch.
- Coordinator: apply policy checks, school scope, action risk class and approval gate before tool execution.

## Risk classes
**R0 — read-only:** health status, approved documentation, aggregate reports authorized for the actor.
**R1 — reversible low impact:** retry a known idempotent job, clear a disposable cache, create a ticket or draft, quarantine an upload in a reversible holding area under predefined policy.
**R2 — controlled change:** patch proposal, dependency update, configuration change, data correction proposal, public-content draft. Requires review/approval before merge or publication.
**R3 — sensitive/high impact:** production schema migration, irreversible deletion, restore/overwrite, role or credential policy changes, salary or payroll mutation/approval, accounting posting, money movement, official report publication, student assessment finalization. Always requires an authorized human approval, recorded reason and auditable evidence.

## Host-live guardrails
- Never grant agents broad shell, database-owner, secrets-reading, or self-escalation access.
- Use explicit allowlists, short-lived credentials, per-agent identity, per-tool authorization, timeouts, idempotency keys, rate limits and bounded retries.
- Redact personal data/secrets from logs and model context. Use only the minimum fields needed for the task.
- Do not let an agent disable monitoring, alter its policy, remove audit records, change its own permissions, or deploy its own unreviewed patch.
- Production deployments require CI, reviewed diff, migration plan, backup/restore readiness, rollback, staging smoke test and post-deployment health check.
- Security incident containment may auto-block a known malicious request or revoke a compromised short-lived token only if an operator-approved playbook defines the trigger, scope, expiration and notification.
- Every tool action records actor/agent, tool, resource scope, risk class, inputs summary, result, timestamps, approval reference and correlation ID; exclude secrets and unnecessary personal data.

## Knowledge lifecycle and self-improvement
- Knowledge sources are versioned with issuer, jurisdiction/level, effective date, review date and owner.
- Agents may index approved documents into a school-scoped retrieval corpus and run evaluation/regression suites.
- Agent-generated policy or knowledge changes are proposals; a designated human approves publication.
- Feedback may improve evaluations and retrieval quality, but confidential student/employee records must not become shared global knowledge or model-training material by default.
- Every answer must distinguish sourced facts from suggestions, cite local document/version, surface stale or missing sources, and avoid fabricated official rules.
- Provider/model selection is configurable; fully local inference is only claimed after a real deployment and privacy/performance tests.

## Required tests before activation
Cross-school access attempts; role escalation; prompt injection in uploaded documents; secret exfiltration attempts; unauthorized report exports; malicious tool arguments; replay/idempotency; payroll/finance action approval; audit completeness; agent timeout/failure behavior; rollback and alert delivery. An agent is not production-enabled merely because its prompt or UI exists.
