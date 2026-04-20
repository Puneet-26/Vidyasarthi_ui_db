-- Check if Siya Sawant exists in students table
SELECT 
  'Student Record' as type,
  id,
  name,
  email,
  phone,
  parent_name,
  parent_phone
FROM students 
WHERE name ILIKE '%siya%sawant%';

-- Check if auth credentials exist for Siya
SELECT 
  'Auth Credentials' as type,
  id,
  email,
  name,
  role,
  password_hash
FROM auth_credentials 
WHERE email IN ('siya.sawant@students.com', 'abha.sawant@parents.com');

-- If credentials don't exist, create them
-- Run this ONLY if the above query shows no results

-- Student credentials
INSERT INTO auth_credentials (id, email, password_hash, name, role)
VALUES (gen_random_uuid(), 'siya.sawant@students.com', 'Student@123', 'Siya Sawant', 'student')
ON CONFLICT (email) DO NOTHING;

-- Parent credentials  
INSERT INTO auth_credentials (id, email, password_hash, name, role)
VALUES (gen_random_uuid(), 'abha.sawant@parents.com', 'Parent@123', 'Abha Sawant', 'parent')
ON CONFLICT (email) DO NOTHING;

-- Verify credentials were created
SELECT 
  'Verification' as type,
  email,
  name,
  role,
  created_at
FROM auth_credentials 
WHERE email IN ('siya.sawant@students.com', 'abha.sawant@parents.com')
ORDER BY email;
