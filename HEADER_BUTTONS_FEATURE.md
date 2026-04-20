# Header Action Buttons Feature

## Overview
Two action buttons in the top-right corner of the dashboard header:
1. **Know Our Faculty** - View faculty members and their details
2. **Connect With Us** - Access social media links

## Layout

```
┌──────────────────────────────────────────────────────────┐
│ [Avatar] Name              [👥 Faculty] [🔗 Connect] [🔔] │
│          ROLE                                             │
└──────────────────────────────────────────────────────────┘
```

## What Was Added

### 1. Know Our Faculty Screen
**Location:** `lib/screens/faculty_screen.dart`

**Features:**
- Displays list of faculty members
- Each card shows:
  - Name and designation
  - Subject taught
  - Qualification
  - Years of experience
  - Email address
- Color-coded by subject
- Clean, professional UI

**Sample Faculty:**
- Dr. Arun Kumar - Physics (15 years)
- Mrs. Priya Sharma - Chemistry (12 years)
- Mr. Vikram Singh - Mathematics (18 years)
- Dr. Meera Patel - English (10 years)
- Mr. Rajesh Gupta - Computer Science (8 years)

### 2. Connect With Us Screen
**Location:** `lib/screens/connect_with_us_screen.dart`

**Features:**
- Instagram, LinkedIn, WhatsApp, Website, Email links
- Opens external links using `url_launcher`
- Error handling for failed opens

### 3. Integration

#### Student Dashboard
**Location:** `lib/screens/student_dashboard.dart`

Two icon buttons in header:
- **Faculty button** (👥 people icon) - Purple accent
- **Connect button** (🔗 connect icon) - Purple accent

#### Parent Dashboard
**Location:** `lib/screens/parent_dashboard.dart`

Two icon buttons in header:
- **Faculty button** (👥 people icon) - Teal accent
- **Connect button** (🔗 connect icon) - Teal accent

## How to Use

### For Students/Parents:
1. Login to the app
2. Look at top-right corner of Home screen
3. Tap **👥 Faculty icon** to view faculty members
4. Tap **🔗 Connect icon** to access social media

### Customizing Faculty List:
Edit `lib/screens/faculty_screen.dart` and modify the `_FacultyCard` widgets:

```dart
_FacultyCard(
  name: 'Teacher Name',
  designation: 'Position',
  subject: 'Subject',
  qualification: 'Degree',
  experience: 'X years',
  email: 'email@example.com',
  color: AppColors.primary,
),
```

### Customizing Social Links:
Edit `lib/screens/connect_with_us_screen.dart` and update URLs in `_launchURL` calls.

## Code Structure

```
lib/screens/
├── faculty_screen.dart (new)
│   ├── FacultyScreen - main screen
│   ├── _FacultyCard - faculty member card
│   └── _DetailRow - detail row widget
├── connect_with_us_screen.dart
│   ├── ConnectWithUsScreen - main screen
│   └── _SocialMediaCard - social media card
├── student_dashboard.dart (updated)
│   └── Added both action buttons
└── parent_dashboard.dart (updated)
    └── Added both action buttons
```

## Features
✅ Two action buttons in header
✅ Faculty screen with detailed info
✅ Social media connection screen
✅ Clean, modern UI
✅ Color-coded by role (student/parent)
✅ Responsive design
✅ Easy to customize
✅ No backend required (static data)

## Button Order (Left to Right)
1. **Faculty** (👥) - Know Our Faculty
2. **Connect** (🔗) - Connect With Us
3. **Notification** (🔔) - Notifications

## Testing
1. App is compiling at: `http://localhost:3000`
2. Login as student or parent
3. Check top-right corner
4. Test Faculty button → View faculty list
5. Test Connect button → Access social media

## Future Enhancements
- Load faculty data from database
- Add faculty photos
- Add faculty schedule/availability
- Add "Contact Faculty" feature
- Add faculty ratings/reviews

## Notes
- Both buttons use glass card effect
- Icons match the dashboard theme colors
- Faculty data is currently static (can be connected to database)
- Social media links are placeholders
- Buttons are positioned before notification bell
