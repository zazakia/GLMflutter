@echo off
echo ================================================
echo Supabase Migration Summary Script
echo ================================================
echo.
echo This script provides a comprehensive overview of the entire
echo three-phase migration process and current status.
echo.

:: Enable delayed expansion for proper variable handling in loops
setlocal EnableExtensions EnableDelayedExpansion

:: Change to script directory to ensure consistent path handling
cd /d "%~dp0"

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Starting Migration Summary >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Initialize phase status
set PHASE1_STATUS=NOT STARTED
set PHASE2_STATUS=NOT STARTED
set PHASE3_STATUS=NOT STARTED
set OVERALL_STATUS=NOT STARTED

echo.
echo ================================================
echo Phase Status Check
echo ================================================
echo.

:: Phase 1: Check authentication status
echo Checking Phase 1: CLI Setup and Authentication...
if exist "%~dp0verify_auth.bat" (
    call "%~dp0verify_auth.bat" >nul 2>&1
    set PHASE1_RESULT=%errorlevel%
    if %PHASE1_RESULT% equ 0 (
        echo [COMPLETE] Phase 1: CLI Setup and Authentication
        set PHASE1_STATUS=COMPLETE
        echo %date% %time% - Phase 1 status: COMPLETE >> "%LOG_PATH%"
    ) else (
        echo [INCOMPLETE] Phase 1: CLI Setup and Authentication
        set PHASE1_STATUS=INCOMPLETE
        echo %date% %time% - Phase 1 status: INCOMPLETE >> "%LOG_PATH%"
    )
) else (
    echo [NOT STARTED] Phase 1: CLI Setup and Authentication
    set PHASE1_STATUS=NOT STARTED
    echo %date% %time% - Phase 1 status: NOT STARTED >> "%LOG_PATH%"
)

:: Phase 2: Check project linking status
echo Checking Phase 2: Project Linking and Connection...
supabase status > temp_phase2_check.txt 2>&1
set PHASE2_RESULT=%errorlevel%
if %PHASE2_RESULT% equ 0 (
    echo [COMPLETE] Phase 2: Project Linking and Connection
    set PHASE2_STATUS=COMPLETE
    echo %date% %time% - Phase 2 status: COMPLETE >> "%LOG_PATH%"
) else (
    echo [INCOMPLETE] Phase 2: Project Linking and Connection
    set PHASE2_STATUS=INCOMPLETE
    echo %date% %time% - Phase 2 status: INCOMPLETE >> "%LOG_PATH%"
)
if exist temp_phase2_check.txt del temp_phase2_check.txt

