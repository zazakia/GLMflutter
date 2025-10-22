# Migration Instructions for Supabase

Since we're experiencing issues with the CLI, here are the manual steps to migrate the database schema to your remote Supabase instance:

## Prerequisites

1. Access to the Supabase Dashboard (https://supabase.com/dashboard)
2. Your project reference: `tzmpwqiaqalrdwdslmkx`

## Steps

1. **Login to Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project with reference `tzmpwqiaqalrdwdslmkx`

2. **Navigate to the SQL Editor**
   - In the left sidebar, click on "SQL Editor"
   - Click on "New query" to open a query editor

3. **Execute the Migration Scripts in Order**

   ### 1. Create Core Schema
   - Copy the contents of `supabase/migrations/20240101000001_create_core_schema.sql`
   - Paste it into the SQL Editor
   - Click "Run" to execute the script
   - Wait for the script to complete successfully

   ### 2. Create Service Reports Schema
   - Copy the contents of `supabase/migrations/20240101000002_create_service_reports_schema.sql`
   - Paste it into the SQL Editor
   - Click "Run" to execute the script
   - Wait for the script to complete successfully

   ### 3. Create RLS Policies
   - Copy the contents of `supabase/migrations/20240101000003_create_rls_policies.sql`
   - Paste it into the SQL Editor
   - Click "Run" to execute the script
   - Wait for the script to complete successfully

   ### 4. Seed Lookup Data
   - Copy the contents of `supabase/migrations/20240101000004_seed_lookup_data.sql`
   - Paste it into the SQL Editor
   - Click "Run" to execute the script
   - Wait for the script to complete successfully

4. **Verify the Migration**
   - In the left sidebar, click on "Table Editor"
   - Verify that all the tables have been created
   - Check that the lookup data has been populated correctly

5. **Update Environment Variables**
   - Ensure your Flutter app's `.env` file has the correct Supabase URL and keys
   - The keys should match what you see in your Supabase project settings

## Troubleshooting

If you encounter any errors during migration:

1. Check the error message in the SQL Editor
2. Ensure you're executing the scripts in the correct order
3. Make sure you have the necessary permissions in your Supabase project
4. If a script fails, you may need to manually fix any issues before proceeding

## Next Steps

After completing the migration:

1. Test your Flutter app to ensure it can connect to the database
2. Verify that authentication works correctly
3. Test basic CRUD operations
4. Check that RLS policies are working as expected

## Notes

- The migration scripts are designed to be run in sequence
- Each script builds upon the previous one
- Do not skip any scripts unless you're sure they're not needed
- Always backup your data before running migrations in production