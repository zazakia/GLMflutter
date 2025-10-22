# Supabase Migration Guide

This directory contains all the necessary files to migrate your Job Order Management System database schema to a remote Supabase instance.

## Files

- `migrations/` - Directory containing individual SQL migration files
  - `20240101000001_create_core_schema.sql` - Creates the core database schema
  - `20240101000002_create_service_reports_schema.sql` - Creates service reports schema
  - `20240101000003_create_rls_policies.sql` - Creates Row Level Security policies
  - `20240101000004_seed_lookup_data.sql` - Seeds lookup data
- `combined_migration.sql` - All migration scripts combined into one file
- `MIGRATION_INSTRUCTIONS.md` - Detailed step-by-step instructions for manual migration
- `combine_sql.bat` - Batch file to combine all SQL files (Windows only)
- `migrate_remote.dart` - Dart script for automated migration (requires setup)
- `migrate.ps1` - PowerShell script for automated migration (requires setup)
- `migrate.bat` - Batch script for automated migration (requires setup)

## Migration Options

### Option 1: Manual Migration (Recommended)

1. Follow the instructions in `MIGRATION_INSTRUCTIONS.md`
2. Copy the contents of `combined_migration.sql`
3. Paste into the Supabase SQL Editor and execute

### Option 2: Automated Migration (Advanced)

If you want to automate the migration process:

1. Set up your environment variables in the `.env` file
2. Run one of the automated scripts:
   - Windows: `.\migrate.bat` or `.\migrate.ps1`
   - Cross-platform: `dart run migrate_remote.dart`

## Project Details

- Project Reference: `tzmpwqiaqalrdwdslmkx`
- Region: ap-southeast-1
- Database: PostgreSQL 15

## Next Steps

After completing the migration:

1. Test your Flutter app to ensure it can connect to the database
2. Verify that authentication works correctly
3. Test basic CRUD operations
4. Check that RLS policies are working as expected

## Troubleshooting

If you encounter any issues:

1. Check the error messages in the Supabase SQL Editor
2. Ensure you're executing the scripts in the correct order
3. Make sure you have the necessary permissions in your Supabase project
4. Review the migration logs for any specific errors

## Support

For additional support:

1. Check the Supabase documentation: https://supabase.com/docs
2. Review the migration scripts for any custom configurations
3. Test in a development environment before applying to production