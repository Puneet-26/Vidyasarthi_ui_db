-- ============================================================================
-- VidyaSarathi Complete Database Setup & Data Population
-- ============================================================================
-- This file contains:
-- 1. Complete normalized database schema
-- 2. All sample data (120+ students, 50 parents, 8 teachers, 1 admin)
-- 3. Proper relationships and constraints
-- 4. Indexes for performance
-- 5. Views for easier data access
-- 6. RLS policies for security
--
-- INSTRUCTIONS:
-- 1. Copy this entire file
-- 2. Go to your Supabase project dashboard
-- 3. Navigate to SQL Editor
-- 4. Paste this content and click "Run"
-- 5. Wait for completion (may take 1-2 minutes)
-- ============================================================================

-- ============================================================================
-- PART 1: DROP EXISTING TABLES (Clean Slate)
-- ============================================================================

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

-- Drop existing views
DROP VIEW IF EXISTS student_details CASCADE;
DROP VIEW IF EXISTS teacher_details CASCADE;
DROP VIEW IF EXISTS timetable_details CASCADE;

-- ============================================================================
-- PART 2: CREATE NORMALIZED SCHEMA
-- ============================================================================

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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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

-- ============================================================================
-- PART 3: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

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

-- ============================================================================
-- PART 4: CREATE VIEWS FOR EASIER DATA ACCESS
-- ============================================================================

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
    s.batch_id,
    b.name as batch_name,
    b.year as batch_year,
    b.section as batch_section,
    s.parent_id,
    p.user_id as parent_user_id,
    pu.name as parent_name,
    pu.email as parent_email,
    pu.phone_number as parent_phone,
    s.user_id
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

-- ============================================================================
-- PART 5: POPULATE WITH SAMPLE DATA
-- ============================================================================

-- Insert Subjects
INSERT INTO subjects (id, name, code, description) VALUES
('sub_physics', 'Physics', 'PHY', 'Classical and Modern Physics'),
('sub_chemistry', 'Chemistry', 'CHE', 'Organic and Inorganic Chemistry'),
('sub_mathematics', 'Mathematics', 'MAT', 'Algebra, Calculus, and Geometry'),
('sub_biology', 'Biology', 'BIO', 'Life Sciences and Human Biology'),
('sub_english', 'English', 'ENG', 'Literature and Communication'),
('sub_hindi', 'Hindi', 'HIN', 'Hindi Language and Literature'),
('sub_computer', 'Computer Science', 'CS', 'Programming and Computer Applications'),
('sub_economics', 'Economics', 'ECO', 'Micro and Macro Economics');

-- Insert Batches
INSERT INTO batches (id, name, year, section, total_students, is_active) VALUES
('batch_12_science_a', 'Class 12 Science', 2024, 'A', 35, true),
('batch_12_science_b', 'Class 12 Science', 2024, 'B', 35, true),
('batch_12_commerce', 'Class 12 Commerce', 2024, 'A', 30, true),
('batch_11_science_a', 'Class 11 Science', 2024, 'A', 40, true),
('batch_11_science_b', 'Class 11 Science', 2024, 'B', 40, true),
('batch_10_a', 'Class 10', 2024, 'A', 45, true);

-- Insert Admin and Staff Users
INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
('admin_001', 'admin@vidya.com', 'System Administrator', '+91-9876543000', 'super_admin', true),
('staff_001', 'reception1@vidya.com', 'Priya Sharma', '+91-9876543001', 'admin_staff', true),
('staff_002', 'reception2@vidya.com', 'Anjali Gupta', '+91-9876543002', 'admin_staff', true);

-- Insert Teacher Users
INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
('user_teacher_001', 'arun.physics@vidya.com', 'Dr. Arun Kumar', '+91-9876543101', 'teacher', true),
('user_teacher_002', 'priya.chemistry@vidya.com', 'Mrs. Priya Nair', '+91-9876543102', 'teacher', true),
('user_teacher_003', 'vikram.maths@vidya.com', 'Mr. Vikram Singh', '+91-9876543103', 'teacher', true),
('user_teacher_004', 'sunita.biology@vidya.com', 'Dr. Sunita Rao', '+91-9876543104', 'teacher', true),
('user_teacher_005', 'rajesh.english@vidya.com', 'Mr. Rajesh Verma', '+91-9876543105', 'teacher', true),
('user_teacher_006', 'meera.hindi@vidya.com', 'Mrs. Meera Joshi', '+91-9876543106', 'teacher', true),
('user_teacher_007', 'amit.computer@vidya.com', 'Mr. Amit Patel', '+91-9876543107', 'teacher', true),
('user_teacher_008', 'kavita.economics@vidya.com', 'Mrs. Kavita Sharma', '+91-9876543108', 'teacher', true);

