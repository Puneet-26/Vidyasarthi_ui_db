# Environment Variables & Secrets Management

Your VidyaSarathi app now uses **secure environment variables** for all sensitive credentials!

---

## 🔐 What's Secured

✅ **Supabase URL** - Never hardcoded  
✅ **Supabase Anon Key** - Loaded from `.env` at runtime  
✅ **Future credentials** - API keys, email passwords, payment gateway keys, etc.

---

## 📁 Files Involved

| File | Purpose | Committed? |
|------|---------|-----------|
| `.env` | 🔐 **SECRETS** - Your actual credentials | ❌ **NO** (in .gitignore) |
| `.env.example` | 📋 Template showing structure | ✅ **YES** (in git) |
| `.gitignore` | Tells git what to ignore | ✅ **YES** (includes .env) |
| `pubspec.yaml` | Includes flutter_dotenv package | ✅ **YES** |
| `lib/services/supabase_config.dart` | Loads from env variables | ✅ **YES** |
| `lib/main.dart` | Initializes dotenv | ✅ **YES** |

---

## ✨ How It Works

### **For You (Development)**

```
┌─ .env (your machine)
│  SUPABASE_URL=...
│  SUPABASE_ANON_KEY=...
│
└─ App reads at startup
   ✓ Credentials loaded securely
   ✓ No hardcoded secrets
```

### **For Others (Cloning Repo)**

```
┌─ .env.example (in git)
│  SUPABASE_URL=https://your-project-ref.supabase.co
│  SUPABASE_ANON_KEY=your_anon_key_here
│
├─ Developer sees template
│
└─ They create their own .env with their credentials
   ✓ No risk of exposing secrets
   ✓ Clear what variables are needed
```

---

## 🚀 Setup Instructions

### **Step 1: File Structure** (Already Done ✅)

Your project already has:
- ✅ `.env` - Contains your actual Supabase credentials
- ✅ `.env.example` - Template for others to copy
- ✅ `.gitignore` - Excludes `.env` from git
- ✅ `flutter_dotenv` package in `pubspec.yaml`
- ✅ `.env` in flutter assets config

### **Step 2: Verify .env File**

Open `.env` in your project root:
```
SUPABASE_URL=https://qhxrvagofgthruceztpc.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
APP_NAME=VidyaSarathi
APP_ENVIRONMENT=development
DEBUG_MODE=true
```

✅ Your credentials are already there!

### **Step 3: Install Dependencies**

```bash
flutter pub get
```

This installs `flutter_dotenv` package needed to load `.env` file.

### **Step 4: Run App**

```bash
flutter run
```

The app will:
1. Load `.env` file at startup
2. Read `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Initialize Supabase with loaded credentials
4. Print status messages in console

---

## 🔍 Console Output (What You'll See)

When you run the app:

```
✓ Environment variables loaded successfully
✓ Supabase initialized successfully
✓ Database service initialized
```

If there's an error:

```
⚠ Warning: Could not load .env file: (reason)
❌ Configuration validation failed. Check your .env file.
```

**Fix by**: Making sure `.env` exists in project root with correct values.

---

## 🔑 Environment Variables Reference

### **Required Variables**
Must be in `.env` for app to work:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

### **Optional Variables**
Add as needed:

```env
APP_NAME=VidyaSarathi              # App display name
APP_ENVIRONMENT=development        # development, staging, production
DEBUG_MODE=true                    # Enable debug logging
```

### **Future Variables** (Add When Needed)
```env
STRIPE_PUBLISHABLE_KEY=pk_...      # Payment gateway
FIREBASE_PROJECT_ID=...            # For push notifications
SUPPORT_EMAIL=support@vidya.com    # Support contact
```

---

## 🛡️ Security Best Practices

### **DO ✅**
- Keep `.env` in `.gitignore` (prevents accidental commits)
- Use `.env.example` to show template structure
- Rotate keys periodically in Supabase
- Use different `.env` files per environment:
  - `.env.development` for local
  - `.env.staging` for testing
  - `.env.production` for live (use different Supabase project!)
- Load variables at runtime, not build time
- Validate all required variables exist on startup

### **DON'T ❌**
- Never commit `.env` with real credentials to git
- Never hardcode secrets in source code
- Never use same Supabase key for development & production
- Never share `.env` file via Slack/email
- Never log sensitive values to console in production

---

## 🔄 Using Credentials in Code

### **Before (Hardcoded - BAD)**
```dart
const String supabaseUrl = 'https://qhxrvagofgthruceztpc.supabase.co';
const String supabaseAnonKey = 'eyJhbGc...'; // Visible in source!
```

### **After (Environment Variables - GOOD)**
```dart
static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
```

✨ **Benefits**:
- Credentials never in source code
- Different values per environment
- Easy to rotate without code changes
- Secure by design

---

## 📚 Example: Adding a New Credential

Say you want to add Stripe payment key:

### **1. Update `.env`**
```env
SUPABASE_URL=https://qhxrvagofgthruceztpc.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
STRIPE_PUBLISHABLE_KEY=pk_test_xxx123
```

### **2. Update `.env.example`**
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```

