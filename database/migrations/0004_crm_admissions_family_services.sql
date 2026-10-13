-- School OS migration 0004: admissions CRM, family service desk, and website publishing contracts.
-- Apply after migrations 0001–0003. Website access must go through an authenticated/allowlisted API.
BEGIN;

CREATE TABLE IF NOT EXISTS public.admission_inquiries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  inquiry_number text NOT NULL,
  contact_name text NOT NULL,
  contact_email text,
  contact_phone text,
  target_education_level text NOT NULL CHECK (target_education_level IN ('KB','TK','SD','SMP','SMA','SMK','OTHER')),
  intended_academic_year_id uuid,
  lead_source text NOT NULL DEFAULT 'website' CHECK (lead_source IN ('website','referral','school_visit','phone','social','event','other')),
  campaign_code text,
  contact_consent_status text NOT NULL DEFAULT 'unknown' CHECK (contact_consent_status IN ('unknown','granted','withdrawn','not_required')),
  pipeline_stage text NOT NULL DEFAULT 'new' CHECK (pipeline_stage IN ('new','contacted','visit_scheduled','application_started','application_submitted','offered','waitlisted','accepted','enrolled','declined','lost')),
  next_follow_up_at timestamptz,
  assigned_to_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  lost_reason text,
  notes_private text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, inquiry_number),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, intended_academic_year_id) REFERENCES public.academic_years(school_id, id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_admission_inquiries_pipeline ON public.admission_inquiries (school_id, pipeline_stage, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admission_inquiries_followup ON public.admission_inquiries (school_id, next_follow_up_at) WHERE next_follow_up_at IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.admission_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  inquiry_id uuid NOT NULL,
  application_number text NOT NULL,
  student_candidate_name text NOT NULL,
  birth_date date,
  target_education_level text NOT NULL CHECK (target_education_level IN ('KB','TK','SD','SMP','SMA','SMK','OTHER')),
  intended_academic_year_id uuid NOT NULL,
  document_checklist jsonb NOT NULL DEFAULT '[]'::jsonb,
  review_status text NOT NULL DEFAULT 'draft' CHECK (review_status IN ('draft','submitted','in_review','incomplete','eligible','ineligible','offered','waitlisted','accepted','declined','withdrawn')),
  decision_reason text,
  reviewed_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  reviewed_at timestamptz,
  linked_student_id uuid,
  submitted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, application_number),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, inquiry_id) REFERENCES public.admission_inquiries(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, intended_academic_year_id) REFERENCES public.academic_years(school_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (school_id, linked_student_id) REFERENCES public.students(school_id, id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_admission_applications_year_status ON public.admission_applications (school_id, intended_academic_year_id, review_status);

CREATE TABLE IF NOT EXISTS public.family_service_tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  ticket_number text NOT NULL,
  category text NOT NULL CHECK (category IN ('admissions','academic','attendance','billing','documents','facility','complaint','safeguarding','technical','other')),
  subject text NOT NULL,
  description_private text NOT NULL,
  priority text NOT NULL DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open','assigned','waiting_family','waiting_school','resolved','closed')),
  requester_name text NOT NULL,
  requester_email text,
  requester_phone text,
  guardian_person_id uuid REFERENCES public.people(id) ON DELETE RESTRICT,
  student_id uuid,
  assigned_to_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  due_at timestamptz,
  resolved_at timestamptz,
  resolution_summary text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, ticket_number),
  UNIQUE (school_id, id),
  FOREIGN KEY (school_id, student_id) REFERENCES public.students(school_id, id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_family_tickets_sla ON public.family_service_tickets (school_id, status, priority, due_at);
CREATE INDEX IF NOT EXISTS idx_family_tickets_assignee ON public.family_service_tickets (school_id, assigned_to_user_id, status);

CREATE TABLE IF NOT EXISTS public.school_publications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  content_type text NOT NULL CHECK (content_type IN ('school_profile','announcement','news','calendar_event','admissions_info','faq')),
  slug text NOT NULL,
  title text NOT NULL,
  summary text,
  body_markdown text NOT NULL,
  locale_code text NOT NULL DEFAULT 'id-ID',
  publication_status text NOT NULL DEFAULT 'draft' CHECK (publication_status IN ('draft','in_review','published','archived')),
  visible_from timestamptz,
  visible_until timestamptz,
  approved_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  published_at timestamptz,
  updated_by_user_id uuid REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (visible_until IS NULL OR visible_from IS NULL OR visible_until >= visible_from),
  UNIQUE (school_id, locale_code, slug),
  UNIQUE (school_id, id)
);
CREATE INDEX IF NOT EXISTS idx_school_publications_public_feed ON public.school_publications (school_id, content_type, published_at DESC) WHERE publication_status = 'published';

CREATE TABLE IF NOT EXISTS public.integration_outbox (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE RESTRICT,
  destination_code text NOT NULL,
  event_type text NOT NULL,
  event_key text NOT NULL,
  payload_minimal jsonb NOT NULL DEFAULT '{}'::jsonb,
  payload_hash text,
  delivery_status text NOT NULL DEFAULT 'pending' CHECK (delivery_status IN ('pending','processing','delivered','retry','dead_letter','cancelled')),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  next_attempt_at timestamptz,
  last_error_code text,
  created_at timestamptz NOT NULL DEFAULT now(),
  delivered_at timestamptz,
  UNIQUE (school_id, destination_code, event_key)
);
CREATE INDEX IF NOT EXISTS idx_integration_outbox_pending ON public.integration_outbox (delivery_status, next_attempt_at, created_at) WHERE delivery_status IN ('pending','retry');

COMMIT;
