# Dapodik 2027 integration plan

## Integration boundary

The Dapodik Windows installer (`.exe`) is a compiled application, not source code for this repository. Do not execute it in CI, unpack it as application source, or commit/bundle it into School OS.

## Supported implementation path

1. Confirm the exact Dapodik 2027 release and official release notes with the relevant official Kemendikdasmen/Dapodik channel.
2. Determine which official export/import format or authorized API is available to this school/operator.
3. Obtain written permission and technical documentation for any protected service/API; do not reverse engineer or bypass access controls.
4. Build a staging importer with upload validation, schema/version detection, field mapping, duplicate detection, dry-run preview, row-level errors, and explicit confirmation before writing.
5. Keep a source reference and import batch ID for traceability; log counts and outcomes without dumping sensitive student records into logs.
6. Add reconciliation reports and role-limited correction workflows.
7. Test with synthetic or minimized data before any real data.

## Mapping areas to assess

School identity and reference codes; students; guardians where authorized; academic year; class/rombel; teacher/staff references; and any other fields supported by the official format. Do not assume fields or endpoints exist until verified from the official documentation for the target release.

## Acceptance criteria

- Invalid or unsupported schema version is rejected with a clear error.
- Dry-run does not change business tables.
- Duplicate imports are idempotent or flagged for resolution.
- A reviewer can see the proposed changes before applying them.
- Every applied batch is auditable and can be reconciled.
- Authorization and privacy checks pass.
