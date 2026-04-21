SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'auth_credentials'
ORDER BY ordinal_position;
