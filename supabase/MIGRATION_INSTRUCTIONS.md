# Migration Instructions for Supabase

**Note**: This document describes the manual migration approach. For most users, we recommend using the automated CLI migration approach which is now available in three phases:
- Phase 1: CLI Setup and Authentication (`setup_cli.bat`)
- Phase 2: Project Linking and Verification (`link_project.bat`)
- Phase 3: Migration Push (`migrate_with_cli.bat`)

See `README.md` for the complete CLI migration workflow.

**Use manual migration if**:
- CLI migration encounters insurmountable issues
- You prefer direct SQL execution
- Corporate network blocks CLI access
- You need fine-grained control over migration steps

## Recommended Approach: CLI Migration

Before proceeding with manual migration, consider using the automated CLI approach:
1. Run `setup_cli.bat` for Phase 1 (authentication)
2. Run `link_project.bat` for Phase 2 (project linking)
3. Run `migrate_with_cli.bat` for Phase 3 (migration push)
4. Run `verify_migration.bat` to verify success

See `README.md` and phase-specific checklists for detailed guidance.

If CLI migration is not feasible, continue with the manual steps below.

## Prerequisites

Before you begin, ensure you have the following:

- Access to the Supabase Dashboard (https://supabase.com/dashboard)
- Your project reference: `tzmpwqiaqalrdwdslmkx`
- User role with DDL permissions (Owner, Admin, or Developer)
- Database is active (not paused)
- Backup of existing data if applicable

## Migration Order Explanation

**Important**: The migration scripts must be executed in the exact order shown below because:
1. Core schema creates base tables and types that other migrations depend on
2. Service reports schema references core tables via foreign keys
3. RLS policies reference tables and functions from previous migrations
4. Seed data inserts into tables created by previous migrations

Executing out of order will result in errors due to missing dependencies.

## Migration Steps

Follow these steps to manually migrate your database schema:

### Step 1: Access the Supabase Dashboard

1. Open your browser and navigate to: https://supabase.com/dashboard
2. Login with your Supabase account credentials
3. Select your project: `tzmpwqiaqalrdwdslmkx`
4. Navigate to the **SQL Editor** from the left sidebar

### Step 2: Execute the Migration Scripts

Execute the migration scripts in the exact order shown below. The order is important because each script depends on the previous one.

#### Migration 1: Core Schema (20240101000001)

1. Open the file `migrations/20240101000001_create_core_schema.sql`
2. Copy the entire content of the file
3. Paste it into the SQL Editor
4. Click **Run** to execute the script
5. Wait for the script to complete (should show "Success. No rows returned")

**What this creates:**
- 21 core tables for job order management
- 8 custom ENUM types
- Functions and triggers for automated timestamp updates
- Multi-tenant structure with organizations

**Expected execution time:** 30-60 seconds

#### Migration 2: Service Reports Schema (20240101000002)

1. Open the file `migrations/20240101000002_create_service_reports_schema.sql`
2. Copy the entire content of the file
3. Paste it into the SQL Editor
4. Click **Run** to execute the script
5. Wait for the script to complete (should show "Success. No rows returned")

**What this creates:**
- 6 service report tables
- Problem causes and job tasks lookup tables
- Service report numbering function
- Performance indexes

**Expected execution time:** 20-40 seconds

#### Migration 3: RLS Policies (20240101000003)

1. Open the file `migrations/20240101000003_create_rls_policies.sql`
2. Copy the entire content of the file
3. Paste it into the SQL Editor
4. Click **Run** to execute the script
5. Wait for the script to complete (should show "Success. No rows returned")

**What this creates:**
- Row Level Security policies for all tables
- Helper functions for multi-tenant isolation
- Security policies for data access control

**Expected execution time:** 40-80 seconds

#### Migration 4: Seed Data (20240101000004)

1. Open the file `migrations/20240101000004_seed_lookup_data.sql`
2. Copy the entire content of the file
3. Paste it into the SQL Editor
4. Click **Run** to execute the script
5. Wait for the script to complete (should show row counts)

**What this creates:**
- 44 problem causes
- 21 job tasks
- Demo organization and branch
- 8 demo inventory items

**Expected execution time:** 10-20 seconds

### Step 3: Verify the Migration

After executing all migration scripts, verify that the migration was successful:

### Automated Verification (Recommended)

If you have CLI access, run:
```bash
.\verify_migration.bat
```

### Manual Verification

#### 1. Check Table Count

Run this query in the SQL Editor:
```sql
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
```

Expected result: 27 tables

#### 2. Check Seed Data

Run these queries to verify seed data:
```sql
-- Check problem causes
SELECT COUNT(*) FROM problem_causes;
-- Expected: 44 rows

-- Check job tasks
SELECT COUNT(*) FROM job_tasks;
-- Expected: 21 rows
```

#### 3. Check RLS Policies

Navigate to **Database** > **Policies** in the Supabase Dashboard to verify that policies exist for all tables.
Expected: 50+ policies across all tables

#### 4. Check Functions

Navigate to **Database** > **Functions** to verify that helper functions exist:
- is_org_member
- user_org_role
- can_access_job
- update_updated_at_column
- generate_service_report_number
- calculate_service_report_totals

#### 5. Check Triggers

Navigate to **Database** > **Triggers** to verify that triggers exist:
Expected: 12+ triggers for updated_at columns and other functions

#### 6. Test Basic Queries

Run some basic queries to ensure everything is working:
```sql
-- Test organizations table
SELECT * FROM organizations WHERE name = 'Demo Company';

-- Test problem causes
SELECT * FROM problem_causes LIMIT 5;

-- Test job tasks
SELECT * FROM job_tasks WHERE device_scope = 'desktop_laptop' LIMIT 5;
```

#### 7. Sample Query Testing

Run comprehensive test queries:
1. Copy contents of `test_queries.sql`
2. Paste into SQL Editor
3. Execute queries and verify expected results
4. Check that all queries return expected row counts

### Step 4: Post-Migration Testing

After successful migration:

#### 1. Test Flutter App Connection
- Update `.env` file with Supabase credentials
- Run your Flutter app
- Verify connection to database works

#### 2. Test Authentication
- Create a test user in Supabase Dashboard
- Test login from Flutter app
- Verify RLS policies work correctly

#### 3. Test CRUD Operations
- Create a test organization
- Create a test job order
- Verify data appears in dashboard
- Test update and delete operations

#### 4. Verify Multi-Tenant Isolation
- Create multiple test organizations
- Verify users can only access their own organization's data
- Test RLS policies prevent cross-organization access

## Troubleshooting

If you encounter any issues during the migration:

### "relation already exists" Error
This occurs if tables already exist in your database. Solutions:
- Use a fresh database
- Manually drop existing tables before migration
- Use `DROP TABLE IF EXISTS` statements (CAUTION: data loss)

### "permission denied" Error
This occurs if your user doesn't have sufficient permissions. Solutions:
- Check your user role in the Supabase Dashboard
- Contact the project owner to upgrade your permissions
- Ensure you have DDL permissions (CREATE, ALTER, DROP)

### "syntax error" Messages
This occurs if there are SQL syntax issues. Solutions:
- Ensure you copied the entire SQL file without truncation
- Check for special characters that may have been corrupted during copy/paste
- Verify the SQL is compatible with PostgreSQL 15

### "database is paused" Error
This occurs on free tier databases that have been inactive. Solutions:
- Resume the database from the Supabase Dashboard
- Wait for the database to fully resume before retrying
- Consider upgrading to a paid tier to avoid auto-pause

### "Function or trigger creation failed" Error
This occurs if functions or triggers fail to create. Solutions:
- Verify PL/pgSQL syntax in function definitions
- Check if required extensions are enabled (uuid-ossp)
- Test function creation in SQL Editor separately
- Verify trigger function exists before creating trigger

### "RLS policy creation failed" Error
This occurs if RLS policies fail to create. Solutions:
- Verify all referenced functions exist (is_org_member, user_org_role, can_access_job)
- Check policy conditions for syntax errors
- Test policy expressions in SQL Editor
- Verify auth.uid() function is available

### "Seed data insertion failed" Error
This occurs if seed data fails to insert. Solutions:
- Check for foreign key constraint violations
- Verify UUID values are valid format
- Check for duplicate key violations
- Verify data types match table definitions

### Partial Migration Failure
If a script fails partway through:
1. Note which migration failed
2. Check the error message for specific issues
3. Fix the issue and continue with remaining migrations
4. Some migrations may need to be adjusted if previous ones partially succeeded

### Rollback Procedures
When to consider rollback vs. forward fixes:
- Rollback if migration failed early with minimal changes
- Forward fixes if migration is mostly successful
- Use manual completion if some migrations applied successfully

Order for dropping objects (reverse dependency order):
1. Drop seed data first
2. Drop functions and triggers
3. Drop tables in reverse order
4. Drop types and extensions

## Next Steps

After completing the migration:

1. **Verify Migration Success**:
   - Run `verify_migration.bat` for automated checks
   - Review `PHASE3_CHECKLIST.md` and complete all items
   - Test with `test_queries.sql` in Supabase Dashboard

2. **Configure Flutter App**:
   - Update `.env` file with Supabase URL and keys
   - Test connection from Flutter app
   - Verify authentication works

3. **Test Application Features**:
   - Test CRUD operations on all tables
   - Verify RLS policies work correctly
   - Test multi-tenant isolation
   - Verify triggers and functions work as expected

4. **Begin Development**:
   - Start building application features
   - Use demo organization for testing
   - Create additional test data as needed

## Tip: Even with Manual Migration

Even if you performed manual migration, you can still use the CLI verification tools:
- Run `verify_migration.bat` to automatically verify the schema
- Use `test_queries.sql` for comprehensive manual testing
- Check `CLI_TROUBLESHOOTING.md` Phase 3 section for common issues

## Notes

- The migration scripts are designed to be run in sequence
- Each script builds upon the previous one
- Do not skip any scripts unless you're sure they're not needed
- Always backup your data before running migrations in production
- The scripts are compatible with PostgreSQL 15
- All migrations include proper error handling and transaction support