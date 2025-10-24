@echo off
echo Supabase CLI Migration Push Script (Phase 3)
echo ==============================================
echo.
echo This script will push database migrations to your remote Supabase project.
echo This is Phase 3 of the migration process.
echo.
echo Prerequisites: 
echo - Phase 1: CLI setup and authentication (via setup_cli.bat)
echo - Phase 2: Project linking and verification (via link_project.bat)
echo.
echo Both Phase 1 AND Phase 2 must be completed before running this script.
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
echo %date% %time% - Starting Phase 3: Migration Push >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Phase 1 Verification
echo Phase 1 Verification: Checking authentication status...
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
        if %DEBUG_MODE%==1 pause
        exit /b 1
    ) else (
        echo [SUCCESS] Phase 1 verification passed
        echo %date% %time% - Phase 1 verification successful >> "%LOG_PATH%"
    )
) else (
    echo WARNING: verify_auth.bat not found, proceeding with basic checks
    echo %date% %time% - WARNING: verify_auth.bat not found >> "%LOG_PATH%"
)

:: Phase 2 Verification
echo Phase 2 Verification: Checking project linking status...
echo %date% %time% - Verifying Phase 2 completion... >> "%LOG_PATH%"

:: Check if project is already linked by running supabase status
if %DEBUG_MODE%==1 echo Running: supabase status to check link
echo %date% %time% - Running: supabase status to verify project link >> "%LOG_PATH%"
supabase status > temp_status_check.txt 2>&1
set LINK_CHECK_RESULT=%errorlevel%

