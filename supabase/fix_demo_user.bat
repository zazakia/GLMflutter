@echo off
echo === Fixing Demo User Authentication ===
echo.

REM Check if Dart is available
dart --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Dart is not installed or not in PATH
    echo Please install Dart SDK first
    pause
    exit /b 1
)

REM Check if .env file exists
if not exist ..\.env (
    echo ERROR: .env file not found in project root
    echo Please ensure .env file exists with SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY
    pause
    exit /b 1
)

echo Running demo user fix script...
cd /d "%~dp0"
dart fix_demo_user.dart

if %errorlevel% equ 0 (
    echo.
    echo === SUCCESS: Demo user created! ===
    echo Email: admin@demo-company.com
    echo Password: demo123456
    echo.
    echo You can now use the 1-Click Admin Login button in the app.
) else (
    echo.
    echo === ERROR: Failed to create demo user ===
    echo Please check the error messages above.
)

pause