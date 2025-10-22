# Manual Migration Steps for Supabase

Since the MCP server is not available in this environment, here are the detailed steps to manually migrate your database using the Supabase Dashboard:

## Step 1: Access Your Supabase Project

1. Go to https://supabase.com/dashboard
2. Select your project with reference `tzmpwqiaqalrdwdslmkx`
3. Navigate to the SQL Editor from the left sidebar

## Step 2: Execute Migration 1 - Core Schema

1. Open `supabase/migrations/20240101000001_create_core_schema.sql` in a text editor
2. Copy the entire content
3. Paste it into the SQL Editor
4. Click "Run" to execute
5. Wait for the script to complete successfully (you should see a success message)

## Step 3: Execute Migration 2 - Service Reports Schema

1. Open `supabase/migrations/20240101000002_create_service_reports_schema.sql`
2. Copy the entire content
3. Paste it into the SQL Editor
4. Click "Run" to execute
5. Wait for the script to complete

## Step 4: Execute Migration 3 - RLS Policies

1. Open `supabase/migrations/20240101000003_create_rls_policies.sql`
2. Copy the entire content
3. Paste it into the SQL Editor
4. Click "Run" to execute
5. Wait for the script to complete

## Step 5: Execute Migration 4 - Seed Data

1. Open `supabase/migrations/20240101000004_seed_lookup_data.sql`
2. Copy the entire content
3. Paste it into the SQL Editor
4. Click "Run" to execute
5. Wait for the script to complete

## Step 6: Create Demo Admin User

1. Open `supabase/create_demo_user.sql`
2. Copy the entire content
3. Paste it into the SQL Editor
4. Click "Run" to execute
5. Wait for the script to complete

## Step 7: Set Demo User Password

1. Navigate to Authentication > Users in the Supabase Dashboard
2. Find the user with email `admin@demo-company.com`
3. Click on the user to expand details
4. Click "Reset Password"
5. Set the password to `demo123456`
6. Click "Save"

## Step 8: Verify the Migration

1. In the left sidebar, click on "Table Editor"
2. You should see all the tables listed:
   - organizations
   - branches
   - user_profiles
   - organization_users
   - job_orders
   - job_order_assignments
   - job_status_history
   - job_items
   - estimates
   - estimate_items
   - invoices
   - invoice_items
   - payments
   - inventory_items
   - inventory_stock_movements
   - attachments
   - messages
   - schedules
   - time_entries
   - signatures
   - event_log
   - service_reports
   - service_report_causes
   - service_report_tasks
   - problem_causes
   - job_tasks
   - service_report_sequences

3. Click on the `organizations` table to verify it has the demo company entry
4. Click on the `problem_causes` table to verify it has the lookup data
5. Click on the `user_profiles` table to verify the demo admin user was created

## Alternative: Use Combined Migration

If you prefer to run all migrations at once:

1. Open `supabase/combined_migration.sql`
2. Copy the entire content
3. Paste it into the SQL Editor
4. Click "Run" to execute
5. Wait for the script to complete (this might take a few minutes)

Then follow Steps 6-8 to create and configure the demo user.

## Troubleshooting

If you encounter any errors:

1. Check the error message in the SQL Editor
2. Ensure you're executing the scripts in the correct order
3. If a script fails, fix the issue before proceeding to the next one
4. You can drop individual tables if needed and re-run a migration

## Next Steps After Migration

1. Test the 1-click admin login in the Flutter app:
   - Run the app in debug mode (development mode)
   - Click the "1-Click Admin Login" button
   - It should log you in as admin@demo-company.com

2. Update your Flutter app's environment variables with the correct Supabase URL and keys
3. Test the app connection to the database
4. Verify authentication works correctly
5. Test basic CRUD operations

## Notes

- The migrations are designed to be run in sequence
- Each migration depends on the previous one
- The RLS policies ensure proper data isolation between organizations
- The seed data provides initial lookup values for service reports
- The demo user allows quick access for development and testing