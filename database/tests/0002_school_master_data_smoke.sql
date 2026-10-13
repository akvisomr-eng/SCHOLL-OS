-- Read-only schema smoke checks for migration 0002.
-- Run against a disposable Neon branch after applying the migration.
WITH expected(table_name) AS (
  VALUES ('people'), ('students'), ('guardian_links'), ('employees'),
         ('class_groups'), ('student_enrollments'), ('student_attendance')
)
SELECT e.table_name,
       (c.table_name IS NOT NULL) AS exists_in_public_schema
FROM expected e
LEFT JOIN information_schema.tables c
  ON c.table_schema = 'public'
 AND c.table_name = e.table_name
ORDER BY e.table_name;

-- Check required uniqueness and indexes exist.
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('people','students','guardian_links','employees','class_groups','student_enrollments','student_attendance')
ORDER BY tablename, indexname;
