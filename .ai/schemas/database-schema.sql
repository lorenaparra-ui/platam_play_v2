CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE "statuses" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "entity_type" varchar(100) NOT NULL,
  "code" varchar(50) NOT NULL,
  "display_name" varchar(100) NOT NULL,
  "description" text,
  "is_active" boolean NOT NULL DEFAULT true,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()),
  UNIQUE ("entity_type", "code")
);

INSERT INTO "statuses" ("entity_type", "code", "display_name") VALUES
  ('users', 'active', 'Activo'),
  ('users', 'blocked', 'Bloqueado'),
  ('users', 'suspended', 'Suspendido'),
  ('users', 'pending', 'Pendiente'),
  ('partners', 'active', 'Activo'),
  ('partners', 'inactive', 'Inactivo'),
  ('partners', 'blocked', 'Bloqueado'),
  ('partner_categories', 'active', 'Activo'),
  ('partner_categories', 'inactive', 'Inactivo'),
  ('partner_categories', 'archived', 'Archivado'),
  ('credit_applications_bnpl', 'authorized', 'Autorizado'),
  ('credit_applications_bnpl', 'cancelled', 'Cancelado'),
  ('credit_applications_bnpl', 'delinquent', 'En mora'),
  ('credit_applications_bnpl', 'closed', 'Cerrado'),
  ('sales_representatives', 'active', 'Activo'),
  ('sales_representatives', 'inactive', 'Inactivo'),
  ('sales_representatives', 'blocked', 'Bloqueado'),
  ('contracts', 'pending', 'Pendiente'),
  ('contracts', 'signed', 'Firmado'),
  ('contracts', 'cancelled', 'Cancelado'),
  ('contract_signers', 'pending', 'Pendiente'),
  ('contract_signers', 'signed', 'Firmado'),
  ('contract_signers', 'declined', 'Rechazado'),
  ('product_bnpl', 'active', 'Activo'),
  ('product_bnpl', 'inactive', 'Inactivo'),
  ('product_bnpl', 'blocked', 'Bloqueado'),
  ('documents', 'pending', 'Pendiente'),
  ('documents', 'verified', 'Verificado'),
  ('documents', 'rejected', 'Rechazado');

CREATE OR REPLACE FUNCTION get_status_id(p_entity_type text, p_code text)
RETURNS BIGINT
LANGUAGE sql
STABLE
AS $$
  SELECT s.id
  FROM statuses s
  WHERE s.entity_type = p_entity_type
    AND s.code = p_code
    AND s.is_active = true
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION validate_status_entity()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  expected_entity text := TG_ARGV[0];
  status_column text := TG_ARGV[1];
  incoming_status_id BIGINT;
  actual_entity text;
BEGIN
  IF status_column = 'status_id' THEN
    incoming_status_id := NEW.status_id;
  ELSIF status_column = 'verification_status_id' THEN
    incoming_status_id := NEW.verification_status_id;
  ELSE
    RAISE EXCEPTION 'Unsupported status column: %', status_column;
  END IF;

  IF incoming_status_id IS NULL THEN
    RAISE EXCEPTION 'Status id cannot be NULL for %', expected_entity;
  END IF;

  SELECT s.entity_type
    INTO actual_entity
  FROM statuses s
  WHERE s.id = incoming_status_id
    AND s.is_active = true;

  IF actual_entity IS NULL THEN
    RAISE EXCEPTION 'Status id % does not exist or is inactive', incoming_status_id;
  END IF;

  IF actual_entity <> expected_entity THEN
    RAISE EXCEPTION
      'Status id % belongs to entity_type %, expected %',
      incoming_status_id, actual_entity, expected_entity;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TABLE "users" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "cognito_sub" uuid UNIQUE NOT NULL,
  "email" varchar UNIQUE NOT NULL,
  "phone" varchar UNIQUE,
  "role_id" BIGINT,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('users', 'active'),
  "last_login_at" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "roles" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "name" varchar(80) NOT NULL UNIQUE,
  "description" text,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()) 
);

CREATE TABLE "permissions" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "code" varchar(120) NOT NULL UNIQUE,
  "description" text,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "role_permissions" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "role_id" BIGINT NOT NULL,
  "permission_id" BIGINT NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()),
  UNIQUE ("role_id", "permission_id")
);

