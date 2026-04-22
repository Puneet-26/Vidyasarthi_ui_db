-- ==========================================
-- PRODUCTION MIGRATION: FIX AUTH CREDENTIALS
-- ==========================================

-- 1. Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Ensure the email column is UNIQUE
-- This is MANDATORY for 'ON CONFLICT (email)' to work correctly
DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'auth_credentials_email_key'
    ) THEN
        ALTER TABLE public.auth_credentials ADD CONSTRAINT auth_credentials_email_key UNIQUE (email);
    END IF;
END $$;

-- 3. Set a default value for the 'id' column
-- This fixes the "null value violates not-null constraint" error.
-- It generates a unique string with a 'cred_' prefix to match your existing data pattern.
ALTER TABLE public.auth_credentials 
ALTER COLUMN id SET DEFAULT ('cred_' || substr(gen_random_uuid()::text, 1, 8));

-- 4. Security Note (Hashing)
-- Your project is currently storing passwords in PLAIN TEXT.
-- To fix this, you should use the crypt() function from pgcrypto.
-- Example of secure insert: 
-- INSERT INTO auth_credentials (email, password_hash) VALUES ('user@email.com', crypt('mypassword', gen_salt('bf')));
--
-- For now, I have fixed the schema so your current inserts will work.
-- Consider migrating to Supabase Auth (auth.users) for enterprise-grade security.

DO $$
BEGIN
    RAISE NOTICE 'Migration complete. auth_credentials.id now has a default value.';
END $$;