:: Phase 3: Check migration status
echo Checking Phase 3: Migration Push and Verification...
if %PHASE2_RESULT% equ 0 (
    supabase db remote exec --query "SELECT COUNT(*)::int FROM information_schema.tables WHERE table_schema = 'public';" > temp_phase3_check.txt 2>&1
    set PHASE3_CHECK_RESULT=%errorlevel%
    if %PHASE3_CHECK_RESULT% equ 0 (
        for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_phase3_check.txt') do set TABLE_COUNT=%%i
        if !TABLE_COUNT! geq 27 (
            echo [COMPLETE] Phase 3: Migration Push and Verification
            set PHASE3_STATUS=COMPLETE
            echo !date! !time! - Phase 3 status: COMPLETE >> "%LOG_PATH%"
        ) else if !TABLE_COUNT! gtr 0 (
            echo [INCOMPLETE] Phase 3: Migration Push and Verification
            set PHASE3_STATUS=INCOMPLETE
            echo !date! !time! - Phase 3 status: INCOMPLETE >> "%LOG_PATH%"
        ) else (
            echo [NOT STARTED] Phase 3: Migration Push and Verification
            set PHASE3_STATUS=NOT STARTED
            echo !date! !time! - Phase 3 status: NOT STARTED >> "%LOG_PATH%"
        )
    ) else (
        echo [INCOMPLETE] Phase 3: Migration Push and Verification
        set PHASE3_STATUS=INCOMPLETE
        echo !date! !time! - Phase 3 status: INCOMPLETE >> "%LOG_PATH%"
    )
    if exist temp_phase3_check.txt del temp_phase3_check.txt
    
    :: Additional migration order verification if Phase 3 is complete
    if !TABLE_COUNT! geq 27 (
        echo Verifying migration order...
        set MIGRATION_ORDER_CORRECT=1
        set EXPECTED_MIGRATIONS=20240101000001_create_core_schema.sql 20240101000002_create_service_reports_schema.sql 20240101000003_create_rls_policies.sql 20240101000004_seed_lookup_data.sql
        set PREVIOUS_TIMESTAMP=
        
        for %%M in (!EXPECTED_MIGRATIONS!) do (
            supabase db remote exec --query "SELECT CASE WHEN EXISTS (SELECT 1 FROM supabase_migrations.schema_migrations WHERE version = '%%M') THEN 1 ELSE 0 END;" > temp_migration_check.txt 2>&1
            set MIGRATION_CHECK_RESULT=!errorlevel!
            if %MIGRATION_CHECK_RESULT% equ 0 (
                for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_migration_check.txt') do set MIGRATION_EXISTS=%%i
                if !MIGRATION_EXISTS! equ 1 (
                    :: Get timestamp for order verification
                    supabase db remote exec --query "SELECT EXTRACT(EPOCH FROM applied_at)::int FROM supabase_migrations.schema_migrations WHERE version = '%%M';" > temp_timestamp_check.txt 2>&1
                    set TIMESTAMP_CHECK_RESULT=!errorlevel!
                    if %TIMESTAMP_CHECK_RESULT% equ 0 (
                        for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_timestamp_check.txt') do set MIGRATION_TIMESTAMP=%%i
                        
                        if defined PREVIOUS_TIMESTAMP (
                            if !MIGRATION_TIMESTAMP! lss !PREVIOUS_TIMESTAMP! (
                                set MIGRATION_ORDER_CORRECT=0
                            )
                        )
                        set PREVIOUS_TIMESTAMP=!MIGRATION_TIMESTAMP!
                    )
                ) else (
                    set MIGRATION_ORDER_CORRECT=0
                )
            )
            if exist temp_migration_check.txt del temp_migration_check.txt
            if exist temp_timestamp_check.txt del temp_timestamp_check.txt
        )
        
        if !MIGRATION_ORDER_CORRECT! equ 1 (
            echo [SUCCESS] Migration order verified
            echo !date! !time! - Migration order correct >> "%LOG_PATH%"
        ) else (
            echo [WARNING] Migration order issues detected
            echo !date! !time! - Migration order issues >> "%LOG_PATH%"
        )
    )
) else (
    echo [NOT STARTED] Phase 3: Migration Push and Verification
    set PHASE3_STATUS=NOT STARTED
    echo !date! !time! - Phase 3 status: NOT STARTED >> "%LOG_PATH%"
)

:: Determine overall status
if "%PHASE1_STATUS%"=="COMPLETE" if "%PHASE2_STATUS%"=="COMPLETE" if "%PHASE3_STATUS%"=="COMPLETE" (
    set OVERALL_STATUS=COMPLETE
) else if "%PHASE1_STATUS%"=="NOT STARTED" (
    set OVERALL_STATUS=NOT STARTED
) else (
    set OVERALL_STATUS=IN PROGRESS
)

echo.
echo ================================================
echo Migration Statistics
echo ================================================
echo.

:: Migration file statistics
echo Migration Files:
if exist "%~dp0migrations" (
    for /f %%i in ('dir /b "%~dp0migrations\*.sql" 2^>nul ^| find /c /v ""') do set MIGRATION_FILES_COUNT=%%i
    echo   Migration files found: !MIGRATION_FILES_COUNT!/4
    echo !date! !time! - Migration files: !MIGRATION_FILES_COUNT!/4 >> "%LOG_PATH%"
    
    if !MIGRATION_FILES_COUNT! equ 4 (
        echo   [SUCCESS] All migration files present
    ) else (
        echo   [WARNING] Some migration files missing
    )
) else (
    echo   [ERROR] migrations directory not found
    echo %date% %time% - ERROR: migrations directory not found >> "%LOG_PATH%"
)