-- Insert Teachers
INSERT INTO teachers (id, user_id, employee_id, qualification, experience_years, specialization, joining_date) VALUES
('teacher_001', 'user_teacher_001', 'EMP001', 'M.Sc Physics, B.Ed', 8, 'Quantum Physics', '2020-06-01'),
('teacher_002', 'user_teacher_002', 'EMP002', 'M.Sc Chemistry, B.Ed', 6, 'Organic Chemistry', '2021-07-15'),
('teacher_003', 'user_teacher_003', 'EMP003', 'M.Sc Mathematics, B.Ed', 10, 'Calculus', '2019-04-01'),
('teacher_004', 'user_teacher_004', 'EMP004', 'Ph.D Biology, B.Ed', 12, 'Molecular Biology', '2018-08-01'),
('teacher_005', 'user_teacher_005', 'EMP005', 'M.A English, B.Ed', 7, 'Literature', '2020-09-01'),
('teacher_006', 'user_teacher_006', 'EMP006', 'M.A Hindi, B.Ed', 9, 'Hindi Literature', '2019-06-01'),
('teacher_007', 'user_teacher_007', 'EMP007', 'MCA, B.Ed', 5, 'Programming', '2022-01-15'),
('teacher_008', 'user_teacher_008', 'EMP008', 'M.A Economics, B.Ed', 8, 'Macro Economics', '2020-03-01');
-- Insert Parent Users (50 parents)
INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
('user_parent_001', 'rajesh.sharma@parents.com', 'Rajesh Sharma', '+91-9876544001', 'parent', true),
('user_parent_002', 'sunita.sharma@parents.com', 'Sunita Sharma', '+91-9876544002', 'parent', true),
('user_parent_003', 'amit.singh@parents.com', 'Amit Singh', '+91-9876544003', 'parent', true),
('user_parent_004', 'priya.singh@parents.com', 'Priya Singh', '+91-9876544004', 'parent', true),
('user_parent_005', 'vikash.kumar@parents.com', 'Vikash Kumar', '+91-9876544005', 'parent', true),
('user_parent_006', 'anita.kumar@parents.com', 'Anita Kumar', '+91-9876544006', 'parent', true),
('user_parent_007', 'suresh.gupta@parents.com', 'Suresh Gupta', '+91-9876544007', 'parent', true),
('user_parent_008', 'meera.gupta@parents.com', 'Meera Gupta', '+91-9876544008', 'parent', true),
('user_parent_009', 'ravi.patel@parents.com', 'Ravi Patel', '+91-9876544009', 'parent', true),
('user_parent_010', 'kavita.patel@parents.com', 'Kavita Patel', '+91-9876544010', 'parent', true),
('user_parent_011', 'deepak.verma@parents.com', 'Deepak Verma', '+91-9876544011', 'parent', true),
('user_parent_012', 'sunita.verma@parents.com', 'Sunita Verma', '+91-9876544012', 'parent', true),
('user_parent_013', 'manoj.joshi@parents.com', 'Manoj Joshi', '+91-9876544013', 'parent', true),
('user_parent_014', 'rekha.joshi@parents.com', 'Rekha Joshi', '+91-9876544014', 'parent', true),
('user_parent_015', 'anil.rao@parents.com', 'Anil Rao', '+91-9876544015', 'parent', true),
('user_parent_016', 'lata.rao@parents.com', 'Lata Rao', '+91-9876544016', 'parent', true),
('user_parent_017', 'sanjay.nair@parents.com', 'Sanjay Nair', '+91-9876544017', 'parent', true),
('user_parent_018', 'geeta.nair@parents.com', 'Geeta Nair', '+91-9876544018', 'parent', true),
('user_parent_019', 'ramesh.agarwal@parents.com', 'Ramesh Agarwal', '+91-9876544019', 'parent', true),
('user_parent_020', 'sushma.agarwal@parents.com', 'Sushma Agarwal', '+91-9876544020', 'parent', true),
('user_parent_021', 'vinod.mishra@parents.com', 'Vinod Mishra', '+91-9876544021', 'parent', true),
('user_parent_022', 'usha.mishra@parents.com', 'Usha Mishra', '+91-9876544022', 'parent', true),
('user_parent_023', 'ashok.tiwari@parents.com', 'Ashok Tiwari', '+91-9876544023', 'parent', true),
('user_parent_024', 'maya.tiwari@parents.com', 'Maya Tiwari', '+91-9876544024', 'parent', true),
('user_parent_025', 'dinesh.pandey@parents.com', 'Dinesh Pandey', '+91-9876544025', 'parent', true),
('user_parent_026', 'shanti.pandey@parents.com', 'Shanti Pandey', '+91-9876544026', 'parent', true),
('user_parent_027', 'mukesh.saxena@parents.com', 'Mukesh Saxena', '+91-9876544027', 'parent', true),
('user_parent_028', 'kiran.saxena@parents.com', 'Kiran Saxena', '+91-9876544028', 'parent', true),
('user_parent_029', 'rajendra.dubey@parents.com', 'Rajendra Dubey', '+91-9876544029', 'parent', true),
('user_parent_030', 'sarita.dubey@parents.com', 'Sarita Dubey', '+91-9876544030', 'parent', true),
('user_parent_031', 'prakash.shukla@parents.com', 'Prakash Shukla', '+91-9876544031', 'parent', true),
('user_parent_032', 'vandana.shukla@parents.com', 'Vandana Shukla', '+91-9876544032', 'parent', true),
('user_parent_033', 'yogesh.tripathi@parents.com', 'Yogesh Tripathi', '+91-9876544033', 'parent', true),
('user_parent_034', 'nisha.tripathi@parents.com', 'Nisha Tripathi', '+91-9876544034', 'parent', true),
('user_parent_035', 'santosh.chandra@parents.com', 'Santosh Chandra', '+91-9876544035', 'parent', true),
('user_parent_036', 'mamta.chandra@parents.com', 'Mamta Chandra', '+91-9876544036', 'parent', true),
('user_parent_037', 'naresh.srivastava@parents.com', 'Naresh Srivastava', '+91-9876544037', 'parent', true),
('user_parent_038', 'sudha.srivastava@parents.com', 'Sudha Srivastava', '+91-9876544038', 'parent', true),
('user_parent_039', 'harish.singh@parents.com', 'Harish Singh', '+91-9876544039', 'parent', true),
('user_parent_040', 'pooja.singh@parents.com', 'Pooja Singh', '+91-9876544040', 'parent', true),
('user_parent_041', 'mohan.yadav@parents.com', 'Mohan Yadav', '+91-9876544041', 'parent', true),
('user_parent_042', 'seema.yadav@parents.com', 'Seema Yadav', '+91-9876544042', 'parent', true),
('user_parent_043', 'gopal.sharma@parents.com', 'Gopal Sharma', '+91-9876544043', 'parent', true),
('user_parent_044', 'radha.sharma@parents.com', 'Radha Sharma', '+91-9876544044', 'parent', true),
('user_parent_045', 'krishna.gupta@parents.com', 'Krishna Gupta', '+91-9876544045', 'parent', true),
('user_parent_046', 'gita.gupta@parents.com', 'Gita Gupta', '+91-9876544046', 'parent', true),
('user_parent_047', 'ram.kumar@parents.com', 'Ram Kumar', '+91-9876544047', 'parent', true),
('user_parent_048', 'sita.kumar@parents.com', 'Sita Kumar', '+91-9876544048', 'parent', true),
('user_parent_049', 'shyam.patel@parents.com', 'Shyam Patel', '+91-9876544049', 'parent', true),
('user_parent_050', 'radha.patel@parents.com', 'Radha Patel', '+91-9876544050', 'parent', true);

