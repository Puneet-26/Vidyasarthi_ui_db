-- ==================== TEACHERS TABLE MIGRATION ====================
-- This script ensures the teachers table has all necessary columns

-- Check if teachers table exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'teachers') THEN
        -- Create teachers table if it doesn't exist
        CREATE TABLE teachers (
            id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            phone TEXT,
            employee_id TEXT UNIQUE NOT NULL,
            subjects TEXT, -- Comma-separated list
            classes TEXT, -- Comma-separated list (7th, 8th, etc.)
            board TEXT DEFAULT 'CBSE',
            batch_id TEXT,
            qualification TEXT,
            experience_years INTEGER DEFAULT 0,
            salary NUMERIC DEFAULT 0,
            joining_date DATE,
            specialization TEXT,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        RAISE NOTICE 'Teachers table created';
    ELSE
        RAISE NOTICE 'Teachers table already exists';
    END IF;
END $$;

-- Add missing columns if they don't exist
DO $$ 
BEGIN
    -- Add name column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='name') THEN
        ALTER TABLE teachers ADD COLUMN name TEXT NOT NULL DEFAULT 'Unknown';
        RAISE NOTICE 'Added name column';
    END IF;

    -- Add email column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='email') THEN
        ALTER TABLE teachers ADD COLUMN email TEXT UNIQUE NOT NULL DEFAULT 'temp@teachers.com';
        RAISE NOTICE 'Added email column';
    END IF;

    -- Add phone column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='phone') THEN
        ALTER TABLE teachers ADD COLUMN phone TEXT;
        RAISE NOTICE 'Added phone column';
    END IF;

    -- Add subjects column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='subjects') THEN
        ALTER TABLE teachers ADD COLUMN subjects TEXT;
        RAISE NOTICE 'Added subjects column';
    END IF;

    -- Add classes column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='classes') THEN
        ALTER TABLE teachers ADD COLUMN classes TEXT;
        RAISE NOTICE 'Added classes column';
    END IF;

    -- Add board column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='board') THEN
        ALTER TABLE teachers ADD COLUMN board TEXT DEFAULT 'CBSE';
        RAISE NOTICE 'Added board column';
    END IF;

    -- Add batch_id column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='batch_id') THEN
        ALTER TABLE teachers ADD COLUMN batch_id TEXT;
        RAISE NOTICE 'Added batch_id column';
    END IF;

    -- Add user_id column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='user_id') THEN
        ALTER TABLE teachers ADD COLUMN user_id UUID REFERENCES users(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added user_id column';
    END IF;

    -- Add is_active column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='teachers' AND column_name='is_active') THEN
        ALTER TABLE teachers ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column';
    END IF;
END $$;

-- Enable RLS (Row Level Security)
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users" ON teachers;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON teachers;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON teachers;

-- Create RLS policies
CREATE POLICY "Enable read access for all users" ON teachers
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON teachers
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON teachers
    FOR UPDATE USING (true);

-- Verify the table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'teachers'
ORDER BY ordinal_position;

-- Show existing teachers
SELECT 
    id,
    name,
    email,
    phone,
    subjects,
    classes,
    board,
    is_active
FROM teachers
ORDER BY created_at DESC;
