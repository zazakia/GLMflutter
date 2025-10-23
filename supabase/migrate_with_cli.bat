@echo off
echo Supabase CLI Migration Script (Phases 2-3)
echo ==========================================
echo.
echo This script will complete the migration process by linking to your
echo Supabase project and pushing the database schema.
echo.
echo Prerequisites: Phase 1 (CLI setup and authentication) must be completed.
echo Use setup_cli.bat to complete Phase 1 if not done yet.
echo.
echo All operations will be logged to CLI_SETUP_LOG.txt
echo.

:: Check for debug flag
set DEBUG_MODE=0
if "%1"=="--debug" set DEBUG_MODE=1
if "%1"=="-debug" set DEBUG_MODE=1
if %DEBUG_MODE%==1 echo Debug mode enabled - verbose output will be shown

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Starting Migration Script (Phases 2-3) >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Phase 1 Verification
echo Phase 1 Verification: Checking authentication status...
echo %date% %time% - Verifying Phase 1 completion... >> "%LOG_PATH%"

:: Check if verify_auth.bat exists and run it
if exist "verify_auth.bat" (
    if %DEBUG_MODE%==1 echo Running verify_auth.bat to check authentication...
    call verify_auth.bat >nul 2>&1
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
pause

:: Step 1: Verify config.toml exists
echo Step 1: Verifying configuration file...
echo %date% %time% - Checking config.toml... >> "%LOG_PATH%"

if exist "config.toml" (
    echo [SUCCESS] config.toml found
    echo %date% %time% - config.toml file found >> "%LOG_PATH%"
    
    :: Check if project ref is in config
    findstr "ref = " config.toml >nul
    if errorlevel 1 (
        echo ERROR: Project reference not found in config.toml
        echo %date% %time% - ERROR: Project reference not found in config.toml >> "%LOG_PATH%"
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] Project reference found in config.toml
        echo %date% %time% - Project reference verified in config.toml >> "%LOG_PATH%"
    )
) else (
    echo ERROR: config.toml not found
    echo %date% %time% - ERROR: config.toml file not found >> "%LOG_PATH%"
    echo Please ensure config.toml exists in the current directory
    pause
    exit /b 1
)

echo.
pause

:: Step 2: Link to project
echo Step 2: Linking to Supabase project...
echo %date% %time% - Linking to project... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase link --project-ref tzmpwqiaqalrdwdslmkx
echo %date% %time% - Running: supabase link --project-ref tzmpwqiaqalrdwdslmkx >> "%LOG_PATH%"
supabase link --project-ref tzmpwqiaqalrdwdslmkx >> "%LOG_PATH%" 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Failed to link to project
    echo %date% %time% - ERROR: Project linking failed >> "%LOG_PATH%"
    echo.
    echo Possible causes:
    echo - Authentication issues (re-run setup_cli.bat)
    echo - Network connectivity problems
    echo - Project reference is incorrect
    echo - Permissions issues with the project
    echo.
    echo Troubleshooting:
    echo 1. Check %LOG_PATH% for detailed error information
    echo 2. Verify you have access to project tzmpwqiaqalrdwdslmkx
    echo 3. Try running 'supabase projects list' to verify your projects
    echo.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Successfully linked to project
    echo %date% %time% - Project linking successful >> "%LOG_PATH%"
)

echo.
pause

:: Step 3: Check status
echo Step 3: Checking project status...
echo %date% %time% - Checking project status... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase status
echo %date% %time% - Running: supabase status >> "%LOG_PATH%"
supabase status >> "%LOG_PATH%" 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Status check failed
    echo %date% %time% - ERROR: Status check failed >> "%LOG_PATH%"
    echo.
    echo This indicates a connection issue with the project.
    echo Please check the error message above for details.
    echo.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Status check completed successfully
    echo %date% %time% - Status check successful >> "%LOG_PATH%"
    echo.
    echo Please review the status output above to ensure:
    echo - API URL is accessible
    - Database URL is accessible
    - Studio URL is accessible
    echo.
    pause
)

:: Step 4: Push migrations
echo Step 4: Pushing migrations to remote database...
echo %date% %time% - Starting migration push... >> "%LOG_PATH%"

if %DEBUG_MODE%==1 echo Running: supabase db push
echo %date% %time% - Running: supabase db push >> "%LOG_PATH%"
supabase db push >> "%LOG_PATH%" 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Migration push failed
    echo %date% %time% - ERROR: Migration push failed >> "%LOG_PATH%"
    echo.
    echo Possible causes:
    echo - SQL syntax errors in migration files
    echo - Database connection issues
    echo - Permission denied for database operations
    echo - Migration conflicts with existing schema
    echo.
    echo Troubleshooting:
    echo 1. Check the error message above for specific SQL issues
    echo 2. Review migration files in the migrations/ directory
    echo 3. Verify your database permissions
    echo 4. Check %LOG_PATH% for detailed error information
    echo.
    echo If migrations fail partially, you may need to:
    echo 1. Manually fix issues in the Supabase Dashboard
    echo 2. Or reset and try again
    echo.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Migration push completed successfully
    echo %date% %time% - Migration push successful >> "%LOG_PATH%"
)

echo.
echo ================================================
echo Migration Summary
echo ================================================
echo.
echo %date% %time% - Generating migration summary... >> "%LOG_PATH%"

echo [SUCCESS] Phase 1: Authentication verified
echo [SUCCESS] Phase 2: Project linking completed
echo [SUCCESS] Phase 3: Migration push completed
echo.
echo Migration process completed successfully!
echo %date% %time% - Migration process completed successfully >> "%LOG_PATH%"
echo.
echo Next steps:
echo 1. Test your Flutter app connection to the database
echo 2. Verify that all tables were created correctly
echo 3. Test authentication and CRUD operations
echo 4. Check that RLS policies are working as expected
echo.

echo ================================================
echo %date% %time% - Migration script completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file saved to: %LOG_PATH%
echo.
pause