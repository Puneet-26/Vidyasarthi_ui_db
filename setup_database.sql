-- VidyaSarathi Database Setup Script
-- Run this script in Supabase SQL Editor to set up the normalized database

-- First, create the normalized schema
-- VidyaSarathi Normalized Database Schema
-- This script creates a properly normalized database with no redundancy

-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS teacher_feedback CASCADE;
DROP TABLE IF EXISTS test_results CASCADE;
DROP TABLE IF EXISTS fee_payments CASCADE;
DROP TABLE IF EXISTS homework CASCADE;
DROP TABLE IF EXISTS tests CASCADE;
DROP TABLE IF EXISTS timetables CASCADE;
DROP TABLE IF EXISTS student_subjects CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS parents CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS broadcasts CASCADE;

-- 1. Users table (base table for all user types)
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone_number TEXT,
    role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin_staff', 'teacher', 'student', 'parent')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Subjects table
CREATE TABLE subjects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Batches table
CREATE TABLE batches (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    year INTEGER NOT NULL,
    section TEXT NOT NULL,
    total_students INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Teachers table
CREATE TABLE teachers (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
    employee_id TEXT UNIQUE NOT NULL,
    qualification TEXT,
    experience_years INTEGER DEFAULT 0,
    salary NUMERIC DEFAULT 0,
    joining_date DATE,
    specialization TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Parents table
CREATE TABLE parents (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
    occupation TEXT,
    annual_income NUMERIC DEFAULT 0,
    address TEXT,
    emergency_contact TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Students table (normalized - no redundant parent info)
CREATE TABLE students (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
    parent_id TEXT REFERENCES parents(id),
    batch_id TEXT REFERENCES batches(id),
    roll_number TEXT UNIQUE NOT NULL,
    date_of_birth DATE,
    address TEXT,
    admission_date DATE,
    total_fees NUMERIC DEFAULT 0,
    fees_paid NUMERIC DEFAULT 0,
    fee_status TEXT DEFAULT 'pending' CHECK (fee_status IN ('pending', 'partial', 'full', 'overdue')),
    enrollment_status TEXT DEFAULT 'active' CHECK (enrollment_status IN ('active', 'inactive', 'dropped', 'graduated')),
    blood_group TEXT,
    medical_conditions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Student-Subject mapping (many-to-many relationship)
CREATE TABLE student_subjects (
    id TEXT PRIMARY KEY,
    student_id TEXT REFERENCES students(id) ON DELETE CASCADE,
    subject_id TEXT REFERENCES subjects(id) ON DELETE CASCADE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(student_id, subject_id)
);

-- 8. Timetables table (normalized with teacher assignment)
CREATE TABLE timetables (
    id TEXT PRIMARY KEY,
    batch_id TEXT REFERENCES batches(id),
    subject_id TEXT REFERENCES subjects(id),
    teacher_id TEXT REFERENCES teachers(id),
    day_of_week TEXT NOT NULL CHECK (day_of_week IN ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_number TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(teacher_id, day_of_week, start_time), -- Prevent teacher conflicts
    UNIQUE(batch_id, day_of_week, start_time), -- Prevent batch conflicts
    UNIQUE(room_number, day_of_week, start_time) -- Prevent room conflicts
);

-- 9. Homework table
CREATE TABLE homework (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id TEXT REFERENCES subjects(id),
    batch_id TEXT REFERENCES batches(id),
    teacher_id TEXT REFERENCES teachers(id),
    assigned_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'overdue')),
    max_marks INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Tests table
CREATE TABLE tests (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id TEXT REFERENCES subjects(id),
    batch_id TEXT REFERENCES batches(id),
    teacher_id TEXT REFERENCES teachers(id),
    test_date DATE,
    start_time TIME,
    duration_minutes INTEGER,
    max_marks INTEGER,
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
    room_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Test Results table
CREATE TABLE test_results (
    id TEXT PRIMARY KEY,
    test_id TEXT REFERENCES tests(id) ON DELETE CASCADE,
    student_id TEXT REFERENCES students(id) ON DELETE CASCADE,
    marks_obtained NUMERIC,
    percentage NUMERIC,
    grade TEXT,
    remarks TEXT,
    submitted_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(test_id, student_id)
);

-- 12. Fee Payments table
CREATE TABLE fee_payments (
    id TEXT PRIMARY KEY,
    student_id TEXT REFERENCES students(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    payment_method TEXT CHECK (payment_method IN ('cash', 'upi', 'bank_transfer', 'card', 'cheque')),
    transaction_id TEXT,
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    description TEXT,
    reference TEXT,
    received_by TEXT REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. Teacher Feedback table (normalized)
CREATE TABLE teacher_feedback (
    id TEXT PRIMARY KEY,
    teacher_id TEXT REFERENCES teachers(id),
    student_id TEXT REFERENCES students(id),
    subject_id TEXT REFERENCES subjects(id),
    message TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general' CHECK (category IN ('academic', 'behaviour', 'attendance', 'general')),
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 14. Broadcasts table
CREATE TABLE broadcasts (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    target_audience TEXT DEFAULT 'all' CHECK (target_audience IN ('all', 'students', 'parents', 'teachers', 'staff')),
    sent_by TEXT REFERENCES users(id),
    sent_date DATE DEFAULT CURRENT_DATE,
    is_urgent BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_students_batch_id ON students(batch_id);
CREATE INDEX idx_students_parent_id ON students(parent_id);
CREATE INDEX idx_students_roll_number ON students(roll_number);
CREATE INDEX idx_student_subjects_student_id ON student_subjects(student_id);
CREATE INDEX idx_student_subjects_subject_id ON student_subjects(subject_id);
CREATE INDEX idx_timetables_batch_id ON timetables(batch_id);
CREATE INDEX idx_timetables_teacher_id ON timetables(teacher_id);
CREATE INDEX idx_timetables_day_time ON timetables(day_of_week, start_time);
CREATE INDEX idx_homework_batch_id ON homework(batch_id);
CREATE INDEX idx_homework_subject_id ON homework(subject_id);
CREATE INDEX idx_homework_teacher_id ON homework(teacher_id);
CREATE INDEX idx_tests_batch_id ON tests(batch_id);
CREATE INDEX idx_test_results_student_id ON test_results(student_id);
CREATE INDEX idx_fee_payments_student_id ON fee_payments(student_id);
CREATE INDEX idx_teacher_feedback_student_id ON teacher_feedback(student_id);
CREATE INDEX idx_teacher_feedback_teacher_id ON teacher_feedback(teacher_id);

-- Create views for easier data access
CREATE VIEW student_details AS
SELECT 
    s.id,
    s.roll_number,
    u.name,
    u.email,
    u.phone_number,
    s.date_of_birth,
    s.address,
    s.admission_date,
    s.total_fees,
    s.fees_paid,
    s.fee_status,
    s.enrollment_status,
    b.name as batch_name,
    b.year as batch_year,
    b.section as batch_section,
    p.user_id as parent_user_id,
    pu.name as parent_name,
    pu.email as parent_email,
    pu.phone_number as parent_phone
FROM students s
JOIN users u ON s.user_id = u.id
JOIN batches b ON s.batch_id = b.id
LEFT JOIN parents p ON s.parent_id = p.id
LEFT JOIN users pu ON p.user_id = pu.id
WHERE u.is_active = true;

CREATE VIEW teacher_details AS
SELECT 
    t.id,
    t.employee_id,
    u.name,
    u.email,
    u.phone_number,
    t.qualification,
    t.experience_years,
    t.specialization,
    t.joining_date
FROM teachers t
JOIN users u ON t.user_id = u.id
WHERE u.is_active = true;

CREATE VIEW timetable_details AS
SELECT 
    tt.id,
    tt.day_of_week,
    tt.start_time,
    tt.end_time,
    tt.room_number,
    b.name as batch_name,
    s.name as subject_name,
    s.code as subject_code,
    u.name as teacher_name
FROM timetables tt
JOIN batches b ON tt.batch_id = b.id
JOIN subjects s ON tt.subject_id = s.id
JOIN teachers t ON tt.teacher_id = t.id
JOIN users u ON t.user_id = u.id
WHERE tt.is_active = true
ORDER BY tt.day_of_week, tt.start_time;

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE timetables ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcasts ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies (allow all operations for now - can be refined later)
CREATE POLICY "Allow all operations" ON users FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON subjects FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON batches FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON teachers FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON parents FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON students FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON student_subjects FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON timetables FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON homework FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON tests FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON test_results FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON fee_payments FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON teacher_feedback FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON broadcasts FOR ALL USING (true);

-- Database setup complete!
SELECT 'Database schema created successfully!' as status;