:: Database statistics (if Phase 2 is complete)
if "%PHASE2_STATUS%"=="COMPLETE" (
    echo.
    echo Database Statistics:
    
    if "%PHASE3_STATUS%"=="COMPLETE" (
        :: Count tables
        supabase db remote exec --query "SELECT COUNT(*)::int FROM information_schema.tables WHERE table_schema = 'public';" > temp_db_stats.txt 2>&1
        set DB_STATS_RESULT=!errorlevel!
        if %DB_STATS_RESULT% equ 0 (
            for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_db_stats.txt') do set TABLE_COUNT=%%i
            echo   Tables created: !TABLE_COUNT!/27
            echo !date! !time! - Database tables: !TABLE_COUNT!/27 >> "%LOG_PATH%"
        )
        
        :: Count policies
        supabase db remote exec --query "SELECT COUNT(*)::int FROM pg_policies WHERE schemaname = 'public';" > temp_db_stats.txt 2>&1
        set POLICY_STATS_RESULT=!errorlevel!
        if %POLICY_STATS_RESULT% equ 0 (
            for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_db_stats.txt') do set POLICY_COUNT=%%i
            echo   RLS policies: !POLICY_COUNT!/50+
            echo !date! !time! - RLS policies: !POLICY_COUNT! >> "%LOG_PATH%"
        )
        
        :: Count functions
        supabase db remote exec --query "SELECT COUNT(*)::int FROM pg_proc WHERE pronamespace = 'public'::regnamespace AND proname NOT LIKE 'pg_%';" > temp_db_stats.txt 2>&1
        set FUNCTION_STATS_RESULT=!errorlevel!
        if %FUNCTION_STATS_RESULT% equ 0 (
            for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_db_stats.txt') do set FUNCTION_COUNT=%%i
            echo   Functions: !FUNCTION_COUNT!/6
            echo !date! !time! - Functions: !FUNCTION_COUNT! >> "%LOG_PATH%"
        )
        
        :: Count triggers
        supabase db remote exec --query "SELECT COUNT(*)::int FROM pg_trigger WHERE tgisinternal = false;" > temp_db_stats.txt 2>&1
        set TRIGGER_STATS_RESULT=!errorlevel!
        if %TRIGGER_STATS_RESULT% equ 0 (
            for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_db_stats.txt') do set TRIGGER_COUNT=%%i
            echo   Triggers: !TRIGGER_COUNT!/12+
            echo !date! !time! - Triggers: !TRIGGER_COUNT! >> "%LOG_PATH%"
        )
        
        :: Count types
        supabase db remote exec --query "SELECT COUNT(*)::int FROM pg_type WHERE typtype = 'e' AND typnamespace = 'public'::regnamespace;" > temp_db_stats.txt 2>&1
        set TYPE_STATS_RESULT=!errorlevel!
        if %TYPE_STATS_RESULT% equ 0 (
            for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_db_stats.txt') do set TYPE_COUNT=%%i
            echo   Custom types: !TYPE_COUNT!/8
            echo !date! !time! - Custom types: !TYPE_COUNT! >> "%LOG_PATH%"
        )
        
        if exist temp_db_stats.txt del temp_db_stats.txt
    ) else (
        echo   Database not yet migrated
    )
)

echo.
echo ================================================
echo Project Information
echo ================================================
echo.

:: Project details
echo Project Details:
echo   Project reference: tzmpwqiaqalrdwdslmkx
echo   Region: ap-southeast-1
echo   Database: PostgreSQL 15

