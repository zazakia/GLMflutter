# Phase 3: Migration Push and Verification Checklist

## Overview

Phase 3 focuses on pushing migration files to the remote database and verifying successful application of all schema changes, RLS policies, and seed data. This is the final phase of the three-phase migration process.

**Objective**: Execute database migrations and verify that all tables, functions, triggers, policies, and seed data are correctly created in the remote Supabase project.

## Prerequisites

Before starting Phase 3, verify the following requirements are met:

- [ ] **Phase 1 completed successfully**
  - Check: `setup_cli.bat` completed without errors
  - Check: `verify_auth.bat` returns success status
  - Required: Valid authentication token and API access

- [ ] **Phase 2 completed successfully**
  - Check: `link_project.bat` completed without errors
  - Check: `supabase status` shows project connection
  - Required: Project is linked and accessible

- [ ] **`verify_auth.bat` returns success status**
  - Check: Run `verify_auth.bat` and confirm "VERIFICATION SUCCESSFUL"
  - Required: Working API access to Supabase projects
  - Check: `CLI_SETUP_LOG.txt` shows successful authentication

- [ ] **`supabase status` shows active project connection**
  - Check: Run `supabase status` and verify all services are accessible
  - Required: Active connection to remote project
  - Check: API URL, Database URL, and Studio URL are displayed

- [ ] **Migration files exist in `migrations/` directory**
  - Check: 4 SQL files exist in migrations folder
  - Required: All migration files present and accessible
  - Check: Files are in correct chronological order

- [ ] **Database is active in Supabase dashboard (not paused)**
  - Check: Login to Supabase dashboard and verify database status
  - Required: Database must be running for migration operations
  - Check: No "Database is paused" message visible

- [ ] **User has sufficient permissions for DDL operations**
  - Check: User role is Owner, Admin, or Developer
  - Required: CREATE, ALTER, DROP permissions on database
  - Check: Can access SQL Editor in dashboard

- [ ] **No existing schema conflicts in target database**
  - Check: Database is clean or has compatible schema
  - Required: No conflicting tables or types
  - Check: Review existing objects if database not empty

- [ ] **Backup of existing data completed (if applicable)**
  - Check: Export existing data if database contains important information
  - Required: Safety measure before schema changes
  - Check: Backup file stored securely

## Pre-flight Checks

Complete these verification steps before running the Phase 3 script:

- [ ] **Phase 1 and Phase 2 completed and verified**
  - Action: Run `verify_auth.bat` and `supabase status`
  - Expected: Both commands execute successfully
  - Log: `CLI_SETUP_LOG.txt` shows successful Phase 1 and 2 completion

- [ ] **`verify_auth.bat` returns success**
  - Check: Exit code 0 from verification script
  - Expected: "VERIFICATION SUCCESSFUL" message
  - If failed: Complete Phase 1 before proceeding

- [ ] **`supabase status` shows active project connection**
  - Action: Run `supabase status` to verify link
  - Expected: All service URLs displayed without errors
  - If failed: Complete Phase 2 before proceeding

- [ ] **Migration files exist: 4 SQL files in `migrations/` directory**
  - Action: List contents of migrations folder
  - Expected: 4 files with correct names and timestamps
  - If missing: Verify all migration files are present

- [ ] **Database is active in Supabase dashboard (not paused)**
  - Action: Login to Supabase dashboard and check database status
  - Expected: "Database is active" indicator
  - If paused: Resume database from dashboard settings

- [ ] **User has Owner, Admin, or Developer role with DDL permissions**
  - Action: Check user role in Supabase dashboard
  - Expected: Sufficient permissions for database operations
  - If insufficient: Contact project owner for access

- [ ] **No existing schema conflicts in target database**
  - Action: Review existing tables in dashboard
  - Expected: Clean database or compatible schema
  - If conflicts: Consider using fresh database

- [ ] **Backup of existing data completed (if applicable)**
  - Action: Export data if database contains important information
  - Expected: Backup file created and verified
  - If needed: Complete backup before proceeding

## Migration File Verification

Verify that all migration files are present and correctly formatted:

- [ ] **Run `migrate_with_cli.bat` script (Step 1: File verification)**
  - Action: Execute the Phase 3 migration script
  - Location: `supabase\migrate_with_cli.bat`
  - Expected: Script starts and displays Phase 3 banner

