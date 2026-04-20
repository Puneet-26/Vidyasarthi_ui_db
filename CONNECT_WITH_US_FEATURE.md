# Connect With Us Feature

## Overview
A simple social media connection feature accessible via a button in the top-right corner of the dashboard header, positioned to sit alongside a future "Know Our Faculty" button.

## What Was Added

### 1. New Screen: `ConnectWithUsScreen`
**Location:** `lib/screens/connect_with_us_screen.dart`

**Features:**
- Clean, modern UI with cards for each social platform
- Instagram, LinkedIn, WhatsApp, Website, and Email links
- Uses `url_launcher` package to open external links
- Error handling with user-friendly messages
- Responsive design with proper spacing and shadows

### 2. Updated DashboardHeader Widget
**Location:** `lib/widgets/shared_widgets.dart`

**Changes:**
- Added `actionButtons` parameter to support custom action buttons
- Buttons appear between the user info and notification bell
- Supports multiple action buttons for future features (e.g., "Know Our Faculty")

### 3. Integration Points

#### Student Dashboard
- **Connect With Us** icon button in top-right corner of header
- Purple accent color matching student theme
- Positioned before the notification bell
- Ready for "Know Our Faculty" button to be added next to it

#### Parent Dashboard
- **Connect With Us** icon button in top-right corner of header
- Teal accent color matching parent theme
- Positioned before the notification bell
- Ready for "Know Our Faculty" button to be added next to it

### 4. Dependencies Added
- `url_launcher: ^6.2.5` in `pubspec.yaml`

## UI Layout

```
┌─────────────────────────────────────────────────────┐
│ [Avatar] Name                [Connect] [🔔]         │
│          ROLE                                        │
└─────────────────────────────────────────────────────┘
           ↑                      ↑        ↑
      User Info          Action Buttons  Notification
                         (Future: Faculty button here)
```

## How to Use

### For Students/Parents:
1. Open the app and login
2. Look at the top-right corner of the Home screen
3. Tap the **Connect icon** (🔗) button
4. Choose any social media platform to open

### Adding "Know Our Faculty" Button (Future):
Simply add another button to the `actionButtons` array:

```dart
actionButtons: [
  // Know Our Faculty button
  GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FacultyScreen(),
      ),
    ),
    child: const GlassCard(
      padding: EdgeInsets.all(10),
      child: Icon(
        Icons.people_rounded,
        color: AppColors.studentAccent,
        size: 22,
      ),
    ),
  ),
  // Connect With Us button
  GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectWithUsScreen(),
      ),
    ),
    child: const GlassCard(
      padding: EdgeInsets.all(10),
      child: Icon(
        Icons.connect_without_contact_rounded,
        color: AppColors.studentAccent,
        size: 22,
      ),
    ),
  ),
],
```

### Customizing Links:
Edit the URLs in `lib/screens/connect_with_us_screen.dart`:

```dart
// Current placeholder links:
- Instagram: https://instagram.com/vidyasarthi
- LinkedIn: https://linkedin.com/company/vidyasarthi
- WhatsApp: https://wa.me/919876543210
- Website: https://vidyasarthi.edu.in
- Email: mailto:contact@vidyasarthi.edu.in
```

## Code Structure

```
lib/
├── screens/
│   ├── connect_with_us_screen.dart (new)
│   ├── student_dashboard.dart (updated - added actionButtons)
│   └── parent_dashboard.dart (updated - added actionButtons)
└── widgets/
    └── shared_widgets.dart (updated - DashboardHeader with actionButtons)
```

## Features
✅ Icon button in top-right corner
✅ Positioned for future "Know Our Faculty" button
✅ Simple and beginner-friendly code
✅ No backend or database required
✅ Clean, modern UI with proper spacing
✅ Error handling for failed link opens
✅ Responsive design
✅ Reusable card widget
✅ Integrated into both Student and Parent dashboards
✅ Consistent with existing UI design

## Testing
1. App is running at: `http://localhost:3000`
2. Login as student or parent
3. Look at top-right corner of Home screen
4. Tap the Connect icon button
5. Test each social media link

## Notes
- Icon button uses glass card effect matching the notification bell
- Links open in external browser/app
- WhatsApp link format: `https://wa.me/<phone_number>`
- Email uses `mailto:` protocol
- All links are placeholder - update with real institute links
- Space reserved for "Know Our Faculty" button next to it
