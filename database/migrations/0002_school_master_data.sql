-- School OS migration 0002: school master data and academic operations.
-- Safe to apply repeatedly; production rollout must use the reviewed migration workflow.
-- Official Dapodik identifiers remain optional until verified against authoritative source data.
BEGIN;

CREATE TABLE IF NOT EXISTS public.people (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  legal_name text NOT NULL CHECK (length(trim(legal_name)) > 0),
  preferred_name text,
  birth_date date,
  sex_code text CHECK (sex_code IS NULL OR sex_code IN ('M','F','U')),
  primary_email text,
  primary_phone text,
  address_line text,
  village_name text,
  district_name text,
  regency_name text,
  province_name text,
  postal_code text,
  record_status text NOT NULL DEFAULT 'active' CHECK (record_status IN ('active','inactive','archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, id)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_schools_organization_id_id ON public.schools (organization_id, id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_academic_years_school_id_id ON public.academic_years (school_id, id);

CREATE INDEX IF NOT EXISTS idx_people_org_name ON public.people (organization_id, legal_name);
CREATE INDEX IF NOT EXISTS idx_people_org_status ON public.people (organization_id, record_status);

CREATE TABLE IF NOT EXISTS public.students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  person_id uuid NOT NULL,
  local_student_number text NOT NULL,
  nisn text,
  previous_school_name text,
  admission_date date,
  enrollment_status text NOT NULL DEFAULT 'applicant' CHECK (enrollment_status IN ('applicant','active','transferred','graduated','withdrawn','inactive')),
  withdrawal_date date,
  withdrawal_reason text,
  data_source text NOT NULL DEFAULT 'school_entry' CHECK (data_source IN ('school_entry','verified_import','official_export','other')),
  verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, local_student_number),
  UNIQUE (school_id, id),
  FOREIGN KEY (organization_id, school_id) REFERENCES public.schools(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, person_id) REFERENCES public.people(organization_id, id) ON DELETE RESTRICT,
  CHECK (withdrawal_date IS NULL OR admission_date IS NULL OR withdrawal_date >= admission_date)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_students_school_nisn
  ON public.students (school_id, nisn) WHERE nisn IS NOT NULL AND length(trim(nisn)) > 0;
CREATE INDEX IF NOT EXISTS idx_students_school_status ON public.students (school_id, enrollment_status);
CREATE INDEX IF NOT EXISTS idx_students_person ON public.students (person_id);

CREATE TABLE IF NOT EXISTS public.guardian_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL,
  guardian_person_id uuid NOT NULL,
  relationship_code text NOT NULL CHECK (relationship_code IN ('mother','father','legal_guardian','grandparent','other')),
  is_primary_contact boolean NOT NULL DEFAULT false,
  can_receive_academic_updates boolean NOT NULL DEFAULT true,
  can_receive_billing_updates boolean NOT NULL DEFAULT false,
  legal_authority_verified boolean NOT NULL DEFAULT false,
  starts_on date NOT NULL DEFAULT CURRENT_DATE,
  ends_on date,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_on IS NULL OR ends_on >= starts_on),
  UNIQUE (student_id, guardian_person_id, relationship_code, starts_on),
  FOREIGN KEY (organization_id, school_id) REFERENCES public.schools(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, student_id) REFERENCES public.students(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, guardian_person_id) REFERENCES public.people(organization_id, id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_guardian_links_student ON public.guardian_links (school_id, student_id);
CREATE INDEX IF NOT EXISTS idx_guardian_links_person ON public.guardian_links (guardian_person_id);

CREATE TABLE IF NOT EXISTS public.employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  person_id uuid NOT NULL,
  employee_number text NOT NULL,
  nuptk text,
  employment_type text NOT NULL CHECK (employment_type IN ('permanent','fixed_term','part_time','honorary','outsourced','volunteer','other')),
  employee_category text NOT NULL CHECK (employee_category IN ('teacher','education_staff','leadership','support','other')),
  position_title text NOT NULL,
  department_name text,
  employment_status text NOT NULL DEFAULT 'active' CHECK (employment_status IN ('active','leave','suspended','ended')),
  start_date date NOT NULL,
  end_date date,
  qualification_summary text,
  verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, employee_number),
  UNIQUE (school_id, id),
  FOREIGN KEY (organization_id, school_id) REFERENCES public.schools(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, person_id) REFERENCES public.people(organization_id, id) ON DELETE RESTRICT,
  CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_employees_school_nuptk
  ON public.employees (school_id, nuptk) WHERE nuptk IS NOT NULL AND length(trim(nuptk)) > 0;
CREATE INDEX IF NOT EXISTS idx_employees_school_status ON public.employees (school_id, employment_status);
CREATE INDEX IF NOT EXISTS idx_employees_person ON public.employees (person_id);

CREATE TABLE IF NOT EXISTS public.class_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  academic_year_id uuid NOT NULL,
  class_code text NOT NULL,
  class_name text NOT NULL,
  education_level text NOT NULL CHECK (education_level IN ('KB','TK','SD','SMP','SMA','SMK','OTHER')),
  grade_label text NOT NULL,
  capacity integer CHECK (capacity IS NULL OR capacity > 0),
  homeroom_employee_id uuid,
  room_label text,
  group_status text NOT NULL DEFAULT 'active' CHECK (group_status IN ('planned','active','closed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (academic_year_id, class_code),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, academic_year_id) REFERENCES public.academic_years(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, homeroom_employee_id) REFERENCES public.employees(school_id, id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_class_groups_school_year ON public.class_groups (school_id, academic_year_id, group_status);

CREATE TABLE IF NOT EXISTS public.student_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  academic_year_id uuid NOT NULL,
  student_id uuid NOT NULL,
  class_group_id uuid NOT NULL,
  enrollment_status text NOT NULL DEFAULT 'active' CHECK (enrollment_status IN ('active','moved','completed','cancelled')),
  starts_on date NOT NULL,
  ends_on date,
  change_reason text,
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_on IS NULL OR ends_on >= starts_on),
  UNIQUE (academic_year_id, student_id),
  UNIQUE (school_id, id),
  UNIQUE (school_id, academic_year_id, id),
  FOREIGN KEY (school_id, academic_year_id) REFERENCES public.academic_years(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, student_id) REFERENCES public.students(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, class_group_id) REFERENCES public.class_groups(school_id, id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_student_enrollments_school_class ON public.student_enrollments (school_id, class_group_id, enrollment_status);
CREATE INDEX IF NOT EXISTS idx_student_enrollments_student ON public.student_enrollments (student_id, academic_year_id);

CREATE TABLE IF NOT EXISTS public.student_attendance (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  academic_year_id uuid NOT NULL,
  student_enrollment_id uuid NOT NULL,
  attendance_date date NOT NULL,
  session_code text NOT NULL DEFAULT 'full_day',
  attendance_status text NOT NULL CHECK (attendance_status IN ('present','sick','permitted','absent','late','left_early','school_activity')),
  minutes_late integer NOT NULL DEFAULT 0 CHECK (minutes_late >= 0),
  reason text,
  evidence_reference text,
  recorded_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  reviewed_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  reviewed_at timestamptz,
  correction_of_id uuid REFERENCES public.student_attendance(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_enrollment_id, attendance_date, session_code),
  FOREIGN KEY (school_id, academic_year_id) REFERENCES public.academic_years(school_id, id) ON DELETE RESTRICT,
  CONSTRAINT student_attendance_enrollment_scope_fkey FOREIGN KEY (school_id, academic_year_id, student_enrollment_id) REFERENCES public.student_enrollments(school_id, academic_year_id, id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_student_attendance_school_date ON public.student_attendance (school_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_student_attendance_enrollment_date ON public.student_attendance (student_enrollment_id, attendance_date DESC);

COMMIT;