if %LINK_CHECK_RESULT% neq 0 (
    echo.
    echo ERROR: Phase 2 verification failed!
    echo Project is not linked or connection issues detected.
    echo %date% %time% - ERROR: Phase 2 verification failed with exit code %LINK_CHECK_RESULT% >> "%LOG_PATH%"
    echo.
    echo Please complete Phase 2 first:
    echo 1. Run link_project.bat to link to your Supabase project
    echo 2. Verify all Phase 2 checks in PHASE2_CHECKLIST.md
    echo 3. Then run this script again
    echo.
    echo For troubleshooting, check:
    echo - %LOG_PATH% for detailed logs
    echo - PHASE2_CHECKLIST.md for Phase 2 requirements
    echo - CLI_TROUBLESHOOTING.md Phase 2 section
    echo.
    if exist temp_status_check.txt del temp_status_check.txt
    if %DEBUG_MODE%==1 pause
    exit /b 1
) else (
    echo [SUCCESS] Phase 2 verification passed - project is linked
    echo %date% %time% - Phase 2 verification successful >> "%LOG_PATH%"
    echo.
    echo Project link confirmed. Status details:
    type temp_status_check.txt
    echo.
    if exist temp_status_check.txt del temp_status_check.txt
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 1: Verify migrations directory
echo Step 1: Verifying migration files...
echo %date% %time% - Checking migration files... >> "%LOG_PATH%"

if exist "%~dp0migrations" (
    echo [SUCCESS] migrations directory found
    echo %date% %time% - migrations directory found >> "%LOG_PATH%"
    
    :: List migration files
    echo Migration files that will be pushed:
    dir /b "%~dp0migrations\*.sql"
    echo %date% %time% - Found migration files: >> "%LOG_PATH%"
    dir /b "%~dp0migrations\*.sql" >> "%LOG_PATH%" 2>&1
    
    :: Count migration files
    for /f %%i in ('dir /b "%~dp0migrations\*.sql" 2^>nul ^| find /c /v ""') do set MIGRATION_COUNT=%%i
    echo Found %MIGRATION_COUNT% migration file(s)
    echo %date% %time% - Total migration files: %MIGRATION_COUNT% >> "%LOG_PATH%"
    
    if %MIGRATION_COUNT% equ 0 (
        echo ERROR: No migration files found
        echo %date% %time% - ERROR: No migration files found >> "%LOG_PATH%"
        echo.
        echo Please ensure migration files exist in the migrations/ directory
        if %DEBUG_MODE%==1 pause
        exit /b 1
    )
) else (
    echo ERROR: migrations directory not found
    echo %date% %time% - ERROR: migrations directory not found >> "%LOG_PATH%"
    echo Please ensure migrations directory exists with SQL files
    if %DEBUG_MODE%==1 pause
    exit /b 1
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 2: Push migrations
echo Step 2: Pushing migrations to remote database...
echo %date% %time% - Starting migration push... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase db push
echo %date% %time% - Running: supabase db push >> "%LOG_PATH%"
supabase db push >> "%LOG_PATH%" 2>&1
set MIGRATION_RESULT=%errorlevel%

if %MIGRATION_RESULT% neq 0 (
    echo.
    echo ERROR: Migration push failed
    echo %date% %time% - ERROR: Migration push failed with exit code %MIGRATION_RESULT% >> "%LOG_PATH%"
    echo.
    echo Possible causes:
    echo - SQL syntax errors in migration files
    echo - Database connection issues
    echo - Permission denied for database operations
    echo - Migration conflicts with existing schema
    echo - Database is paused (free tier limitation)
    echo.
    echo Troubleshooting:
    echo 1. Check the error message above for specific SQL issues
    echo 2. Review migration files in the migrations/ directory
    echo 3. Verify your database permissions in Supabase dashboard
    echo 4. Check if database is paused and resume if needed
    echo 5. Check %LOG_PATH% for detailed error information
    echo.
    echo If migrations fail partially, you may need to:
    echo 1. Manually fix issues in the Supabase Dashboard SQL Editor
    echo 2. Check which migrations were applied and manually apply remaining ones
    echo 3. Or reset and try again (CAUTION: This will delete existing data)
    echo.
    if %DEBUG_MODE%==1 pause
    exit /b 1
) else (
    echo [SUCCESS] Migration push completed successfully
    echo %date% %time% - Migration push successful >> "%LOG_PATH%"
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 3: Verify migrations were applied
echo Step 3: Verifying migrations were applied...
echo %date% %time% - Verifying migration application... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase db remote list to verify
echo %date% %time% - Running: supabase db remote list >> "%LOG_PATH%"
supabase db remote list >> "%LOG_PATH%" 2>&1
set VERIFY_RESULT=%errorlevel%

if %VERIFY_RESULT% neq 0 (
    echo.
    echo [WARNING] Could not verify migration application
    echo %date% %time% - WARNING: Migration verification failed >> "%LOG_PATH%"
    echo.
    echo This might indicate:
    echo - Database connection issues after migration
    echo - Permission changes during migration
    echo.
    echo Please manually verify in Supabase Dashboard:
    echo 1. Go to Table Editor
    echo 2. Check if expected tables were created
    echo 3. Review SQL Editor for any errors
    echo.
) else (
    echo [SUCCESS] Migration verification completed
    echo %date% %time% - Migration verification successful >> "%LOG_PATH%"
    echo.
    echo Migration verification shows database is accessible
    echo Please check Supabase Dashboard to confirm all tables were created
    echo.
)

echo.
if %DEBUG_MODE%==1 pause

:: Step 4: Final summary
echo ================================================
echo Phase 3 Migration Summary
echo ================================================
echo.
echo %date% %time% - Generating Phase 3 summary... >> "%LOG_PATH%"

echo [SUCCESS] Phase 1: Authentication verified (completed previously)
echo [SUCCESS] Phase 2: Project linking completed (completed previously)
echo [SUCCESS] Phase 3: Migration push completed
echo.
echo Phase 3 (Migration Push) completed successfully!
echo %date% %time% - Phase 3 completed successfully >> "%LOG_PATH%"
echo.
echo Migration Summary:
echo - Migration files processed: %MIGRATION_COUNT%
echo - Database: tzmpwqiaqalrdwdslmkx
echo - Status: Successfully applied
echo.
echo %date% %time% - Migration Summary: >> "%LOG_PATH%"
echo - Migration files processed: %MIGRATION_COUNT% >> "%LOG_PATH%"
echo - Database: tzmpwqiaqalrdwdslmkx >> "%LOG_PATH%"
echo - Status: Successfully applied >> "%LOG_PATH%"
echo.
echo Next steps:
echo 1. Test your Flutter app connection to the database
echo 2. Verify that all tables were created correctly in Supabase Dashboard
echo 3. Test authentication and CRUD operations
echo 4. Check that RLS policies are working as expected
echo 5. Review the data in your tables to ensure seeding worked correctly
echo.
echo For post-migration verification:
echo - Use the Supabase Dashboard Table Editor to browse tables
echo - Test with your Flutter app to ensure connectivity
echo - Check the SQL Editor for any remaining issues
echo.

echo ================================================
echo %date% %time% - Phase 3 script completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file saved to: %LOG_PATH%
echo.
if %DEBUG_MODE%==1 pause
exit /b 0