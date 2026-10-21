-- School OS migration 0003: HR attendance/payroll, inventory, and accounting primitives.
-- Apply only after 0002_school_master_data.sql. Payroll/accounting posting remains application-controlled.
BEGIN;

CREATE TABLE IF NOT EXISTS public.employee_attendance (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  employee_id uuid NOT NULL,
  attendance_date date NOT NULL,
  scheduled_minutes integer NOT NULL DEFAULT 0 CHECK (scheduled_minutes >= 0),
  worked_minutes integer NOT NULL DEFAULT 0 CHECK (worked_minutes >= 0),
  attendance_status text NOT NULL CHECK (attendance_status IN ('present','sick','leave','permitted','absent','late','remote','school_duty')),
  late_minutes integer NOT NULL DEFAULT 0 CHECK (late_minutes >= 0),
  overtime_minutes integer NOT NULL DEFAULT 0 CHECK (overtime_minutes >= 0),
  source_code text NOT NULL DEFAULT 'manual' CHECK (source_code IN ('manual','approved_import','device','corrected')),
  correction_reason text,
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  recorded_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (school_id, employee_id) REFERENCES public.employees(school_id, id) ON DELETE RESTRICT,
  UNIQUE (employee_id, attendance_date)
);
CREATE INDEX IF NOT EXISTS idx_employee_attendance_school_date ON public.employee_attendance (school_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_employee_attendance_employee_date ON public.employee_attendance (employee_id, attendance_date DESC);

CREATE TABLE IF NOT EXISTS public.pay_components (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  component_code text NOT NULL,
  component_name text NOT NULL,
  component_type text NOT NULL CHECK (component_type IN ('earning','deduction','employer_contribution','information')),
  calculation_method text NOT NULL CHECK (calculation_method IN ('fixed','per_attendance_day','per_overtime_hour','percentage','manual')),
  default_amount numeric(14,2) NOT NULL DEFAULT 0 CHECK (default_amount >= 0),
  taxable_flag boolean NOT NULL DEFAULT false,
  attendance_sensitive boolean NOT NULL DEFAULT false,
  effective_from date NOT NULL,
  effective_until date,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (effective_until IS NULL OR effective_until >= effective_from),
  UNIQUE (school_id, component_code),
  UNIQUE (school_id, id)
);

CREATE TABLE IF NOT EXISTS public.employee_pay_component_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  employee_id uuid NOT NULL,
  pay_component_id uuid NOT NULL,
  amount_override numeric(14,2) CHECK (amount_override IS NULL OR amount_override >= 0),
  percentage_override numeric(7,4) CHECK (percentage_override IS NULL OR (percentage_override >= 0 AND percentage_override <= 100)),
  effective_from date NOT NULL,
  effective_until date,
  approval_status text NOT NULL DEFAULT 'pending' CHECK (approval_status IN ('pending','approved','rejected','ended')),
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (effective_until IS NULL OR effective_until >= effective_from),
  FOREIGN KEY (school_id, employee_id) REFERENCES public.employees(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, pay_component_id) REFERENCES public.pay_components(school_id, id) ON DELETE RESTRICT,
  UNIQUE (school_id, employee_id, pay_component_id, effective_from)
);
CREATE INDEX IF NOT EXISTS idx_employee_pay_assignments_effective ON public.employee_pay_component_assignments (school_id, employee_id, effective_from, effective_until);

CREATE TABLE IF NOT EXISTS public.payroll_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  period_start date NOT NULL,
  period_end date NOT NULL,
  payroll_code text NOT NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','review','approved','closed','cancelled')),
  attendance_cutoff_at timestamptz,
  prepared_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  reviewed_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  closed_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  closed_at timestamptz,
  gross_total numeric(16,2) NOT NULL DEFAULT 0 CHECK (gross_total >= 0),
  deduction_total numeric(16,2) NOT NULL DEFAULT 0 CHECK (deduction_total >= 0),
  net_total numeric(16,2) NOT NULL DEFAULT 0 CHECK (net_total >= 0),
  calculation_version text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT payroll_runs_period_check CHECK (period_end >= period_start),
  CONSTRAINT payroll_runs_net_pay_math_check CHECK (net_total = gross_total - deduction_total),
  UNIQUE (school_id, payroll_code),
  UNIQUE (school_id, id),
  UNIQUE (school_id, period_start, period_end)
);

