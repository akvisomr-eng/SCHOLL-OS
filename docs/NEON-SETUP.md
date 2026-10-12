# Neon setup and safety checklist

The provided Neon project/branch URL identifies the intended database environment, but this repository does not receive access to its credentials from the URL alone. Never paste connection strings or passwords into Git commits or public issues.

## Before applying migrations

1. Open the intended Neon project and verify project name, branch name, and database name in the console.
2. Create or use a development branch; do not apply initial schema to production by assumption.
3. Copy the connection string into a local environment variable named `DATABASE_URL` or a protected GitHub Actions secret. Do not commit real values.
4. Confirm the connection uses SSL and least-privilege credentials.
5. Review `database/migrations/0001_foundation.sql` and take a branch/snapshot as supported by the current Neon plan.
6. Apply the migration only to the verified target branch, then inspect created tables and indexes.
7. Record migration ID, branch, timestamp, and result in the project log.

## Current limitation

No database connection was executed by this repository initialization. The schema file is prepared but **has not been applied to Neon**. Use a migration runner or Neon SQL Editor after verifying the target branch. Application code must use server-side database access only; never expose `DATABASE_URL` to browser code.

## Required before real student data

- Authentication and server-side authorization for every protected operation.
- Explicit tenant/school scoping and tests against cross-school access.
- Retention, export, correction, and deletion policies consistent with applicable requirements.
- Audit trails that do not accidentally log passwords, tokens, or unnecessary child data.
