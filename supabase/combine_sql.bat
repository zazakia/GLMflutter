@echo off
echo Combining SQL migration files...

REM Create the combined file header
echo -- COMBINED MIGRATION SCRIPT FOR SUPABASE > combined_migration.sql
echo -- This file contains all migration scripts in the correct order >> combined_migration.sql
echo -- Generated on %date% at %time% >> combined_migration.sql
echo. >> combined_migration.sql

REM Add each migration file with headers
echo -- ===================================================== >> combined_migration.sql
echo -- 1. CREATE CORE SCHEMA >> combined_migration.sql
echo -- ===================================================== >> combined_migration.sql
type migrations\20240101000001_create_core_schema.sql >> combined_migration.sql
echo. >> combined_migration.sql

echo -- ===================================================== >> combined_migration.sql
echo -- 2. CREATE SERVICE REPORTS SCHEMA >> combined_migration.sql
echo -- ===================================================== >> combined_migration.sql
type migrations\20240101000002_create_service_reports_schema.sql >> combined_migration.sql
echo. >> combined_migration.sql

echo -- ===================================================== >> combined_migration.sql
echo -- 3. CREATE RLS POLICIES >> combined_migration.sql
echo -- ===================================================== >> combined_migration.sql
type migrations\20240101000003_create_rls_policies.sql >> combined_migration.sql
echo. >> combined_migration.sql

echo -- ===================================================== >> combined_migration.sql
echo -- 4. SEED LOOKUP DATA >> combined_migration.sql
echo -- ===================================================== >> combined_migration.sql
type migrations\20240101000004_seed_lookup_data.sql >> combined_migration.sql

echo.
echo Combined migration script created: combined_migration.sql
echo You can now copy and paste this file into the Supabase SQL Editor.
pause