@echo off
echo ================================================
echo Supabase Migration Verification Script
echo ================================================
echo.
echo This script will verify that Phase 3 migrations were applied successfully
echo by testing the database schema, data, and functionality.
echo Results will be logged to CLI_SETUP_LOG.txt
echo.

:: Enable delayed expansion for proper variable handling in loops
setlocal EnableExtensions EnableDelayedExpansion

:: Change to script directory to ensure consistent path handling
cd /d "%~dp0"

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Starting Migration Verification >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Initialize verification status
set VERIFICATION_SUCCESS=1
set TABLES_VERIFIED=0
set RLS_VERIFIED=0
set FUNCTIONS_VERIFIED=0
set TRIGGERS_VERIFIED=0
set DATA_VERIFIED=0
set TYPES_VERIFIED=0
set INDEXES_VERIFIED=0

:: ================================================
:: SQL Helper Subroutine
:: ================================================
:RunSqlToNumber
:: Usage: Call :RunSqlToNumber "SQL_QUERY" OUTPUT_VARIABLE_NAME
:: Executes SQL query and captures numeric result into output variable
set SQL_QUERY=%~1
set OUTPUT_VAR=%~2

:: Initialize output variable to 0
set !OUTPUT_VAR!=0

:: Execute SQL query with tuples-only, unaligned mode for cleaner output
supabase db remote exec --query "%SQL_QUERY%" --tuples-only --no-align 2> temp_sql_error.txt > temp_sql_result.txt
set SQL_ERRORLEVEL=%errorlevel%

if %SQL_ERRORLEVEL% equ 0 (
    :: Extract numeric value from output, trim whitespace, and handle empty results
    for /f "tokens=*" %%i in ('type temp_sql_result.txt 2^>nul') do (
        set "RAW_VALUE=%%i"
        :: Trim leading/trailing whitespace
        for /f "tokens=* delims= " %%j in ("!RAW_VALUE!") do set "TRIMMED_VALUE=%%j"
        :: Check if trimmed value is numeric
        echo !TRIMMED_VALUE! | findstr "^[0-9][0-9]*$" >nul
        if !errorlevel! equ 0 (
            set !OUTPUT_VAR!=!TRIMMED_VALUE!
        )
    )
) else (
    :: Log error if SQL execution failed
    echo %date% %time% - SQL ERROR: %SQL_QUERY% >> "%LOG_PATH%"
    if exist temp_sql_error.txt (
        echo %date% %time% - SQL Error output: >> "%LOG_PATH%"
        type temp_sql_error.txt >> "%LOG_PATH%"
    )
)

:: Clean up temp files
if exist temp_sql_result.txt del temp_sql_result.txt
if exist temp_sql_error.txt del temp_sql_error.txt

goto :eof

:: ================================================
:: Main Script
:: ================================================

:: Collect environment information
echo %date% %time% - Collecting verification environment... >> "%LOG_PATH%"
echo Migration Verification Environment: >> "%LOG_PATH%"
echo Windows Version: >> "%LOG_PATH%"
ver >> "%LOG_PATH%" 2>&1
echo. >> "%LOG_PATH%"

echo.
echo Prerequisites Check: Verifying Phase 3 completion...
echo %date% %time% - Prerequisites check... >> "%LOG_PATH%"

:: Check if project is linked
echo Checking project link status...
supabase status > temp_verification_status.txt 2>&1
set LINK_CHECK_RESULT=%errorlevel%

if %LINK_CHECK_RESULT% neq 0 (
    echo [FAILED] Project is not linked or connection issues
    echo %date% %time% - ERROR: Project not linked for verification >> "%LOG_PATH%"
    echo.
    echo Please complete Phase 2 first:
    echo 1. Run link_project.bat to link to your Supabase project
    echo 2. Verify project connection with supabase status
    echo 3. Then run this verification script again
    echo.
    if exist temp_verification_status.txt del temp_verification_status.txt
    pause
    exit /b 1
) else (
    echo [SUCCESS] Project is linked and accessible
    echo %date% %time% - Project link verified >> "%LOG_PATH%"
)

if exist temp_verification_status.txt del temp_verification_status.txt