CREATE TABLE IF NOT EXISTS public.payroll_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  payroll_run_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  employee_number_snapshot text NOT NULL,
  employee_name_snapshot text NOT NULL,
  attendance_summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  component_breakdown jsonb NOT NULL DEFAULT '[]'::jsonb,
  gross_pay numeric(14,2) NOT NULL CHECK (gross_pay >= 0),
  deduction_total numeric(14,2) NOT NULL CHECK (deduction_total >= 0),
  net_pay numeric(14,2) NOT NULL CHECK (net_pay >= 0),
  payslip_storage_key text,
  payment_status text NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending','prepared','paid','failed','reversed')),
  payment_reference text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (net_pay = gross_pay - deduction_total),
  FOREIGN KEY (school_id, payroll_run_id) REFERENCES public.payroll_runs(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, employee_id) REFERENCES public.employees(school_id, id) ON DELETE RESTRICT,
  UNIQUE (payroll_run_id, employee_id),
  UNIQUE (school_id, id)
);
CREATE INDEX IF NOT EXISTS idx_payroll_entries_employee ON public.payroll_entries (school_id, employee_id, payroll_run_id);
CREATE INDEX IF NOT EXISTS idx_payroll_entries_payment ON public.payroll_entries (school_id, payment_status);

CREATE TABLE IF NOT EXISTS public.inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  item_code text NOT NULL,
  item_name text NOT NULL,
  item_category text NOT NULL CHECK (item_category IN ('learning_material','stationery','cleaning','it_equipment','furniture','laboratory','sports','medical','other')),
  unit_name text NOT NULL,
  specification text,
  storage_location text,
  minimum_quantity numeric(14,3) NOT NULL DEFAULT 0 CHECK (minimum_quantity >= 0),
  is_asset boolean NOT NULL DEFAULT false,
  custodian_employee_id uuid,
  item_status text NOT NULL DEFAULT 'active' CHECK (item_status IN ('active','inactive','discontinued')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, item_code),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, custodian_employee_id) REFERENCES public.employees(school_id, id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.inventory_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  inventory_item_id uuid NOT NULL,
  movement_date date NOT NULL DEFAULT CURRENT_DATE,
  movement_type text NOT NULL CHECK (movement_type IN ('opening','receipt','issue','transfer_in','transfer_out','adjustment','return','disposal')),
  quantity_delta numeric(14,3) NOT NULL CHECK (quantity_delta <> 0),
  unit_cost numeric(14,2) CHECK (unit_cost IS NULL OR unit_cost >= 0),
  reference_code text,
  reason text,
  source_document_key text,
  recorded_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (school_id, inventory_item_id) REFERENCES public.inventory_items(school_id, id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_item_date ON public.inventory_movements (school_id, inventory_item_id, movement_date DESC);

CREATE TABLE IF NOT EXISTS public.chart_of_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  account_code text NOT NULL,
  account_name text NOT NULL,
  account_type text NOT NULL CHECK (account_type IN ('asset','liability','equity','income','expense')),
  normal_balance text NOT NULL CHECK (normal_balance IN ('debit','credit')),
  parent_account_id uuid,
  is_control_account boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, account_code),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, parent_account_id) REFERENCES public.chart_of_accounts(school_id, id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  journal_number text NOT NULL,
  journal_date date NOT NULL,
  accounting_period text NOT NULL,
  description text NOT NULL,
  source_type text NOT NULL,
  source_reference text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','review','approved','posted','reversed')),
  debit_total numeric(16,2) NOT NULL DEFAULT 0 CHECK (debit_total >= 0),
  credit_total numeric(16,2) NOT NULL DEFAULT 0 CHECK (credit_total >= 0),
  prepared_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  posted_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  posted_at timestamptz,
  reverses_entry_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, journal_number),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, reverses_entry_id) REFERENCES public.journal_entries(school_id, id) ON DELETE RESTRICT,
  CONSTRAINT journal_entries_posted_balance_check CHECK (status <> 'posted' OR (debit_total > 0 AND debit_total = credit_total))
);

CREATE TABLE IF NOT EXISTS public.journal_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  journal_entry_id uuid NOT NULL,
  line_number integer NOT NULL CHECK (line_number > 0),
  account_id uuid NOT NULL,
  description text,
  debit_amount numeric(16,2) NOT NULL DEFAULT 0 CHECK (debit_amount >= 0),
  credit_amount numeric(16,2) NOT NULL DEFAULT 0 CHECK (credit_amount >= 0),
  cost_center_code text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((debit_amount > 0 AND credit_amount = 0) OR (credit_amount > 0 AND debit_amount = 0)),
  FOREIGN KEY (school_id, journal_entry_id) REFERENCES public.journal_entries(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, account_id) REFERENCES public.chart_of_accounts(school_id, id) ON DELETE RESTRICT,
  UNIQUE (journal_entry_id, line_number)
);
CREATE INDEX IF NOT EXISTS idx_journal_entries_school_date ON public.journal_entries (school_id, journal_date DESC, status);
CREATE INDEX IF NOT EXISTS idx_journal_lines_entry ON public.journal_lines (school_id, journal_entry_id, line_number);
CREATE INDEX IF NOT EXISTS idx_journal_lines_account ON public.journal_lines (school_id, account_id);

COMMIT;
