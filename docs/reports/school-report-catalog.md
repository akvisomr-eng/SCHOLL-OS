# School OS — Report Center Catalog (National Core)

This catalog defines report contracts, not a claim that the report UI or exports are already implemented. Each report must be permission-checked server-side, scoped to the selected school, generated with a timestamp/data cut-off, and expose filters, source records, validation warnings, and approval status. Sensitive exports require elevated permission and an audit event.

## Academic and student administration

| Report | Required filters | Specific output / checks |
|---|---|---|
| Data induk peserta didik | School, academic year, enrollment status, class | Local student number, NISN only if verified, name, enrollment status, admission/exit dates, guardian linkage; duplicates and missing-field flags |
| Rekap PPDB | Intake year, level, stage, source | Applicants by stage, incomplete documents, offers, accepted, waitlisted, declined/lost with reason, conversion rate |
| Daftar rombel | Academic year, level, class | Class code/name, grade, homeroom teacher, capacity, active student count, over-capacity warning |
| Riwayat mutasi/status siswa | Date range, status, class | Effective date, old/new status or class, reason, approver and audit reference |
| Rekap presensi siswa | Date range, class, status | Scheduled sessions, present, sick, permitted, absent, late, excused school activity; reconcile against enrollment effective dates |
| Validasi data Dapodik | Export profile/version, school, academic year | Required fields, invalid codes/date ranges, duplicate candidate IDs, unverified official identifiers, rejected rows and correction owner |
| Rapor/kemajuan belajar | Academic period, level, class, student | Versioned level-specific template, evidence, assessments, teacher notes, approval, publication status; no draft presented as final |
| Kalender/program kegiatan | Period, activity type, responsible unit | Planned vs actual date, PIC, attendance/evidence, status and follow-up |

## HR, attendance and payroll

| Report | Required filters | Specific output / checks |
|---|---|---|
| Daftar pegawai/PTK | School, employment status, category | Employee number, verified identifiers, position, contract dates, qualification and missing documents |
| Rekap presensi pegawai | Period, unit, employee, status | Scheduled days/hours, attendance, leave, permission, sickness, overtime and correction approvals |
| Rekap komponen payroll | Payroll period, school, component | Base salary, allowances, overtime, deductions, gross/net; permission-restricted and reconciled to approved run |
| Rekonsiliasi presensi–payroll | Payroll period, employee | Attendance source vs payroll input, differences, unresolved corrections and approver |
| Slip gaji individual | Employee-owned period | Workdays, attendance counts, approved leave/overtime, each earning/deduction and reason, gross/net, payment status; private PDF |
| Kontrak & masa berlaku | Date range, unit, employment type | Contract end dates, certificates/documents expiring, assigned follow-up owner |

## ERP, inventory and procurement

| Report | Required filters | Specific output / checks |
|---|---|---|
| Kartu stok | Item, location, period | Opening, receipt, issue, transfer, adjustment, closing; quantity reconciliation |
| Daftar aset | School, location, custodian, condition | Asset tag, source/acquisition date, cost, custodian, condition, warranty, useful life and status |
| Hasil stock opname | Date, location, category | Book quantity vs counted quantity, variance, explanation, reviewer and adjustment approval |
| Pemeliharaan aset | Asset, priority, date range | Ticket, downtime, maintenance due date, work log, costs and overdue status |
| Rekap pengadaan | Budget line, requester, stage, vendor | Request, quotation comparison, approval, purchase order, receipt inspection and invoice match |

## Accounting and finance

| Report | Required filters | Specific output / checks |
|---|---|---|
| Buku kas/bank | Account, date range | Opening balance, receipts, payments, references, closing balance and reconciliation status |
| Jurnal umum | Period, account, source | Balanced debit/credit lines, source document, preparer, reviewer, posting/reversal status |
| Buku besar & neraca saldo | Period, account range | Opening, movement, closing; debit/credit balance check |
| Anggaran vs realisasi | Fiscal period, school, cost center, funding source | Budget, committed, actual, remaining, variance and explanation |
| Piutang tagihan siswa | Academic period, payer, aging bucket | Invoice, due date, billed, paid, credit/aid, balance, aging and dispute status; finance-only details |
| Utang vendor | Vendor, due date, status | Invoice, receipt/PO match, due date, outstanding, approval and payment reconciliation |
| Rekonsiliasi payroll | Payroll period, account | Approved payroll totals vs journal and payment batch; unmatched entries |
| Tutup buku periode | Period, unit | Reconciliation checklist, unposted journals, open exceptions, reviewer approval and lock timestamp |

## CRM, service and leadership

| Report | Required filters | Specific output / checks |
|---|---|---|
| Funnel PPDB | Intake, source/campaign, level | Inquiry-to-enrollment conversion, aging at stage, follow-up due, response time |
| Tiket layanan keluarga | Category, SLA, owner, status | Open/overdue/resolved, resolution time, escalation and satisfaction follow-up; mask sensitive narrative |
| Ringkasan operasional pimpinan | Period, school/unit | Enrollment, attendance, staffing, budget/actual, collection, asset issues and unresolved risks with source drill-down |
| Audit aktivitas | Period, actor, school, action, entity | Who/what/when/request reference; no secret/token values or unnecessary sensitive payloads |
| Kualitas data & integrasi | Source, run, period | Failed imports/exports, webhook delivery, retries, duplicate candidates, unresolved mapping and owner |

## Official-format governance

Maintain a registry for every external official form/report with: issuing authority, document/API URL, release/version, effective date, applicable level, field mapping, validation rules, test fixtures, reviewer, and last-verified date. The export must identify its format version. If no approved API/interface exists, provide a controlled file export and never describe it as a live official integration.
