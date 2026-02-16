# DuRey - Kurdish Voting App

A modern Flutter application for voting on questions across different categories with real-time results.

## Features

- 🎨 Professional dark theme with Kurdish font support
- 📊 Real-time vote counting with Supabase backend
- 🎯 6 categories: All, Life, General, Technology, Relationship, Talent
- 🎭 Animated results display
- 🔒 Device-based vote tracking (one vote per device per question)
- 💫 Smooth splash screen with KGD branding
- 📱 Responsive design for all screen sizes
- 🎬 Banner ad placeholder ready for monetization

## Tech Stack

- **Framework**: Flutter 3.10.7+
- **State Management**: Riverpod
- **Backend**: Supabase
- **Database**: PostgreSQL (via Supabase)
- **Monetization**: Google Mobile Ads (AdMob)
- **Navigation**: Go Router

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK
- Android Studio / Xcode (for iOS)
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/durey.git
cd durey
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Add your Supabase credentials
   - Add your AdMob app IDs

4. Run the app:
```bash
flutter run
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS IPA (requires macOS)
```bash
flutter build ios --release
```

Then use Xcode to archive and export the IPA.

## Project Structure

```
durey/
├── lib/
│   ├── core/           # Core configurations
│   ├── models/         # Data models
│   ├── providers/      # Riverpod providers
│   ├── screens/        # UI screens
│   ├── services/       # Business logic
│   └── widgets/        # Reusable widgets
├── assets/
│   ├── images/         # Images and logos
│   └── fonts/          # Kurdish font
├── supabase/           # Database schema and functions
└── android/ios/        # Platform-specific code
```

## Database Setup

1. Create a Supabase project
2. Run the SQL scripts in `supabase/` folder:
   - `schema.sql` - Creates tables
   - `rls_policies.sql` - Sets up security policies
   - `rpc_functions.sql` - Creates database functions

## Configuration

### Supabase
Update `lib/core/supabase/supabase_config.dart` with your credentials.

### AdMob
Update `lib/core/ads/admob_config.dart` with your ad unit IDs.

## Version

Current version: **V1.0**

## Credits

Developed by **KGD**

## License

All rights reserved.
