@echo off
REM Build script with environment variables
REM Usage: build_with_env.cmd [android|ios|apk|appbundle]

set PLATFORM=%1

if "%PLATFORM%"=="" (
    echo Usage: build_with_env.cmd [android^|ios^|apk^|appbundle]
    exit /b 1
)

REM Set your environment variables here or load from .env file
set API_BASE_URL=https://api.example.com
set APP_ENV=production

if "%PLATFORM%"=="android" (
    flutter run --dart-define=API_BASE_URL=%API_BASE_URL% --dart-define=APP_ENV=%APP_ENV%
) else if "%PLATFORM%"=="ios" (
    flutter run --dart-define=API_BASE_URL=%API_BASE_URL% --dart-define=APP_ENV=%APP_ENV%
) else if "%PLATFORM%"=="apk" (
    flutter build apk --release --dart-define=API_BASE_URL=%API_BASE_URL% --dart-define=APP_ENV=%APP_ENV%
) else if "%PLATFORM%"=="appbundle" (
    flutter build appbundle --release --dart-define=API_BASE_URL=%API_BASE_URL% --dart-define=APP_ENV=%APP_ENV%
) else (
    echo Invalid platform. Use: android, ios, apk, or appbundle
    exit /b 1
)