CREATE TABLE "persons" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "country_code" varchar(2),
  "first_name" varchar(255) NOT NULL,
  "last_name" varchar(255) NOT NULL,
  "doc_type" varchar(100) NOT NULL,
  "doc_number" varchar UNIQUE NOT NULL,
  "doc_issue_date" date,
  "birth_date" date,
  "gender" varchar(20),
  "phone" varchar,
  "residential_address" text,
  "business_address" text,
  "city_id" BIGINT,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "companies" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "country_code" varchar(2),
  "city_id" BIGINT,
  "legal_name" varchar (255) NOT NULL,
  "trade_name" varchar (255),
  "tax_id" varchar (50) UNIQUE NOT NULL,
  "year_of_establishment" int,
  "business_activity_code" varchar(10),
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "legal_representatives" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "company_id" BIGINT NOT NULL,
  "person_id" BIGINT NOT NULL,
  "is_primary" boolean DEFAULT true,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "shareholders" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "company_id" BIGINT NOT NULL,
  "person_id" BIGINT NOT NULL,
  "ownership_percentage" decimal(5,4),
  "evaluation_order" int,
  "credit_check_required" boolean DEFAULT false,
  "credit_check_completed" boolean DEFAULT false,
  "is_legal_representative" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "guarantors" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "credit_application_id" BIGINT NOT NULL,
  "person_id" BIGINT NOT NULL,
  "contract_signer_id" BIGINT,
  "guarantor_type" varchar(20) NOT NULL CHECK ("guarantor_type" IN ('personal', 'corporate', 'spousal', 'third_party')),
  "relationship_to_applicant" varchar(100),
  "is_primary_guarantor" boolean DEFAULT false,
  "selected_after_credit_check" boolean DEFAULT false,
  "signature_url" text,
  "signature_date" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "partners" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "country_code" varchar(2),
  "company_name" varchar (255) NOT NULL,
  "trade_name" varchar (255),
  "acronym" varchar(10),
  "logo_url" text,
  "co_branding_logo_url" text,
  "primary_color" varchar(20),
  "secondary_color" varchar(20),
  "light_color" varchar(20),
  "sales_rep_role_name" varchar(50) DEFAULT 'Sales Rep',
  "sales_rep_role_name_plural" varchar(50) DEFAULT 'Sales Reps',
  "api_key_hash" varchar,
  "notification_email" varchar,
  "webhook_url" text,
  "send_sales_rep_voucher" boolean DEFAULT false,
  "disbursement_notification_email" varchar,
  "default_rep_id" BIGINT,
  "default_category_id" BIGINT,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('partners', 'active'),
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "partner_categories" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "partner_id" BIGINT NOT NULL,
  "name" varchar(100) NOT NULL,
  "discount_percentage" decimal(5,4) NOT NULL,
  "interest_rate" decimal(5,4) NOT NULL,
  "disbursement_fee_percent" decimal(5,4),
  "minimum_disbursement_fee" bigint,
  "delay_days" int NOT NULL,
  "term_days" int NOT NULL,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('partner_categories', 'active'),
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "credit_applications_bnpl" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "user_product_id" BIGINT,
  "partner_id" BIGINT,
  "partner_category_id" BIGINT,
  "sales_rep_id" BIGINT,
  "business_name" varchar(255),
  "business_type" varchar(50) CHECK ( /*pendiente de revisar*/
    "business_type" IN (
      'Distribuidor / Mayorista',
      'Venta de productos de belleza',
      'Servicios de belleza',
      'Miscelánea',
      'Tienda de barrio / Minimercado',
      'Profesional independiente',
      'Otro',
      'Academia de belleza',
      'Farmacia / Droguería',
      'Cafetería',
      'Servicios de belleza',
      'Vendedor independiente',
      'Tienda de muebles y hogar',
      'Retailer',
      'Entrenador',
      'Venta Online',
      'Gimnasio',
      'Restaurante',
      'Farmacia',
      'Ferreteria',
      'Tiendas de ropa, calzado, accesorios',
      'Supermercado',
      'Centro de estética',
      'Tienda de electrónica',
      'Carnicería'
    )
  ),
  "business_address" text,
  "business_city" varchar(120),
  "number_of_locations" int,
  "number_of_employees" int,
  "business_seniority_id" BIGINT,
  "sector_experience" varchar,
  "relationship_to_business" varchar,
  "monthly_income" bigint,
  "monthly_expenses" bigint,
  "monthly_purchases" bigint,
  "current_purchases" bigint,
  "total_assets" bigint,
  "requested_credit_line" bigint,
  "is_current_client" boolean DEFAULT false,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('credit_applications_bnpl', 'authorized'),
  "submission_date" timestamptz,
  "approval_date" timestamptz,
  "rejection_reason" varchar(500),
  "credit_study_date" timestamptz,
  "credit_score" decimal(8,2),
  "credit_decision" varchar,
  "approved_credit_line" bigint,
  "analyst_report" text,
  "risk_profile" varchar,
  "privacy_policy_accepted" boolean DEFAULT false,
  "privacy_policy_date" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);