- [ ] **Script confirms migrations directory exists**
  - Check: "[SUCCESS] migrations directory found" message
  - Expected: Directory is accessible and contains SQL files
  - If missing: Create migrations directory with SQL files

- [ ] **All 4 migration files detected**
  - Action: Script lists all migration files found
  - Expected: All files listed without errors
  - Check: File names match expected migration files

- [ ] **`20240101000001_create_core_schema.sql` (Core schema)**
  - Check: File exists and is readable
  - Expected: Creates 21 core tables, types, functions, triggers
  - Content: Organizations, users, job orders, inventory, etc.

- [ ] **`20240101000002_create_service_reports_schema.sql` (Service reports)**
  - Check: File exists and is readable
  - Expected: Creates 6 service report tables and functions
  - Content: Service reports, problem causes, job tasks

- [ ] **`20240101000003_create_rls_policies.sql` (RLS policies)**
  - Check: File exists and is readable
  - Expected: Creates 50+ security policies and helper functions
  - Content: Row Level Security for multi-tenant isolation

- [ ] **`20240101000004_seed_lookup_data.sql` (Seed data)**
  - Check: File exists and is readable
  - Expected: Inserts lookup data and demo organization
  - Content: Problem causes, job tasks, demo data

- [ ] **Migration files are in correct chronological order**
  - Check: File timestamps follow sequence 1-4
  - Expected: Proper order for dependency resolution
  - If out of order: Rename files to correct sequence

- [ ] **No SQL syntax errors in migration files**
  - Check: Files can be opened without encoding issues
  - Expected: Clean SQL syntax throughout
  - If errors: Review and fix syntax issues

## Migration Push Steps

Execute the migration push process:

- [ ] **Script executes `supabase db push` command**
  - Check: "Running: supabase db push" message displayed
  - Expected: Command starts without immediate errors
  - If fails: Check connection and permissions

- [ ] **Migration push starts without immediate errors**
  - Check: No syntax or connection errors at startup
  - Expected: Migration process begins execution
  - If errors: Review specific error messages

- [ ] **Core schema migration applies successfully**
  - Check: First migration completes without errors
  - Expected: 21 tables, 8 types, functions created
  - Log: Success message in `CLI_SETUP_LOG.txt`

- [ ] **Service reports schema migration applies successfully**
  - Check: Second migration completes without errors
  - Expected: 6 tables, functions, indexes created
  - Log: Success message in `CLI_SETUP_LOG.txt`

- [ ] **RLS policies migration applies successfully**
  - Check: Third migration completes without errors
  - Expected: 50+ policies, helper functions created
  - Log: Success message in `CLI_SETUP_LOG.txt`

- [ ] **Seed data migration applies successfully**
  - Check: Fourth migration completes without errors
  - Expected: 44 causes, 21 tasks, demo data inserted
  - Log: Success message in `CLI_SETUP_LOG.txt`

- [ ] **No SQL errors reported during push**
  - Check: Clean execution without SQL exceptions
  - Expected: All migrations complete successfully
  - If errors: Review specific SQL error messages

- [ ] **Script reports "[SUCCESS] Migration push completed successfully"**
  - Check: Clear success message from migration script
  - Expected: All 4 migrations applied
  - Log: Success entry in `CLI_SETUP_LOG.txt`

- [ ] **All migrations logged to `CLI_SETUP_LOG.txt`**
  - Check: Detailed log entries for each migration
  - Expected: Timestamps and success/failure status
  - If missing: Check log file permissions

## Post-Migration Verification Steps

Verify that the migration was applied correctly:

- [ ] **Run `verify_migration.bat` to test schema**
  - Action: Execute the post-migration verification script
  - Location: `supabase\verify_migration.bat`
  - Expected: Comprehensive verification of all components

- [ ] **Core tables created: organizations, branches, user_profiles, job_orders, etc.**
  - Check: All 21 core tables exist
  - Expected: Table structure matches migration definitions
  - If missing: Review core schema migration

- [ ] **Service reports tables created: service_reports, problem_causes, job_tasks**
  - Check: All 6 service report tables exist
  - Expected: Tables with proper relationships
  - If missing: Review service reports schema migration

- [ ] **RLS policies enabled on all tables**
  - Check: Row Level Security is enabled
  - Expected: All tables have RLS enabled
  - If disabled: Review RLS policies migration

