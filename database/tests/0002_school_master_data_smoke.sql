-- Fails the CI job if migration 0002 did not create its required tables or scope constraints.
DO $$
DECLARE
  missing_tables text;
  missing_constraints text;
BEGIN
  SELECT string_agg(expected.table_name, ', ' ORDER BY expected.table_name)
    INTO missing_tables
  FROM (VALUES ('people'), ('students'), ('guardian_links'), ('employees'),
               ('class_groups'), ('student_enrollments'), ('student_attendance')) AS expected(table_name)
  WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.tables t
    WHERE t.table_schema = 'public' AND t.table_name = expected.table_name
  );

  IF missing_tables IS NOT NULL THEN
    RAISE EXCEPTION 'Missing School OS master-data tables: %', missing_tables;
  END IF;

  SELECT string_agg(expected.constraint_name, ', ' ORDER BY expected.constraint_name)
    INTO missing_constraints
  FROM (VALUES
    ('students', 'students_organization_id_person_id_fkey'),
    ('students', 'students_organization_id_school_id_fkey'),
    ('guardian_links', 'guardian_links_organization_id_guardian_person_id_fkey'),
    ('employees', 'employees_organization_id_person_id_fkey'),
    ('class_groups', 'class_groups_school_id_academic_year_id_fkey'),
    ('student_enrollments', 'student_enrollments_school_id_class_group_id_fkey'),
    ('student_attendance', 'student_attendance_enrollment_scope_fkey')
  ) AS expected(table_name, constraint_name)
  WHERE NOT EXISTS (
    SELECT 1 FROM pg_constraint c
    JOIN pg_class r ON r.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = r.relnamespace
    WHERE n.nspname = 'public'
      AND r.relname = expected.table_name
      AND c.conname = expected.constraint_name
  );

  IF missing_constraints IS NOT NULL THEN
    RAISE EXCEPTION 'Missing School OS tenant-scope constraints: %', missing_constraints;
  END IF;
END $$;

SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('people','students','guardian_links','employees','class_groups','student_enrollments','student_attendance')
ORDER BY tablename, indexname;