CREATE TABLE "business_seniority" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "range_start" int NOT NULL CHECK ("range_start" >= 0),
  "range_end" int NOT NULL CHECK ("range_end" >= "range_start"),
  "description" varchar(100) NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()),
  UNIQUE ("range_start", "range_end"),
  UNIQUE ("description")
);


CREATE TABLE "ai_agent_analysis" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "application_id" BIGINT NOT NULL,
  "html_url_agent_analysis" text,
  "json_agent_analysis" jsonb,
  "agent_analysis_timestamptz" timestamptz,
  "agent_recommended_loc" bigint,
  "agent_recomendation" bigint,
  "created_at" timestamptz DEFAULT (now()),  
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "sales_representatives" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "partner_id" BIGINT NOT NULL,
  "user_id" BIGINT,
  "name" varchar NOT NULL,
  "role" varchar NOT NULL,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('sales_representatives', 'active'),
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "contracts" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "application_id" BIGINT,
  "zapsign_token" varchar UNIQUE,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('contracts', 'pending'),
  "original_file_url" text,
  "signed_file_url" text,
  "form_answers_json" jsonb,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "contract_signers" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "contract_id" BIGINT,
  "person_id" BIGINT,
  "zapsign_signer_token" varchar,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('contract_signers', 'pending'),
  "sign_url" text,
  "ip_address" varchar(45),
  "geo_latitude" varchar(20),
  "geo_longitude" varchar(20),
  "signed_at" timestamptz,
  "document_photo_url" text,
  "document_verse_photo_url" text,
  "selfie_photo_url" text,
  "signature_image_url" text,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "user_products" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "product_type" varchar NOT NULL,
  "activated_at" timestamptz NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "product_bnpl" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_product_id" BIGINT UNIQUE NOT NULL,
  "credit_limit" bigint NOT NULL,
  "available_credit_limit" bigint NOT NULL,
  "status_id" BIGINT NOT NULL DEFAULT get_status_id('product_bnpl', 'active'),
  "has_active_payment_plan" boolean DEFAULT false,
  "notification_channels" text[],
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "bnpl_categories" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "product_bnpl_id" BIGINT,
  "category_id" BIGINT,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "risk_profile" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "user_product_id" BIGINT NOT NULL,
  "risk_profile" varchar,
  "collection_priority_score" decimal(8,4),
  "payment_probability_score" decimal(8,4),
  "internal_score" decimal(8,2),
  "hybrid_score" decimal(8,2),
  "risk_ai_reasoning" text,
  "json_proyections" jsonb,
  "json_weights" jsonb,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "documents" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "person_id" BIGINT,
  "company_id" BIGINT,
  "application_id" BIGINT,
  "document_type" varchar NOT NULL,
  "document_url" text NOT NULL,
  "verification_status_id" BIGINT NOT NULL DEFAULT get_status_id('documents', 'pending'),
  "upload_date" timestamptz DEFAULT (now()),
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "credit_reports" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" BIGINT NOT NULL,
  "person_id" BIGINT,
  "company_id" BIGINT,
  "application_id" BIGINT,
  "report_date" date NOT NULL,
  "bureau_name" varchar,
  "full_report_json" jsonb,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "currencies" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "code" varchar(3) NOT NULL,
  "name" varchar(120) NOT NULL,
  "symbol" varchar(10),
  "decimal_places" int NOT NULL DEFAULT 2 CHECK ("decimal_places" BETWEEN 0 AND 6),
  "thousand_separator" varchar(1),
  "decimal_separator" varchar(1),
  "is_active" boolean NOT NULL DEFAULT true,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()),
  UNIQUE ("code")
);

