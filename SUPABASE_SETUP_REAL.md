# SUPABASE SETUP - REAL DATABASE INTEGRATION

## Step 1: Create Supabase Project

1. Go to https://app.supabase.com
2. Click "New Project"
3. Fill in:
   - Project Name: `vidyasarathi`
   - Database Password: Create a strong password
   - Region: Choose closest to you
   - Plan: Free tier is fine
4. Click "Create new project" - Wait 2-3 minutes for setup

## Step 2: Get Your Credentials

1. Go to your project Dashboard
2. Click "Settings" → "API"
3. Copy these values:
   - **Project URL** - Copy the URL
   - **Anon Key** - Copy the key (under "anon public" section)

## Step 3: Update .env File

Create or update `.env` file in project root with:

```
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```

Example:
```
SUPABASE_URL=https://abcdefgh.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Step 4: Create Tables in Supabase

Run the SQL in your Supabase SQL Editor (Settings → SQL Editor → New Query):

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  phone_number VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create subjects table
CREATE TABLE subjects (
  id VARCHAR(10) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) UNIQUE NOT NULL,
  description TEXT
);

-- Create batches table
CREATE TABLE batches (
  id VARCHAR(10) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  level VARCHAR(50) NOT NULL,
  subject_ids TEXT[] NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create students table
CREATE TABLE students (
  id VARCHAR(10) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  parent_phone VARCHAR(20),
  parent_name TEXT,
  parent_email TEXT,
  batch_id VARCHAR(10) REFERENCES batches(id),
  subject_ids TEXT[] NOT NULL,
  total_fees DECIMAL(10,2),
  fees_paid DECIMAL(10,2),
  fee_status VARCHAR(50),
  enrollment_status VARCHAR(50),
  enrollment_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create auth mapping table (email to password hash)
CREATE TABLE auth_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create admissions table
CREATE TABLE admissions (
  id VARCHAR(20) PRIMARY KEY,
  student_name VARCHAR(255) NOT NULL,
  parent_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  parent_phone VARCHAR(20),
  applied_batch_id VARCHAR(10),
  requested_subject_ids TEXT[],
  status VARCHAR(50),
  applied_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create timetable table
CREATE TABLE timetables (
  id VARCHAR(20) PRIMARY KEY,
  batch_id VARCHAR(10),
  subject_id VARCHAR(10),
  teacher_id VARCHAR(50),
  day VARCHAR(20) NOT NULL,
  start_time VARCHAR(10) NOT NULL,
  end_time VARCHAR(10) NOT NULL,
  room VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create homework table
CREATE TABLE homework (
  id VARCHAR(20) PRIMARY KEY,
  batch_id VARCHAR(10),
  subject_id VARCHAR(10),
  teacher_id VARCHAR(50),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  due_date TIMESTAMP,
  assigned_students TEXT[],
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create tests table
CREATE TABLE tests (
  id VARCHAR(20) PRIMARY KEY,
  batch_id VARCHAR(10),
  subject_id VARCHAR(10),
  teacher_id VARCHAR(50),
  title VARCHAR(255) NOT NULL,
  test_date TIMESTAMP,
  total_marks INTEGER,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create fee payments table
CREATE TABLE fee_payments (
  id VARCHAR(20) PRIMARY KEY,
  student_id VARCHAR(10),
  amount DECIMAL(10,2),
  payment_method VARCHAR(50),
  payment_date TIMESTAMP,
  status VARCHAR(50),
  reference VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS for security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_credentials ENABLE ROW LEVEL SECURITY;
```

## Step 5: Insert Sample Data

Copy this SQL and run in Supabase SQL Editor:

