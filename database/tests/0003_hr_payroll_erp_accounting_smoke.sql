-- Fails CI if HR/payroll, inventory, or accounting tables/critical constraints are missing.
DO $$
DECLARE missing_tables text;
BEGIN
  SELECT string_agg(e.table_name, ', ' ORDER BY e.table_name) INTO missing_tables
  FROM (VALUES ('employee_attendance'), ('pay_components'), ('employee_pay_component_assignments'),
               ('payroll_runs'), ('payroll_entries'), ('inventory_items'), ('inventory_movements'),
               ('chart_of_accounts'), ('journal_entries'), ('journal_lines')) AS e(table_name)
  WHERE NOT EXISTS (SELECT 1 FROM information_schema.tables t WHERE t.table_schema='public' AND t.table_name=e.table_name);
  IF missing_tables IS NOT NULL THEN RAISE EXCEPTION 'Missing HR/ERP/finance tables: %', missing_tables; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payroll_runs_net_total_check') THEN
    RAISE EXCEPTION 'Payroll net-total consistency constraint missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='journal_entries_posted_balance_check') THEN
    RAISE EXCEPTION 'Posted journal balance constraint missing';
  END IF;
END $$;