echo.
echo ================================================
echo Step 1: Table Existence Verification
echo ================================================
echo %date% %time% - Starting table verification... >> "%LOG_PATH%"

:: Check core tables
echo Verifying core tables...
set CORE_TABLES_FOUND=0

:: List of expected core tables (21 total)
set CORE_TABLES=organizations branches user_profiles organization_users job_orders job_order_assignments job_status_history job_items estimates estimate_items invoices invoice_items payments inventory_items inventory_stock_movements attachments messages schedules time_entries signatures event_log

for %%T in (%CORE_TABLES%) do (
    echo Checking table: %%T
    supabase db remote exec --query "SELECT CASE WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '%%T') THEN 1 ELSE 0 END;" > temp_table_check.txt 2>&1
    set TABLE_CHECK_RESULT=%errorlevel%
    if %TABLE_CHECK_RESULT% equ 0 (
        findstr "^1$" temp_table_check.txt >nul
        set TABLE_EXISTS_RESULT=%errorlevel%
        if %TABLE_EXISTS_RESULT% equ 0 (
            echo   [PASS] %%T table exists
            echo !date! !time! - [PASS] Table %%T exists >> "%LOG_PATH%"
            set /a CORE_TABLES_FOUND+=1
        ) else (
            echo   [FAIL] %%T table missing
            echo !date! !time! - [FAIL] Table %%T missing >> "%LOG_PATH%"
            set VERIFICATION_SUCCESS=0
        )
    ) else (
        echo   [ERROR] Could not verify %%T table
        echo %date% %time% - [ERROR] Could not verify table %%T >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
    )
)

:: Check service report tables
echo.
echo Verifying service report tables...
set SERVICE_TABLES_FOUND=0

set SERVICE_TABLES=service_reports service_report_causes service_report_tasks problem_causes job_tasks service_report_sequences

for %%T in (%SERVICE_TABLES%) do (
    echo Checking table: %%T
    supabase db remote exec --query "SELECT CASE WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '%%T') THEN 1 ELSE 0 END;" > temp_table_check.txt 2>&1
    set SERVICE_TABLE_CHECK_RESULT=%errorlevel%
    if %SERVICE_TABLE_CHECK_RESULT% equ 0 (
        findstr "^1$" temp_table_check.txt >nul
        set SERVICE_TABLE_EXISTS_RESULT=%errorlevel%
        if %SERVICE_TABLE_EXISTS_RESULT% equ 0 (
            echo   [PASS] %%T table exists
            echo !date! !time! - [PASS] Table %%T exists >> "%LOG_PATH%"
            set /a SERVICE_TABLES_FOUND+=1
        ) else (
            echo   [FAIL] %%T table missing
            echo !date! !time! - [FAIL] Table %%T missing >> "%LOG_PATH%"
            set VERIFICATION_SUCCESS=0
        )
    ) else (
        echo   [ERROR] Could not verify %%T table
        echo %date% %time% - [ERROR] Could not verify table %%T >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
    )
)

if exist temp_table_check.txt del temp_table_check.txt

set /a TOTAL_TABLES_FOUND=!CORE_TABLES_FOUND!+!SERVICE_TABLES_FOUND!
echo.
echo Tables Summary:
echo   Core tables found: !CORE_TABLES_FOUND!/21
echo   Service tables found: !SERVICE_TABLES_FOUND!/6
echo   Total tables found: !TOTAL_TABLES_FOUND!/27

