# RUNNING VIDYASARATHI AS MOBILE VIEW

## Option 1: Flutter Web with Mobile Simulation (Easiest)

### Step 1: Run Flutter Web
```bash
cd c:\Users\Puneet\Desktop\vidyasarathi_UI
flutter run -d web
```

### Step 2: Open Chrome DevTools Mobile View
1. When the app opens in Chrome
2. Press **F12** or Right-Click → "Inspect"
3. Press **Ctrl+Shift+M** (or click device toolbar icon)
4. Select **iPhone 12** or **Pixel 5** device from dropdown
5. Refresh the page (F5)

✓ Now you'll see the app in mobile viewport!


## Option 2: Windows Setup (For Desktop Testing First)

If you want to test on Windows desktop first before mobile emulator:

```bash
flutter run -d windows
```

Then resize window to mobile proportions (375x812 for iPhone perspective)


## Option 3: Android Emulator (More Realistic)

### Prerequisites:
- Android Studio installed
- Android Emulator configured

### Commands:
```bash
# List available emulators
flutter emulators

# Run on specific emulator
flutter run -d emulator-5554
```

Or use Android Studio:
1. Open Android Studio
2. Click AVD Manager
3. Start an emulator
4. Run: `flutter run`


## Option 4: iOS Simulator (Mac Only)

```bash
open -a Simulator
flutter run -d ios
```


## Full Setup Instructions with Supabase

### Step 1: Set Up .env File

Create `.env` file in project root:

```
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### Step 2: Create Supabase Tables

Follow instructions in SUPABASE_SETUP_REAL.md file

### Step 3: Run the App

#### For Web (Desktop + Mobile View):
```bash
flutter run -d web
```
Then open Chrome DevTools mobile view (F12 → Ctrl+Shift+M)

#### For Android Emulator:
```bash
# Start emulator first
flutter emulators --launch emulator-5554

# Then run
flutter run
```

#### For Windows (Quick Testing):
```bash
flutter run -d windows
```


## Testing Credentials

After setting up Supabase, use these to login:

**Admin Account:**
- Email: `admin@vidya.com`
- Password: `Admin@123`

**Teacher (Physics):**
- Email: `physics@vidya.com`
- Password: `Physics@123`

**Student:**
- Email: `aryan.sharma@students.com`
- Password: `Student@123`

**Parent:**
- Email: `rajesh.sharma@parents.com`
- Password: `Parent@123`

**Receptionist:**
- Email: `reception1@vidya.com`
- Password: `Reception@123`


## Troubleshooting

### Issue: "Chrome not found"
```bash
# Explicitly specify Chrome path
flutter run -d web --web-renderer html
```

### Issue: "No emulator found"
```bash
# Create a new one in Android Studio or:
flutter emulators --create --name test_device
flutter emulators --launch test_device
flutter run
```

### Issue: "SUPABASE_URL not set"
- Verify .env file exists in project root
- Restart the app
- Check SUPABASE_SETUP_REAL.md for setup steps

### Issue: "Connection timeout to Supabase"
- Check internet connection
- Verify Supabase project is active
- Check .env has correct credentials
- Run: `flutter pub get` and try again

### Issue: "Table not found" on login
- Run SQL scripts in SUPABASE_SETUP_REAL.md
- Verify you're using correct Supabase project
- Check table names match (auth_credentials, students, etc)

### Issue: Flutter web is slow
Use HTML renderer instead:
```bash
flutter run -d web --web-renderer html
```


## Recommended Setup Path

**Fastest way to see working mobile app:**

1. ✅ Click the button below to run Flutter Web:
   ```bash
   flutter run -d web
   ```

2. ✅ Open Chrome DevTools (F12)

3. ✅ Enable Mobile View (Ctrl+Shift+M)

4. ✅ Select iPhone 12 device

5. ✅ Login with: `admin@vidya.com` / `Admin@123`

6. ✅ Start exploring the dashboard!

**Then for Real Data:**

1. Create Supabase project (supabase.com)
2. Copy URL and key to .env
3. Run SQL scripts from SUPABASE_SETUP_REAL.md
4. Restart the app
5. Now using real Supabase database!


## Publishing to Mobile Stores

When ready for production:

### Android Build:
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS Build (Mac Only):
```bash
flutter build ios --release
```

### Web Build:
```bash
flutter build web --release
```


## Performance Optimization Tips

- Use release mode for testing:
  ```bash
  flutter run --release
  ```

- Profile performance:
  ```bash
  flutter run --profile
  ```

- Check frame rate in DevTools:
  - Press 'P' during `flutter run`
  - Or use the performance tab in DevTools


## Next Steps After Running

1. **Test all user roles** - Login as each role and verify dashboard
2. **Test navigation** - Click buttons and verify screens work
3. **Test data display** - Check if real Supabase data appears
4. **Test authentication** - Try invalid login
5. **Check UI responsiveness** - Test on different screen sizes
6. **Test performance** - Monitor loading times

For more info: https://flutter.dev/docs
