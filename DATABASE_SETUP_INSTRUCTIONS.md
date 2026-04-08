# VidyaSarathi Database Setup Instructions

## Overview
This guide will help you set up the normalized database with 120+ students, 50 parents, 8 teachers, and comprehensive data.

## Step 1: Set up Database Schema

1. **Open Supabase Dashboard**
   - Go to your Supabase project dashboard
   - Navigate to the SQL Editor

2. **Run Database Schema**
   - Copy the contents of `setup_database.sql`
   - Paste it into the SQL Editor
   - Click "Run" to execute the script
   - This will create all normalized tables, indexes, views, and RLS policies

## Step 2: Seed Database with Data

### Option A: Using the App (Recommended)
1. **Run the Flutter App**
   ```bash
   flutter run
   ```

2. **Login as Reception Staff**
   - Email: `reception1@vidya.com`
   - Password: `password123`

3. **Seed Database**
   - Go to the Reception Dashboard
   - Click on "Seed Database" button in Quick Actions
   - Wait for the seeding process to complete (may take 1-2 minutes)
   - You'll see a success message when done

### Option B: Using Command Line (Alternative)
1. **Run the Seeder Script**
   ```bash
   dart run run_seeder.dart
   ```

## What Gets Created

### Users (178 total)
- **1 Admin**: `admin@vidya.com`
- **2 Reception Staff**: `reception1@vidya.com`, `reception2@vidya.com`
- **8 Teachers**: Physics, Chemistry, Math, Biology, English, Hindi, Computer Science, Economics
- **50 Parents**: Various occupations and income levels
- **120 Students**: Distributed across different batches

### Academic Structure
- **8 Subjects**: Physics, Chemistry, Mathematics, Biology, English, Hindi, Computer Science, Economics
- **6 Batches**: 
  - Class 12 Science A (35 students)
  - Class 12 Science B (35 students)
  - Class 12 Commerce (30 students)
  - Class 11 Science A (40 students)
  - Class 11 Science B (40 students)
  - Class 10 A (45 students)

### Additional Data
- **Student-Subject Mappings**: Each student enrolled in 4-5 subjects
- **Timetables**: Non-conflicting schedules for teachers, batches, and rooms
- **Homework**: 4 assignments across different subjects
- **Tests**: 3 scheduled tests with results for completed ones
- **Test Results**: 35 results for Physics Unit Test
- **Fee Payments**: Multiple payment records per student
- **Teacher Feedback**: 50 feedback messages across different categories
- **Broadcasts**: 3 announcements for different audiences

## Database Features

### Normalized Structure
- **No Data Redundancy**: Parent info stored separately, linked via foreign keys
- **Referential Integrity**: All foreign key constraints properly set up
- **Optimized Queries**: Indexes on frequently queried columns
- **Views**: Pre-built views for complex joins (student_details, teacher_details, timetable_details)

### Data Quality
- **Realistic Data**: Names, addresses, phone numbers, emails follow Indian patterns
- **Proper Relationships**: Students linked to parents, batches, subjects
- **Fee Management**: Realistic fee amounts and payment patterns
- **Academic Records**: Proper grade distribution and test results

### Security
- **Row Level Security (RLS)**: Enabled on all tables
- **Basic Policies**: Allow all operations (can be refined for production)

## Verification

After seeding, you can verify the data:

1. **Check Student Count**
   ```sql
   SELECT COUNT(*) FROM students;
   -- Should return 120
   ```

2. **Check User Roles**
   ```sql
   SELECT role, COUNT(*) FROM users GROUP BY role;
   -- Should show: admin(1), admin_staff(2), teacher(8), parent(50), student(120)
   ```

3. **Check Student Details View**
   ```sql
   SELECT * FROM student_details LIMIT 5;
   -- Should show joined data with parent information
   ```

## Troubleshooting

### Common Issues

1. **Foreign Key Violations**
   - Ensure the schema is created before seeding
   - Check that all referenced IDs exist

2. **Seeding Takes Too Long**
   - This is normal for 120+ students with relationships
   - Wait for completion message

3. **Duplicate Key Errors**
   - Clear existing data first by running the seeder again
   - The seeder automatically clears old data before inserting new

### Support
If you encounter issues:
1. Check the Flutter console for detailed error messages
2. Verify Supabase connection is working
3. Ensure all SQL scripts ran successfully
4. Check Supabase logs for database errors

## Next Steps

After successful setup:
1. **Test Different User Roles**: Login as teacher, parent, student
2. **Verify Data Relationships**: Check that students show correct parent info
3. **Test Fee Management**: Record payments and verify fee status updates
4. **Test Teacher Feedback**: Send feedback from teacher to parent
5. **Explore Dashboards**: Each role has different data views

The database is now ready for full application testing with realistic, comprehensive data!