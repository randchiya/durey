# Building IPA for iOS

This guide will help you build an IPA file for the DuRey app.

## Prerequisites

- macOS computer (required for iOS builds)
- Xcode installed (latest version recommended)
- Apple Developer Account ($99/year)
- Flutter SDK installed
- CocoaPods installed

## Step 1: Configure iOS Project

1. Open the iOS project in Xcode:
```bash
cd durey
open ios/Runner.xcworkspace
```

2. In Xcode, select the Runner project in the left sidebar

3. Under "Signing & Capabilities":
   - Select your Team (Apple Developer Account)
   - Change Bundle Identifier to your unique ID (e.g., `com.kgd.durey`)
   - Enable "Automatically manage signing"

## Step 2: Update App Information

1. In Xcode, update the following in `Runner` target:
   - **Display Name**: DuRey
   - **Bundle Identifier**: com.kgd.durey (or your custom ID)
   - **Version**: 1.0.0
   - **Build**: 1

2. Update `ios/Runner/Info.plist` if needed for permissions

## Step 3: Add App Icons

1. Place your app icon in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. Or use the flutter_launcher_icons package:
```bash
flutter pub run flutter_launcher_icons
```

## Step 4: Build the IPA

### Method 1: Using Flutter Command (Recommended)

1. Clean the project:
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

2. Build the iOS app:
```bash
flutter build ios --release
```

3. Open Xcode and archive:
```bash
open ios/Runner.xcworkspace
```

4. In Xcode:
   - Select "Any iOS Device (arm64)" as the build target
   - Go to **Product > Archive**
   - Wait for the archive to complete
   - Click **Distribute App**
   - Choose distribution method:
     - **App Store Connect** - For App Store submission
     - **Ad Hoc** - For testing on registered devices
     - **Enterprise** - For enterprise distribution
     - **Development** - For development testing

5. Follow the wizard to export the IPA

### Method 2: Using Xcode Directly

1. Open the workspace:
```bash
open ios/Runner.xcworkspace
```

2. Select "Any iOS Device (arm64)" as target

3. Go to **Product > Archive**

4. Once archived, the Organizer window opens

5. Click **Distribute App** and follow the steps

## Step 5: Testing the IPA

### Install on Physical Device (Ad Hoc)

1. Connect your iPhone/iPad via USB
2. Open Xcode
3. Go to **Window > Devices and Simulators**
4. Select your device
5. Drag and drop the IPA file onto the device

### Using TestFlight (App Store Connect)

1. Upload IPA to App Store Connect
2. Add internal/external testers
3. Testers install via TestFlight app

## Common Issues

### Issue: "No signing certificate found"
**Solution**: 
- Go to Xcode > Preferences > Accounts
- Add your Apple ID
- Download certificates

### Issue: "Provisioning profile doesn't match"
**Solution**:
- Enable "Automatically manage signing" in Xcode
- Or create a manual provisioning profile in Apple Developer Portal

### Issue: "CocoaPods not installed"
**Solution**:
```bash
sudo gem install cocoapods
```

### Issue: "Build failed with code signing error"
**Solution**:
- Clean build folder: Product > Clean Build Folder
- Delete derived data
- Restart Xcode

## Environment Variables

Before building, ensure you have:

1. Created `.env` file with Supabase credentials
2. Updated AdMob IDs in `lib/core/ads/admob_config.dart`
3. Configured `ios/Runner/Info.plist` with required keys

## App Store Submission Checklist

- [ ] App icons added (all sizes)
- [ ] Launch screen configured
- [ ] Privacy policy URL ready
- [ ] App description and screenshots prepared
- [ ] Supabase backend configured
- [ ] AdMob account set up
- [ ] Test on multiple iOS devices
- [ ] All features working correctly
- [ ] No debug code or console logs
- [ ] Version and build numbers set correctly

## Build Commands Reference

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Install iOS pods
cd ios && pod install && cd ..

# Build for iOS (creates .app file)
flutter build ios --release

# Build with specific bundle ID
flutter build ios --release --bundle-id=com.kgd.durey

# Build with specific build number
flutter build ios --release --build-number=1

# Build with specific version
flutter build ios --release --build-name=1.0.0
```

## Additional Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Portal](https://developer.apple.com)
- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight](https://developer.apple.com/testflight/)

## Support

For issues or questions, contact KGD development team.
