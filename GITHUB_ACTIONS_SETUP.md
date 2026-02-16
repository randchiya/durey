# GitHub Actions iOS Build Setup

This guide will help you set up automated IPA builds using GitHub Actions.

## Prerequisites

1. **Apple Developer Account** ($99/year)
2. **Code Signing Certificate** (.p12 file)
3. **Provisioning Profile** (.mobileprovision file)
4. **GitHub Repository** (already set up)

## Step 1: Prepare Code Signing Files

### A. Export Certificate from Keychain (on Mac)

1. Open **Keychain Access** on a Mac
2. Select **login** keychain
3. Find your **Apple Development** or **Apple Distribution** certificate
4. Right-click → **Export**
5. Save as `.p12` file
6. Set a password (remember this!)

### B. Download Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Profiles**
4. Download your provisioning profile (`.mobileprovision`)

## Step 2: Convert Files to Base64

### On Mac/Linux:
```bash
# Convert certificate to base64
base64 -i YourCertificate.p12 | pbcopy

# Convert provisioning profile to base64
base64 -i YourProfile.mobileprovision | pbcopy
```

### On Windows (PowerShell):
```powershell
# Convert certificate to base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("YourCertificate.p12")) | Set-Clipboard

# Convert provisioning profile to base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("YourProfile.mobileprovision")) | Set-Clipboard
```

## Step 3: Add Secrets to GitHub

1. Go to your repository: https://github.com/randchiya/durey
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

### Required Secrets:

| Secret Name | Description | Value |
|------------|-------------|-------|
| `IOS_CERTIFICATE_P12` | Base64 encoded .p12 certificate | Paste base64 string |
| `IOS_CERTIFICATE_PASSWORD` | Password for .p12 file | Your certificate password |
| `IOS_PROVISIONING_PROFILE` | Base64 encoded provisioning profile | Paste base64 string |

## Step 4: Update exportOptions.plist

1. Open `ios/exportOptions.plist`
2. Replace `YOUR_TEAM_ID` with your Apple Team ID
   - Find it at: https://developer.apple.com/account
   - Or in Xcode: Preferences → Accounts → View Details
3. Replace `YOUR_PROVISIONING_PROFILE_NAME` with your profile name
4. Update bundle identifier if needed: `com.kgd.durey`

## Step 5: Update iOS Bundle Identifier

1. Open `ios/Runner.xcodeproj` in Xcode (on Mac)
2. Select **Runner** target
3. Under **Signing & Capabilities**:
   - Set **Bundle Identifier**: `com.kgd.durey`
   - Select your **Team**
   - Choose your **Provisioning Profile**

## Step 6: Commit and Push

```bash
git add .
git commit -m "Add GitHub Actions iOS build workflow"
git push
```

## Step 7: Trigger Build

### Automatic Trigger:
- Push to `main` branch triggers build automatically

### Manual Trigger:
1. Go to **Actions** tab on GitHub
2. Select **Build iOS IPA** workflow
3. Click **Run workflow**
4. Select branch: `main`
5. Click **Run workflow**

## Step 8: Download IPA

After build completes (15-20 minutes):

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download **DuRey-IPA.zip**
5. Extract to get the `.ipa` file

## Build Methods

The workflow supports different distribution methods. Edit `ios/exportOptions.plist`:

### Ad Hoc (Testing on registered devices)
```xml
<key>method</key>
<string>ad-hoc</string>
```

### App Store (for App Store submission)
```xml
<key>method</key>
<string>app-store</string>
```

### Enterprise (for enterprise distribution)
```xml
<key>method</key>
<string>enterprise</string>
```

### Development (for development testing)
```xml
<key>method</key>
<string>development</string>
```

## Troubleshooting

### Error: "No signing certificate found"
- Verify `IOS_CERTIFICATE_P12` secret is correct
- Check certificate password in `IOS_CERTIFICATE_PASSWORD`

### Error: "No provisioning profile found"
- Verify `IOS_PROVISIONING_PROFILE` secret is correct
- Ensure profile matches bundle identifier

### Error: "Code signing failed"
- Check Team ID in `exportOptions.plist`
- Verify provisioning profile name
- Ensure certificate is valid (not expired)

### Error: "Build failed"
- Check workflow logs in Actions tab
- Verify Flutter version compatibility
- Check for syntax errors in code

## Alternative: Use Codemagic

If GitHub Actions is too complex, try [Codemagic](https://codemagic.io):

1. Sign up at codemagic.io
2. Connect your GitHub repository
3. Configure iOS code signing in UI
4. Click "Start new build"
5. Download IPA from build artifacts

Codemagic has a free tier and easier setup!

## Cost Considerations

- **GitHub Actions**: Free for public repos, 2000 minutes/month for private
- **macOS runners**: 10x multiplier (20 min build = 200 minutes)
- **Codemagic**: 500 free build minutes/month

## Security Notes

- Never commit `.p12` files or provisioning profiles directly
- Always use GitHub Secrets for sensitive data
- Rotate certificates regularly
- Use separate certificates for CI/CD

## Next Steps

1. Set up secrets in GitHub ✓
2. Update exportOptions.plist ✓
3. Push changes ✓
4. Trigger build ✓
5. Download IPA ✓
6. Test on device
7. Submit to App Store (optional)

## Support

For issues:
- Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
- Review [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- Check workflow logs for errors

## Useful Commands

```bash
# Check workflow status
gh run list

# View workflow logs
gh run view

# Download artifacts
gh run download
```

Good luck with your iOS build! 🚀