if !TOTAL_TABLES_FOUND! geq 27 (
    echo   [SUCCESS] All expected tables found
    echo !date! !time! - [SUCCESS] All tables found (!TOTAL_TABLES_FOUND!/27) >> "%LOG_PATH%"
    set TABLES_VERIFIED=1
) else (
    echo   [FAIL] Some tables are missing
    echo !date! !time! - [FAIL] Missing tables (!TOTAL_TABLES_FOUND!/27) >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

echo.
echo ================================================
echo Step 1.5: Migration Order Verification
echo ================================================
echo %date% %time% - Starting migration order verification... >> "%LOG_PATH%"

echo Verifying migration history...
set MIGRATIONS_VERIFIED=1

:: Check if all expected migration files exist in the migration history table
echo Checking migration history for all 4 expected files...

:: First, verify the schema and column names
echo Verifying migration history table structure...
supabase db remote exec --query "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'supabase_migrations' AND table_name = 'schema_migrations' ORDER BY ordinal_position;" > temp_migration_schema.txt 2>&1
set SCHEMA_CHECK_RESULT=%errorlevel%

if %SCHEMA_CHECK_RESULT% equ 0 (
    echo %date% %time% - Migration history table schema verified >> "%LOG_PATH%"
) else (
    echo [ERROR] Could not verify migration history table structure
    echo %date% %time% - [ERROR] Migration history schema check failed >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

:: Expected migration files in order (using timestamp portion for version comparison)
set EXPECTED_MIGRATIONS=20240101000001 20240101000002 20240101000003 20240101000004

:: Verify each migration exists in history and is in correct order
set MIGRATION_ORDER_CORRECT=1
set PREVIOUS_TIMESTAMP=

for %%M in (%EXPECTED_MIGRATIONS%) do (
    echo Checking migration: %%M
    call :RunSqlToNumber "SELECT CASE WHEN EXISTS (SELECT 1 FROM supabase_migrations.schema_migrations WHERE version LIKE '%%M%%') THEN 1 ELSE 0 END;" MIGRATION_EXISTS
    
    if !MIGRATION_EXISTS! equ 1 (
        echo   [PASS] Migration %%M found in history
        echo !date! !time! - [PASS] Migration %%M found >> "%LOG_PATH%"
        
        :: Get applied timestamp for order verification
        call :RunSqlToNumber "SELECT EXTRACT(EPOCH FROM applied_at)::int FROM supabase_migrations.schema_migrations WHERE version LIKE '%%M%%' LIMIT 1;" MIGRATION_TIMESTAMP
        
        if defined PREVIOUS_TIMESTAMP (
            if !MIGRATION_TIMESTAMP! geq !PREVIOUS_TIMESTAMP! (
                echo   [PASS] Migration %%M in correct order
                echo !date! !time! - [PASS] Migration %%M in correct order >> "%LOG_PATH%"
            ) else (
                echo   [FAIL] Migration %%M out of order
                echo !date! !time! - [FAIL] Migration %%M out of order >> "%LOG_PATH%"
                set MIGRATION_ORDER_CORRECT=0
                set VERIFICATION_SUCCESS=0
            )
        )
        set PREVIOUS_TIMESTAMP=!MIGRATION_TIMESTAMP!
    ) else (
        echo   [FAIL] Migration %%M missing from history
        echo !date! !time! - [FAIL] Migration %%M missing >> "%LOG_PATH%"
        set MIGRATIONS_VERIFIED=0
        set VERIFICATION_SUCCESS=0
    )
)

if exist temp_migration_schema.txt del temp_migration_schema.txt

if !MIGRATIONS_VERIFIED! equ 1 (
    if !MIGRATION_ORDER_CORRECT! equ 1 (
        echo   [SUCCESS] All migrations present and in correct order
        echo !date! !time! - [SUCCESS] Migration order verified >> "%LOG_PATH%"
    ) else (
        echo   [FAIL] Migrations present but out of order
        echo !date! !time! - [FAIL] Migration order incorrect >> "%LOG_PATH%"
    )
) else (
    echo   [FAIL] Some migrations missing from history
    echo !date! !time! - [FAIL] Migration history incomplete >> "%LOG_PATH%"
)

echo.
echo ================================================
echo Step 2: RLS Policy Verification
echo ================================================
echo %date% %time% - Starting RLS policy verification... >> "%LOG_PATH%"

echo Verifying RLS policies on tables...
set RLS_ENABLED_COUNT=0
set POLICIES_COUNT=0

:: Check RLS enabled status
supabase db remote exec --query "SELECT COUNT(*)::int FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') AND EXISTS (SELECT 1 FROM pg_class WHERE relname = table_name AND relrowsecurity = true);" > temp_rls_check.txt 2>&1
set RLS_CHECK_RESULT=%errorlevel%

if %RLS_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_rls_check.txt') do set RLS_ENABLED_COUNT=%%i
    echo RLS enabled on !RLS_ENABLED_COUNT! tables
    echo !date! !time! - RLS enabled on !RLS_ENABLED_COUNT! tables >> "%LOG_PATH%"
    
    :: Compare RLS enabled count to expected base tables (27)
    if !RLS_ENABLED_COUNT! geq 27 (
        echo   [SUCCESS] RLS enabled on sufficient tables
        echo !date! !time! - [SUCCESS] RLS enabled on !RLS_ENABLED_COUNT!/27 tables >> "%LOG_PATH%"
        set RLS_TABLES_VERIFIED=1
    ) else (
        echo   [FAIL] RLS not enabled on enough tables
        echo !date! !time! - [FAIL] RLS only on !RLS_ENABLED_COUNT!/27 tables >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
        set RLS_TABLES_VERIFIED=0
    )
) else (
    echo [ERROR] Could not check RLS status
    echo %date% %time% - [ERROR] RLS check failed >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
    set RLS_TABLES_VERIFIED=0
)

:: Count total policies
supabase db remote exec --query "SELECT COUNT(*)::int FROM pg_policies WHERE schemaname = 'public';" > temp_policies_check.txt 2>&1
set POLICIES_CHECK_RESULT=%errorlevel%

if %POLICIES_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_policies_check.txt') do set POLICIES_COUNT=%%i
    echo Total RLS policies found: !POLICIES_COUNT!
    echo !date! !time! - Total RLS policies: !POLICIES_COUNT! >> "%LOG_PATH%"
    
    if !POLICIES_COUNT! geq 50 (
        echo   [SUCCESS] Sufficient RLS policies found
        echo !date! !time! - [SUCCESS] RLS policies verified (!POLICIES_COUNT!) >> "%LOG_PATH%"
        set RLS_POLICIES_VERIFIED=1
    ) else (
        echo   [FAIL] Insufficient RLS policies
        echo !date! %time% - [FAIL] Insufficient RLS policies (!POLICIES_COUNT!) >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
        set RLS_POLICIES_VERIFIED=0
    )
) else (
    echo [ERROR] Could not count RLS policies
    echo %date% %time% - [ERROR] Policy count failed >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
    set RLS_POLICIES_VERIFIED=0
)

