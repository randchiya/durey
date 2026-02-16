@echo off
echo ========================================
echo DuRey App Icon Generator
echo ========================================
echo.
echo Installing flutter_launcher_icons...
call flutter pub get
echo.
echo Generating app icons...
call flutter pub run flutter_launcher_icons
echo.
echo ========================================
echo Done! App icons have been generated.
echo ========================================
pause
