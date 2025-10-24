@echo off
echo ================================================
echo Supabase CLI Project Linking and Verification (Phase 2)
echo ================================================
echo.
echo This script will link the CLI to your remote Supabase project
echo and verify connectivity and permissions.
echo.
echo Prerequisites: Phase 1 (CLI setup and authentication) must be completed.
echo Use setup_cli.bat and verify_auth.bat to complete Phase 1 if not done yet.
echo.
echo All operations will be logged to CLI_SETUP_LOG.txt
echo.

:: Change to script directory to ensure consistent path handling
cd /d "%~dp0"

:: Check for debug flag
set DEBUG_MODE=0
if "%1"=="--debug" set DEBUG_MODE=1
if "%1"=="-debug" set DEBUG_MODE=1
if %DEBUG_MODE%==1 echo Debug mode enabled - verbose output will be shown

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Starting Phase 2: Project Linking and Verification >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Step 1: Prerequisites Check - Verify Phase 1 completion
echo Step 1: Verifying Phase 1 completion...
echo %date% %time% - Verifying Phase 1 completion... >> "%LOG_PATH%"

:: Check if verify_auth.bat exists and run it
if exist "%~dp0verify_auth.bat" (
    if %DEBUG_MODE%==1 echo Running verify_auth.bat to check authentication...
    call "%~dp0verify_auth.bat" >nul 2>&1
    set AUTH_RESULT=%errorlevel%
    
    if %AUTH_RESULT% neq 0 (
        echo.
        echo ERROR: Phase 1 verification failed!
        echo Authentication is not complete or has issues.
        echo %date% %time% - ERROR: Phase 1 verification failed with exit code %AUTH_RESULT% >> "%LOG_PATH%"
        echo.
        echo Please complete Phase 1 first:
        echo 1. Run setup_cli.bat to install/update CLI and authenticate
        echo 2. Run verify_auth.bat to confirm authentication
        echo 3. Then run this script again
        echo.
        echo For troubleshooting, check:
        echo - %LOG_PATH% for detailed logs
        echo - CLI_TROUBLESHOOTING.md for common issues
        echo.
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] Phase 1 verification passed
        echo %date% %time% - Phase 1 verification successful >> "%LOG_PATH%"
    )
) else (
    echo WARNING: verify_auth.bat not found, proceeding with basic checks
    echo %date% %time% - WARNING: verify_auth.bat not found >> "%LOG_PATH%"
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 2: Config Validation
echo Step 2: Validating config.toml...
echo %date% %time% - Validating config.toml... >> "%LOG_PATH%"

if exist "%~dp0config.toml" (
    echo [SUCCESS] config.toml found
    echo %date% %time% - config.toml file found >> "%LOG_PATH%"
    
    :: Check if project ref is in config
    findstr "ref = \"tzmpwqiaqalrdwdslmkx\"" "%~dp0config.toml" >nul
    if errorlevel 1 (
        echo ERROR: Project reference not found or incorrect in config.toml
        echo %date% %time% - ERROR: Project reference not found in config.toml >> "%LOG_PATH%"
        echo Expected: ref = "tzmpwqiaqalrdwdslmkx"
        if %DEBUG_MODE%==1 pause
        exit /b 1
    ) else (
        echo [SUCCESS] Project reference found in config.toml
        echo %date% %time% - Project reference verified in config.toml >> "%LOG_PATH%"
    )
) else (
    echo ERROR: config.toml not found
    echo %date% %time% - ERROR: config.toml file not found >> "%LOG_PATH%"
    echo Please ensure config.toml exists in the script directory
    if %DEBUG_MODE%==1 pause
    exit /b 1
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 3: Network Connectivity Test
echo Step 3: Testing network connectivity...
echo %date% %time% - Testing network connectivity... >> "%LOG_PATH%"

:: Test basic internet connectivity
echo Testing basic internet connectivity...
ping -n 1 api.supabase.com >nul 2>&1
if errorlevel 1 (
    echo [FAILED] Cannot reach api.supabase.com
    echo %date% %time% - ERROR: Cannot reach api.supabase.com >> "%LOG_PATH%"
    echo.
    echo Possible causes:
    echo - No internet connection
    echo - DNS resolution issues
    echo - Firewall blocking Supabase domains
    echo.
    echo Troubleshooting:
    echo 1. Check your internet connection
    echo 2. Try running test_connection.bat for detailed diagnostics
    echo 3. Configure firewall to allow Supabase domains
    echo.
    if %DEBUG_MODE%==1 pause
    set NETWORK_OK=0
    exit /b 1
) else (
    echo [SUCCESS] Basic internet connectivity verified
    echo %date% %time% - Basic internet connectivity successful >> "%LOG_PATH%"
    set NETWORK_OK=1
)

:: Test DNS resolution for project-specific endpoint
echo Testing DNS resolution for project endpoint...
nslookup tzmpwqiaqalrdwdslmkx.supabase.co >nul 2>&1
if errorlevel 1 (
    echo [WARNING] DNS resolution for project endpoint failed
    echo %date% %time% - WARNING: DNS resolution for project endpoint failed >> "%LOG_PATH%"
    echo This might indicate network issues but will continue...
) else (
    echo [SUCCESS] DNS resolution for project endpoint successful
    echo %date% %time% - DNS resolution successful >> "%LOG_PATH%"
)

:: Measure network latency
echo Measuring network latency...
for /f "tokens=5" %%i in ('ping -n 4 api.supabase.com ^| find "Average"') do set LATENCY=%%i
if defined LATENCY (
    echo Average latency: %LATENCY%ms
    echo %date% %time% - Network latency: %LATENCY%ms >> "%LOG_PATH%"
) else (
    echo Could not measure latency
    echo %date% %time% - Could not measure network latency >> "%LOG_PATH%"
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 4: Project Linking
echo Step 4: Linking to Supabase project...
echo %date% %time% - Linking to project... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase link --project-ref tzmpwqiaqalrdwdslmkx
echo %date% %time% - Running: supabase link --project-ref tzmpwqiaqalrdwdslmkx >> "%LOG_PATH%"
supabase link --project-ref tzmpwqiaqalrdwdslmkx >> "%LOG_PATH%" 2>&1
set LINK_RESULT=%errorlevel%

if %LINK_RESULT% neq 0 (
    echo.
    echo ERROR: Failed to link to project
    echo %date% %time% - ERROR: Project linking failed with exit code %LINK_RESULT% >> "%LOG_PATH%"
    echo.
    echo Possible causes:
    echo - Authentication issues (re-run Phase 1)
    echo - Network connectivity problems
    echo - Project reference is incorrect
    echo - Permissions issues with the project
    echo - Project does not exist
    echo.
    echo Troubleshooting:
    echo 1. Check %LOG_PATH% for detailed error information
    echo 2. Verify you have access to project tzmpwqiaqalrdwdslmkx
    echo 3. Try running 'supabase projects list' to verify your projects
    echo 4. Run test_connection.bat for network diagnostics
    echo.
    
    :: Run firewall diagnostics immediately on link failure
    echo Running firewall diagnostics...
    echo %date% %time% - Running firewall diagnostics... >> "%LOG_PATH%"
    
    echo Testing port 443 (HTTPS) accessibility...
    powershell -NoProfile -Command "Test-NetConnection -ComputerName api.supabase.com -Port 443" >> "%LOG_PATH%" 2>&1
    
    echo Testing port 5432 (PostgreSQL) accessibility...
    powershell -NoProfile -Command "Test-NetConnection -ComputerName tzmpwqiaqalrdwdslmkx.supabase.co -Port 5432" >> "%LOG_PATH%" 2>&1
    
    echo Firewall diagnostics completed. Check log for details.
    echo.
    if %DEBUG_MODE%==1 pause
    set LINK_OK=0
    exit /b 1
) else (
    echo [SUCCESS] Successfully linked to project
    echo %date% %time% - Project linking successful >> "%LOG_PATH%"
    set LINK_OK=1
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 5: Connection Status Verification
echo Step 5: Verifying connection status...
echo %date% %time% - Verifying connection status... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase status
echo %date% %time% - Running: supabase status >> "%LOG_PATH%"
supabase status > temp_status_output.txt 2>&1
set STATUS_RESULT=%errorlevel%

if %STATUS_RESULT% neq 0 (
    echo.
    echo ERROR: Status check failed
    echo %date% %time% - ERROR: Status check failed with exit code %STATUS_RESULT% >> "%LOG_PATH%"
    echo.
    echo This indicates a connection issue with the project.
    echo Please check the error message in the log for details.
    echo.
    type temp_status_output.txt >> "%LOG_PATH%"
    del temp_status_output.txt
    if %DEBUG_MODE%==1 pause
    set STATUS_OK=0
    exit /b 1
) else (
    echo [SUCCESS] Status check completed successfully
    echo %date% %time% - Status check successful >> "%LOG_PATH%"
    set STATUS_OK=1
    echo.
    echo Connection details:
    type temp_status_output.txt
    echo.
    echo %date% %time% - Status output: >> "%LOG_PATH%"
    type temp_status_output.txt >> "%LOG_PATH%"
    del temp_status_output.txt
    
    echo.
    echo Please review the status output above to ensure:
    echo - API URL is accessible
    echo - Database URL is accessible
    echo - Studio URL is accessible
    echo.
)

if %DEBUG_MODE%==1 pause

:: Step 6: Database Permission Test
echo Step 6: Testing database permissions...
echo %date% %time% - Testing database permissions... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase projects list to verify project access
echo %date% %time% - Running: supabase projects list >> "%LOG_PATH%"
supabase projects list >> "%LOG_PATH%" 2>&1
set DB_TEST_RESULT=%errorlevel%

if %DB_TEST_RESULT% neq 0 (
    echo.
    echo [WARNING] Database permission test failed
    echo %date% %time% - WARNING: Database permission test failed with exit code %DB_TEST_RESULT% >> "%LOG_PATH%"
    echo.
    echo This might indicate:
    echo - Insufficient database permissions
    echo - Database is paused (free tier limitation)
    echo - Network issues with database connection
    echo.
    echo Troubleshooting:
    echo 1. Check Supabase dashboard for database status
    echo 2. Verify your user role in the project
    echo 3. Ensure database is not paused
    echo.
    set DB_PERMISSION=0
) else (
    echo [SUCCESS] Database permission test passed
    echo %date% %time% - Database permission test successful >> "%LOG_PATH%"
    set DB_PERMISSION=1
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 7: Firewall Detection (consolidated section)
:: Note: Firewall diagnostics now run immediately on link failure

:: Step 8: Summary Report
echo ================================================
echo Phase 2 Linking Summary
echo ================================================
echo.
echo %date% %time% - Generating Phase 2 summary... >> "%LOG_PATH%"

echo Network connectivity:
if %NETWORK_OK% equ 1 (
    echo SUCCESS
    echo - Network connectivity: SUCCESS >> "%LOG_PATH%"
) else (
    echo FAIL
    echo - Network connectivity: FAIL >> "%LOG_PATH%"
)

echo Project linking:
if %LINK_OK% equ 1 (
    echo SUCCESS
    echo - Project linking: SUCCESS >> "%LOG_PATH%"
) else (
    echo FAIL
    echo - Project linking: FAIL >> "%LOG_PATH%"
)

echo Status verification:
if %STATUS_OK% equ 1 (
    echo SUCCESS
    echo - Status verification: SUCCESS >> "%LOG_PATH%"
) else (
    echo FAIL
    echo - Status verification: FAIL >> "%LOG_PATH%"
)

echo Database permissions:
if %DB_PERMISSION% equ 1 (
    echo SUCCESS
    echo - Database permissions: SUCCESS >> "%LOG_PATH%"
) else (
    echo NEEDS ATTENTION
    echo - Database permissions: NEEDS ATTENTION >> "%LOG_PATH%"
)

echo.
echo %date% %time% - Phase 2 Summary: >> "%LOG_PATH%"

echo.
:: Check if all critical checks passed
set ALL_CRITICAL_PASSED=1
if %NETWORK_OK% neq 1 set ALL_CRITICAL_PASSED=0
if %LINK_OK% neq 1 set ALL_CRITICAL_PASSED=0
if %STATUS_OK% neq 1 set ALL_CRITICAL_PASSED=0

if %ALL_CRITICAL_PASSED% equ 1 (
    if %DB_PERMISSION% equ 1 (
        echo Phase 2 completed successfully!
        echo %date% %time% - Phase 2 completed successfully >> "%LOG_PATH%"
        echo.
        echo Next steps:
        echo 1. Run migrate_with_cli.bat to complete Phase 3 (Migration Push)
        echo 2. Test your Flutter app connection to the database
        echo.
        exit /b 0
    ) else (
        echo Phase 2 completed with warnings
        echo %date% %time% - Phase 2 completed with database permission issues >> "%LOG_PATH%"
        echo.
        echo You can proceed to Phase 3, but may encounter database access issues.
        echo Next steps:
        echo 1. Check database permissions in Supabase dashboard
        echo 2. Run migrate_with_cli.bat to attempt Phase 3
        echo 3. If Phase 3 fails, resolve database permissions first
        echo.
        exit /b 0
    )
) else (
    echo Phase 2 failed - critical errors detected
    echo %date% %time% - Phase 2 failed with critical errors >> "%LOG_PATH%"
    echo.
    echo Please resolve the critical failures above before proceeding.
    echo.
    exit /b 1
)

echo ================================================
echo %date% %time% - Phase 2 script completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file saved to: %LOG_PATH%
echo.
if %DEBUG_MODE%==1 pause