CREATE TABLE "cities" (
  "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "external_id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "country_name" varchar(120) NOT NULL,
  "country_code" varchar(2) NOT NULL,
  "state_name" varchar(120) NOT NULL,
  "state_code" varchar(3),
  "city_name" varchar(120) NOT NULL,
  "currency_id" BIGINT NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()),
  CHECK ("country_code" ~ '^[A-Z]{2}$'),
  CHECK ("state_code" IS NULL OR "state_code" ~ '^[A-Z0-9]{2,3}$'),
  UNIQUE ("country_code", "state_name", "city_name")
);



ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");
ALTER TABLE "users" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "role_permissions" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");
ALTER TABLE "role_permissions" ADD FOREIGN KEY ("permission_id") REFERENCES "permissions" ("id");
ALTER TABLE "persons" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "persons" ADD FOREIGN KEY ("city_id") REFERENCES "cities" ("id");
ALTER TABLE "companies" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "companies" ADD FOREIGN KEY ("city_id") REFERENCES "cities" ("id");
ALTER TABLE "legal_representatives" ADD FOREIGN KEY ("company_id") REFERENCES "companies" ("id");
ALTER TABLE "legal_representatives" ADD FOREIGN KEY ("person_id") REFERENCES "persons" ("id");
ALTER TABLE "shareholders" ADD FOREIGN KEY ("company_id") REFERENCES "companies" ("id");
ALTER TABLE "shareholders" ADD FOREIGN KEY ("person_id") REFERENCES "persons" ("id");
ALTER TABLE "guarantors" ADD FOREIGN KEY ("credit_application_id") REFERENCES "credit_applications_bnpl" ("id");
ALTER TABLE "guarantors" ADD FOREIGN KEY ("person_id") REFERENCES "persons" ("id");
ALTER TABLE "guarantors" ADD FOREIGN KEY ("contract_signer_id") REFERENCES "contract_signers" ("id");
ALTER TABLE "partners" ADD FOREIGN KEY ("default_rep_id") REFERENCES "sales_representatives" ("id");
ALTER TABLE "partners" ADD FOREIGN KEY ("default_category_id") REFERENCES "partner_categories" ("id");
ALTER TABLE "partners" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "partner_categories" ADD FOREIGN KEY ("partner_id") REFERENCES "partners" ("id");
ALTER TABLE "partner_categories" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("user_product_id") REFERENCES "user_products" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("partner_id") REFERENCES "partners" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("partner_category_id") REFERENCES "partner_categories" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("sales_rep_id") REFERENCES "sales_representatives" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("business_seniority_id") REFERENCES "business_seniority" ("id");
ALTER TABLE "credit_applications_bnpl" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "ai_agent_analysis" ADD FOREIGN KEY ("application_id") REFERENCES "credit_applications_bnpl" ("id");
ALTER TABLE "sales_representatives" ADD FOREIGN KEY ("partner_id") REFERENCES "partners" ("id");
ALTER TABLE "sales_representatives" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "sales_representatives" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "contracts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "contracts" ADD FOREIGN KEY ("application_id") REFERENCES "credit_applications_bnpl" ("id");
ALTER TABLE "contracts" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "contract_signers" ADD FOREIGN KEY ("contract_id") REFERENCES "contracts" ("id");
ALTER TABLE "contract_signers" ADD FOREIGN KEY ("person_id") REFERENCES "persons" ("id");
ALTER TABLE "contract_signers" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "user_products" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "product_bnpl" ADD FOREIGN KEY ("user_product_id") REFERENCES "user_products" ("id");
ALTER TABLE "product_bnpl" ADD FOREIGN KEY ("status_id") REFERENCES "statuses" ("id");
ALTER TABLE "bnpl_categories" ADD FOREIGN KEY ("product_bnpl_id") REFERENCES "product_bnpl" ("id");
ALTER TABLE "bnpl_categories" ADD FOREIGN KEY ("category_id") REFERENCES "partner_categories" ("id");
ALTER TABLE "risk_profile" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "risk_profile" ADD FOREIGN KEY ("user_product_id") REFERENCES "user_products" ("id");
ALTER TABLE "documents" ADD FOREIGN KEY ("person_id") REFERENCES "persons" ("id");
ALTER TABLE "documents" ADD FOREIGN KEY ("company_id") REFERENCES "companies" ("id");
ALTER TABLE "documents" ADD FOREIGN KEY ("application_id") REFERENCES "credit_applications_bnpl" ("id");
ALTER TABLE "documents" ADD FOREIGN KEY ("verification_status_id") REFERENCES "statuses" ("id");
ALTER TABLE "credit_reports" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "credit_reports" ADD FOREIGN KEY ("person_id") REFERENCES "persons" ("id");
ALTER TABLE "credit_reports" ADD FOREIGN KEY ("company_id") REFERENCES "companies" ("id");
ALTER TABLE "credit_reports" ADD FOREIGN KEY ("application_id") REFERENCES "credit_applications_bnpl" ("id");
ALTER TABLE "cities" ADD FOREIGN KEY ("currency_id") REFERENCES "currencies" ("id");