:: Set RLS_VERIFIED only if both conditions are met
if !RLS_TABLES_VERIFIED! equ 1 if !RLS_POLICIES_VERIFIED! equ 1 (
    set RLS_VERIFIED=1
) else (
    set RLS_VERIFIED=0
)

if exist temp_rls_check.txt del temp_rls_check.txt
if exist temp_policies_check.txt del temp_policies_check.txt

echo.
echo ================================================
echo Step 3: Function Verification
echo ================================================
echo %date% %time% - Starting function verification... >> "%LOG_PATH%"

echo Verifying helper functions...
set FUNCTIONS_FOUND=0

set EXPECTED_FUNCTIONS=is_org_member user_org_role can_access_job update_updated_at_column generate_service_report_number calculate_service_report_totals

for %%F in (%EXPECTED_FUNCTIONS%) do (
    echo Checking function: %%F
    supabase db remote exec --query "SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = '%%F' AND pronamespace = 'public'::regnamespace) THEN 1 ELSE 0 END;" > temp_function_check.txt 2>&1
    set FUNCTION_CHECK_RESULT=%errorlevel%
    if %FUNCTION_CHECK_RESULT% equ 0 (
        findstr "^1$" temp_function_check.txt >nul
        set FUNCTION_EXISTS_RESULT=%errorlevel%
        if %FUNCTION_EXISTS_RESULT% equ 0 (
            echo   [PASS] Function %%F exists
            echo !date! !time! - [PASS] Function %%F exists >> "%LOG_PATH%"
            set /a FUNCTIONS_FOUND+=1
        ) else (
            echo   [FAIL] Function %%F missing
            echo !date! !time! - [FAIL] Function %%F missing >> "%LOG_PATH%"
            set VERIFICATION_SUCCESS=0
        )
    ) else (
        echo   [ERROR] Could not verify function %%F
        echo %date% %time% - [ERROR] Could not verify function %%F >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
    )
)

if exist temp_function_check.txt del temp_function_check.txt

echo.
echo Functions Summary:
echo   Functions found: !FUNCTIONS_FOUND!/6