-- Insert Parents
INSERT INTO parents (id, user_id, occupation, annual_income, address, emergency_contact) VALUES
('parent_001', 'user_parent_001', 'Software Engineer', 1200000, '123 MG Road, Delhi', '+91-9876544002'),
('parent_002', 'user_parent_002', 'Teacher', 600000, '123 MG Road, Delhi', '+91-9876544001'),
('parent_003', 'user_parent_003', 'Business Owner', 1500000, '456 Park Street, Mumbai', '+91-9876544004'),
('parent_004', 'user_parent_004', 'Doctor', 1800000, '456 Park Street, Mumbai', '+91-9876544003'),
('parent_005', 'user_parent_005', 'Engineer', 1000000, '789 Brigade Road, Bangalore', '+91-9876544006'),
('parent_006', 'user_parent_006', 'Nurse', 500000, '789 Brigade Road, Bangalore', '+91-9876544005'),
('parent_007', 'user_parent_007', 'Accountant', 800000, '321 Civil Lines, Pune', '+91-9876544008'),
('parent_008', 'user_parent_008', 'Homemaker', 0, '321 Civil Lines, Pune', '+91-9876544007'),
('parent_009', 'user_parent_009', 'Manager', 1100000, '654 Sector 15, Noida', '+91-9876544010'),
('parent_010', 'user_parent_010', 'Designer', 700000, '654 Sector 15, Noida', '+91-9876544009'),
('parent_011', 'user_parent_011', 'Lawyer', 1300000, '987 Connaught Place, Delhi', '+91-9876544012'),
('parent_012', 'user_parent_012', 'Homemaker', 0, '987 Connaught Place, Delhi', '+91-9876544011'),
('parent_013', 'user_parent_013', 'Banker', 900000, '147 Bandra West, Mumbai', '+91-9876544014'),
('parent_014', 'user_parent_014', 'Teacher', 600000, '147 Bandra West, Mumbai', '+91-9876544013'),
('parent_015', 'user_parent_015', 'Doctor', 2000000, '258 Koramangala, Bangalore', '+91-9876544016'),
('parent_016', 'user_parent_016', 'Pharmacist', 800000, '258 Koramangala, Bangalore', '+91-9876544015'),
('parent_017', 'user_parent_017', 'IT Professional', 1400000, '369 Hinjewadi, Pune', '+91-9876544018'),
('parent_018', 'user_parent_018', 'HR Manager', 1000000, '369 Hinjewadi, Pune', '+91-9876544017'),
('parent_019', 'user_parent_019', 'Businessman', 1600000, '741 Sector 62, Gurgaon', '+91-9876544020'),
('parent_020', 'user_parent_020', 'Interior Designer', 900000, '741 Sector 62, Gurgaon', '+91-9876544019'),
('parent_021', 'user_parent_021', 'Government Officer', 800000, '852 Gomti Nagar, Lucknow', '+91-9876544022'),
('parent_022', 'user_parent_022', 'School Principal', 700000, '852 Gomti Nagar, Lucknow', '+91-9876544021'),
('parent_023', 'user_parent_023', 'Police Officer', 900000, '963 Hazratganj, Lucknow', '+91-9876544024'),
('parent_024', 'user_parent_024', 'Homemaker', 0, '963 Hazratganj, Lucknow', '+91-9876544023'),
('parent_025', 'user_parent_025', 'Professor', 1100000, '159 University Area, Allahabad', '+91-9876544026'),
('parent_026', 'user_parent_026', 'Librarian', 500000, '159 University Area, Allahabad', '+91-9876544025'),
('parent_027', 'user_parent_027', 'Chartered Accountant', 1500000, '357 Cantonment, Varanasi', '+91-9876544028'),
('parent_028', 'user_parent_028', 'Bank Manager', 1000000, '357 Cantonment, Varanasi', '+91-9876544027'),
('parent_029', 'user_parent_029', 'Advocate', 1200000, '468 Civil Court, Kanpur', '+91-9876544030'),
('parent_030', 'user_parent_030', 'Social Worker', 400000, '468 Civil Court, Kanpur', '+91-9876544029'),
('parent_031', 'user_parent_031', 'Sales Manager', 1000000, '579 Mall Road, Agra', '+91-9876544032'),
('parent_032', 'user_parent_032', 'Fashion Designer', 800000, '579 Mall Road, Agra', '+91-9876544031'),
('parent_033', 'user_parent_033', 'Photographer', 600000, '681 Sadar Bazaar, Meerut', '+91-9876544034'),
('parent_034', 'user_parent_034', 'Artist', 400000, '681 Sadar Bazaar, Meerut', '+91-9876544033'),
('parent_035', 'user_parent_035', 'Journalist', 700000, '792 Press Colony, Ghaziabad', '+91-9876544036'),
('parent_036', 'user_parent_036', 'Editor', 800000, '792 Press Colony, Ghaziabad', '+91-9876544035'),
('parent_037', 'user_parent_037', 'Pilot', 1800000, '813 Airport Road, Delhi', '+91-9876544038'),
('parent_038', 'user_parent_038', 'Air Hostess', 1200000, '813 Airport Road, Delhi', '+91-9876544037'),
('parent_039', 'user_parent_039', 'Army Officer', 1100000, '924 Cantonment, Delhi', '+91-9876544040'),
('parent_040', 'user_parent_040', 'Army Doctor', 1300000, '924 Cantonment, Delhi', '+91-9876544039'),
('parent_041', 'user_parent_041', 'Farmer', 500000, '135 Village Kheda, Mathura', '+91-9876544042'),
('parent_042', 'user_parent_042', 'Homemaker', 0, '135 Village Kheda, Mathura', '+91-9876544041'),
('parent_043', 'user_parent_043', 'Shopkeeper', 600000, '246 Main Market, Aligarh', '+91-9876544044'),
('parent_044', 'user_parent_044', 'Tailor', 300000, '246 Main Market, Aligarh', '+91-9876544043'),
('parent_045', 'user_parent_045', 'Mechanic', 400000, '357 Industrial Area, Moradabad', '+91-9876544046'),
('parent_046', 'user_parent_046', 'Cook', 200000, '357 Industrial Area, Moradabad', '+91-9876544045'),
('parent_047', 'user_parent_047', 'Driver', 300000, '468 Transport Nagar, Bareilly', '+91-9876544048'),
('parent_048', 'user_parent_048', 'Maid', 150000, '468 Transport Nagar, Bareilly', '+91-9876544047'),
('parent_049', 'user_parent_049', 'Electrician', 400000, '579 New Colony, Firozabad', '+91-9876544050'),
('parent_050', 'user_parent_050', 'Homemaker', 0, '579 New Colony, Firozabad', '+91-9876544049');
-- Insert Student Users (120 students)
-- Class 12 Science A (35 students)
INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
('user_student_001', 'aryan.sharma@students.com', 'Aryan Sharma', '+91-9876545001', 'student', true),
('user_student_002', 'priya.singh@students.com', 'Priya Singh', '+91-9876545002', 'student', true),
('user_student_003', 'rahul.kumar@students.com', 'Rahul Kumar', '+91-9876545003', 'student', true),
('user_student_004', 'sneha.gupta@students.com', 'Sneha Gupta', '+91-9876545004', 'student', true),
('user_student_005', 'vikash.patel@students.com', 'Vikash Patel', '+91-9876545005', 'student', true),
('user_student_006', 'anita.verma@students.com', 'Anita Verma', '+91-9876545006', 'student', true),
('user_student_007', 'suresh.joshi@students.com', 'Suresh Joshi', '+91-9876545007', 'student', true),
('user_student_008', 'meera.rao@students.com', 'Meera Rao', '+91-9876545008', 'student', true),
('user_student_009', 'ravi.nair@students.com', 'Ravi Nair', '+91-9876545009', 'student', true),
('user_student_010', 'kavita.agarwal@students.com', 'Kavita Agarwal', '+91-9876545010', 'student', true),
('user_student_011', 'deepak.mishra@students.com', 'Deepak Mishra', '+91-9876545011', 'student', true),
('user_student_012', 'sunita.tiwari@students.com', 'Sunita Tiwari', '+91-9876545012', 'student', true),
('user_student_013', 'manoj.pandey@students.com', 'Manoj Pandey', '+91-9876545013', 'student', true),
('user_student_014', 'rekha.saxena@students.com', 'Rekha Saxena', '+91-9876545014', 'student', true),
('user_student_015', 'anil.dubey@students.com', 'Anil Dubey', '+91-9876545015', 'student', true),
('user_student_016', 'lata.shukla@students.com', 'Lata Shukla', '+91-9876545016', 'student', true),
('user_student_017', 'sanjay.tripathi@students.com', 'Sanjay Tripathi', '+91-9876545017', 'student', true),
('user_student_018', 'geeta.chandra@students.com', 'Geeta Chandra', '+91-9876545018', 'student', true),
('user_student_019', 'ramesh.srivastava@students.com', 'Ramesh Srivastava', '+91-9876545019', 'student', true),
('user_student_020', 'sushma.singh@students.com', 'Sushma Singh', '+91-9876545020', 'student', true),
('user_student_021', 'vinod.yadav@students.com', 'Vinod Yadav', '+91-9876545021', 'student', true),
('user_student_022', 'usha.sharma@students.com', 'Usha Sharma', '+91-9876545022', 'student', true),
('user_student_023', 'ashok.gupta@students.com', 'Ashok Gupta', '+91-9876545023', 'student', true),
('user_student_024', 'maya.kumar@students.com', 'Maya Kumar', '+91-9876545024', 'student', true),
('user_student_025', 'dinesh.patel@students.com', 'Dinesh Patel', '+91-9876545025', 'student', true),
('user_student_026', 'shanti.verma@students.com', 'Shanti Verma', '+91-9876545026', 'student', true),
('user_student_027', 'mukesh.joshi@students.com', 'Mukesh Joshi', '+91-9876545027', 'student', true),
('user_student_028', 'kiran.rao@students.com', 'Kiran Rao', '+91-9876545028', 'student', true),
('user_student_029', 'rajendra.nair@students.com', 'Rajendra Nair', '+91-9876545029', 'student', true),
('user_student_030', 'sarita.agarwal@students.com', 'Sarita Agarwal', '+91-9876545030', 'student', true),
('user_student_031', 'prakash.mishra@students.com', 'Prakash Mishra', '+91-9876545031', 'student', true),
('user_student_032', 'vandana.tiwari@students.com', 'Vandana Tiwari', '+91-9876545032', 'student', true),
('user_student_033', 'yogesh.pandey@students.com', 'Yogesh Pandey', '+91-9876545033', 'student', true),
('user_student_034', 'nisha.saxena@students.com', 'Nisha Saxena', '+91-9876545034', 'student', true),
('user_student_035', 'santosh.dubey@students.com', 'Santosh Dubey', '+91-9876545035', 'student', true);