:: Database status
if "%PHASE2_STATUS%"=="COMPLETE" (
    echo.
    echo Database Status:
    supabase status > temp_project_status.txt 2>&1
    set PROJECT_STATUS_RESULT=!errorlevel!
    if %PROJECT_STATUS_RESULT% equ 0 (
        type temp_project_status.txt
    ) else (
        echo   [ERROR] Could not retrieve project status
    )
    if exist temp_project_status.txt del temp_project_status.txt
) else (
    echo   Database: Not connected (Phase 2 incomplete)
)

echo.
echo ================================================
echo File Inventory
echo ================================================
echo.

:: List migration files
echo Migration Files:
if exist "%~dp0migrations" (
    dir /b "%~dp0migrations\*.sql" 2>nul
    echo   Total: !MIGRATION_FILES_COUNT! files
) else (
    echo   [ERROR] migrations directory not found
)

:: List phase scripts
echo.
echo Phase Scripts:
if exist "%~dp0setup_cli.bat" echo   setup_cli.bat (Phase 1)
if exist "%~dp0link_project.bat" echo   link_project.bat (Phase 2)
if exist "%~dp0migrate_with_cli.bat" echo   migrate_with_cli.bat (Phase 3)

:: List verification scripts
echo.
echo Verification Scripts:
if exist "%~dp0verify_auth.bat" echo   verify_auth.bat (Phase 1)
if exist "%~dp0test_connection.bat" echo   test_connection.bat (Phase 2)
if exist "%~dp0verify_migration.bat" echo   verify_migration.bat (Phase 3)

:: List documentation
echo.
echo Documentation:
if exist "%~dp0PHASE1_CHECKLIST.md" echo   PHASE1_CHECKLIST.md
if exist "%~dp0PHASE2_CHECKLIST.md" echo   PHASE2_CHECKLIST.md
if exist "%~dp0PHASE3_CHECKLIST.md" echo   PHASE3_CHECKLIST.md
if exist "%~dp0CLI_TROUBLESHOOTING.md" echo   CLI_TROUBLESHOOTING.md
if exist "%~dp0README.md" echo   README.md
if exist "%~dp0MIGRATION_INSTRUCTIONS.md" echo   MIGRATION_INSTRUCTIONS.md

:: List test files
echo.
echo Test Files:
if exist "%~dp0test_queries.sql" echo   test_queries.sql

:: List log files
echo.
echo Log Files:
if exist "%~dp0CLI_SETUP_LOG.txt" echo   CLI_SETUP_LOG.txt

echo.
echo ================================================
echo Recent Activity
echo ================================================
echo.

:: Show recent log entries
echo Recent Log Entries (Last 10):
powershell -NoProfile -Command "Get-Content '%LOG_PATH%' | Select-Object -Last 10" 2>nul
set LOG_READ_RESULT=%errorlevel%
if %LOG_READ_RESULT% neq 0 (
    echo   [INFO] Could not read log file
)

echo.
echo ================================================
echo Verification Status
echo ================================================
echo.

:: Run verification if Phase 3 is complete
if "%PHASE3_STATUS%"=="COMPLETE" (
    echo Running automated verification...
    if exist "%~dp0verify_migration.bat" (
        call "%~dp0verify_migration.bat" >nul 2>&1
        set VERIFICATION_RESULT=!errorlevel!
        if !VERIFICATION_RESULT! equ 0 (
            echo   [SUCCESS] Migration verification passed
            echo !date! !time! - Verification: SUCCESS >> "%LOG_PATH%"
        ) else (
            echo   [FAILED] Migration verification failed
            echo !date! !time! - Verification: FAILED >> "%LOG_PATH%"
            echo.
            echo   Run verify_migration.bat for detailed results
        )
    ) else (
        echo   [ERROR] verify_migration.bat not found
    )
) else (
    echo   [INFO] Cannot verify - Phase 3 not complete
)

echo.
echo ================================================
echo Health Check
echo ================================================
echo.

:: Initialize health status
set HEALTH_STATUS=HEALTHY
set HEALTH_ISSUES=0

