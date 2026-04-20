-- Run this in Supabase SQL Editor to see actual batches table columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'batches'
ORDER BY ordinal_position;