-- Continue with remaining 85 student users (simplified for brevity)
-- Class 12 Science B (35 students) - students 036-070
-- Class 12 Commerce (30 students) - students 071-100  
-- Class 11 Science A (40 students) - students 101-140 (but we only go to 120)
-- Class 11 Science B (40 students) - students 141-180 (but we only go to 120)
-- Class 10 A (45 students) - students 181-225 (but we only go to 120)

-- For brevity, I'll add the remaining students with a pattern
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 36..120 LOOP
        INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
        ('user_student_' || LPAD(i::text, 3, '0'), 'student' || i || '@students.com', 'Student ' || i, '+91-98765' || (45000 + i), 'student', true);
    END LOOP;
END $$;

-- Insert Students for Class 12 Science A (35 students)
INSERT INTO students (id, user_id, parent_id, batch_id, roll_number, date_of_birth, address, admission_date, total_fees, fees_paid, fee_status, blood_group) VALUES
('student_001', 'user_student_001', 'parent_001', 'batch_12_science_a', '12SA001', '2006-05-15', '123 MG Road, Delhi', '2023-04-01', 55000, 40000, 'partial', 'B+'),
('student_002', 'user_student_002', 'parent_003', 'batch_12_science_a', '12SA002', '2006-08-22', '456 Park Street, Mumbai', '2023-04-01', 55000, 55000, 'full', 'A+'),
('student_003', 'user_student_003', 'parent_005', 'batch_12_science_a', '12SA003', '2006-12-10', '789 Brigade Road, Bangalore', '2023-04-01', 55000, 25000, 'partial', 'O+'),
('student_004', 'user_student_004', 'parent_007', 'batch_12_science_a', '12SA004', '2006-03-18', '321 Civil Lines, Pune', '2023-04-01', 55000, 55000, 'full', 'AB+'),
('student_005', 'user_student_005', 'parent_009', 'batch_12_science_a', '12SA005', '2006-07-25', '654 Sector 15, Noida', '2023-04-01', 55000, 30000, 'partial', 'B-'),
('student_006', 'user_student_006', 'parent_011', 'batch_12_science_a', '12SA006', '2006-11-08', '987 Connaught Place, Delhi', '2023-04-01', 55000, 55000, 'full', 'A-'),
('student_007', 'user_student_007', 'parent_013', 'batch_12_science_a', '12SA007', '2006-04-14', '147 Bandra West, Mumbai', '2023-04-01', 55000, 35000, 'partial', 'O-'),
('student_008', 'user_student_008', 'parent_015', 'batch_12_science_a', '12SA008', '2006-09-30', '258 Koramangala, Bangalore', '2023-04-01', 55000, 55000, 'full', 'AB-'),
('student_009', 'user_student_009', 'parent_017', 'batch_12_science_a', '12SA009', '2006-01-12', '369 Hinjewadi, Pune', '2023-04-01', 55000, 20000, 'partial', 'B+'),
('student_010', 'user_student_010', 'parent_019', 'batch_12_science_a', '12SA010', '2006-06-28', '741 Sector 62, Gurgaon', '2023-04-01', 55000, 55000, 'full', 'A+'),
('student_011', 'user_student_011', 'parent_021', 'batch_12_science_a', '12SA011', '2006-02-14', '852 Gomti Nagar, Lucknow', '2023-04-01', 55000, 45000, 'partial', 'O+'),
('student_012', 'user_student_012', 'parent_023', 'batch_12_science_a', '12SA012', '2006-10-05', '963 Hazratganj, Lucknow', '2023-04-01', 55000, 55000, 'full', 'B+'),
('student_013', 'user_student_013', 'parent_025', 'batch_12_science_a', '12SA013', '2006-08-17', '159 University Area, Allahabad', '2023-04-01', 55000, 30000, 'partial', 'A-'),
('student_014', 'user_student_014', 'parent_027', 'batch_12_science_a', '12SA014', '2006-12-03', '357 Cantonment, Varanasi', '2023-04-01', 55000, 55000, 'full', 'AB+'),
('student_015', 'user_student_015', 'parent_029', 'batch_12_science_a', '12SA015', '2006-04-21', '468 Civil Court, Kanpur', '2023-04-01', 55000, 40000, 'partial', 'O-'),
('student_016', 'user_student_016', 'parent_031', 'batch_12_science_a', '12SA016', '2006-07-09', '579 Mall Road, Agra', '2023-04-01', 55000, 55000, 'full', 'B-'),
('student_017', 'user_student_017', 'parent_033', 'batch_12_science_a', '12SA017', '2006-11-26', '681 Sadar Bazaar, Meerut', '2023-04-01', 55000, 25000, 'partial', 'A+'),
('student_018', 'user_student_018', 'parent_035', 'batch_12_science_a', '12SA018', '2006-03-13', '792 Press Colony, Ghaziabad', '2023-04-01', 55000, 55000, 'full', 'O+'),
('student_019', 'user_student_019', 'parent_037', 'batch_12_science_a', '12SA019', '2006-09-01', '813 Airport Road, Delhi', '2023-04-01', 55000, 35000, 'partial', 'AB-'),
('student_020', 'user_student_020', 'parent_039', 'batch_12_science_a', '12SA020', '2006-05-18', '924 Cantonment, Delhi', '2023-04-01', 55000, 55000, 'full', 'B+'),
('student_021', 'user_student_021', 'parent_041', 'batch_12_science_a', '12SA021', '2006-01-25', '135 Village Kheda, Mathura', '2023-04-01', 55000, 20000, 'partial', 'A-'),
('student_022', 'user_student_022', 'parent_043', 'batch_12_science_a', '12SA022', '2006-08-11', '246 Main Market, Aligarh', '2023-04-01', 55000, 45000, 'partial', 'O-'),
('student_023', 'user_student_023', 'parent_045', 'batch_12_science_a', '12SA023', '2006-12-28', '357 Industrial Area, Moradabad', '2023-04-01', 55000, 55000, 'full', 'AB+'),
('student_024', 'user_student_024', 'parent_047', 'batch_12_science_a', '12SA024', '2006-04-06', '468 Transport Nagar, Bareilly', '2023-04-01', 55000, 30000, 'partial', 'B-'),
('student_025', 'user_student_025', 'parent_049', 'batch_12_science_a', '12SA025', '2006-10-23', '579 New Colony, Firozabad', '2023-04-01', 55000, 55000, 'full', 'A+'),
('student_026', 'user_student_026', 'parent_001', 'batch_12_science_a', '12SA026', '2006-06-15', '123 MG Road, Delhi', '2023-04-01', 55000, 40000, 'partial', 'O+'),
('student_027', 'user_student_027', 'parent_003', 'batch_12_science_a', '12SA027', '2006-02-02', '456 Park Street, Mumbai', '2023-04-01', 55000, 25000, 'partial', 'B+'),
('student_028', 'user_student_028', 'parent_005', 'batch_12_science_a', '12SA028', '2006-09-19', '789 Brigade Road, Bangalore', '2023-04-01', 55000, 55000, 'full', 'AB-'),
('student_029', 'user_student_029', 'parent_007', 'batch_12_science_a', '12SA029', '2006-05-07', '321 Civil Lines, Pune', '2023-04-01', 55000, 35000, 'partial', 'A-'),
('student_030', 'user_student_030', 'parent_009', 'batch_12_science_a', '12SA030', '2006-11-24', '654 Sector 15, Noida', '2023-04-01', 55000, 55000, 'full', 'O-'),
('student_031', 'user_student_031', 'parent_011', 'batch_12_science_a', '12SA031', '2006-07-12', '987 Connaught Place, Delhi', '2023-04-01', 55000, 20000, 'partial', 'B-'),
('student_032', 'user_student_032', 'parent_013', 'batch_12_science_a', '12SA032', '2006-03-29', '147 Bandra West, Mumbai', '2023-04-01', 55000, 45000, 'partial', 'A+'),
('student_033', 'user_student_033', 'parent_015', 'batch_12_science_a', '12SA033', '2006-10-16', '258 Koramangala, Bangalore', '2023-04-01', 55000, 55000, 'full', 'AB+'),
('student_034', 'user_student_034', 'parent_017', 'batch_12_science_a', '12SA034', '2006-06-04', '369 Hinjewadi, Pune', '2023-04-01', 55000, 30000, 'partial', 'O+'),
('student_035', 'user_student_035', 'parent_019', 'batch_12_science_a', '12SA035', '2006-01-21', '741 Sector 62, Gurgaon', '2023-04-01', 55000, 55000, 'full', 'B+');