- [ ] **Helper functions created: is_org_member, user_org_role, can_access_job**
  - Check: Security helper functions exist
  - Expected: Functions return correct results
  - If missing: Review RLS policies migration

- [ ] **Triggers created: update_updated_at_column, generate_service_report_number**
  - Check: Automated triggers are functional
  - Expected: Timestamps and numbering work correctly
  - If missing: Review schema migrations for trigger definitions

- [ ] **Seed data populated: problem_causes (44 rows), job_tasks (21 rows)**
  - Check: Lookup tables contain expected data
  - Expected: Correct row counts and content
  - If empty: Review seed data migration

- [ ] **Demo organization and branch created**
  - Check: Demo company exists in organizations table
  - Expected: "Demo Company" with main branch
  - If missing: Review seed data migration

- [ ] **Demo inventory items created (8 items)**
  - Check: Sample inventory items exist
  - Expected: Services and parts with pricing
  - If missing: Review seed data migration

## Dashboard Verification Steps

Verify the migration in the Supabase Dashboard:

- [ ] **Login to Supabase Dashboard at https://supabase.com/dashboard**
  - Action: Navigate to Supabase dashboard and login
  - Expected: Access to project dashboard
  - If denied: Check user credentials and permissions

- [ ] **Navigate to project: tzmpwqiaqalrdwdslmkx**
  - Action: Select the correct project from dashboard
  - Expected: Project loads without errors
  - If not found: Verify project reference

- [ ] **Open Table Editor and verify tables exist**
  - Action: Navigate to Table Editor section
  - Expected: List of all 27 tables visible
  - If missing: Check migration completion

- [ ] **Check organizations table has demo data**
  - Action: Open organizations table and browse data
  - Expected: "Demo Company" record present
  - If empty: Review seed data migration

- [ ] **Check problem_causes table has 44 rows**
  - Action: Open problem_causes table and count rows
  - Expected: 44 problem cause entries
  - If incorrect: Review seed data migration

- [ ] **Check job_tasks table has 21 rows**
  - Action: Open job_tasks table and count rows
  - Expected: 21 job task entries
  - If incorrect: Review seed data migration

- [ ] **Check inventory_items table has 8 demo items**
  - Action: Open inventory_items table and browse data
  - Expected: 8 inventory items with pricing
  - If empty: Review seed data migration

- [ ] **Open Database > Policies and verify RLS policies exist**
  - Action: Navigate to Database > Policies section
  - Expected: 50+ policies listed for all tables
  - If missing: Review RLS policies migration

- [ ] **Open Database > Functions and verify helper functions exist**
  - Action: Navigate to Database > Functions section
  - Expected: Security helper functions listed
  - If missing: Review RLS policies migration

- [ ] **Open Database > Triggers and verify triggers exist**
  - Action: Navigate to Database > Triggers section
  - Expected: Update triggers for timestamp columns
  - If missing: Review schema migrations

## Sample Query Testing

Test the migration with sample queries:

- [ ] **Run `test_queries.sql` in SQL Editor**
  - Action: Copy contents to SQL Editor and execute
  - Location: `supabase\test_queries.sql`
  - Expected: All queries execute without errors

- [ ] **Query 1: Select from organizations returns demo company**
  - Check: `SELECT * FROM organizations WHERE name = 'Demo Company'`
  - Expected: One row with demo organization data
  - If empty: Review seed data migration

- [ ] **Query 2: Select from problem_causes returns 44 rows**
  - Check: `SELECT COUNT(*) FROM problem_causes`
  - Expected: Count of 44
  - If incorrect: Review seed data migration

- [ ] **Query 3: Select from job_tasks returns 21 rows**
  - Check: `SELECT COUNT(*) FROM job_tasks`
  - Expected: Count of 21
  - If incorrect: Review seed data migration

- [ ] **Query 4: Select from inventory_items returns 8 items**
  - Check: `SELECT COUNT(*) FROM inventory_items`
  - Expected: Count of 8
  - If incorrect: Review seed data migration

- [ ] **Query 5: Test RLS helper functions work correctly**
  - Check: Test functions with appropriate parameters
  - Expected: Functions return expected boolean values
  - If errors: Review RLS policies migration

- [ ] **Query 6: Verify triggers are functional**
  - Check: Update a record and check timestamp changes
  - Expected: updated_at column updates automatically
  - If not working: Review trigger definitions

