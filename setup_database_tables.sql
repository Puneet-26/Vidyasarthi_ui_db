-- VidyaSarathi Database Setup Script
-- Run this in your Supabase SQL editor to set up all required tables

-- 1. Subjects table
CREATE TABLE IF NOT EXISTS subjects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Batches table
CREATE TABLE IF NOT EXISTS batches (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    year INTEGER NOT NULL,
    section TEXT,
    total_students INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Students table
CREATE TABLE IF NOT EXISTS students (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone_number TEXT,
    batch_id TEXT REFERENCES batches(id),
    roll_number TEXT,
    date_of_birth DATE,
    address TEXT,
    parent_name TEXT,
    parent_email TEXT,
    parent_phone TEXT,
    admission_date DATE,
    total_fees NUMERIC DEFAULT 0,
    fees_paid NUMERIC DEFAULT 0,
    fee_status TEXT DEFAULT 'pending',
    is_active BOOLEAN DEFAULT true,
    enrollment_status TEXT DEFAULT 'active',
    subject_ids TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Homework table
CREATE TABLE IF NOT EXISTS homework (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id TEXT REFERENCES subjects(id),
    batch_id TEXT REFERENCES batches(id),
    assigned_date DATE,
    due_date DATE,
    status TEXT DEFAULT 'active',
    assigned_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tests table
CREATE TABLE IF NOT EXISTS tests (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id TEXT REFERENCES subjects(id),
    batch_id TEXT REFERENCES batches(id),
    test_date DATE,
    duration_minutes INTEGER,
    max_marks INTEGER,
    status TEXT DEFAULT 'scheduled',
    created_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Test Results table
CREATE TABLE IF NOT EXISTS test_results (
    id TEXT PRIMARY KEY,
    test_id TEXT REFERENCES tests(id),
    student_id TEXT REFERENCES students(id),
    marks_obtained NUMERIC,
    max_marks NUMERIC,
    percentage NUMERIC,
    grade TEXT,
    remarks TEXT,
    submitted_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Fee Payments table
CREATE TABLE IF NOT EXISTS fee_payments (
    id TEXT PRIMARY KEY,
    student_id TEXT REFERENCES students(id),
    amount NUMERIC NOT NULL,
    payment_date DATE,
    payment_method TEXT,
    transaction_id TEXT,
    status TEXT DEFAULT 'completed',
    description TEXT,
    reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Broadcasts table
CREATE TABLE IF NOT EXISTS broadcasts (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    target_audience TEXT DEFAULT 'all',
    sent_by TEXT,
    sent_date DATE,
    is_urgent BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Timetables table
CREATE TABLE IF NOT EXISTS timetables (
    id TEXT PRIMARY KEY,
    batch_id TEXT REFERENCES batches(id),
    subject_id TEXT REFERENCES subjects(id),
    day_of_week TEXT NOT NULL,
    start_time TIME,
    end_time TIME,
    teacher_id TEXT,
    room_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Teacher Feedback table
CREATE TABLE IF NOT EXISTS teacher_feedback (
    id TEXT PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    teacher_name TEXT NOT NULL,
    student_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    message TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_students_batch_id ON students(batch_id);
CREATE INDEX IF NOT EXISTS idx_students_parent_email ON students(parent_email);
CREATE INDEX IF NOT EXISTS idx_homework_batch_id ON homework(batch_id);
CREATE INDEX IF NOT EXISTS idx_homework_subject_id ON homework(subject_id);
CREATE INDEX IF NOT EXISTS idx_tests_batch_id ON tests(batch_id);
CREATE INDEX IF NOT EXISTS idx_test_results_student_id ON test_results(student_id);
CREATE INDEX IF NOT EXISTS idx_fee_payments_student_id ON fee_payments(student_id);
CREATE INDEX IF NOT EXISTS idx_timetables_batch_id ON timetables(batch_id);
CREATE INDEX IF NOT EXISTS idx_teacher_feedback_student_id ON teacher_feedback(student_id);
CREATE INDEX IF NOT EXISTS idx_teacher_feedback_teacher_id ON teacher_feedback(teacher_id);

-- Insert sample data
INSERT INTO subjects (id, name, code, description) VALUES
    ('sub_physics', 'Physics', 'PHY', 'Classical and Modern Physics'),
    ('sub_chemistry', 'Chemistry', 'CHE', 'Organic and Inorganic Chemistry'),
    ('sub_mathematics', 'Mathematics', 'MAT', 'Algebra, Calculus, and Geometry'),
    ('sub_biology', 'Biology', 'BIO', 'Life Sciences and Human Biology'),
    ('sub_english', 'English', 'ENG', 'Literature and Communication')
ON CONFLICT (id) DO NOTHING;

INSERT INTO batches (id, name, year, section, total_students, is_active) VALUES
    ('batch_12_science', 'Class 12 Science', 2024, 'A', 25, true),
    ('batch_11_science', 'Class 11 Science', 2024, 'A', 30, true),
    ('batch_10_all', 'Class 10', 2024, 'A', 28, true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO students (id, user_id, name, email, phone_number, batch_id, roll_number, date_of_birth, address, parent_name, parent_email, parent_phone, admission_date, total_fees, fees_paid, fee_status, is_active, enrollment_status, subject_ids) VALUES
    ('student_001', 'student_001', 'Aryan Sharma', 'aryan.sharma@students.com', '+91-9876543210', 'batch_12_science', 'S001', '2006-05-15', '123 MG Road, Delhi', 'Rajesh Sharma', 'rajesh.sharma@parents.com', '+91-9876543211', '2023-04-01', 50000, 35000, 'partial', true, 'active', ARRAY['sub_physics', 'sub_chemistry', 'sub_mathematics']),
    ('student_002', 'student_002', 'Priya Singh', 'priya.singh@students.com', '+91-9876543212', 'batch_11_science', 'S002', '2007-08-22', '456 Park Street, Mumbai', 'Amit Singh', 'amit.singh@parents.com', '+91-9876543213', '2023-04-01', 45000, 45000, 'full', true, 'active', ARRAY['sub_physics', 'sub_chemistry', 'sub_mathematics'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO homework (id, title, description, subject_id, batch_id, assigned_date, due_date, status, assigned_by) VALUES
    ('hw_001', 'Physics - Laws of Motion', 'Solve problems from Chapter 5, Questions 1-10', 'sub_physics', 'batch_12_science', '2024-04-01', '2024-04-08', 'active', 'teacher_001'),
    ('hw_002', 'Chemistry - Organic Compounds', 'Complete the worksheet on organic reactions', 'sub_chemistry', 'batch_12_science', '2024-04-02', '2024-04-09', 'active', 'teacher_002')
ON CONFLICT (id) DO NOTHING;

INSERT INTO tests (id, title, description, subject_id, batch_id, test_date, duration_minutes, max_marks, status, created_by) VALUES
    ('test_001', 'Physics Unit Test 1', 'Test on Mechanics and Thermodynamics', 'sub_physics', 'batch_12_science', '2024-04-15', 90, 100, 'scheduled', 'teacher_001')
ON CONFLICT (id) DO NOTHING;

INSERT INTO fee_payments (id, student_id, amount, payment_date, payment_method, transaction_id, status, description, reference) VALUES
    ('pay_001', 'student_001', 25000, '2023-04-01', 'bank_transfer', 'TXN001', 'completed', 'First installment payment', 'BANK_TXN_001'),
    ('pay_002', 'student_001', 10000, '2023-08-01', 'upi', 'TXN002', 'completed', 'Second installment payment', 'UPI_TXN_002')
ON CONFLICT (id) DO NOTHING;

INSERT INTO broadcasts (id, title, message, target_audience, sent_by, sent_date, is_urgent) VALUES
    ('broadcast_001', 'School Holiday Notice', 'School will remain closed on April 10th due to local festival. Regular classes will resume on April 11th.', 'all', 'admin_001', '2024-04-05', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO timetables (id, batch_id, subject_id, day_of_week, start_time, end_time, teacher_id, room_number) VALUES
    ('tt_001', 'batch_12_science', 'sub_physics', 'monday', '09:00', '10:00', 'teacher_001', 'Room 101'),
    ('tt_002', 'batch_12_science', 'sub_chemistry', 'monday', '10:00', '11:00', 'teacher_002', 'Lab 1')
ON CONFLICT (id) DO NOTHING;

INSERT INTO teacher_feedback (id, teacher_id, teacher_name, student_id, student_name, subject_id, subject_name, message, category) VALUES
    ('feedback_001', 'teacher_001', 'Mr. Arun Kumar', 'student_001', 'Aryan Sharma', 'sub_physics', 'Physics', 'Aryan shows excellent understanding of physics concepts. Keep up the good work!', 'academic'),
    ('feedback_002', 'teacher_002', 'Mrs. Priya Sharma', 'student_001', 'Aryan Sharma', 'sub_chemistry', 'Chemistry', 'Good progress in organic chemistry. Needs to focus more on inorganic reactions.', 'academic')
ON CONFLICT (id) DO NOTHING;