:: Check CLI installation
echo Checking CLI installation...
supabase --version >nul 2>&1
set CLI_VERSION_RESULT=!errorlevel!
if %CLI_VERSION_RESULT% equ 0 (
    echo   [PASS] Supabase CLI installed and accessible
) else (
    echo   [FAIL] Supabase CLI not found
    set /a HEALTH_ISSUES+=1
    set HEALTH_STATUS=ISSUES DETECTED
)

:: Check authentication
echo Checking authentication...
if "%PHASE1_STATUS%"=="COMPLETE" (
    echo   [PASS] Authentication working
) else (
    echo   [FAIL] Authentication issues detected
    set /a HEALTH_ISSUES+=1
    set HEALTH_STATUS=ISSUES DETECTED
)

:: Check project link
echo Checking project link...
if "%PHASE2_STATUS%"=="COMPLETE" (
    echo   [PASS] Project linked successfully
) else (
    echo   [FAIL] Project not linked
    set /a HEALTH_ISSUES+=1
    set HEALTH_STATUS=ISSUES DETECTED
)

:: Check migration
echo Checking migration...
if "%PHASE3_STATUS%"=="COMPLETE" (
    echo   [PASS] Migration completed
) else (
    echo   [FAIL] Migration not complete
    set /a HEALTH_ISSUES+=1
    set HEALTH_STATUS=ISSUES DETECTED
)

:: Check log file
echo Checking log file...
if exist "%LOG_PATH%" (
    echo   [PASS] Log file accessible
) else (
    echo   [FAIL] Log file not found
    set /a HEALTH_ISSUES+=1
    set HEALTH_STATUS=ISSUES DETECTED
)

echo.
echo Health Status: !HEALTH_STATUS!
if !HEALTH_ISSUES! gtr 0 (
    echo Issues detected: !HEALTH_ISSUES!
)

echo.
echo ================================================
echo Summary Report
echo ================================================
echo.

echo Migration Summary:
echo   Phase 1 (Authentication): %PHASE1_STATUS%
echo   Phase 2 (Project Linking): %PHASE2_STATUS%
echo   Phase 3 (Migration Push): %PHASE3_STATUS%
echo   Overall Status: %OVERALL_STATUS%

if "%PHASE3_STATUS%"=="COMPLETE" (
    echo.
    echo Migration Statistics:
    echo   Migration files: !MIGRATION_FILES_COUNT!/4
    if defined TABLE_COUNT echo   Tables created: !TABLE_COUNT!/27
    if defined POLICY_COUNT echo   RLS policies: !POLICY_COUNT!
    if defined FUNCTION_COUNT echo   Functions: !FUNCTION_COUNT!/6
    if defined TRIGGER_COUNT echo   Triggers: !TRIGGER_COUNT!
    if defined TYPE_COUNT echo   Custom types: !TYPE_COUNT!/8
)

echo.
echo Next Steps Guidance:
if "%PHASE1_STATUS%"=="NOT STARTED" (
    echo   1. Run setup_cli.bat to begin Phase 1
    echo   2. Complete CLI installation and authentication
    echo   3. Run verify_auth.bat to confirm success
) else if "%PHASE1_STATUS%"=="INCOMPLETE" (
    echo   1. Complete Phase 1 requirements
    echo   2. Run verify_auth.bat to identify issues
    echo   3. Check CLI_TROUBLESHOOTING.md Phase 1 section
) else if "%PHASE2_STATUS%"=="INCOMPLETE" (
    echo   1. Run link_project.bat to begin Phase 2
    echo   2. Complete project linking and verification
    echo   3. Check CLI_TROUBLESHOOTING.md Phase 2 section
) else if "%PHASE3_STATUS%"=="INCOMPLETE" (
    echo   1. Run migrate_with_cli.bat to begin Phase 3
    echo   2. Complete migration push and verification
    echo   3. Check CLI_TROUBLESHOOTING.md Phase 3 section
) else (
    echo   1. Migration complete! Test with your Flutter app
    echo   2. Configure Flutter app with Supabase credentials
    echo   3. Test authentication and CRUD operations
)

