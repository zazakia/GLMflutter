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
- `setup_cli.bat` - Phase 1 setup and authentication script
- `verify_auth.bat` - Authentication verification utility
- `CLI_SETUP_LOG.txt` - Log file for CLI operations

## Migration Options

### Option 1: Manual Migration (Recommended)

1. Follow the instructions in `MIGRATION_INSTRUCTIONS.md`
2. Copy the contents of `combined_migration.sql`
3. Paste into the Supabase SQL Editor and execute

### Option 2: CLI Migration (Phased Approach)

This is the recommended automated approach using the Supabase CLI:

#### Quick Start for CLI Migration

1. **Phase 1: Setup and Authentication**
   ```bash
   .\setup_cli.bat
   ```
   - Installs/updates Supabase CLI
   - Authenticates with your Supabase account
   - Creates access token for API access

2. **Phase 2: Verify Authentication**
   ```bash
   .\verify_auth.bat
   ```
   - Confirms authentication is working
   - Tests API connectivity
   - Validates access token

3. **Phase 3: Complete Migration**
   ```bash
   .\migrate_with_cli.bat
   ```
   - Links to your Supabase project
   - Pushes migration files to remote database
   - Completes the migration process

#### Prerequisites for CLI Migration

- **Supabase CLI Installation Requirements**:
  - Windows 10/11 with latest updates
  - npm, Scoop, or direct download access
  - Administrative privileges (if needed)

- **Network Connectivity Requirements**:
  - Stable internet connection
  - Access to api.supabase.com and related domains
  - No firewall blocking Supabase services

- **Authentication Requirements**:
  - Active Supabase account
  - Default browser configured for OAuth
  - Access to project with reference `tzmpwqiaqalrdwdslmkx`

### Option 3: Legacy Automated Migration (Advanced)

If you want to use the older automated scripts:

1. Set up your environment variables in the `.env` file
2. Run one of the automated scripts:
   - Windows: `.\migrate.bat` or `.\migrate.ps1`
   - Cross-platform: `dart run migrate_remote.dart`

**Note**: This approach is deprecated. Use the CLI Migration (Option 2) instead.

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

## Troubleshooting CLI Issues

If you encounter issues with the CLI migration approach:

1. **Check the log file**: Review `CLI_SETUP_LOG.txt` for detailed error information
2. **Consult the troubleshooting guide**: See `CLI_TROUBLESHOOTING.md` for common issues
3. **Use the verification script**: Run `verify_auth.bat` to check authentication status
4. **Follow the checklist**: Use `PHASE1_CHECKLIST.md` for systematic troubleshooting

### Common Issues

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| `supabase command not found` | CLI not installed or not in PATH | Run `setup_cli.bat` or install manually |
| Authentication fails | Network issues or browser problems | Check `CLI_TROUBLESHOOTING.md` |
| Migration push fails | SQL errors or permission issues | Review error logs and check permissions |
| Connection timeout | Network/firewall blocking | Check network settings and firewall |

## General Troubleshooting

If you encounter any issues:

1. **For CLI Migration**: Check `CLI_SETUP_LOG.txt` and `CLI_TROUBLESHOOTING.md`
2. **For Manual Migration**: Check the error messages in the Supabase SQL Editor
3. **Ensure you're executing the scripts in the correct order**
4. **Make sure you have the necessary permissions in your Supabase project**
5. **Review the migration logs for any specific errors**

## Support

For additional support:

1. **CLI Documentation**: Check the Supabase documentation: https://supabase.com/docs/guides/cli
2. **Project-specific Issues**: Review the migration scripts for any custom configurations
3. **Best Practices**: Test in a development environment before applying to production
4. **Phase-specific Help**:
   - Phase 1 issues: `PHASE1_CHECKLIST.md` and `CLI_TROUBLESHOOTING.md`
   - Phase 2-3 issues: Check `CLI_SETUP_LOG.txt` for error details

## When to Use Each Migration Option

- **CLI Migration (Recommended)**: For most users, provides automated process with good error handling
- **Manual Migration**: When CLI has issues or for users who prefer direct SQL execution
- **Legacy Scripts**: Only for backward compatibility with existing workflows