-- For brevity, I'll add the remaining students with a pattern
DO $$
DECLARE
    i INTEGER;
    batch_id TEXT;
    parent_id TEXT;
    roll_prefix TEXT;
    fees INTEGER;
    fees_paid INTEGER;
    fee_status TEXT;
    blood_groups TEXT[] := ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    addresses TEXT[] := ARRAY['Delhi', 'Mumbai', 'Bangalore', 'Pune', 'Noida', 'Gurgaon', 'Lucknow', 'Kanpur'];
BEGIN
    FOR i IN 36..120 LOOP
        -- Determine batch based on student number
        IF i <= 70 THEN
            batch_id := 'batch_12_science_b';
            roll_prefix := '12SB';
            fees := 55000;
        ELSIF i <= 100 THEN
            batch_id := 'batch_12_commerce';
            roll_prefix := '12C';
            fees := 50000;
        ELSE
            batch_id := 'batch_11_science_a';
            roll_prefix := '11SA';
            fees := 50000;
        END IF;
        
        -- Assign parent (cycling through available parents)
        parent_id := 'parent_' || LPAD(((i - 1) % 50 + 1)::text, 3, '0');
        
        -- Random fees paid and status
        fees_paid := fees * (0.3 + (i % 8) * 0.1); -- Varies from 30% to 100%
        IF fees_paid >= fees THEN
            fee_status := 'full';
        ELSIF fees_paid > 0 THEN
            fee_status := 'partial';
        ELSE
            fee_status := 'pending';
        END IF;
        
        INSERT INTO students (id, user_id, parent_id, batch_id, roll_number, date_of_birth, address, admission_date, total_fees, fees_paid, fee_status, blood_group) VALUES
        ('student_' || LPAD(i::text, 3, '0'), 
         'user_student_' || LPAD(i::text, 3, '0'), 
         parent_id, 
         batch_id, 
         roll_prefix || LPAD((i % 50 + 1)::text, 3, '0'),
         '2006-' || LPAD((i % 12 + 1)::text, 2, '0') || '-' || LPAD((i % 28 + 1)::text, 2, '0'),
         'Address ' || i || ', ' || addresses[i % 8 + 1],
         '2023-04-01',
         fees,
         fees_paid,
         fee_status,
         blood_groups[i % 8 + 1]);
    END LOOP;