CREATE TRIGGER trg_users_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "users"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('users', 'status_id');

CREATE TRIGGER trg_partners_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "partners"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('partners', 'status_id');

CREATE TRIGGER trg_partner_categories_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "partner_categories"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('partner_categories', 'status_id');

CREATE TRIGGER trg_credit_applications_bnpl_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "credit_applications_bnpl"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('credit_applications_bnpl', 'status_id');

CREATE TRIGGER trg_sales_representatives_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "sales_representatives"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('sales_representatives', 'status_id');

CREATE TRIGGER trg_contracts_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "contracts"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('contracts', 'status_id');

CREATE TRIGGER trg_contract_signers_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "contract_signers"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('contract_signers', 'status_id');

CREATE TRIGGER trg_product_bnpl_validate_status
BEFORE INSERT OR UPDATE OF status_id ON "product_bnpl"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('product_bnpl', 'status_id');

CREATE TRIGGER trg_documents_validate_verification_status
BEFORE INSERT OR UPDATE OF verification_status_id ON "documents"
FOR EACH ROW
EXECUTE FUNCTION validate_status_entity('documents', 'verification_status_id');

-- =========================================================
-- Unique indexes for secure external references (UUID)
-- =========================================================
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_external_id ON "users" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_roles_external_id ON "roles" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_permissions_external_id ON "permissions" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_role_permissions_external_id ON "role_permissions" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_persons_external_id ON "persons" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_companies_external_id ON "companies" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_legal_representatives_external_id ON "legal_representatives" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_shareholders_external_id ON "shareholders" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_guarantors_external_id ON "guarantors" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_partners_external_id ON "partners" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_partner_categories_external_id ON "partner_categories" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_credit_applications_bnpl_external_id ON "credit_applications_bnpl" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_ai_agent_analysis_external_id ON "ai_agent_analysis" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_representatives_external_id ON "sales_representatives" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_contracts_external_id ON "contracts" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_contract_signers_external_id ON "contract_signers" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_products_external_id ON "user_products" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_product_bnpl_external_id ON "product_bnpl" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_bnpl_categories_external_id ON "bnpl_categories" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_risk_profile_external_id ON "risk_profile" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_documents_external_id ON "documents" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_credit_reports_external_id ON "credit_reports" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_statuses_external_id ON "statuses" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_currencies_external_id ON "currencies" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_cities_external_id ON "cities" ("external_id");
CREATE UNIQUE INDEX IF NOT EXISTS idx_business_seniority_external_id ON "business_seniority" ("external_id");

