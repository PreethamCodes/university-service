CREATE SCHEMA IF NOT EXISTS university;
SET LOCAL search_path TO university, pg_catalog;
CREATE ROLE university_runtime NOLOGIN;
REVOKE ALL ON SCHEMA university FROM PUBLIC;
GRANT USAGE ON SCHEMA university TO university_runtime;

CREATE TABLE university_students (
    student_id text primary key,
    registration_ref text unique not null
);
ALTER TABLE university_students ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE ON university_students TO university_runtime;
CREATE POLICY service_access ON university_students TO university_runtime USING (true) WITH CHECK (true);

CREATE TABLE academic_programmes (
    code text primary key,
    programme text not null,
    department text not null
);
ALTER TABLE academic_programmes ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE ON academic_programmes TO university_runtime;
CREATE POLICY service_access ON academic_programmes TO university_runtime USING (true) WITH CHECK (true);

CREATE TABLE enrolment_records (
    record_ref text primary key,
    student_id text not null references university_students,
    programme_code text not null references academic_programmes,
    admission_year int not null,
    registration_status text not null,
    enrolment_status text not null check(enrolment_status in ('ACTIVE','INACTIVE','PENDING')),
    updated_at timestamptz not null default now()
);
ALTER TABLE enrolment_records ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE ON enrolment_records TO university_runtime;
CREATE POLICY service_access ON enrolment_records TO university_runtime USING (true) WITH CHECK (true);
CREATE INDEX ON enrolment_records (student_id);
CREATE INDEX ON enrolment_records (programme_code);

CREATE TABLE bonafide_certificates (
    certificate_ref text primary key,
    record_ref text not null references enrolment_records,
    valid_until date not null,
    updated_at timestamptz not null default now()
);
ALTER TABLE bonafide_certificates ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE ON bonafide_certificates TO university_runtime;
CREATE POLICY service_access ON bonafide_certificates TO university_runtime USING (true) WITH CHECK (true);
CREATE INDEX ON bonafide_certificates (record_ref);
GRANT USAGE ON ALL SEQUENCES IN SCHEMA university TO university_runtime;
