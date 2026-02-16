# DuRey Assets

This folder contains all image assets for the DuRey application.

## Folder Structure

```
assets/
└── images/
    ├── backgrounds/    # Background images
    ├── logos/          # App logos and branding
    └── icons/          # App icons and UI icons
```

## Asset Guidelines

### Backgrounds (`assets/images/backgrounds/`)
- **Format**: PNG or JPG
- **Recommended Size**: 1080x1920 or higher
- **Usage**: Full-screen background images
- **Naming Convention**: 
  - `bg_main.png` - Main background
  - `bg_category.png` - Category screen background
  - `bg_voting.png` - Voting screen background

### Logos (`assets/images/logos/`)
- **Format**: PNG with transparency
- **Recommended Sizes**:
  - `logo.png` - 512x512 (main square logo)
  - `logo_horizontal.png` - 1024x256 (horizontal variant)
  - `logo_white.png` - 512x512 (white version for dark backgrounds)
  - `logo_text.png` - Text-only logo variant
- **Usage**: App branding, splash screen, about page

### Icons (`assets/images/icons/`)
- **Format**: PNG with transparency
- **App Launcher Icons**:
  - `icon_1024.png` - 1024x1024 (iOS App Store)
  - `icon_512.png` - 512x512 (Android Play Store)
  - `icon_192.png` - 192x192 (Android adaptive icon)
- **UI Icons**: Custom icons for the app interface

## How to Use Assets in Code

### Load an image:
```dart
Image.asset('assets/images/logos/logo.png')
```

### Load as background:
```dart
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/backgrounds/bg_main.png'),
      fit: BoxFit.cover,
    ),
  ),
)
```

### Preload images:
```dart
await precacheImage(
  AssetImage('assets/images/logos/logo.png'),
  context,
);
```

## Notes

- All assets must be added to `pubspec.yaml` under the `assets:` section
- Keep file sizes optimized for mobile (compress images)
- Use PNG for images requiring transparency
- Use JPG for photos/backgrounds without transparency
- Follow naming conventions for consistency