if !FUNCTIONS_FOUND! geq 6 (
    echo   [SUCCESS] All expected functions found
    echo !date! !time! - [SUCCESS] All functions found (!FUNCTIONS_FOUND!/6) >> "%LOG_PATH%"
    set FUNCTIONS_VERIFIED=1
) else (
    echo   [FAIL] Some functions are missing
    echo !date! !time! - [FAIL] Missing functions (!FUNCTIONS_FOUND!/6) >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

echo.
echo ================================================
echo Step 4: Trigger Verification
echo ================================================
echo %date% %time% - Starting trigger verification... >> "%LOG_PATH%"

echo Verifying database triggers...
set TRIGGERS_FOUND=0

supabase db remote exec --query "SELECT COUNT(*)::int FROM pg_trigger WHERE tgisinternal = false;" > temp_triggers_check.txt 2>&1

set TRIGGERS_CHECK_RESULT=%errorlevel%
if %TRIGGERS_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_triggers_check.txt') do set TRIGGERS_FOUND=%%i
    echo Total triggers found: !TRIGGERS_FOUND!
    echo !date! !time! - Total triggers: !TRIGGERS_FOUND! >> "%LOG_PATH%"
    
    if !TRIGGERS_FOUND! geq 12 (
        echo   [SUCCESS] Sufficient triggers found
        echo !date! !time! - [SUCCESS] Triggers verified (!TRIGGERS_FOUND!) >> "%LOG_PATH%"
        set TRIGGERS_VERIFIED=1
    ) else (
        echo   [FAIL] Insufficient triggers found
        echo !date! !time! - [FAIL] Insufficient triggers (!TRIGGERS_FOUND!) >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
    )
) else (
    echo [ERROR] Could not count triggers
    echo %date% %time% - [ERROR] Trigger count failed >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

if exist temp_triggers_check.txt del temp_triggers_check.txt

echo.
echo ================================================
echo Step 5: Seed Data Verification
echo ================================================
echo %date% %time% - Starting seed data verification... >> "%LOG_PATH%"

echo Verifying seed data in lookup tables...

:: Check problem_causes
echo Checking problem_causes data...
supabase db remote exec --query "SELECT COUNT(*)::int FROM problem_causes;" > temp_data_check.txt 2>&1

set PROBLEM_CAUSES_CHECK_RESULT=%errorlevel%
if %PROBLEM_CAUSES_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_data_check.txt') do set PROBLEM_CAUSES_COUNT=%%i
    echo   Problem causes: !PROBLEM_CAUSES_COUNT! rows
    echo !date! !time! - Problem causes: !PROBLEM_CAUSES_COUNT! rows >> "%LOG_PATH%"
    
    if !PROBLEM_CAUSES_COUNT! geq 44 (
        echo   [PASS] Problem causes data correct
    ) else (
        echo   [FAIL] Problem causes data incomplete
        set VERIFICATION_SUCCESS=0
    )
) else (
    echo   [ERROR] Could not check problem_causes data
    set VERIFICATION_SUCCESS=0
)

:: Check job_tasks
echo Checking job_tasks data...
supabase db remote exec --query "SELECT COUNT(*)::int FROM job_tasks;" > temp_data_check.txt 2>&1

set JOB_TASKS_CHECK_RESULT=%errorlevel%
if %JOB_TASKS_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_data_check.txt') do set JOB_TASKS_COUNT=%%i
    echo   Job tasks: !JOB_TASKS_COUNT! rows
    echo !date! !time! - Job tasks: !JOB_TASKS_COUNT! rows >> "%LOG_PATH%"
    
    if !JOB_TASKS_COUNT! geq 21 (
        echo   [PASS] Job tasks data correct
    ) else (
        echo   [FAIL] Job tasks data incomplete
        set VERIFICATION_SUCCESS=0
    )
) else (
    echo   [ERROR] Could not check job_tasks data
    set VERIFICATION_SUCCESS=0
)

:: Check organizations
echo Checking organizations data...
supabase db remote exec --query "SELECT COUNT(*)::int FROM organizations WHERE name = 'Demo Company';" > temp_data_check.txt 2>&1

