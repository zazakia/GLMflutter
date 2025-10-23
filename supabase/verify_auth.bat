@echo off
echo ================================================
echo Supabase CLI Authentication Verification
echo ================================================
echo.
echo This script will verify your Supabase CLI authentication status.
echo Results will be logged to CLI_SETUP_LOG.txt
echo.

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt
echo Log file location: %LOG_PATH%
echo.

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Running Authentication Verification >> "%LOG_PATH%"
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

:: Initialize verification status
set AUTH_SUCCESS=0
set TOKEN_EXISTS=0
set API_ACCESS=0

:: Step 1: Check if access token file exists
echo Step 1: Checking for access token file...
echo %date% %time% - Checking access token file... >> "%LOG_PATH%"

if exist "%USERPROFILE%\.supabase\access-token" (
    echo [SUCCESS] Access token file found at: %USERPROFILE%\.supabase\access-token
    for %%i in ("%USERPROFILE%\.supabase\access-token") do set TOKEN_DATE=%%~ti
    echo Token last modified: %TOKEN_DATE%
    echo %date% %time% - Access token found, last modified: %TOKEN_DATE% >> "%LOG_PATH%"
    set TOKEN_EXISTS=1
) else (
    echo [INFO] Access token file not found
    echo Expected location: %USERPROFILE%\.supabase\access-token
    echo %date% %time% - INFO: Access token file not found >> "%LOG_PATH%"
    echo.
    echo Note: Tokens may be stored in native credential storage.
    echo We will verify authentication via API access instead.
    echo.
    set TOKEN_EXISTS=0
)

echo.
pause

:: Step 2: Test API connectivity with projects list
echo Step 2: Testing API connectivity...
echo %date% %time% - Testing API connectivity with projects list... >> "%LOG_PATH%"

supabase projects list --output json > temp_projects_output.txt 2>&1
set PROJECTS_EXIT_CODE=%errorlevel%

if %PROJECTS_EXIT_CODE% equ 0 (
    echo [SUCCESS] API connectivity verified
    echo %date% %time% - API connectivity successful >> "%LOG_PATH%"
    set API_ACCESS=1
    
    :: Count projects by counting "id" occurrences in JSON
    for /f %%i in ('find "\"id\"" temp_projects_output.txt ^| find /c /v ""') do set PROJECTS_COUNT=%%i
    echo Found %PROJECTS_COUNT% project(s) in your account
    echo %date% %time% - Found %PROJECTS_COUNT% projects >> "%LOG_PATH%"
) else (
    echo [FAILED] API connectivity test failed
    echo %date% %time% - ERROR: API connectivity failed with exit code %PROJECTS_EXIT_CODE% >> "%LOG_PATH%"
    echo.
    echo Error output:
    type temp_projects_output.txt
    echo.
    type temp_projects_output.txt >> "%LOG_PATH%"
    echo %date% %time% - Error output logged >> "%LOG_PATH%"
    echo.
    echo Common causes:
    echo - Network connectivity issues
    echo - Firewall or proxy blocking the connection
    echo - Invalid or expired access token
    echo - Supabase API service issues
    echo.
)

:: Clean up temp file
if exist temp_projects_output.txt del temp_projects_output.txt

echo.
pause

:: Step 3: Overall verification result
echo Step 3: Overall verification result
echo %date% %time% - Calculating overall verification result... >> "%LOG_PATH%"

:: Check if SUPABASE_ACCESS_TOKEN environment variable is set
if defined SUPABASE_ACCESS_TOKEN (
    echo %date% %time% - SUPABASE_ACCESS_TOKEN environment variable is set >> "%LOG_PATH%"
    set TOKEN_EXISTS=1
)

if %API_ACCESS% equ 1 (
    echo.
    echo ================================================
    echo VERIFICATION SUCCESSFUL
    echo ================================================
    echo.
    echo Your Supabase CLI authentication is working correctly!
    echo You can proceed with the migration process.
    echo.
    if not exist "%USERPROFILE%\.supabase\access-token" (
        echo Note: Authentication verified via API access.
        echo Tokens may be stored in native credential storage.
        echo.
    )
    echo %date% %time% - Overall verification: SUCCESS >> "%LOG_PATH%"
    set AUTH_SUCCESS=1
) else (
    if %TOKEN_EXISTS% equ 1 (
        echo.
        echo ================================================
        echo VERIFICATION PARTIAL
        echo ================================================
        echo.
        echo Access token exists but API access is failing.
        echo This might indicate:
        echo - Network connectivity issues
        echo - Token has expired
        echo - Temporary API service issues
        echo.
        echo Troubleshooting steps:
        echo 1. Check your internet connection
        echo 2. Try running 'supabase login' again
        echo 3. Check if firewall is blocking Supabase domains
        echo 4. Wait a few minutes and try again
        echo.
        echo %date% %time% - Overall verification: PARTIAL (token exists, API fails) >> "%LOG_PATH%"
    ) else (
        echo.
        echo ================================================
        echo VERIFICATION FAILED
        echo ================================================
        echo.
        echo Authentication is not complete.
        echo Please complete the authentication process first.
        echo.
        echo Next steps:
        echo 1. Run setup_cli.bat to complete authentication
        echo 2. Or run 'supabase login' manually
        echo 3. Run this verification script again
        echo.
        echo %date% %time% - Overall verification: FAILED (no token, API fails) >> "%LOG_PATH%"
    )
)

echo.
echo ================================================
echo Verification Summary
echo ================================================
echo Access Token File: %TOKEN_EXISTS%
echo API Access: %API_ACCESS%
echo Overall Status: 
if %AUTH_SUCCESS% equ 1 (
    echo SUCCESS
) else (
    echo NEEDS ATTENTION
)
echo.
echo %date% %time% - Verification completed with status: AUTH_SUCCESS=%AUTH_SUCCESS% >> "%LOG_PATH%"
echo ================================================
echo.

:: Exit with appropriate code
if %AUTH_SUCCESS% equ 1 (
    echo You can now run migrate_with_cli.bat to complete the migration.
    exit /b 0
) else (
    echo Please resolve authentication issues before proceeding.
    echo Check CLI_TROUBLESHOOTING.md for detailed help.
    exit /b 1
)