END $$;
-- Insert Student-Subject Mappings
-- Science students (1-70) get Physics, Chemistry, Mathematics, English
-- Some also get Biology (1-35)
-- Commerce students (71-100) get Mathematics, Economics, English, Hindi
-- Class 11 students (101-120) get Physics, Chemistry, Mathematics, English, Biology

DO $$
DECLARE
    i INTEGER;
    student_id TEXT;
    subject_ids TEXT[];
    subject_id TEXT;
BEGIN
    FOR i IN 1..120 LOOP
        student_id := 'student_' || LPAD(i::text, 3, '0');
        
        -- Determine subjects based on student batch
        IF i <= 35 THEN
            -- Class 12 Science A - with Biology
            subject_ids := ARRAY['sub_physics', 'sub_chemistry', 'sub_mathematics', 'sub_english', 'sub_biology'];
        ELSIF i <= 70 THEN
            -- Class 12 Science B - without Biology
            subject_ids := ARRAY['sub_physics', 'sub_chemistry', 'sub_mathematics', 'sub_english'];
        ELSIF i <= 100 THEN
            -- Class 12 Commerce
            subject_ids := ARRAY['sub_mathematics', 'sub_economics', 'sub_english', 'sub_hindi'];
        ELSE
            -- Class 11 Science A
            subject_ids := ARRAY['sub_physics', 'sub_chemistry', 'sub_mathematics', 'sub_english', 'sub_biology'];
        END IF;
        
        -- Insert mappings for each subject
        FOREACH subject_id IN ARRAY subject_ids
        LOOP
            INSERT INTO student_subjects (id, student_id, subject_id, enrollment_date, is_active) VALUES
            ('ss_' || student_id || '_' || subject_id, student_id, subject_id, '2023-04-01', true);
        END LOOP;
    END LOOP;
END $$;

-- Insert Timetables (Non-conflicting schedules)
INSERT INTO timetables (id, batch_id, subject_id, teacher_id, day_of_week, start_time, end_time, room_number, is_active) VALUES
-- Monday Schedule
('tt_001', 'batch_12_science_a', 'sub_physics', 'teacher_001', 'monday', '09:00', '10:00', 'Room 101', true),
('tt_002', 'batch_12_science_a', 'sub_chemistry', 'teacher_002', 'monday', '10:00', '11:00', 'Lab 1', true),
('tt_003', 'batch_12_science_a', 'sub_mathematics', 'teacher_003', 'monday', '11:30', '12:30', 'Room 102', true),
('tt_004', 'batch_12_science_a', 'sub_english', 'teacher_005', 'monday', '13:30', '14:30', 'Room 103', true),

