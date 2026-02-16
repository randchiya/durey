# App Icon Setup Instructions

## Current Status
✅ Logo added to home screen (logo1.png)
✅ Background image added to home screen (bg.png)
⏳ App icon needs to be set up

## App Icon Setup

### Option 1: Using flutter_launcher_icons (Recommended)

1. Add the package to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. Add configuration to `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icons/appicon.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/images/icons/appicon.png"
```

3. Run the command:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Option 2: Manual Setup (Current Method)

#### Android Icon Sizes Required:
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

#### Steps:
1. Resize `appicon.png` to the sizes above
2. Copy to respective folders:
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

#### iOS Icon Sizes Required:
Place in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024
- Each at @1x, @2x, @3x scales

### Option 3: Online Icon Generator

1. Go to: https://icon.kitchen or https://appicon.co
2. Upload `appicon.png`
3. Download generated icons
4. Replace icons in Android and iOS folders

## Current Implementation

### Home Screen
- ✅ Logo: `assets/images/logos/logo1.png` (80px height)
- ✅ Background: `assets/images/backgrounds/bg.png` (with dark overlay)
- ✅ Subtitle: "جۆری پرسیارەکان هەڵبژێرە"

### Assets Structure
```
assets/
└── images/
    ├── backgrounds/
    │   └── bg.png (background image)
    ├── logos/
    │   └── logo1.png (app logo)
    └── icons/
        └── appicon.png (app launcher icon)
```

## Quick Setup Command (Recommended)

```bash
# Install flutter_launcher_icons
flutter pub add --dev flutter_launcher_icons

# Add config to pubspec.yaml (see Option 1 above)

# Generate icons
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for both Android and iOS!