echo.
echo ================================================
echo Quick Links
echo ================================================
echo.

echo Resources:
echo   Supabase Dashboard: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx
echo   Table Editor: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx/editor
echo   SQL Editor: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx/sql
echo   Documentation: README.md, CLI_TROUBLESHOOTING.md
echo   Checklists: PHASE1_CHECKLIST.md, PHASE2_CHECKLIST.md, PHASE3_CHECKLIST.md

echo.
echo ================================================
echo Interactive Options
echo ================================================
echo.

echo Press a key to perform an action:
echo   1 - View detailed log
echo   2 - Run verification
echo   3 - View troubleshooting guide
echo   4 - Export summary to file
echo   5 - Exit
echo.

choice /c 12345 /n /m "Select an option: "

if errorlevel 5 (
    echo Exiting...
) else if errorlevel 4 (
    echo.
    echo Exporting summary to MIGRATION_SUMMARY.txt...
    (
        echo Supabase Migration Summary
        echo Generated: %date% %time%
        echo.
        echo Migration Summary:
        echo   Phase 1 (Authentication): %PHASE1_STATUS%
        echo   Phase 2 (Project Linking): %PHASE2_STATUS%
        echo   Phase 3 (Migration Push): %PHASE3_STATUS%
        echo   Overall Status: %OVERALL_STATUS%
        echo.
        echo Migration Statistics:
        echo   Migration files: !MIGRATION_FILES_COUNT!/4
        if defined TABLE_COUNT echo   Tables created: !TABLE_COUNT!/27
        if defined POLICY_COUNT echo   RLS policies: !POLICY_COUNT!
        if defined FUNCTION_COUNT echo   Functions: !FUNCTION_COUNT!/6
        if defined TRIGGER_COUNT echo   Triggers: !TRIGGER_COUNT!
        if defined TYPE_COUNT echo   Custom types: !TYPE_COUNT!/8
        echo.
        echo Health Status: !HEALTH_STATUS!
        if !HEALTH_ISSUES! gtr 0 echo Issues detected: !HEALTH_ISSUES!
        echo.
        echo Next Steps:
        if "%PHASE1_STATUS%"=="NOT STARTED" (
            echo   1. Run setup_cli.bat to begin Phase 1
        ) else if "%PHASE1_STATUS%"=="INCOMPLETE" (
            echo   1. Complete Phase 1 requirements
        ) else if "%PHASE2_STATUS%"=="INCOMPLETE" (
            echo   1. Run link_project.bat to begin Phase 2
        ) else if "%PHASE3_STATUS%"=="INCOMPLETE" (
            echo   1. Run migrate_with_cli.bat to begin Phase 3
        ) else (
            echo   1. Migration complete! Test with your Flutter app
        )
    ) > MIGRATION_SUMMARY.txt
    echo Summary exported to MIGRATION_SUMMARY.txt
) else if errorlevel 3 (
    echo.
    echo Opening troubleshooting guide...
    if exist "%~dp0CLI_TROUBLESHOOTING.md" (
        start "" "%~dp0CLI_TROUBLESHOOTING.md"
    ) else (
        echo [ERROR] CLI_TROUBLESHOOTING.md not found
    )
) else if errorlevel 2 (
    echo.
    echo Running verification...
    if exist "%~dp0verify_migration.bat" (
        call "%~dp0verify_migration.bat"
    ) else (
        echo [ERROR] verify_migration.bat not found
    )
) else if errorlevel 1 (
    echo.
    echo Displaying detailed log...
    if exist "%LOG_PATH%" (
        type "%LOG_PATH%"
    ) else (
        echo [ERROR] Log file not found
    )
)

echo.
echo ================================================
echo !date! !time! - Migration summary completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file location: %LOG_PATH%
echo.

exit /b 0