-- Tuesday Schedule
('tt_005', 'batch_12_science_b', 'sub_physics', 'teacher_001', 'tuesday', '09:00', '10:00', 'Room 101', true),
('tt_006', 'batch_12_science_b', 'sub_chemistry', 'teacher_002', 'tuesday', '10:00', '11:00', 'Lab 1', true),
('tt_007', 'batch_12_science_b', 'sub_mathematics', 'teacher_003', 'tuesday', '11:30', '12:30', 'Room 102', true),
('tt_008', 'batch_12_science_b', 'sub_english', 'teacher_005', 'tuesday', '13:30', '14:30', 'Room 103', true),

-- Wednesday Schedule
('tt_009', 'batch_12_commerce', 'sub_economics', 'teacher_008', 'wednesday', '09:00', '10:00', 'Room 201', true),
('tt_010', 'batch_12_commerce', 'sub_mathematics', 'teacher_003', 'wednesday', '10:00', '11:00', 'Room 102', true),
('tt_011', 'batch_12_commerce', 'sub_english', 'teacher_005', 'wednesday', '11:30', '12:30', 'Room 103', true),
('tt_012', 'batch_12_commerce', 'sub_hindi', 'teacher_006', 'wednesday', '13:30', '14:30', 'Room 104', true),

-- Thursday Schedule
('tt_013', 'batch_11_science_a', 'sub_physics', 'teacher_001', 'thursday', '09:00', '10:00', 'Room 101', true),
('tt_014', 'batch_11_science_a', 'sub_biology', 'teacher_004', 'thursday', '10:00', '11:00', 'Lab 2', true),
('tt_015', 'batch_11_science_a', 'sub_mathematics', 'teacher_003', 'thursday', '11:30', '12:30', 'Room 102', true),
('tt_016', 'batch_11_science_a', 'sub_english', 'teacher_005', 'thursday', '13:30', '14:30', 'Room 103', true);

-- Insert Homework
INSERT INTO homework (id, title, description, subject_id, batch_id, teacher_id, assigned_date, due_date, status, max_marks) VALUES
('hw_001', 'Physics - Laws of Motion', 'Solve problems from Chapter 5, Questions 1-10', 'sub_physics', 'batch_12_science_a', 'teacher_001', '2024-04-01', '2024-04-08', 'active', 50),
('hw_002', 'Chemistry - Organic Compounds', 'Complete the worksheet on organic reactions', 'sub_chemistry', 'batch_12_science_a', 'teacher_002', '2024-04-02', '2024-04-09', 'active', 40),
('hw_003', 'Mathematics - Calculus', 'Solve integration problems from Chapter 7', 'sub_mathematics', 'batch_12_science_b', 'teacher_003', '2024-04-03', '2024-04-10', 'active', 60),
('hw_004', 'Economics - Market Structure', 'Analyze different market structures with examples', 'sub_economics', 'batch_12_commerce', 'teacher_008', '2024-04-04', '2024-04-11', 'active', 45),
('hw_005', 'Biology - Cell Structure', 'Draw and label plant and animal cells', 'sub_biology', 'batch_11_science_a', 'teacher_004', '2024-04-05', '2024-04-12', 'active', 35),
('hw_006', 'English - Essay Writing', 'Write a 500-word essay on Environmental Conservation', 'sub_english', 'batch_12_science_a', 'teacher_005', '2024-04-06', '2024-04-13', 'active', 30);

-- Insert Tests
INSERT INTO tests (id, title, description, subject_id, batch_id, teacher_id, test_date, start_time, duration_minutes, max_marks, status, room_number) VALUES
('test_001', 'Physics Unit Test 1', 'Test on Mechanics and Thermodynamics', 'sub_physics', 'batch_12_science_a', 'teacher_001', '2024-04-15', '09:00', 90, 100, 'completed', 'Exam Hall 1'),
('test_002', 'Chemistry Practical Test', 'Practical examination on organic chemistry', 'sub_chemistry', 'batch_12_science_a', 'teacher_002', '2024-04-20', '10:00', 120, 80, 'scheduled', 'Lab 1'),
('test_003', 'Mathematics Mid-term', 'Comprehensive test on calculus and algebra', 'sub_mathematics', 'batch_11_science_a', 'teacher_003', '2024-04-25', '09:00', 180, 150, 'scheduled', 'Exam Hall 2'),
('test_004', 'Economics Unit Test', 'Test on market structures and demand-supply', 'sub_economics', 'batch_12_commerce', 'teacher_008', '2024-04-18', '11:00', 90, 100, 'scheduled', 'Room 201'),
('test_005', 'Biology Practical', 'Microscopy and cell observation', 'sub_biology', 'batch_11_science_a', 'teacher_004', '2024-04-22', '14:00', 120, 50, 'scheduled', 'Lab 2');

-- Insert Test Results (for completed test only)
DO $$
DECLARE
    i INTEGER;
    student_id TEXT;
    marks INTEGER;
    percentage NUMERIC;
    grade TEXT;
    remarks TEXT;
BEGIN
    FOR i IN 1..35 LOOP -- Class 12 Science A students
        student_id := 'student_' || LPAD(i::text, 3, '0');
        marks := 60 + (i % 40); -- Random marks between 60-100
        percentage := (marks::NUMERIC / 100.0) * 100;
        
        -- Assign grade based on percentage
        IF percentage >= 90 THEN
            grade := 'A+';
            remarks := 'Outstanding performance!';
        ELSIF percentage >= 80 THEN
            grade := 'A';
            remarks := 'Excellent work!';
        ELSIF percentage >= 70 THEN
            grade := 'B+';
            remarks := 'Good performance';
        ELSIF percentage >= 60 THEN
            grade := 'B';
            remarks := 'Satisfactory performance';
        ELSE
            grade := 'C';
            remarks := 'Need improvement';
        END IF;
        
        INSERT INTO test_results (id, test_id, student_id, marks_obtained, percentage, grade, remarks, submitted_date) VALUES
        ('result_' || LPAD(i::text, 3, '0'), 'test_001', student_id, marks, percentage, grade, remarks, '2024-04-15');
    END LOOP;
END $$;

-- Insert Fee Payments (Multiple payments per student)
DO $$
DECLARE
    i INTEGER;
    j INTEGER;
    student_id TEXT;
    payment_amount INTEGER;
    payment_date DATE;
    payment_methods TEXT[] := ARRAY['cash', 'upi', 'bank_transfer', 'card', 'cheque'];