### **3. Update `supabase_config.dart`**
```dart
static String get stripePublishableKey {
  return dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
}
```

### **4. Use in Code**
```dart
import 'services/supabase_config.dart';

final stripeKey = SupabaseConfig.stripePublishableKey;
```

✅ Done! Your credential is now secure and reusable.

---

## 🚨 If You Accidentally Commit `.env`

**If you realized you committed `.env` with credentials:**

### **Immediate Action**
1. Don't panic! Just delete it from git history
2. Rotate your Supabase keys immediately (they're considered exposed)
3. Never reuse the old keys

### **Remove from Git History**
```bash
# Remove .env from git history completely
git filter-branch --tree-filter 'rm -f .env' HEAD

# Force push (be careful!)
git push origin --force
```

### **Create New Supabase Keys**
1. Go to Supabase Dashboard
2. Project Settings → API
3. Regenerate Anon Key
4. Update `.env` with new key

---

## ✅ Verification Checklist

Before pushing to production:

- [ ] `.env` is in `.gitignore` (prevents accidental commits)
- [ ] `.env.example` exists showing structure
- [ ] App loads `.env` on startup (console shows ✓ message)
- [ ] `supabase_config.dart` uses `dotenv.env[]` not hardcoded values
- [ ] All required variables validated on startup
- [ ] Never logged secrets to console
- [ ] Different keys for dev/production if applicable
- [ ] Team members know to create their own `.env` after cloning

---

## 📞 Troubleshooting

### **"Could not load .env file"**
**Cause**: .env file not found in project root  
**Fix**: Make sure `.env` is in `c:\Users\Puneet\Desktop\vidyasarathi_UI\.env`

### **"SUPABASE_URL environment variable is not set"**
**Cause**: Missing or empty variable in .env  
**Fix**: Check `.env` has correct lines:
```env
SUPABASE_URL=https://qhxrvagofgthruceztpc.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

### **App compiles but credentials not loading**
**Cause**: Hotreload doesn't reload .env file  
**Fix**: Do a full restart:
```bash
flutter run --no-fast-start
```

---

## 🎉 Summary

Your app is now **production-grade secure**:
- ✅ Credentials loaded from environment variables
- ✅ No secrets in source code
- ✅ Easy to manage different credentials per environment
- ✅ Safe to commit to git (only .env.example)
- ✅ Template for team members (.env.example)
- ✅ Validated on startup (fails fast if missing)

**Next**: If you need to add more credentials (API keys, payment keys), just:
1. Add to `.env`
2. Add to `.env.example`
3. Create getter in `SupabaseConfig` class
4. Use in code via `SupabaseConfig.variableName`

Done! 🔐
