-- ==================== STUDENTS TABLE MIGRATION ====================
-- Add missing columns to students table for proper data storage

-- Add class column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='class') THEN
        ALTER TABLE students ADD COLUMN class TEXT;
        RAISE NOTICE 'Added class column';
    END IF;
END $$;

-- Add board column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='board') THEN
        ALTER TABLE students ADD COLUMN board TEXT DEFAULT 'CBSE';
        RAISE NOTICE 'Added board column';
    END IF;
END $$;

-- Add total_fees column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='total_fees') THEN
        ALTER TABLE students ADD COLUMN total_fees NUMERIC DEFAULT 0;
        RAISE NOTICE 'Added total_fees column';
    END IF;
END $$;

-- Add fees_paid column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='fees_paid') THEN
        ALTER TABLE students ADD COLUMN fees_paid NUMERIC DEFAULT 0;
        RAISE NOTICE 'Added fees_paid column';
    END IF;
END $$;

-- Add admission_date column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='admission_date') THEN
        ALTER TABLE students ADD COLUMN admission_date DATE;
        RAISE NOTICE 'Added admission_date column';
    END IF;
END $$;

-- Add date_of_birth column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='date_of_birth') THEN
        ALTER TABLE students ADD COLUMN date_of_birth DATE;
        RAISE NOTICE 'Added date_of_birth column';
    END IF;
END $$;

-- Add address column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='address') THEN
        ALTER TABLE students ADD COLUMN address TEXT;
        RAISE NOTICE 'Added address column';
    END IF;
END $$;

-- Add roll_number column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='students' AND column_name='roll_number') THEN
        ALTER TABLE students ADD COLUMN roll_number TEXT;
        RAISE NOTICE 'Added roll_number column';
    END IF;
END $$;

-- Verify the table structure
SELECT 
    '=== STUDENTS TABLE STRUCTURE ===' as section,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;

-- Show sample student data
SELECT 
    '=== SAMPLE STUDENT DATA ===' as section,
    name,
    email,
    class,
    board,
    total_fees,
    fees_paid,
    batch_id
FROM students
LIMIT 5;