-- =========================================================
-- Baseline performance indexes (FKs + frequent join filters)
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_users_role_id ON "users" ("role_id");
CREATE INDEX IF NOT EXISTS idx_users_status_id ON "users" ("status_id");
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON "role_permissions" ("permission_id");
CREATE INDEX IF NOT EXISTS idx_persons_user_id ON "persons" ("user_id");
CREATE INDEX IF NOT EXISTS idx_persons_city_id ON "persons" ("city_id");
CREATE INDEX IF NOT EXISTS idx_companies_user_id ON "companies" ("user_id");
CREATE INDEX IF NOT EXISTS idx_companies_city_id ON "companies" ("city_id");
CREATE INDEX IF NOT EXISTS idx_legal_representatives_company_id ON "legal_representatives" ("company_id");
CREATE INDEX IF NOT EXISTS idx_legal_representatives_person_id ON "legal_representatives" ("person_id");
CREATE INDEX IF NOT EXISTS idx_shareholders_company_id ON "shareholders" ("company_id");
CREATE INDEX IF NOT EXISTS idx_shareholders_person_id ON "shareholders" ("person_id");
CREATE INDEX IF NOT EXISTS idx_guarantors_credit_application_id ON "guarantors" ("credit_application_id");
CREATE INDEX IF NOT EXISTS idx_guarantors_person_id ON "guarantors" ("person_id");
CREATE INDEX IF NOT EXISTS idx_guarantors_contract_signer_id ON "guarantors" ("contract_signer_id");
CREATE INDEX IF NOT EXISTS idx_partners_default_rep_id ON "partners" ("default_rep_id");
CREATE INDEX IF NOT EXISTS idx_partners_default_category_id ON "partners" ("default_category_id");
CREATE INDEX IF NOT EXISTS idx_partners_status_id ON "partners" ("status_id");
CREATE INDEX IF NOT EXISTS idx_partner_categories_partner_id ON "partner_categories" ("partner_id");
CREATE INDEX IF NOT EXISTS idx_partner_categories_status_id ON "partner_categories" ("status_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_user_id ON "credit_applications_bnpl" ("user_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_user_product_id ON "credit_applications_bnpl" ("user_product_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_partner_id ON "credit_applications_bnpl" ("partner_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_partner_category_id ON "credit_applications_bnpl" ("partner_category_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_sales_rep_id ON "credit_applications_bnpl" ("sales_rep_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_business_seniority_id ON "credit_applications_bnpl" ("business_seniority_id");
CREATE INDEX IF NOT EXISTS idx_credit_applications_status_id ON "credit_applications_bnpl" ("status_id");
CREATE INDEX IF NOT EXISTS idx_ai_agent_analysis_application_id ON "ai_agent_analysis" ("application_id");
CREATE INDEX IF NOT EXISTS idx_sales_representatives_partner_id ON "sales_representatives" ("partner_id");
CREATE INDEX IF NOT EXISTS idx_sales_representatives_user_id ON "sales_representatives" ("user_id");
CREATE INDEX IF NOT EXISTS idx_sales_representatives_status_id ON "sales_representatives" ("status_id");
CREATE INDEX IF NOT EXISTS idx_contracts_user_id ON "contracts" ("user_id");
CREATE INDEX IF NOT EXISTS idx_contracts_application_id ON "contracts" ("application_id");
CREATE INDEX IF NOT EXISTS idx_contracts_status_id ON "contracts" ("status_id");
CREATE INDEX IF NOT EXISTS idx_contract_signers_contract_id ON "contract_signers" ("contract_id");
CREATE INDEX IF NOT EXISTS idx_contract_signers_person_id ON "contract_signers" ("person_id");
CREATE INDEX IF NOT EXISTS idx_contract_signers_status_id ON "contract_signers" ("status_id");
CREATE INDEX IF NOT EXISTS idx_user_products_user_id ON "user_products" ("user_id");
CREATE INDEX IF NOT EXISTS idx_product_bnpl_status_id ON "product_bnpl" ("status_id");
CREATE INDEX IF NOT EXISTS idx_bnpl_categories_product_bnpl_id ON "bnpl_categories" ("product_bnpl_id");
CREATE INDEX IF NOT EXISTS idx_bnpl_categories_category_id ON "bnpl_categories" ("category_id");
CREATE INDEX IF NOT EXISTS idx_risk_profile_user_id ON "risk_profile" ("user_id");
CREATE INDEX IF NOT EXISTS idx_risk_profile_user_product_id ON "risk_profile" ("user_product_id");
CREATE INDEX IF NOT EXISTS idx_documents_person_id ON "documents" ("person_id");
CREATE INDEX IF NOT EXISTS idx_documents_company_id ON "documents" ("company_id");
CREATE INDEX IF NOT EXISTS idx_documents_application_id ON "documents" ("application_id");
CREATE INDEX IF NOT EXISTS idx_documents_verification_status_id ON "documents" ("verification_status_id");
CREATE INDEX IF NOT EXISTS idx_credit_reports_user_id ON "credit_reports" ("user_id");
CREATE INDEX IF NOT EXISTS idx_credit_reports_person_id ON "credit_reports" ("person_id");
CREATE INDEX IF NOT EXISTS idx_credit_reports_company_id ON "credit_reports" ("company_id");
CREATE INDEX IF NOT EXISTS idx_credit_reports_application_id ON "credit_reports" ("application_id");
CREATE INDEX IF NOT EXISTS idx_cities_country_state_name ON "cities" ("country_code", "state_name", "city_name");
CREATE INDEX IF NOT EXISTS idx_cities_currency_id ON "cities" ("currency_id");
