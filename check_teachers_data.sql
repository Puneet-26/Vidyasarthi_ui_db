SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'teachers' ORDER BY ordinal_position;

SELECT id, name, email, phone, subjects, classes FROM teachers LIMIT 10;
