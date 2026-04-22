-- ========================================================
-- MASSIVE DATA SEEDER FOR VIDYASARATHI
-- ========================================================
-- This script populates the database with:
-- 1. 15 Batches (8th to 12th, Divisions A, B, C)
-- 2. 15 Teachers with profiles and login credentials
-- 3. 200 Students with linked parents (including Rajesh Sharma)
-- 4. Login credentials for all roles
-- ========================================================

DO $$
DECLARE
    grade_num INT;
    grade_str TEXT;
    division TEXT;
    batch_id_val TEXT;
    i INT;
    teacher_id_val TEXT;
    student_id_val TEXT;
    cred_id_val TEXT;
    user_id_val UUID;
    parent_email TEXT;
    parent_name_val TEXT;
    student_name_val TEXT;
    teacher_name_val TEXT;
    first_names TEXT[] := ARRAY['Arjun', 'Ananya', 'Aditya', 'Diya', 'Aryan', 'Ishani', 'Rohan', 'Myra', 'Kabir', 'Saanvi', 'Ishaan', 'Aavya', 'Vivaan', 'Pari', 'Vihaan', 'Kyra', 'Krishna', 'Navya', 'Advait', 'Zara', 'Ayaan', 'Siya', 'Reyansh', 'Kiara', 'Aarav', 'Meera'];
    last_names TEXT[] := ARRAY['Sharma', 'Verma', 'Gupta', 'Singh', 'Kumar', 'Patel', 'Reddy', 'Mehta', 'Joshi', 'Iyer', 'Nair', 'Das', 'Chatterjee', 'Malhotra', 'Bose', 'Kulkarni'];
    subject_names TEXT[] := ARRAY['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'History', 'Geography', 'Computer Science'];
BEGIN
    RAISE NOTICE 'Starting data seeding...';

    -- 1. Create Batches (8-12, A/B/C)
    FOR grade_num IN 8..12 LOOP
        grade_str := grade_num || 'th';
        FOR division IN SELECT unnest(ARRAY['A', 'B', 'C']) LOOP
            batch_id_val := 'batch_' || grade_num || division;
            INSERT INTO batches (id, name, level)
            VALUES (batch_id_val, grade_num || '-' || division || ' (CBSE)', grade_str)
            ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, level = EXCLUDED.level;
        END LOOP;
    END LOOP;
    RAISE NOTICE 'Batches created.';

    -- 2. Create 15 Teachers
    FOR i IN 1..15 LOOP
        teacher_name_val := first_names[(i % array_length(first_names, 1)) + 1] || ' ' || last_names[(i % array_length(last_names, 1)) + 1];
        cred_id_val := 'cred_tea_' || i;
        
        -- Auth Creds
        INSERT INTO auth_credentials (id, email, password_hash, name, role)
        VALUES (cred_id_val, 'teacher' || i || '@vidya.com', 'Teacher@123', teacher_name_val, 'teacher')
        ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, password_hash = EXCLUDED.password_hash;

        -- Users
        INSERT INTO users (email, name, role, is_active, credential_id)
        VALUES ('teacher' || i || '@vidya.com', teacher_name_val, 'teacher', true, cred_id_val)
        ON CONFLICT (email) DO UPDATE SET credential_id = EXCLUDED.credential_id
        RETURNING id INTO user_id_val;

        -- Teacher Profile
        INSERT INTO teachers (id, user_id, name, email, employee_id, subjects, classes, board)
        VALUES ('tea_' || i, user_id_val, teacher_name_val, 'teacher' || i || '@vidya.com', 'EMP-' || (1000 + i), subject_names[(i % 8) + 1], '8th, 9th, 10th', 'CBSE')
        ON CONFLICT (id) DO UPDATE SET user_id = EXCLUDED.user_id, email = EXCLUDED.email, subjects = EXCLUDED.subjects;
    END LOOP;
    RAISE NOTICE '15 Teachers created.';

    -- 3. Create 200 Students
    FOR i IN 1..200 LOOP
        student_name_val := first_names[(i % array_length(first_names, 1)) + 1] || ' ' || last_names[(i % array_length(last_names, 1)) + 1];
        
        -- Assign to a batch
        grade_num := 8 + ((i-1) / 40); -- 40 students per grade
        IF grade_num > 12 THEN grade_num := 12; END IF;
        
        division := CASE WHEN (i % 3) = 0 THEN 'A' WHEN (i % 3) = 1 THEN 'B' ELSE 'C' END;
        batch_id_val := 'batch_' || grade_num || division;
        grade_str := grade_num || 'th';

        -- Parent Logic (First 3 students belong to Rajesh Sharma)
        IF i <= 3 THEN
            parent_email := 'rajesh.sharma@parents.com';
            parent_name_val := 'Rajesh Sharma (' || parent_email || ')';
        ELSE
            parent_email := 'parent' || i || '@gmail.com';
            -- Create a realistic parent name using a different last name or same
            parent_name_val := first_names[((i+10) % array_length(first_names, 1)) + 1] || ' ' || last_names[(i % array_length(last_names, 1)) + 1] || ' (' || parent_email || ')';
        END IF;

        cred_id_val := 'cred_std_' || i;
        
        -- Auth Creds for Student
        INSERT INTO auth_credentials (id, email, password_hash, name, role)
        VALUES (cred_id_val, 'student' || i || '@vidya.com', 'Student@123', student_name_val, 'student')
        ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, password_hash = EXCLUDED.password_hash;

        -- Users for Student
        INSERT INTO users (email, name, role, is_active, credential_id)
        VALUES ('student' || i || '@vidya.com', student_name_val, 'student', true, cred_id_val)
        ON CONFLICT (email) DO UPDATE SET credential_id = EXCLUDED.credential_id
        RETURNING id INTO user_id_val;

        -- Student Profile
        INSERT INTO students (id, user_id, name, email, batch_id, parent_name, roll_number, class, board, total_fees, fees_paid, fee_status)
        VALUES ('std_' || i, user_id_val, student_name_val, 'student' || i || '@vidya.com', batch_id_val, parent_name_val, 'RN-' || (1000 + i), grade_str, 'CBSE', 50000, 20000, 'partial')
        ON CONFLICT (id) DO UPDATE SET batch_id = EXCLUDED.batch_id, email = EXCLUDED.email, parent_name = EXCLUDED.parent_name;

        -- Create Parent Creds
        INSERT INTO auth_credentials (email, password_hash, name, role)
        VALUES (parent_email, 'Parent@123', 'Parent of ' || student_name_val, 'parent')
        ON CONFLICT (email) DO UPDATE SET 
            password_hash = EXCLUDED.password_hash,
            name = EXCLUDED.name;
    END LOOP;
    RAISE NOTICE '200 Students created.';
    RAISE NOTICE 'DATA SEEDING COMPLETE.';
END $$;

-- Verify
SELECT 'Batches' as table, count(*) FROM batches
UNION ALL
SELECT 'Teachers', count(*) FROM teachers
UNION ALL
SELECT 'Students', count(*) FROM students
UNION ALL
SELECT 'Users', count(*) FROM users
UNION ALL
SELECT 'Credentials', count(*) FROM auth_credentials;
