-- Add 20 students to batch_10b for testing

-- Insert students for batch_10b
INSERT INTO students (id, user_id, name, email, phone, parent_name, parent_email, parent_phone, batch_id, enrollment_status) VALUES
('stu_batch10b_001', gen_random_uuid(), 'Rahul Mehra', 'rahul.mehra@students.com', '+91-9000000001', 'Mr. Suresh Mehra', 'suresh.mehra@parents.com', '+91-9000000002', 'batch_10b', 'active'),
('stu_batch10b_002', gen_random_uuid(), 'Nisha Verma', 'nisha.verma@students.com', '+91-9000000003', 'Mrs. Pooja Verma', 'pooja.verma@parents.com', '+91-9000000004', 'batch_10b', 'active'),
('stu_batch10b_003', gen_random_uuid(), 'Arjun Singh', 'arjun.singh@students.com', '+91-9000000005', 'Mr. Ramesh Singh', 'ramesh.singh@parents.com', '+91-9000000006', 'batch_10b', 'active'),
('stu_batch10b_004', gen_random_uuid(), 'Priya Gupta', 'priya.gupta@students.com', '+91-9000000007', 'Mr. Raj Gupta', 'raj.gupta@parents.com', '+91-9000000008', 'batch_10b', 'active'),
('stu_batch10b_005', gen_random_uuid(), 'Akshay Patel', 'akshay.patel@students.com', '+91-9000000009', 'Mr. Vikram Patel', 'vikram.patel@parents.com', '+91-9000000010', 'batch_10b', 'active'),
('stu_batch10b_006', gen_random_uuid(), 'Sneha Sharma', 'sneha.sharma@students.com', '+91-9000000011', 'Mrs. Kavya Sharma', 'kavya.sharma@parents.com', '+91-9000000012', 'batch_10b', 'active'),
('stu_batch10b_007', gen_random_uuid(), 'Karan Dubey', 'karan.dubey@students.com', '+91-9000000013', 'Mr. Anil Dubey', 'anil.dubey@parents.com', '+91-9000000014', 'batch_10b', 'active'),
('stu_batch10b_008', gen_random_uuid(), 'Ananya Joshi', 'ananya.joshi@students.com', '+91-9000000015', 'Mrs. Anjali Joshi', 'anjali.joshi@parents.com', '+91-9000000016', 'batch_10b', 'active'),
('stu_batch10b_009', gen_random_uuid(), 'Rohan Yadav', 'rohan.yadav@students.com', '+91-9000000017', 'Mr. Suresh Yadav', 'suresh.yadav@parents.com', '+91-9000000018', 'batch_10b', 'active'),
('stu_batch10b_010', gen_random_uuid(), 'Zara Khan', 'zara.khan@students.com', '+91-9000000019', 'Mr. Ahmed Khan', 'ahmed.khan@parents.com', '+91-9000000020', 'batch_10b', 'active'),
('stu_batch10b_011', gen_random_uuid(), 'Varun Iyer', 'varun.iyer@students.com', '+91-9000000021', 'Mr. Rajesh Iyer', 'rajesh.iyer@parents.com', '+91-9000000022', 'batch_10b', 'active'),
('stu_batch10b_012', gen_random_uuid(), 'Diya Saxena', 'diya.saxena@students.com', '+91-9000000023', 'Mrs. Neha Saxena', 'neha.saxena@parents.com', '+91-9000000024', 'batch_10b', 'active'),
('stu_batch10b_013', gen_random_uuid(), 'Nitin Verma', 'nitin.verma@students.com', '+91-9000000025', 'Mr. Vinod Verma', 'vinod.verma@parents.com', '+91-9000000026', 'batch_10b', 'active'),
('stu_batch10b_014', gen_random_uuid(), 'Olivia Roy', 'olivia.roy@students.com', '+91-9000000027', 'Mr. Ashok Roy', 'ashok.roy@parents.com', '+91-9000000028', 'batch_10b', 'active'),
('stu_batch10b_015', gen_random_uuid(), 'Pramod Sinha', 'pramod.sinha@students.com', '+91-9000000029', 'Mr. Ravi Sinha', 'ravi.sinha@parents.com', '+91-9000000030', 'batch_10b', 'active'),
('stu_batch10b_016', gen_random_uuid(), 'Qurisha Ahmed', 'qurisha.ahmed@students.com', '+91-9000000031', 'Mrs. Fatima Ahmed', 'fatima.ahmed@parents.com', '+91-9000000032', 'batch_10b', 'active'),
('stu_batch10b_017', gen_random_uuid(), 'Sanjay Reddy', 'sanjay.reddy@students.com', '+91-9000000033', 'Mr. Hari Reddy', 'hari.reddy@parents.com', '+91-9000000034', 'batch_10b', 'active'),
('stu_batch10b_018', gen_random_uuid(), 'Riya Chopra', 'riya.chopra@students.com', '+91-9000000035', 'Mr. Rajiv Chopra', 'rajiv.chopra@parents.com', '+91-9000000036', 'batch_10b', 'active'),
('stu_batch10b_019', gen_random_uuid(), 'Tejas Nair', 'tejas.nair@students.com', '+91-9000000037', 'Mr. Ashish Nair', 'ashish.nair@parents.com', '+91-9000000038', 'batch_10b', 'active'),
('stu_batch10b_020', gen_random_uuid(), 'Urvi Bhat', 'urvi.bhat@students.com', '+91-9000000039', 'Mrs. Sunita Bhat', 'sunita.bhat@parents.com', '+91-9000000040', 'batch_10b', 'active');

-- Verify the insertion
SELECT COUNT(*) as total_students, 
       COUNT(CASE WHEN batch_id = 'batch_10a' THEN 1 END) as batch_10a_count,
       COUNT(CASE WHEN batch_id = 'batch_10b' THEN 1 END) as batch_10b_count
FROM students;