BEGIN
    FOR i IN 1..120 LOOP
        student_id := 'student_' || LPAD(i::text, 3, '0');
        
        -- Each student has 1-3 payments
        FOR j IN 1..(1 + (i % 3)) LOOP
            payment_amount := 10000 + (i % 20) * 1000; -- Varies from 10k to 30k
            payment_date := '2023-04-01'::DATE + (j * 30 + i % 30) * INTERVAL '1 day';
            
            INSERT INTO fee_payments (id, student_id, amount, payment_date, payment_method, transaction_id, status, description, received_by) VALUES
            ('pay_' || student_id || '_' || j, 
             student_id, 
             payment_amount, 
             payment_date, 
             payment_methods[(i + j) % 5 + 1], 
             'TXN' || (1000000 + i * 10 + j), 
             'completed', 
             'Fee payment installment ' || j, 
             'staff_001');
        END LOOP;
    END LOOP;
END $$;

-- Insert Teacher Feedback (50 feedback messages)
DO $$
DECLARE
    i INTEGER;
    student_id TEXT;
    teacher_id TEXT;
    subject_id TEXT;
    categories TEXT[] := ARRAY['academic', 'behaviour', 'attendance', 'general'];
    category TEXT;
    messages TEXT[];
    message TEXT;
BEGIN
    FOR i IN 1..50 LOOP
        student_id := 'student_' || LPAD(i::text, 3, '0');
        teacher_id := 'teacher_' || LPAD((i % 8 + 1)::text, 3, '0');
        subject_id := CASE 
            WHEN i % 4 = 1 THEN 'sub_physics'
            WHEN i % 4 = 2 THEN 'sub_chemistry'
            WHEN i % 4 = 3 THEN 'sub_mathematics'
            ELSE 'sub_english'
        END;
        category := categories[i % 4 + 1];
        
        -- Select appropriate message based on category
        messages := CASE category
            WHEN 'academic' THEN ARRAY['Shows excellent understanding of concepts', 'Needs to focus more on problem-solving', 'Great improvement in recent tests', 'Should practice more numerical problems']
            WHEN 'behaviour' THEN ARRAY['Well-behaved and respectful student', 'Shows leadership qualities', 'Needs to be more attentive in class', 'Participates actively in discussions']
            WHEN 'attendance' THEN ARRAY['Regular attendance, keep it up!', 'Frequent absences affecting performance', 'Good punctuality', 'Should improve attendance']
            ELSE ARRAY['Overall good performance', 'Shows potential for improvement', 'Hardworking and dedicated student', 'Should maintain consistency']
        END;
        
        message := messages[i % 4 + 1];
        
        INSERT INTO teacher_feedback (id, teacher_id, student_id, subject_id, message, category, is_read, created_at) VALUES
        ('feedback_' || LPAD(i::text, 3, '0'), 
         teacher_id, 
         student_id, 
         subject_id, 
         message, 
         category, 
         (i % 3 = 0), -- Some feedback is read, some unread
         NOW() - (i || ' days')::INTERVAL);
    END LOOP;
END $$;

-- Insert Broadcasts
INSERT INTO broadcasts (id, title, message, target_audience, sent_by, sent_date, is_urgent, is_active) VALUES
('broadcast_001', 'School Holiday Notice', 'School will remain closed on April 10th due to local festival. Regular classes will resume on April 11th.', 'all', 'admin_001', '2024-04-05', false, true),
('broadcast_002', 'Parent-Teacher Meeting', 'Parent-Teacher meeting is scheduled for April 20th from 10 AM to 4 PM. Please confirm your attendance.', 'parents', 'admin_001', '2024-04-08', true, true),
('broadcast_003', 'Exam Schedule Released', 'The final examination schedule has been released. Please check the notice board for details.', 'students', 'staff_001', '2024-04-12', false, true),
('broadcast_004', 'Library Books Due', 'All library books are due for return by April 30th. Late fees will be applicable after the due date.', 'students', 'staff_002', '2024-04-15', false, true),
('broadcast_005', 'Sports Day Announcement', 'Annual Sports Day will be held on May 5th. All students are encouraged to participate.', 'all', 'admin_001', '2024-04-18', false, true);

-- ============================================================================
-- PART 6: ENABLE ROW LEVEL SECURITY AND CREATE POLICIES
-- ============================================================================

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

-- ============================================================================
-- PART 7: VERIFICATION QUERIES
-- ============================================================================

-- Verify data counts
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Subjects', COUNT(*) FROM subjects
UNION ALL
SELECT 'Batches', COUNT(*) FROM batches
UNION ALL
SELECT 'Teachers', COUNT(*) FROM teachers
UNION ALL
SELECT 'Parents', COUNT(*) FROM parents
UNION ALL
SELECT 'Students', COUNT(*) FROM students
UNION ALL
SELECT 'Student Subjects', COUNT(*) FROM student_subjects
UNION ALL
SELECT 'Timetables', COUNT(*) FROM timetables
UNION ALL
SELECT 'Homework', COUNT(*) FROM homework
UNION ALL
SELECT 'Tests', COUNT(*) FROM tests
UNION ALL
SELECT 'Test Results', COUNT(*) FROM test_results
UNION ALL
SELECT 'Fee Payments', COUNT(*) FROM fee_payments
UNION ALL
SELECT 'Teacher Feedback', COUNT(*) FROM teacher_feedback
UNION ALL
SELECT 'Broadcasts', COUNT(*) FROM broadcasts;

-- Verify user roles
SELECT role, COUNT(*) as count 
FROM users 
GROUP BY role 
ORDER BY role;

-- Verify student distribution by batch
SELECT b.name as batch_name, COUNT(s.id) as student_count
FROM batches b
LEFT JOIN students s ON b.id = s.batch_id
GROUP BY b.id, b.name
ORDER BY b.name;

-- Test the student_details view
SELECT COUNT(*) as student_details_count FROM student_details;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================

SELECT '🎉 VidyaSarathi Database Setup Complete! 🎉' as status,
       'Database is ready with 120+ students, 50 parents, 8 teachers, and comprehensive data.' as message;