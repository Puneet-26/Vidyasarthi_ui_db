-- Comprehensive Data Population Script
-- This script populates the normalized database with realistic data

-- Insert Subjects
INSERT INTO subjects (id, name, code, description) VALUES
('sub_physics', 'Physics', 'PHY', 'Classical and Modern Physics'),
('sub_chemistry', 'Chemistry', 'CHE', 'Organic and Inorganic Chemistry'),
('sub_mathematics', 'Mathematics', 'MAT', 'Algebra, Calculus, and Geometry'),
('sub_biology', 'Biology', 'BIO', 'Life Sciences and Human Biology'),
('sub_english', 'English', 'ENG', 'Literature and Communication'),
('sub_hindi', 'Hindi', 'HIN', 'Hindi Language and Literature'),
('sub_computer', 'Computer Science', 'CS', 'Programming and Computer Applications'),
('sub_economics', 'Economics', 'ECO', 'Micro and Macro Economics'),
('sub_history', 'History', 'HIS', 'World and Indian History'),
('sub_geography', 'Geography', 'GEO', 'Physical and Human Geography');

-- Insert Batches
INSERT INTO batches (id, name, year, section, total_students, is_active) VALUES
('batch_12_science_a', 'Class 12 Science', 2024, 'A', 35, true),
('batch_12_science_b', 'Class 12 Science', 2024, 'B', 35, true),
('batch_12_commerce', 'Class 12 Commerce', 2024, 'A', 30, true),
('batch_11_science_a', 'Class 11 Science', 2024, 'A', 40, true),
('batch_11_science_b', 'Class 11 Science', 2024, 'B', 40, true),
('batch_11_commerce', 'Class 11 Commerce', 2024, 'A', 35, true),
('batch_10_a', 'Class 10', 2024, 'A', 45, true),
('batch_10_b', 'Class 10', 2024, 'B', 45, true);

-- Insert Admin User
INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
('admin_001', 'admin@vidya.com', 'System Administrator', '+91-9876543000', 'super_admin', true);

-- Insert Reception Staff
INSERT INTO users (id, email, name, phone_number, role, is_active) VALUES
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
('user_teacher_008', 'kavita.economics@vidya.com', 'Mrs. Kavita Sharma', '+91-9876543108', 'teacher', true),
('user_teacher_009', 'suresh.history@vidya.com', 'Mr. Suresh Kumar', '+91-9876543109', 'teacher', true),
('user_teacher_010', 'anita.geography@vidya.com', 'Mrs. Anita Singh', '+91-9876543110', 'teacher', true);

-- Insert Teachers
INSERT INTO teachers (id, user_id, employee_id, qualification, experience_years, specialization, joining_date) VALUES
('teacher_001', 'user_teacher_001', 'EMP001', 'M.Sc Physics, B.Ed', 8, 'Quantum Physics', '2020-06-01'),
('teacher_002', 'user_teacher_002', 'EMP002', 'M.Sc Chemistry, B.Ed', 6, 'Organic Chemistry', '2021-07-15'),
('teacher_003', 'user_teacher_003', 'EMP003', 'M.Sc Mathematics, B.Ed', 10, 'Calculus', '2019-04-01'),
('teacher_004', 'user_teacher_004', 'EMP004', 'Ph.D Biology, B.Ed', 12, 'Molecular Biology', '2018-08-01'),
('teacher_005', 'user_teacher_005', 'EMP005', 'M.A English, B.Ed', 7, 'Literature', '2020-09-01'),
('teacher_006', 'user_teacher_006', 'EMP006', 'M.A Hindi, B.Ed', 9, 'Hindi Literature', '2019-06-01'),
('teacher_007', 'user_teacher_007', 'EMP007', 'MCA, B.Ed', 5, 'Programming', '2022-01-15'),
('teacher_008', 'user_teacher_008', 'EMP008', 'M.A Economics, B.Ed', 8, 'Macro Economics', '2020-03-01'),
('teacher_009', 'user_teacher_009', 'EMP009', 'M.A History, B.Ed', 11, 'Indian History', '2018-07-01'),
('teacher_010', 'user_teacher_010', 'EMP010', 'M.A Geography, B.Ed', 6, 'Physical Geography', '2021-05-01');

-- Insert Parent Users (50 parents for 100+ students)
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

-- Continue with the rest of the data in the next file due to length...