```sql
-- Insert Subjects
INSERT INTO subjects (id, name, code, description) VALUES
('1', 'Physics', 'PHY101', 'Physics Fundamentals'),
('2', 'Chemistry', 'CHM101', 'Chemistry Basics'),
('3', 'Mathematics', 'MTH101', 'Mathematics Advanced');

-- Insert Batches
INSERT INTO batches (id, name, level, subject_ids, created_at) VALUES
('B1', 'Class 10 - A', '10th', '{"1","2","3"}', NOW()),
('B2', 'Class 10 - B', '10th', '{"1","2","3"}', NOW()),
('B3', 'Class 11 - A', '11th', '{"1","2","3"}', NOW());

-- Insert Students
INSERT INTO students (id, user_id, name, email, phone, parent_phone, parent_name, parent_email, batch_id, subject_ids, total_fees, fees_paid, fee_status, enrollment_status, enrollment_date) VALUES
('S001', 'user_s001', 'Aryan Sharma', 'aryan.sharma@students.com', '+91-9876543210', '+91-9876543200', 'Mr. Rajesh Sharma & Mrs. Kavya Sharma', 'rajesh.sharma@parents.com,kavya.sharma@parents.com', 'B1', '{"1","2","3"}', 50000, 50000, 'active', 'active', NOW()),
('S002', 'user_s002', 'Priya Singh', 'priya.singh@students.com', '+91-9876543211', '+91-9876543220', 'Mr. Amit Singh & Mrs. Sneha Singh', 'amit.singh@parents.com,sneha.singh@parents.com', 'B1', '{"1","2","3"}', 50000, 50000, 'active', 'active', NOW());

-- Insert Auth Credentials (with plain text - in production use bcrypt)
INSERT INTO auth_credentials (email, password_hash, role, name) VALUES
('admin@vidya.com', 'Admin@123', 'super_admin', 'Dr. Rajesh Kumar'),
('physics@vidya.com', 'Physics@123', 'teacher', 'Mr. Arun Kumar'),
('chemistry@vidya.com', 'Chemistry@123', 'teacher', 'Mrs. Priya Sharma'),
('maths@vidya.com', 'Maths@123', 'teacher', 'Mr. Vikram Singh'),
('reception1@vidya.com', 'Reception@123', 'admin_staff', 'Ms. Anjali Patel'),
('reception2@vidya.com', 'Reception@456', 'admin_staff', 'Mr. Arjun Verma'),
('aryan.sharma@students.com', 'Student@123', 'student', 'Aryan Sharma'),
('priya.singh@students.com', 'Student@456', 'student', 'Priya Singh'),
('rajesh.sharma@parents.com', 'Parent@123', 'parent', 'Mr. Rajesh Sharma'),
('kavya.sharma@parents.com', 'Parent@124', 'parent', 'Mrs. Kavya Sharma'),
('amit.singh@parents.com', 'Parent@456', 'parent', 'Mr. Amit Singh'),
('sneha.singh@parents.com', 'Parent@457', 'parent', 'Mrs. Sneha Singh');
```

## Step 6: Verify Connection

Once .env is updated, run:
```bash
flutter run
```

The app will now use real Supabase data!

## Important Security Notes

⚠️ **Production Checklist:**
- [ ] Store passwords as bcrypt hashes (not plain text)
- [ ] Enable RLS policies on all tables
- [ ] Set up proper authentication middleware
- [ ] Use JWT tokens for API access
- [ ] Hide Supabase URL/key in production
- [ ] Enable HTTPS only
- [ ] Set up rate limiting
- [ ] Regular database backups
- [ ] Audit logging for sensitive operations

## Troubleshooting

**Issue: "403 Unauthorized" error**
- Check .env file has correct URL and key
- Verify RLS policies aren't blocking access

**Issue: "Connection timeout"**
- Check internet connection
- Verify Supabase project is running
- Check firewall/VPN settings

**Issue: "Table not found"**
- Run the SQL creation scripts again
- Verify you're using correct table names
- Check project is selected in Supabase

## Next Steps

1. Set up proper authentication (passwords should be hashed)
2. Configure RLS policies for data security
3. Add activity logging
4. Set up automated backups
5. Implement API rate limiting

For more info: https://supabase.com/docs
