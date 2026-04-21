SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'broadcasts' ORDER BY ordinal_position;

SELECT id, title, target_audience, sent_by, sent_date FROM broadcasts LIMIT 3;
