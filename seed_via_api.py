#!/usr/bin/env python3
"""
Script to seed Supabase database with comprehensive test data using REST API
"""
import requests
import json
import sys
from datetime import datetime, timedelta

SUPABASE_URL = "https://qhxrvagofgthruceztpc.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFoeHJ2YWdvZmd0aHJ1Y2V6dHBjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0OTg4ODEsImV4cCI6MjA4OTA3NDg4MX0.1Gqqki182T49daytZ6vRhNxoF4AIHe8Nbv2HnPYluJw"

headers = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

def clear_table(table_name):
    """Clear all data from a table"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table_name}"
        headers_for_delete = headers.copy()
        headers_for_delete.pop("Prefer", None)
        headers_for_delete["Prefer"] = "return=representation"
        
        response = requests.delete(url, headers=headers_for_delete)
        if response.status_code in [200, 204]:
            print(f"[OK] Cleared table: {table_name}")
            return True
        else:
            print(f"[!] Could not clear {table_name}: {response.status_code}")
            return False
    except Exception as e:
        print(f"[!] Error clearing {table_name}: {e}")
        return False

def insert_batch(table, records):
    """Insert multiple records into a table"""
    if not records:
        return True
    
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table}"
        response = requests.post(url, headers=headers, json=records)
        
        if response.status_code in [200, 201]:
            print(f"[OK] Inserted {len(records)} records into {table}")
            return True
        else:
            print(f"[!] Error inserting into {table}: {response.status_code}")
            print(f"    Response: {response.text[:200]}")
            return False
    except Exception as e:
        print(f"[!] Error inserting into {table}: {e}")
        return False

def seed_database():
    """Main seeding function"""
    
    print("[*] VidyaSarathi Database Seeder")
    print("[*] ================================")
    
    # Clear existing data in reverse order of dependencies
    print("\n[*] Clearing existing data...")
    clear_table("students")
    clear_table("teachers")
    clear_table("parents")
    clear_table("users")
    clear_table("batches")
    clear_table("subjects")
    
    # Insert Subjects
    print("\n[*] Inserting subjects...")
    subjects = [
        {'id': 'sub_physics', 'name': 'Physics', 'code': 'PHY'},
        {'id': 'sub_chemistry', 'name': 'Chemistry', 'code': 'CHE'},
        {'id': 'sub_mathematics', 'name': 'Mathematics', 'code': 'MAT'},
        {'id': 'sub_biology', 'name': 'Biology', 'code': 'BIO'},
    ]
    insert_batch("subjects", subjects)
    
    # Insert Batches
    print("\n[*] Inserting batches...")
    batches = [
        {'id': 'batch_10a', 'name': 'Class 10-A', 'level': '10'},
        {'id': 'batch_10b', 'name': 'Class 10-B', 'level': '10'},
        {'id': 'batch_11a', 'name': 'Class 11-A', 'level': '11'},
        {'id': 'batch_12a', 'name': 'Class 12-A', 'level': '12'},
    ]
    insert_batch("batches", batches)
    
    # Insert Users (Teachers, Parents, Students)
    print("\n[*] Inserting teachers...")
    teachers = [
        {
            'id': 'user_teacher_001',
            'email': 'arun.physics@vidya.com',
            'name': 'Dr. Arun Kumar',
            'role': 'teacher',
            'phone_number': '+91-9876543101',
            'is_active': True
        },
        {
            'id': 'user_teacher_002',
            'email': 'priya.chemistry@vidya.com',
            'name': 'Mrs. Priya Sharma',
            'role': 'teacher',
            'phone_number': '+91-9876543102',
            'is_active': True
        },
        {
            'id': 'user_teacher_003',
            'email': 'vikram.maths@vidya.com',
            'name': 'Mr. Vikram Singh',
            'role': 'teacher',
            'phone_number': '+91-9876543103',
            'is_active': True
        },
    ]
    insert_batch("users", teachers)
    
    # Insert Parents
    print("\n[*] Inserting parents...")
    parents = []
    for i in range(1, 51):
        parents.append({
            'id': f'user_parent_{i:03d}',
            'email': f'parent{i}@vidya.com',
            'name': f'Parent {i}',
            'role': 'parent',
            'phone_number': f'+91-987654{4000+i}',
            'is_active': True
        })
    insert_batch("users", parents)
    
    # Insert Students (20 per batch for testing)
    print("\n[*] Inserting students...")
    batches_list = ['batch_10a', 'batch_10b', 'batch_11a', 'batch_12a']
    students = []
    
    student_counter = 1
    for batch in batches_list:
        for i in range(1, 21):  # 20 students per batch
            students.append({
                'id': f'stu_{student_counter:04d}',
                'name': f'Student {student_counter}',
                'email': f'student{student_counter}@vidya.com',
                'phone': f'+91-987600{1000+student_counter}',
                'batch_id': batch,
                'roll_number': str(i),
                'enrollment_status': 'active',
                'parent_email': f'parent{(student_counter % 50) + 1}@vidya.com',
                'parent_phone': f'+91-987654{4000+(student_counter % 50)+1}',
            })
            student_counter += 1
    
    insert_batch("students", students)
    
    print("\n[+] Database seeding completed!")
    print(f"[*] Total students inserted: {len(students)}")
    print(f"    - {len([s for s in students if 'batch_10a' in s['batch_id']])} in batch_10a")
    print(f"    - {len([s for s in students if 'batch_10b' in s['batch_id']])} in batch_10b")
    print(f"    - {len([s for s in students if 'batch_11a' in s['batch_id']])} in batch_11a")
    print(f"    - {len([s for s in students if 'batch_12a' in s['batch_id']])} in batch_12a")
    
    # Verify
    print("\n[*] Verifying data...")
    try:
        url = f"{SUPABASE_URL}/rest/v1/students?select=batch_id&count=exact"
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            count = response.headers.get('content-range', '0-0/0').split('/')[-1]
            print(f"[OK] Total students in DB: {count}")
    except:
        pass

if __name__ == "__main__":
    try:
        seed_database()
    except Exception as e:
        print(f"[!] Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
