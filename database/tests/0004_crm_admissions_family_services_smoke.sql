-- Fails CI if CRM, family service and website publishing tables are missing.
DO $$
DECLARE missing_tables text;
BEGIN
  SELECT string_agg(e.table_name, ', ' ORDER BY e.table_name) INTO missing_tables
  FROM (VALUES ('admission_inquiries'), ('admission_applications'), ('family_service_tickets'), ('school_publications'), ('integration_outbox')) AS e(table_name)
  WHERE NOT EXISTS (SELECT 1 FROM information_schema.tables t WHERE t.table_schema='public' AND t.table_name=e.table_name);
  IF missing_tables IS NOT NULL THEN RAISE EXCEPTION 'Missing CRM/website tables: %', missing_tables; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='idx_school_publications_public_feed') THEN
    RAISE EXCEPTION 'Published-content-only index missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='idx_integration_outbox_pending') THEN
    RAISE EXCEPTION 'Integration retry index missing';
  END IF;
END $$;
