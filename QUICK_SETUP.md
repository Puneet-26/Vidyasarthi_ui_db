# Quick Supabase Setup (4 Easy Steps)

Your app is ready. Now set up Supabase backend in 20 minutes.

---

## 🎯 Step 1: Run SQL Schema (5 min)

1. Open **https://app.supabase.com** → Select your project
2. Left sidebar → **SQL Editor**
3. Click **New Query**
4. Open file: `database_schema.sql` from your project
5. Copy ALL content (Ctrl+A → Ctrl+C)
6. Paste into Supabase SQL Editor
7. Click **Run** button (top right)
8. Wait for green ✓ (don't close until done)

**Result**: 15 table created with data + RLS policies

---

## 👥 Step 2: Create Auth Users (10 min)

1. Go to **Authentication** → **Users** tab
2. Click **Add user** button (top right)
3. Enter:
   - Email: `admin@vidya.com`
   - Password: `admin123`
   - Uncheck "Auto send password" if checked
4. Click **Create user**
5. Click on user just created
6. Find **User Metadata** section (scroll down)
7. Add this:
   ```json
   {"role": "super_admin"}
   ```
8. Save

**Repeat for:**
- `staff@vidya.com` / `staff123` → `{"role": "admin_staff"}`
- `teacher@vidya.com` / `teacher123` → `{"role": "teacher"}`
- `student@vidya.com` / `student123` → `{"role": "student"}`
- `parent@vidya.com` / `parent123` → `{"role": "parent"}`

**Result**: 5 users ready to log in

---

## ✅ Step 3: Verify Database (5 min)

1. Go to **Table Editor** in Supabase
2. Check these tables exist:
   - ✓ subjects (3 rows: Physics, Chemistry, Math)
   - ✓ batches (3 rows: 10-A, 10-B, 11-A)
   - ✓ users (may be empty)
   - ✓ admissions, timetables, homework, etc.

**If any table missing**:
- Go back to SQL Editor
- Run `database_schema.sql` again
- Make sure NO errors appear

---

## 🚀 Step 4: Test App (just run it!)

```bash
cd c:\Users\Puneet\Desktop\vidyasarathi_UI
flutter pub get
flutter run
```

**Try logging in with:**
- admin@vidya.com / admin123

**Expected**: Should navigate to Admin Dashboard

---

## 🎉 Done!

Your VidyaSarathi app is now connected to real Supabase backend!

All 5 roles work:
- Admin Dashboard ✅
- Reception Staff Dashboard ✅
- Teacher Dashboard ✅
- Student Dashboard ✅
- Parent Dashboard ✅

---

## ⏱️ Troubleshooting

**App crashes on startup?**
- Check C` supabase_config.dart` has your URL and key

**Login fails?**
- Check user exists in Supabase Auth → Users
- Verify user has metadata with `"role"`

**No tables in database?**
- Run SQL schema again from scratch

**RLS errors?**
- Click each table → 3 dots → make sure "RLS" is enabled

---

**Questions?** Read `SUPABASE_INTEGRATION_COMPLETE.md` for detailed explanations.
