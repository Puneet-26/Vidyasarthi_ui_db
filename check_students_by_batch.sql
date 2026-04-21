-- Check all students grouped by batch
SELECT 
  b.id as batch_id,
  b.name as batch_name,
  COUNT(s.id) as student_count,
  STRING_AGG(s.name, ', ') as student_names
FROM batches b
LEFT JOIN students s ON b.id = s.batch_id AND s.enrollment_status = 'active'
GROUP BY b.id, b.name
ORDER BY b.name;

-- Show detailed student info by batch
SELECT 
  b.name as batch,
  s.id,
  s.name as student_name,
  s.email,
  s.enrollment_status,
  s.parent_name
FROM students s
JOIN batches b ON s.batch_id = b.id
ORDER BY b.name, s.name;

-- Count active students per batch
SELECT 
  b.name as batch,
  COUNT(s.id) as active_students
FROM batches b
LEFT JOIN students s ON b.id = s.batch_id AND s.enrollment_status = 'active'
GROUP BY b.id, b.name
ORDER BY b.name;
