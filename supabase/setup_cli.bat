@echo off
echo ================================================
echo Supabase CLI Setup and Authentication (Phase 1)
echo ================================================
echo.
echo This script will help you install/update the Supabase CLI
echo and authenticate with your Supabase account.
echo.
echo All operations will be logged to CLI_SETUP_LOG.txt
echo.

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt
echo Log file location: %LOG_PATH%
echo.

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Starting Phase 1: CLI Setup and Authentication >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Collect environment information for diagnostics
echo %date% %time% - Collecting environment information... >> "%LOG_PATH%"
echo Windows Version: >> "%LOG_PATH%"
ver >> "%LOG_PATH%" 2>&1
echo. >> "%LOG_PATH%"
echo PowerShell Version: >> "%LOG_PATH%"
powershell -NoProfile -Command "$PSVersionTable.PSVersion" >> "%LOG_PATH%" 2>&1
echo. >> "%LOG_PATH%"
echo PATH (first 500 chars): >> "%LOG_PATH%"
powershell -NoProfile -Command "$p=$env:Path; if ($p.Length -gt 500) {$p.Substring(0,500)} else {$p}" >> "%LOG_PATH%" 2>&1
echo. >> "%LOG_PATH%"
echo Connectivity Test: >> "%LOG_PATH%"
ping -n 1 api.supabase.com >> "%LOG_PATH%" 2>&1
echo. >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"
echo.

:: Step 1: Check if Supabase CLI is already installed
echo Step 1: Checking if Supabase CLI is installed...
echo %date% %time% - Checking Supabase CLI installation... >> "%LOG_PATH%"
supabase --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo Supabase CLI is not installed or not in PATH.
    echo %date% %time% - ERROR: Supabase CLI not found >> "%LOG_PATH%"
    echo.
    echo Please install the Supabase CLI first:
    echo 1. Visit https://supabase.com/docs/guides/cli/getting-started
    echo 2. Follow the installation instructions for Windows
    echo 3. After installation, run this script again
    echo.
    echo Common installation methods:
    echo - Via npm: npm install -g supabase
    echo - Via Scoop: scoop install supabase
    echo - Direct download from GitHub releases
    echo.
    echo %date% %time% - Installation instructions provided to user >> "%LOG_PATH%"
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('supabase --version') do set SUPABASE_VERSION=%%i
    echo Supabase CLI found: %SUPABASE_VERSION%
    echo %date% %time% - Found Supabase CLI version: %SUPABASE_VERSION% >> "%LOG_PATH%"
)

echo.
pause

:: Step 2: Update Supabase CLI
echo Step 2: Updating Supabase CLI...
echo %date% %time% - Updating Supabase CLI... >> "%LOG_PATH%"
echo %date% %time% - Running: supabase update >> "%LOG_PATH%"
supabase update >> "%LOG_PATH%" 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Failed to update Supabase CLI
    echo %date% %time% - ERROR: Supabase CLI update failed >> "%LOG_PATH%"
    echo.
    echo This might be due to:
    echo - Network connectivity issues
    echo - Insufficient permissions
    echo - CLI already at latest version (can be ignored)
    echo.
    echo Continuing with current version...
    echo %date% %time% - Continuing with current version >> "%LOG_PATH%"
) else (
    echo Supabase CLI updated successfully
    echo %date% %time% - Supabase CLI updated successfully >> "%LOG_PATH%"
)

echo.
pause

:: Step 3: Prompt user to login
echo Step 3: Authentication
echo.
echo You will now be prompted to login to your Supabase account.
echo This will open a browser window for authentication.
echo.
echo %date% %time% - Prompting user for authentication >> "%LOG_PATH%"
pause

echo Running: supabase login
echo %date% %time% - Running: supabase login >> "%LOG_PATH%"
supabase login >> "%LOG_PATH%" 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Login command failed
    echo %date% %time% - ERROR: supabase login command failed >> "%LOG_PATH%"
    echo.
    echo Possible causes:
    echo - Network connectivity issues
    echo - Browser not opening properly
    echo - Firewall blocking the connection
    echo.
    echo Please try again or check CLI_TROUBLESHOOTING.md for help
    pause
    exit /b 1
) else (
    echo Login command completed
    echo %date% %time% - supabase login command completed >> "%LOG_PATH%"
)

echo.
pause

:: Step 4: Verify authentication
echo Step 4: Verifying authentication...
echo %date% %time% - Verifying authentication... >> "%LOG_PATH%"

:: Check if access token exists
if exist "%USERPROFILE%\.supabase\access-token" (
    echo Access token file found
    for %%i in ("%USERPROFILE%\.supabase\access-token") do set TOKEN_DATE=%%~ti
    echo Token last modified: %TOKEN_DATE%
    echo %date% %time% - Access token file found, last modified: %TOKEN_DATE% >> "%LOG_PATH%"
) else (
    echo.
    echo INFO: Access token file not found at %USERPROFILE%\.supabase\access-token
    echo %date% %time% - INFO: Access token file not found >> "%LOG_PATH%"
    echo.
    echo Note: Tokens may be stored in native credential storage.
    echo We will verify authentication via API access instead.
    echo.
)

:: Test authentication with projects list
echo.
echo Testing authentication by listing projects...
echo %date% %time% - Testing authentication with projects list... >> "%LOG_PATH%"
echo %date% %time% - Running: supabase projects list >> "%LOG_PATH%"
supabase projects list >> "%LOG_PATH%" 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Authentication verification failed
    echo %date% %time% - ERROR: Authentication verification failed >> "%LOG_PATH%"
    echo.
    echo The access token might be invalid or expired.
    echo Please try running 'supabase login' again.
    echo.
    echo For troubleshooting, check CLI_TROUBLESHOOTING.md
    set API_ACCESS=0
    pause
    exit /b 1
) else (
    echo Authentication successful! Can access Supabase projects.
    echo %date% %time% - Authentication verification successful >> "%LOG_PATH%"
    set API_ACCESS=1
)

echo.
pause

:: Step 5: Summary
echo ================================================
echo Phase 1 Setup Summary
echo ================================================
echo.
echo %date% %time% - Generating summary... >> "%LOG_PATH%"

:: Display summary based on API access success
if %API_ACCESS% equ 1 (
    echo [SUCCESS] Supabase CLI is installed and updated
    echo [SUCCESS] Authentication completed successfully
    echo [SUCCESS] API access verified
    echo.
    echo Phase 1 completed successfully!
    echo %date% %time% - Phase 1 completed successfully >> "%LOG_PATH%"
    echo.
    if not exist "%USERPROFILE%\.supabase\access-token" (
        echo Note: Authentication verified via API access.
        echo Tokens may be stored in native credential storage.
        echo.
    )
    echo Next steps:
    echo 1. Run verify_auth.bat to double-check authentication
    echo 2. Run migrate_with_cli.bat to complete the migration
    echo.
) else (
    echo [PARTIAL] Supabase CLI is installed and updated
    echo [FAILED] Authentication verification failed
    echo [ACTION] Please run 'supabase login' manually
    echo.
    echo Phase 1 partially completed.
    echo %date% %time% - Phase 1 partially completed - authentication issues >> "%LOG_PATH%"
    echo.
    echo Troubleshooting:
    echo 1. Check CLI_TROUBLESHOOTING.md
    echo 2. Run verify_auth.bat for detailed status
    echo 3. Try running 'supabase login' manually
    echo.
)

echo ================================================
echo %date% %time% - Phase 1 setup script completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file saved to: %LOG_PATH%
echo.
pause