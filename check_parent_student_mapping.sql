-- Check all students and their parent information
SELECT 
  id,
  name as student_name,
  email as student_email,
  parent_name,
  parent_phone,
  batch_id,
  enrollment_status
FROM students
ORDER BY name;

-- Check auth credentials for Deven Saran
SELECT 
  'Auth Credentials' as type,
  email,
  name,
  role
FROM auth_credentials
WHERE email ILIKE '%deven%' OR email ILIKE '%saran%'
ORDER BY role, email;

-- Check if Reet Saran exists
SELECT 
  'Reet Saran Record' as type,
  id,
  name,
  email,
  parent_name
FROM students
WHERE name ILIKE '%reet%';

-- Check what parent email is stored for Reet
SELECT 
  name as student_name,
  parent_name,
  SUBSTRING(parent_name FROM '\(([^)]+)\)') as extracted_parent_email
FROM students
WHERE name ILIKE '%reet%';
