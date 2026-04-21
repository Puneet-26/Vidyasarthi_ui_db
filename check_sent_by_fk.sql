SELECT constraint_name, constraint_type FROM information_schema.table_constraints WHERE table_name = 'broadcasts';

SELECT tc.constraint_name, kcu.column_name, ccu.table_name AS foreign_table, ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_name = 'broadcasts' AND tc.constraint_type = 'FOREIGN KEY';