set ORG_CHECK_RESULT=%errorlevel%
if %ORG_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_data_check.txt') do set ORG_COUNT=%%i
    echo   Demo organization: !ORG_COUNT! rows
    echo !date! !time! - Demo organization: !ORG_COUNT! rows >> "%LOG_PATH%"
    
    if !ORG_COUNT! geq 1 (
        echo   [PASS] Demo organization exists
    ) else (
        echo   [FAIL] Demo organization missing
        set VERIFICATION_SUCCESS=0
    )
) else (
    echo   [ERROR] Could not check organizations data
    set VERIFICATION_SUCCESS=0
)

:: Check inventory_items
echo Checking inventory_items data...
supabase db remote exec --query "SELECT COUNT(*)::int FROM inventory_items;" > temp_data_check.txt 2>&1

set INVENTORY_CHECK_RESULT=%errorlevel%
if %INVENTORY_CHECK_RESULT% equ 0 (
    for /f "tokens=*" %%i in ('findstr "^[0-9][0-9]*$" temp_data_check.txt') do set INVENTORY_COUNT=%%i
    echo   Inventory items: !INVENTORY_COUNT! rows
    echo !date! !time! - Inventory items: !INVENTORY_COUNT! rows >> "%LOG_PATH%"
    
    if !INVENTORY_COUNT! geq 8 (
        echo   [PASS] Inventory items data correct
    ) else (
        echo   [FAIL] Inventory items data incomplete
        set VERIFICATION_SUCCESS=0
    )
) else (
    echo   [ERROR] Could not check inventory_items data
    set VERIFICATION_SUCCESS=0
)

if exist temp_data_check.txt del temp_data_check.txt

