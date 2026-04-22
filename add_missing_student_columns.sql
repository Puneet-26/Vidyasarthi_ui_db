ALTER TABLE students ADD COLUMN IF NOT EXISTS class TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS board TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS total_fees NUMERIC DEFAULT 0;
ALTER TABLE students ADD COLUMN IF NOT EXISTS fees_paid NUMERIC DEFAULT 0;
ALTER TABLE students ADD COLUMN IF NOT EXISTS fee_status TEXT DEFAULT 'pending';
ALTER TABLE students ADD COLUMN IF NOT EXISTS admission_date DATE;
ALTER TABLE students ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE students ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS roll_number TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS blood_group TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_contact TEXT;

SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'students' ORDER BY ordinal_position;