- [ ] **All queries execute without errors**
  - Check: No SQL exceptions or permission errors
  - Expected: Clean execution of all test queries
  - If errors: Review specific error messages

## Troubleshooting Reference

Use these resources if issues occur during Phase 3:

### Quick Links
- **Phase 3 Troubleshooting**: `CLI_TROUBLESHOOTING.md` Phase 3 section
- **Log File Location**: `CLI_SETUP_LOG.txt`
- **Migration Verification**: `verify_migration.bat`
- **Sample Queries**: `test_queries.sql`
- **Supabase Dashboard SQL Editor**: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx/sql

### Common Issues and Solutions

1. **"SQL syntax error" Error**
   - Solution: Review the specific migration file mentioned in error
   - Check: Missing semicolons, incorrect PostgreSQL syntax
   - Reference: Migration files in `migrations/` directory

2. **"Permission denied" Error**
   - Solution: Verify user role in Supabase dashboard
   - Check: Owner, Admin, or Developer role with DDL permissions
   - Reference: Supabase Dashboard > Settings > Database > Roles

3. **"Migration conflict" Error**
   - Solution: Check for existing schema objects
   - Check: "relation already exists" or "type already exists" errors
   - Reference: Supabase Dashboard > Database > Tables

4. **"Database paused" Error**
   - Solution: Resume database from Supabase dashboard
   - Check: Free tier auto-pause after inactivity
   - Reference: Supabase Dashboard > Settings > General

5. **"Partial migration failure" Error**
   - Solution: Check which migration failed in log
   - Check: Apply remaining migrations manually if needed
   - Reference: `CLI_SETUP_LOG.txt` for detailed error information

## Sign-off

Complete this section to confirm Phase 3 completion:

- [ ] **All checks passed**
  - Verification: Review all checkboxes above
  - Requirement: All critical items checked and successful

- [ ] **All 4 migrations applied successfully**
  - Confirmation: Migration script completed without errors
  - Verification: `CLI_SETUP_LOG.txt` shows success for all migrations

- [ ] **Schema verified in dashboard**
  - Confirmation: All tables, policies, functions visible in dashboard
  - Verification: Manual checks of database objects

- [ ] **Sample queries executed successfully**
  - Confirmation: All test queries return expected results
  - Verification: No SQL errors during testing

- [ ] **Ready for Flutter app integration**
  - Confirmation: Database is ready for application connection
  - Next step: Configure Flutter app with Supabase credentials

- **Date and time of completion**: ________________________
- **Completed by**: ______________________________________

## Common Failure Points

Be aware of these typical issues where users encounter problems:

### 1. SQL Syntax Errors
- **Symptom**: Migration fails with SQL parsing errors
- **Quick Fix**: Review specific migration file for syntax issues
- **Reference: CLI_TROUBLESHOOTING.md** Phase 3 section

### 2. Database Permission Issues
- **Symptom**: "Permission denied" during DDL operations
- **Quick Fix**: Verify user role and DDL permissions
- **Reference: CLI_TROUBLESHOOTING.md** permission section

### 3. Schema Conflicts
- **Symptom**: "relation already exists" errors
- **Quick Fix**: Drop conflicting objects or use clean database
- **Reference: CLI_TROUBLESHOOTING.md** migration conflict section

### 4. Database Paused (Free Tier)
- **Symptom**: Connection errors, timeout during migration
- **Quick Fix**: Resume database from Supabase dashboard
- **Reference: CLI_TROUBLESHOOTING.md** database status section

### 5. Network Interruption
- **Symptom**: Migration fails partway through
- **Quick Fix**: Check connection, retry migration
- **Reference: CLI_TROUBLESHOOTING.md** network section

## Next Steps

After completing Phase 3 successfully:

1. **Configure Flutter App**: Update `.env` file with Supabase URL and keys
2. **Test Authentication**: Verify login works from Flutter app
3. **Test CRUD Operations**: Verify create, read, update, delete operations
4. **Verify RLS Policies**: Test multi-tenant isolation works correctly
5. **Begin Application Development**: Start building app features

---

**Note**: If any step fails, document the issue in `CLI_SETUP_LOG.txt` and refer to `CLI_TROUBLESHOOTING.md` Phase 3 section before proceeding to Flutter app integration.