if !PROBLEM_CAUSES_COUNT! geq 44 if !JOB_TASKS_COUNT! geq 21 if !ORG_COUNT! geq 1 if !INVENTORY_COUNT! geq 8 (
    echo.
    echo   [SUCCESS] All seed data verified
    echo !date! !time! - [SUCCESS] All seed data verified >> "%LOG_PATH%"
    set DATA_VERIFIED=1
) else (
    echo.
    echo   [FAIL] Some seed data missing or incomplete
    echo !date! !time! - [FAIL] Seed data verification failed >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

echo.
echo ================================================
echo Step 6: Custom Type Verification
echo ================================================
echo %date% %time% - Starting custom type verification... >> "%LOG_PATH%"

echo Verifying custom ENUM types...
set TYPES_FOUND=0

set EXPECTED_TYPES=org_role job_status estimate_status invoice_status payment_method payment_status device_type signature_role

for %%T in (%EXPECTED_TYPES%) do (
    echo Checking type: %%T
    supabase db remote exec --query "SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = '%%T' AND typtype = 'e') THEN 1 ELSE 0 END;" > temp_type_check.txt 2>&1
    set TYPE_CHECK_RESULT=%errorlevel%
    if %TYPE_CHECK_RESULT% equ 0 (
        findstr "^1$" temp_type_check.txt >nul
        set TYPE_EXISTS_RESULT=%errorlevel%
        if %TYPE_EXISTS_RESULT% equ 0 (
            echo   [PASS] Type %%T exists
            echo !date! !time! - [PASS] Type %%T exists >> "%LOG_PATH%"
            set /a TYPES_FOUND+=1
        ) else (
            echo   [FAIL] Type %%T missing
            echo !date! !time! - [FAIL] Type %%T missing >> "%LOG_PATH%"
            set VERIFICATION_SUCCESS=0
        )
    ) else (
        echo   [ERROR] Could not verify type %%T
        echo %date% %time% - [ERROR] Could not verify type %%T >> "%LOG_PATH%"
        set VERIFICATION_SUCCESS=0
    )
)

if exist temp_type_check.txt del temp_type_check.txt

echo.
echo Types Summary:
echo   Custom types found: !TYPES_FOUND!/8

if !TYPES_FOUND! geq 8 (
    echo   [SUCCESS] All expected types found
    echo !date! !time! - [SUCCESS] All types found (!TYPES_FOUND!/8) >> "%LOG_PATH%"
    set TYPES_VERIFIED=1
) else (
    echo   [FAIL] Some types are missing
    echo !date! !time! - [FAIL] Missing types (!TYPES_FOUND!/8) >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

echo.
echo ================================================
echo Step 7: Index Verification
echo ================================================
echo %date% %time% - Starting index verification... >> "%LOG_PATH%"

echo Verifying database indexes...
set INDEXES_FOUND=0

call :RunSqlToNumber "SELECT COUNT(*)::int FROM pg_indexes WHERE schemaname = 'public';" INDEXES_FOUND
echo Total indexes found: !INDEXES_FOUND!
echo !date! !time! - Total indexes: !INDEXES_FOUND! >> "%LOG_PATH%"

if !INDEXES_FOUND! geq 20 (
    echo   [SUCCESS] Sufficient indexes found
    echo !date! !time! - [SUCCESS] Indexes verified (!INDEXES_FOUND!) >> "%LOG_PATH%"
    set INDEXES_VERIFIED=1
) else (
    echo   [FAIL] Insufficient indexes found
    echo !date! !time! - [FAIL] Insufficient indexes (!INDEXES_FOUND!) >> "%LOG_PATH%"
    set VERIFICATION_SUCCESS=0
)

if exist temp_indexes_check.txt del temp_indexes_check.txt

echo.
echo ================================================
echo Verification Summary
echo ================================================
echo.
echo %date% %time% - Generating verification summary... >> "%LOG_PATH%"

echo Migration Verification Results:
echo   Tables created: !TOTAL_TABLES_FOUND!/27
echo   RLS policies: !POLICIES_COUNT!/50+
echo   Functions: !FUNCTIONS_FOUND!/6
echo   Triggers: !TRIGGERS_FOUND!/12+
echo   Seed data: problem_causes(!PROBLEM_CAUSES_COUNT!), job_tasks(!JOB_TASKS_COUNT!), org(!ORG_COUNT!), inventory(!INVENTORY_COUNT!)
echo   Custom types: !TYPES_FOUND!/8
echo   Indexes: !INDEXES_FOUND!/20+

echo !date! !time! - Verification Summary: >> "%LOG_PATH%"
echo   Tables: !TOTAL_TABLES_FOUND!/27 >> "%LOG_PATH%"
echo   RLS policies: !POLICIES_COUNT! >> "%LOG_PATH%"
echo   Functions: !FUNCTIONS_FOUND!/6 >> "%LOG_PATH%"
echo   Triggers: !TRIGGERS_FOUND! >> "%LOG_PATH%"
echo   Seed data: PC=!PROBLEM_CAUSES_COUNT!, JT=!JOB_TASKS_COUNT!, ORG=!ORG_COUNT!, INV=!INVENTORY_COUNT! >> "%LOG_PATH%"
echo   Types: !TYPES_FOUND!/8 >> "%LOG_PATH%"
echo   Indexes: !INDEXES_FOUND! >> "%LOG_PATH%"

if !VERIFICATION_SUCCESS! equ 1 (
    echo.
    echo ================================================
    echo MIGRATION VERIFICATION SUCCESSFUL
    echo ================================================
    echo.
    echo All migration components have been verified successfully!
    echo Your database is ready for Flutter app integration.
    echo.
    echo Next steps:
    echo 1. Test with sample queries (test_queries.sql)
    echo 2. Configure Flutter app with Supabase credentials
    echo 3. Test authentication and CRUD operations
    echo.
    echo !date! !time! - OVERALL VERIFICATION: SUCCESS >> "%LOG_PATH%"
) else (
    echo.
    echo ================================================
    echo MIGRATION VERIFICATION FAILED
    echo ================================================
    echo.
    echo Some migration components could not be verified.
    echo Please review the issues above and take corrective action.
    echo.
    echo Troubleshooting:
    echo 1. Check CLI_SETUP_LOG.txt for detailed error information
    echo 2. Review CLI_TROUBLESHOOTING.md Phase 3 section
    echo 3. Manually verify in Supabase Dashboard
    echo 4. Re-run migration if necessary
    echo.
    echo !date! !time! - OVERALL VERIFICATION: FAILED >> "%LOG_PATH%"
)

echo.
echo ================================================
echo %date% %time% - Migration verification completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file saved to: %LOG_PATH%
echo.

:: Exit with appropriate code
if !VERIFICATION_SUCCESS! equ 1 (
    exit /b 0
) else (
    exit /b 1
)