# Manual Migration Instructions for Supabase

## Problem Identified and Fixed

The original issue was a **duplicate key constraint violation** in the `job_tasks` table:
- Error: `23505: duplicate key value violates unique constraint "job_tasks_code_key"`
- Cause: Two entries had the same code `'test_isolate_parts'` for different device scopes
- **FIXED**: Changed to `'test_isolate_parts_desktop'` and `'test_isolate_parts_printer'`

## Quick Solution: Run Migration Manually

### Option 1: Use Supabase SQL Editor (Recommended)

1. **Open your Supabase project**
   - Go to https://supabase.com/dashboard
   - Select your project: `tzmpwqiaqalrdwdslmkx`

2. **Open SQL Editor**
   - In the left sidebar, click "SQL Editor"
   - Click "New query"

3. **Copy and paste the entire content**
   - Open the file: [`combined_migration.sql`](combined_migration.sql)
   - Copy all the content (Ctrl+A, Ctrl+C)
   - Paste into the SQL Editor (Ctrl+V)

4. **Execute the migration**
   - Click the "Run" button (or press Ctrl+Enter)
   - Wait for the migration to complete

5. **Verify tables were created**
   - Go to "Table Editor" in the sidebar
   - You should see tables like: `organizations`, `job_orders`, `job_tasks`, etc.

### Option 2: Create RPC Function First

If you want to use the automated script:

1. **Create the exec_sql function** in SQL Editor:
```sql
CREATE OR REPLACE FUNCTION exec_sql(query TEXT) 
RETURNS TEXT 
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$
BEGIN 
  EXECUTE query; 
  RETURN 'SQL executed successfully'; 
END; 
$$;
```

2. **Run the migration script**:
```bash
cd supabase
dart run migrate_remote.dart
```

## What Was Fixed

### Duplicate Job Task Codes
- **Before**: Two entries with code `'test_isolate_parts'`
- **After**: 
  - `'test_isolate_parts_desktop'` for desktop/laptop tasks
  - `'test_isolate_parts_printer'` for printer tasks

### Files Modified
1. [`combined_migration.sql`](combined_migration.sql) - Fixed duplicate codes
2. [`20240101000004_seed_lookup_data.sql`](migrations/20240101000004_seed_lookup_data.sql) - Fixed source file
3. [`migrate_remote.dart`](migrate_remote.dart) - Added better error handling and logging

## Verification

After running the migration, you should have these tables:

### Core Tables
- `organizations` - Multi-tenant organizations
- `branches` - Organization branches
- `user_profiles` - User profiles linked to auth.users
- `organization_users` - Organization user mappings

### Job Management
- `job_orders` - Main job orders table
- `job_order_assignments` - Job assignments
- `job_status_history` - Status change tracking
- `job_items` - Services and parts for jobs

### Financial
- `estimates` - Job estimates
- `estimate_items` - Estimate line items
- `invoices` - Job invoices
- `invoice_items` - Invoice line items
- `payments` - Payment records

### Service Reports
- `service_reports` - Service report forms
- `service_report_causes` - Problem causes
- `service_report_tasks` - Job tasks performed
- `problem_causes` - Lookup table for causes
- `job_tasks` - Lookup table for tasks (FIXED)

### Other Tables
- `inventory_items` - Parts and services inventory
- `attachments` - File attachments
- `messages` - Job communications
- `schedules` - Technician schedules
- `time_entries` - Time tracking
- `signatures` - Digital signatures
- `event_log` - Audit trail

## Troubleshooting

If you still get errors:

1. **Check for existing tables**:
   - Go to Table Editor to see if some tables already exist
   - If so, you may need to drop them first

2. **Verify duplicate fix**:
   - The duplicate `'test_isolate_parts'` issue should be resolved
   - Check the `job_tasks` table for unique codes

3. **Check permissions**:
   - Make sure you're using the SERVICE_ROLE key
   - Verify your Supabase project URL is correct

## Next Steps

Once tables are created:
1. Your Flutter app should connect successfully
2. The authentication flow should work
3. You can create test data and verify functionality

The original Android simulator "crash" was actually this database migration error preventing the app from initializing properly.