# Fonts Folder

Place custom font files here for use in the DuRey app.

## Recommended Fonts for Kurdish/Arabic Text

### Google Fonts (Free)
- **Noto Sans Arabic** - Clean, modern sans-serif
- **Cairo** - Geometric sans-serif, great for UI
- **Tajawal** - Modern Arabic font
- **Almarai** - Clean and readable
- **Amiri** - Traditional Arabic calligraphy style

Download from: https://fonts.google.com

### File Formats
- `.ttf` (TrueType Font) - Recommended
- `.otf` (OpenType Font) - Also supported

## How to Add Fonts

1. **Download font files** and place them in this folder
   ```
   assets/fonts/
   ├── Cairo-Regular.ttf
   ├── Cairo-Bold.ttf
   └── Cairo-Light.ttf
   ```

2. **Update pubspec.yaml**
   ```yaml
   flutter:
     fonts:
       - family: Cairo
         fonts:
           - asset: assets/fonts/Cairo-Regular.ttf
           - asset: assets/fonts/Cairo-Bold.ttf
             weight: 700
           - asset: assets/fonts/Cairo-Light.ttf
             weight: 300
   ```

3. **Use in your app**
   ```dart
   Text(
     'جۆری پرسیارەکان هەڵبژێرە',
     style: TextStyle(
       fontFamily: 'Cairo',
       fontSize: 20,
       fontWeight: FontWeight.bold,
     ),
   )
   ```

4. **Set as default theme font**
   ```dart
   MaterialApp(
     theme: ThemeData(
       fontFamily: 'Cairo',
     ),
   )
   ```

## Font Weights

- 100: Thin
- 200: Extra Light
- 300: Light
- 400: Regular (normal)
- 500: Medium
- 600: Semi Bold
- 700: Bold
- 800: Extra Bold
- 900: Black

## Tips

- Use Regular (400) for body text
- Use Bold (700) for headings
- Use Medium (500) for buttons
- Keep font files under 500KB each for better performance
- Test fonts with Kurdish text to ensure proper rendering
