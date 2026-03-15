-- ============================================================
--  VIDYASARATHI - COMPLETE SUPABASE SETUP
--  Run this ENTIRE file in Supabase SQL Editor (New Query)
--  This creates all tables AND seeds all demo data
-- ============================================================

-- ==================== STEP 1: DROP EXISTING TABLES (clean slate) ====================
DROP TABLE IF EXISTS feedbacks CASCADE;
DROP TABLE IF EXISTS doubts CASCADE;
DROP TABLE IF EXISTS broadcasts CASCADE;
DROP TABLE IF EXISTS fee_payments CASCADE;
DROP TABLE IF EXISTS test_results CASCADE;
DROP TABLE IF EXISTS tests CASCADE;
DROP TABLE IF EXISTS homework_submissions CASCADE;
DROP TABLE IF EXISTS homework CASCADE;
DROP TABLE IF EXISTS syllabus_items CASCADE;
DROP TABLE IF EXISTS timetables CASCADE;
DROP TABLE IF EXISTS admissions CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS auth_credentials CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==================== STEP 2: AUTH CREDENTIALS TABLE ====================
-- This is how VidyaSarathi handles login (custom auth, not Supabase Auth)
CREATE TABLE auth_credentials (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,  -- Plain text for MVP; use bcrypt in production
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin_staff', 'teacher', 'student', 'parent')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS but allow all reads (auth is handled in app layer)
ALTER TABLE auth_credentials ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read for login" ON auth_credentials FOR SELECT USING (TRUE);
CREATE POLICY "Allow insert for signup" ON auth_credentials FOR INSERT WITH CHECK (TRUE);

-- ==================== STEP 3: SUBJECTS TABLE ====================
CREATE TABLE subjects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view subjects" ON subjects FOR SELECT USING (TRUE);
CREATE POLICY "Admins manage subjects" ON subjects FOR ALL USING (TRUE);

-- ==================== STEP 4: BATCHES TABLE ====================
CREATE TABLE batches (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  level TEXT NOT NULL,
  subject_ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view batches" ON batches FOR SELECT USING (TRUE);
CREATE POLICY "Admins manage batches" ON batches FOR ALL USING (TRUE);

-- ==================== STEP 5: USERS TABLE ====================
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin_staff', 'teacher', 'student', 'parent')),
  phone_number TEXT,
  profile_image TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  credential_id TEXT REFERENCES auth_credentials(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read all users" ON users FOR SELECT USING (TRUE);
CREATE POLICY "Allow insert users" ON users FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow update users" ON users FOR UPDATE USING (TRUE);

-- ==================== STEP 6: STUDENTS TABLE ====================
CREATE TABLE students (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  parent_name TEXT,
  parent_email TEXT,
  parent_phone TEXT,
  batch_id TEXT NOT NULL REFERENCES batches(id),
  subject_ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  total_fees INTEGER DEFAULT 0,
  fees_paid INTEGER DEFAULT 0,
  fee_status TEXT DEFAULT 'pending' CHECK (fee_status IN ('pending', 'partial', 'full', 'overdue')),
  enrollment_status TEXT DEFAULT 'active' CHECK (enrollment_status IN ('active', 'inactive', 'suspended')),
  enrollment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read all students" ON students FOR SELECT USING (TRUE);
CREATE POLICY "Allow insert students" ON students FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow update students" ON students FOR UPDATE USING (TRUE);

-- ==================== STEP 7: ADMISSIONS TABLE ====================
CREATE TABLE admissions (
  id TEXT PRIMARY KEY,
  student_name TEXT NOT NULL,
  parent_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  parent_phone TEXT,
  applied_batch_id TEXT NOT NULL REFERENCES batches(id),
  requested_subject_ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  applied_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE admissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all admissions" ON admissions FOR ALL USING (TRUE);

-- ==================== STEP 8: TIMETABLES TABLE ====================
CREATE TABLE timetables (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL REFERENCES batches(id),
  subject_id TEXT NOT NULL REFERENCES subjects(id),
  teacher_id UUID NOT NULL REFERENCES users(id),
  day TEXT NOT NULL CHECK (day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')),
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  room TEXT,
  proxy_teacher_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE timetables ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all timetables" ON timetables FOR ALL USING (TRUE);

-- ==================== STEP 9: SYLLABUS_ITEMS TABLE ====================
CREATE TABLE syllabus_items (
  id TEXT PRIMARY KEY,
  subject_id TEXT NOT NULL REFERENCES subjects(id),
  topic TEXT NOT NULL,
  description TEXT,
  ordering INTEGER,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE syllabus_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all syllabus" ON syllabus_items FOR ALL USING (TRUE);

-- ==================== STEP 10: HOMEWORK TABLE ====================
CREATE TABLE homework (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL REFERENCES batches(id),
  subject_id TEXT NOT NULL REFERENCES subjects(id),
  teacher_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMP WITH TIME ZONE NOT NULL,
  assigned_students TEXT[] DEFAULT ARRAY[]::TEXT[],
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'overdue')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE homework ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all homework" ON homework FOR ALL USING (TRUE);

-- ==================== STEP 11: HOMEWORK_SUBMISSIONS TABLE ====================
CREATE TABLE homework_submissions (
  id TEXT PRIMARY KEY,
  homework_id TEXT NOT NULL REFERENCES homework(id) ON DELETE CASCADE,
  student_id TEXT NOT NULL REFERENCES students(id),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'submitted', 'late', 'graded')),
  submitted_date TIMESTAMP WITH TIME ZONE,
  remarks TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE homework_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all submissions" ON homework_submissions FOR ALL USING (TRUE);

-- ==================== STEP 12: TESTS TABLE ====================
CREATE TABLE tests (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL REFERENCES batches(id),
  subject_id TEXT NOT NULL REFERENCES subjects(id),
  teacher_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  test_date TIMESTAMP WITH TIME ZONE NOT NULL,
  total_marks INTEGER DEFAULT 100,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all tests" ON tests FOR ALL USING (TRUE);

-- ==================== STEP 13: TEST_RESULTS TABLE ====================
CREATE TABLE test_results (
  id TEXT PRIMARY KEY,
  test_id TEXT NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
  student_id TEXT NOT NULL REFERENCES students(id),
  marks_obtained INTEGER,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'graded')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all test results" ON test_results FOR ALL USING (TRUE);

-- ==================== STEP 14: FEE_PAYMENTS TABLE ====================
CREATE TABLE fee_payments (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL REFERENCES students(id),
  amount INTEGER NOT NULL,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'card', 'upi', 'bank_transfer')),
  payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
  reference TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE fee_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all fee payments" ON fee_payments FOR ALL USING (TRUE);

-- ==================== STEP 15: BROADCASTS TABLE ====================
CREATE TABLE broadcasts (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  sent_by UUID NOT NULL REFERENCES users(id),
  sent_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  target_audience TEXT NOT NULL CHECK (target_audience IN ('all', 'students', 'parents', 'teachers', 'staff')),
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('normal', 'high', 'urgent')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE broadcasts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all broadcasts" ON broadcasts FOR ALL USING (TRUE);

-- ==================== STEP 16: DOUBTS TABLE ====================
CREATE TABLE doubts (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL REFERENCES students(id),
  subject_id TEXT NOT NULL REFERENCES subjects(id),
  title TEXT NOT NULL,
  description TEXT,
  raised_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved')),
  resolved_by UUID REFERENCES users(id),
  resolution TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE doubts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all doubts" ON doubts FOR ALL USING (TRUE);

-- ==================== STEP 17: FEEDBACKS TABLE ====================
CREATE TABLE feedbacks (
  id TEXT PRIMARY KEY,
  student_id TEXT REFERENCES students(id),
  parent_id UUID REFERENCES users(id),
  message TEXT NOT NULL,
  submitted_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'reviewed', 'approved')),
  admin_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all feedbacks" ON feedbacks FOR ALL USING (TRUE);

-- ============================================================
--  SEED DATA - INSERT ALL USERS AND DEMO DATA
-- ============================================================

-- ==================== AUTH CREDENTIALS (Login accounts) ====================
INSERT INTO auth_credentials (id, email, password_hash, name, role) VALUES
  ('cred_admin',   'admin@vidya.com',              'Admin@123',      'Dr. Rajesh Kumar',  'super_admin'),
  ('cred_rec1',    'reception1@vidya.com',          'Reception@123',  'Ms. Anjali Patel',  'admin_staff'),
  ('cred_rec2',    'reception2@vidya.com',          'Reception@456',  'Mr. Arjun Verma',   'admin_staff'),
  ('cred_phy',     'physics@vidya.com',             'Physics@123',    'Mr. Arun Kumar',    'teacher'),
  ('cred_chem',    'chemistry@vidya.com',           'Chemistry@123',  'Mrs. Priya Sharma', 'teacher'),
  ('cred_math',    'maths@vidya.com',               'Maths@123',      'Mr. Vikram Singh',  'teacher'),
  ('cred_stu1',    'aryan.sharma@students.com',     'Student@123',    'Aryan Sharma',      'student'),
  ('cred_stu2',    'priya.singh@students.com',      'Student@456',    'Priya Singh',       'student'),
  ('cred_par1',    'rajesh.sharma@parents.com',     'Parent@123',     'Mr. Rajesh Sharma', 'parent'),
  ('cred_par2',    'kavya.sharma@parents.com',      'Parent@124',     'Mrs. Kavya Sharma', 'parent'),
  ('cred_par3',    'amit.singh@parents.com',        'Parent@456',     'Mr. Amit Singh',    'parent'),
  ('cred_par4',    'sneha.singh@parents.com',       'Parent@457',     'Mrs. Sneha Singh',  'parent');

-- ==================== SUBJECTS ====================
INSERT INTO subjects (id, name, code, description) VALUES
  ('subj_physics',   'Physics',     'PHY101', 'Physics - Core Science Subject'),
  ('subj_chemistry', 'Chemistry',   'CHM101', 'Chemistry - Core Science Subject'),
  ('subj_math',      'Mathematics', 'MTH101', 'Mathematics - Core Subject');

-- ==================== BATCHES ====================
INSERT INTO batches (id, name, level, subject_ids) VALUES
  ('batch_10a', 'Class 10-A', '10', ARRAY['subj_physics', 'subj_chemistry', 'subj_math']),
  ('batch_10b', 'Class 10-B', '10', ARRAY['subj_physics', 'subj_chemistry', 'subj_math']),
  ('batch_11a', 'Class 11-A', '11', ARRAY['subj_physics', 'subj_chemistry', 'subj_math']);

-- ==================== USERS (linked to credentials) ====================
INSERT INTO users (id, email, name, role, phone_number, is_active, credential_id) VALUES
  ('a0000001-0000-0000-0000-000000000001', 'admin@vidya.com',              'Dr. Rajesh Kumar',  'super_admin',  '+91-9876500001', TRUE, 'cred_admin'),
  ('a0000001-0000-0000-0000-000000000002', 'reception1@vidya.com',         'Ms. Anjali Patel',  'admin_staff',  '+91-9876500002', TRUE, 'cred_rec1'),
  ('a0000001-0000-0000-0000-000000000003', 'reception2@vidya.com',         'Mr. Arjun Verma',   'admin_staff',  '+91-9876500003', TRUE, 'cred_rec2'),
  ('a0000001-0000-0000-0000-000000000004', 'physics@vidya.com',            'Mr. Arun Kumar',    'teacher',      '+91-9876500004', TRUE, 'cred_phy'),
  ('a0000001-0000-0000-0000-000000000005', 'chemistry@vidya.com',          'Mrs. Priya Sharma', 'teacher',      '+91-9876500005', TRUE, 'cred_chem'),
  ('a0000001-0000-0000-0000-000000000006', 'maths@vidya.com',              'Mr. Vikram Singh',  'teacher',      '+91-9876500006', TRUE, 'cred_math'),
  ('a0000001-0000-0000-0000-000000000007', 'aryan.sharma@students.com',    'Aryan Sharma',      'student',      '+91-9876543210', TRUE, 'cred_stu1'),
  ('a0000001-0000-0000-0000-000000000008', 'priya.singh@students.com',     'Priya Singh',       'student',      '+91-9876543220', TRUE, 'cred_stu2'),
  ('a0000001-0000-0000-0000-000000000009', 'rajesh.sharma@parents.com',    'Mr. Rajesh Sharma', 'parent',       '+91-9876543200', TRUE, 'cred_par1'),
  ('a0000001-0000-0000-0000-000000000010', 'kavya.sharma@parents.com',     'Mrs. Kavya Sharma', 'parent',       '+91-9876543200', TRUE, 'cred_par2'),
  ('a0000001-0000-0000-0000-000000000011', 'amit.singh@parents.com',       'Mr. Amit Singh',    'parent',       '+91-9876543220', TRUE, 'cred_par3'),
  ('a0000001-0000-0000-0000-000000000012', 'sneha.singh@parents.com',      'Mrs. Sneha Singh',  'parent',       '+91-9876543220', TRUE, 'cred_par4');

-- ==================== STUDENTS ====================
INSERT INTO students (id, user_id, name, email, phone, parent_name, parent_email, parent_phone, batch_id, subject_ids, total_fees, fees_paid, fee_status, enrollment_status) VALUES
  ('stu_001',
   'a0000001-0000-0000-0000-000000000007',
   'Aryan Sharma',
   'aryan.sharma@students.com',
   '+91-9876543210',
   'Mr. Rajesh Sharma',
   'rajesh.sharma@parents.com',
   '+91-9876543200',
   'batch_10a',
   ARRAY['subj_physics', 'subj_chemistry', 'subj_math'],
   50000, 50000, 'full', 'active'),
  ('stu_002',
   'a0000001-0000-0000-0000-000000000008',
   'Priya Singh',
   'priya.singh@students.com',
   '+91-9876543220',
   'Mr. Amit Singh',
   'amit.singh@parents.com',
   '+91-9876543220',
   'batch_10a',
   ARRAY['subj_physics', 'subj_chemistry', 'subj_math'],
   50000, 50000, 'full', 'active');

-- ==================== ADMISSIONS ====================
INSERT INTO admissions (id, student_name, parent_name, email, phone, parent_phone, applied_batch_id, requested_subject_ids, status, notes) VALUES
  ('adm_001', 'Rahul Mehra',   'Mr. Suresh Mehra',  'rahul.mehra@example.com',   '+91-9000000001', '+91-9000000002', 'batch_10b', ARRAY['subj_physics', 'subj_math'],      'pending',  'Strong candidate from CBSE background'),
  ('adm_002', 'Sneha Gupta',   'Mrs. Anita Gupta',  'sneha.gupta@example.com',   '+91-9000000003', '+91-9000000004', 'batch_10a', ARRAY['subj_chemistry', 'subj_math'],   'approved', 'Admission approved on interview'),
  ('adm_003', 'Karan Patel',   'Mr. Rajan Patel',   'karan.patel@example.com',   '+91-9000000005', '+91-9000000006', 'batch_11a', ARRAY['subj_physics', 'subj_chemistry'], 'rejected', 'Did not meet minimum marks criteria'),
  ('adm_004', 'Nisha Verma',   'Mrs. Pooja Verma',  'nisha.verma@example.com',   '+91-9000000007', '+91-9000000008', 'batch_10b', ARRAY['subj_physics', 'subj_chemistry', 'subj_math'], 'pending', NULL),
  ('adm_005', 'Rohan Kapoor',  'Mr. Amit Kapoor',   'rohan.kapoor@example.com',  '+91-9000000009', '+91-9000000010', 'batch_10a', ARRAY['subj_math'],                     'pending',  'Referred by existing student');

-- ==================== TIMETABLES ====================
INSERT INTO timetables (id, batch_id, subject_id, teacher_id, day, start_time, end_time, room) VALUES
  ('tt_001', 'batch_10a', 'subj_physics',   'a0000001-0000-0000-0000-000000000004', 'Monday',    '09:00', '10:00', 'Room 101'),
  ('tt_002', 'batch_10a', 'subj_chemistry', 'a0000001-0000-0000-0000-000000000005', 'Monday',    '10:00', '11:00', 'Room 102'),
  ('tt_003', 'batch_10a', 'subj_math',      'a0000001-0000-0000-0000-000000000006', 'Monday',    '11:00', '12:00', 'Room 103'),
  ('tt_004', 'batch_10a', 'subj_physics',   'a0000001-0000-0000-0000-000000000004', 'Tuesday',   '09:00', '10:00', 'Room 101'),
  ('tt_005', 'batch_10a', 'subj_chemistry', 'a0000001-0000-0000-0000-000000000005', 'Wednesday', '09:00', '10:00', 'Room 102'),
  ('tt_006', 'batch_10a', 'subj_math',      'a0000001-0000-0000-0000-000000000006', 'Thursday',  '11:00', '12:00', 'Room 103'),
  ('tt_007', 'batch_10b', 'subj_physics',   'a0000001-0000-0000-0000-000000000004', 'Tuesday',   '10:00', '11:00', 'Room 201'),
  ('tt_008', 'batch_10b', 'subj_chemistry', 'a0000001-0000-0000-0000-000000000005', 'Thursday',  '09:00', '10:00', 'Room 202'),
  ('tt_009', 'batch_10b', 'subj_math',      'a0000001-0000-0000-0000-000000000006', 'Friday',    '10:00', '11:00', 'Room 203'),
  ('tt_010', 'batch_11a', 'subj_physics',   'a0000001-0000-0000-0000-000000000004', 'Wednesday', '11:00', '12:00', 'Room 301'),
  ('tt_011', 'batch_11a', 'subj_chemistry', 'a0000001-0000-0000-0000-000000000005', 'Friday',    '09:00', '10:00', 'Room 302'),
  ('tt_012', 'batch_11a', 'subj_math',      'a0000001-0000-0000-0000-000000000006', 'Saturday',  '09:00', '11:00', 'Room 303');

-- ==================== SYLLABUS ITEMS ====================
INSERT INTO syllabus_items (id, subject_id, topic, description, ordering, is_completed) VALUES
  ('syl_phy_01', 'subj_physics',   'Motion in a Straight Line',    'Basic kinematics and equations of motion',         1,  TRUE),
  ('syl_phy_02', 'subj_physics',   'Newton''s Laws of Motion',     'Three fundamental laws governing motion',          2,  TRUE),
  ('syl_phy_03', 'subj_physics',   'Work, Energy and Power',       'Work-energy theorem and conservation of energy',   3,  TRUE),
  ('syl_phy_04', 'subj_physics',   'Gravitation',                  'Universal law of gravitation and its applications',4,  FALSE),
  ('syl_phy_05', 'subj_physics',   'Thermodynamics',               'Laws of thermodynamics and heat engines',          5,  FALSE),
  ('syl_chem_01','subj_chemistry', 'Atomic Structure',             'Bohr model and quantum numbers',                   1,  TRUE),
  ('syl_chem_02','subj_chemistry', 'Chemical Bonding',             'Ionic, covalent and metallic bonds',               2,  TRUE),
  ('syl_chem_03','subj_chemistry', 'States of Matter',             'Solid, liquid, gas and their properties',          3,  FALSE),
  ('syl_chem_04','subj_chemistry', 'Thermochemistry',              'Enthalpy, entropy and Gibbs energy',               4,  FALSE),
  ('syl_math_01','subj_math',      'Sets and Functions',           'Set theory, relations and types of functions',     1,  TRUE),
  ('syl_math_02','subj_math',      'Trigonometry',                 'Ratios, identities and inverse functions',         2,  TRUE),
  ('syl_math_03','subj_math',      'Differential Calculus',        'Limits, continuity and differentiation',           3,  FALSE),
  ('syl_math_04','subj_math',      'Integral Calculus',            'Indefinite and definite integrals',                4,  FALSE);

-- ==================== HOMEWORK ====================
INSERT INTO homework (id, batch_id, subject_id, teacher_id, title, description, due_date, status) VALUES
  ('hw_001', 'batch_10a', 'subj_physics',   'a0000001-0000-0000-0000-000000000004',
   'Laws of Motion Problems', 'Solve problems 3.1 to 3.15 from NCERT Chapter 3',
   NOW() + INTERVAL '3 days', 'active'),
  ('hw_002', 'batch_10a', 'subj_chemistry', 'a0000001-0000-0000-0000-000000000005',
   'Chemical Bonding Worksheet', 'Complete the worksheet on ionic vs covalent bonding',
   NOW() + INTERVAL '5 days', 'active'),
  ('hw_003', 'batch_10a', 'subj_math',      'a0000001-0000-0000-0000-000000000006',
   'Integration Practice', 'Solve exercises 7.1 to 7.10 from your textbook',
   NOW() + INTERVAL '2 days', 'active'),
  ('hw_004', 'batch_10b', 'subj_physics',   'a0000001-0000-0000-0000-000000000004',
   'Kinematics Assignment', 'Graphical analysis of motion problems',
   NOW() - INTERVAL '2 days', 'overdue'),
  ('hw_005', 'batch_11a', 'subj_math',      'a0000001-0000-0000-0000-000000000006',
   'Differential Equations', 'First order ODE practice problems from Module 4',
   NOW() + INTERVAL '7 days', 'active');

-- ==================== HOMEWORK SUBMISSIONS ====================
INSERT INTO homework_submissions (id, homework_id, student_id, status, submitted_date) VALUES
  ('hsub_001', 'hw_001', 'stu_001', 'submitted',  NOW() - INTERVAL '1 day'),
  ('hsub_002', 'hw_001', 'stu_002', 'pending',    NULL),
  ('hsub_003', 'hw_002', 'stu_001', 'submitted',  NOW() - INTERVAL '2 days'),
  ('hsub_004', 'hw_002', 'stu_002', 'submitted',  NOW() - INTERVAL '1 day'),
  ('hsub_005', 'hw_003', 'stu_001', 'pending',    NULL),
  ('hsub_006', 'hw_003', 'stu_002', 'late',       NOW());

-- ==================== TESTS ====================
INSERT INTO tests (id, batch_id, subject_id, teacher_id, title, test_date, total_marks, status) VALUES
  ('test_001', 'batch_10a', 'subj_physics',   'a0000001-0000-0000-0000-000000000004',
   'Unit Test 1 - Laws of Motion',   NOW() - INTERVAL '14 days', 100, 'completed'),
  ('test_002', 'batch_10a', 'subj_chemistry', 'a0000001-0000-0000-0000-000000000005',
   'Unit Test 1 - Atomic Structure', NOW() - INTERVAL '10 days', 100, 'completed'),
  ('test_003', 'batch_10a', 'subj_math',      'a0000001-0000-0000-0000-000000000006',
   'Unit Test 1 - Calculus',         NOW() - INTERVAL '7 days',  100, 'completed'),
  ('test_004', 'batch_10a', 'subj_physics',   'a0000001-0000-0000-0000-000000000004',
   'Mid-Term Physics Exam',          NOW() + INTERVAL '14 days', 100, 'scheduled'),
  ('test_005', 'batch_10a', 'subj_math',      'a0000001-0000-0000-0000-000000000006',
   'Mid-Term Mathematics Exam',      NOW() + INTERVAL '18 days', 100, 'scheduled');

-- ==================== TEST RESULTS ====================
INSERT INTO test_results (id, test_id, student_id, marks_obtained, status) VALUES
  ('tr_001', 'test_001', 'stu_001', 85,  'graded'),
  ('tr_002', 'test_001', 'stu_002', 78,  'graded'),
  ('tr_003', 'test_002', 'stu_001', 91,  'graded'),
  ('tr_004', 'test_002', 'stu_002', 88,  'graded'),
  ('tr_005', 'test_003', 'stu_001', 76,  'graded'),
  ('tr_006', 'test_003', 'stu_002', 82,  'graded');

-- ==================== FEE PAYMENTS ====================
INSERT INTO fee_payments (id, student_id, amount, payment_method, payment_date, status, reference) VALUES
  ('fee_001', 'stu_001', 25000, 'upi',           NOW() - INTERVAL '90 days', 'completed', 'UPI-20240101-001'),
  ('fee_002', 'stu_001', 25000, 'bank_transfer',  NOW() - INTERVAL '30 days', 'completed', 'NEFT-20240201-001'),
  ('fee_003', 'stu_002', 25000, 'cash',           NOW() - INTERVAL '85 days', 'completed', 'CASH-20240101-002'),
  ('fee_004', 'stu_002', 25000, 'upi',            NOW() - INTERVAL '28 days', 'completed', 'UPI-20240201-002');

-- ==================== BROADCASTS ====================
INSERT INTO broadcasts (id, title, message, sent_by, target_audience, priority) VALUES
  ('bcast_001',
   'VidyaSarathi Platform Launch!',
   'We are excited to announce the launch of our new academic management platform. All students and parents can now track attendance, marks, and homework online.',
   'a0000001-0000-0000-0000-000000000001',
   'all', 'high'),
  ('bcast_002',
   'Mid-Term Exam Schedule Released',
   'The mid-term examination schedule has been published. Physics exam on 28th March, Chemistry on 30th March, and Mathematics on 1st April. Please prepare accordingly.',
   'a0000001-0000-0000-0000-000000000001',
   'students', 'high'),
  ('bcast_003',
   'Parent-Teacher Meeting - 22nd March',
   'A Parent-Teacher Meeting is scheduled for 22nd March 2026 from 10 AM to 1 PM. All parents are requested to attend.',
   'a0000001-0000-0000-0000-000000000002',
   'parents', 'urgent'),
  ('bcast_004',
   'Holiday Notice - Holi',
   'The institute will remain closed on Holi (14th March). Classes will resume from 15th March. Happy Holi!',
   'a0000001-0000-0000-0000-000000000001',
   'all', 'normal'),
  ('bcast_005',
   'Staff Meeting - Training Update',
   'All teaching staff are requested to attend a training session on the new grading system on 20th March at 2 PM.',
   'a0000001-0000-0000-0000-000000000001',
   'teachers', 'normal');

-- ==================== DOUBTS ====================
INSERT INTO doubts (id, student_id, subject_id, title, description, status) VALUES
  ('dbt_001', 'stu_001', 'subj_physics',
   'Energy conservation in collisions',
   'How do we determine if kinetic energy is conserved in a collision? When is it elastic vs inelastic?',
   'open'),
  ('dbt_002', 'stu_001', 'subj_math',
   'Integration by parts - when to use',
   'I''m confused about when to apply integration by parts vs substitution. Can you provide a general rule?',
   'in_progress'),
  ('dbt_003', 'stu_002', 'subj_chemistry',
   'Hybridisation of SF6',
   'Why does SF6 have sp3d2 hybridization and an octahedral structure?',
   'resolved');

-- ==================== FEEDBACKS ====================
INSERT INTO feedbacks (id, student_id, parent_id, message, status) VALUES
  ('fb_001', 'stu_001', 'a0000001-0000-0000-0000-000000000009',
   'The teaching quality is excellent! Aryan has improved significantly in Physics. The homework tracking feature is very useful.',
   'reviewed'),
  ('fb_002', 'stu_002', 'a0000001-0000-0000-0000-000000000011',
   'Priya finds the chemistry classes very engaging. Would appreciate more practice tests before the mid-terms.',
   'submitted');

-- ==================== INDEXES ====================
CREATE INDEX idx_auth_credentials_email ON auth_credentials(email);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_students_batch_id ON students(batch_id);
CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_timetables_batch_id ON timetables(batch_id);
CREATE INDEX idx_timetables_teacher_id ON timetables(teacher_id);
CREATE INDEX idx_homework_batch_id ON homework(batch_id);
CREATE INDEX idx_test_results_student_id ON test_results(student_id);
CREATE INDEX idx_fee_payments_student_id ON fee_payments(student_id);
CREATE INDEX idx_broadcasts_sent_date ON broadcasts(sent_date);

-- ============================================================
--  SETUP COMPLETE!
--  Tables Created: auth_credentials, users, subjects, batches, 
--                  students, admissions, timetables, syllabus_items,
--                  homework, homework_submissions, tests, test_results,
--                  fee_payments, broadcasts, doubts, feedbacks
--
--  Login with any of these credentials:
--  Admin:      admin@vidya.com         / Admin@123
--  Reception:  reception1@vidya.com    / Reception@123
--  Teacher:    physics@vidya.com       / Physics@123
--  Student:    aryan.sharma@students.com / Student@123
--  Parent:     rajesh.sharma@parents.com / Parent@123
-- ============================================================
