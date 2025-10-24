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
- `link_project.bat` - Phase 2 project linking and verification script
- `migrate_with_cli.bat` - Phase 3 migration push script
- `test_connection.bat` - Network connectivity diagnostic utility
- `PHASE1_CHECKLIST.md` - Phase 1 completion checklist
- `PHASE2_CHECKLIST.md` - Phase 2 completion checklist
- `PHASE3_CHECKLIST.md` - Phase 3 completion checklist
- `verify_migration.bat` - Post-migration verification script
- `test_queries.sql` - Sample SQL queries for manual testing
- `migration_summary.bat` - Final migration summary script
- `CLI_SETUP_LOG.txt` - Log file for CLI operations

## Migration Options

### Option 1: Manual Migration (Recommended)

1. Follow the instructions in `MIGRATION_INSTRUCTIONS.md`
2. Copy the contents of `combined_migration.sql`
3. Paste into the Supabase SQL Editor and execute

### Option 2: CLI Migration (Three-Phase Approach)

This is the recommended automated approach using the Supabase CLI, now broken into three distinct phases for better error handling and troubleshooting:

#### Quick Start for CLI Migration

```bash
# Phase 1: Setup and Authentication
.\setup_cli.bat
.\verify_auth.bat

# Phase 2: Project Linking and Verification
.\link_project.bat

# Phase 3: Migration Push
.\migrate_with_cli.bat

# Post-Migration Verification
.\verify_migration.bat
# Then test with test_queries.sql in Dashboard
```

#### Detailed Phase Breakdown

**Phase 1: Setup and Authentication**
- Run `setup_cli.bat` to install/update Supabase CLI
- Run `verify_auth.bat` to confirm authentication works
- Follow `PHASE1_CHECKLIST.md` for systematic verification
- Installs/updates Supabase CLI
- Authenticates with your Supabase account
- Creates access token for API access

**Phase 2: Project Linking and Verification** (NEW)
- Run `link_project.bat` to link CLI to remote project
- Verifies network connectivity and permissions
- Tests database access and connection status
- Follow `PHASE2_CHECKLIST.md` for comprehensive verification
- Use `test_connection.bat` for network diagnostics if issues occur
- Links CLI to remote Supabase project
- Verifies connectivity and permissions
- Confirms database access

**Phase 3: Migration Push**
- Run `migrate_with_cli.bat` to push migrations
- Verifies migration files and applies them to database
- Confirms successful migration application
- Pushes migration files to remote database
- Completes the migration process

**Post-Migration Verification**
- Run `verify_migration.bat` to test schema
- Tests all tables were created (27 tables expected)
- Verifies RLS policies exist (50+ policies)
- Checks functions and triggers
- Validates seed data (44 problem causes, 21 job tasks)
- Use `test_queries.sql` for manual testing in Dashboard

#### Prerequisites for CLI Migration

- **Phase 1 Prerequisites**:
  - Windows 10/11 with latest updates
  - npm, Scoop, or direct download access
  - Administrative privileges (if needed)
  - Active Supabase account
  - Default browser configured for OAuth

- **Phase 2 Prerequisites**:
  - Phase 1 must be completed successfully
  - Network connectivity to Supabase services
  - Appropriate permissions on the target project
  - Firewall configured to allow Supabase domains
  - Access to project with reference `tzmpwqiaqalrdwdslmkx`

- **Phase 3 Prerequisites**:
  - Phase 1 and Phase 2 must be completed successfully
  - Database must be active (not paused)
  - User must have DDL permissions (CREATE, ALTER, DROP)
  - No conflicting schema objects in target database
  - Backup of existing data if applicable

- **General Requirements**:
  - Stable internet connection
  - Access to api.supabase.com and related domains
  - No firewall blocking Supabase services

### Option 3: Legacy Automated Migration (Advanced)

If you want to use the older automated scripts:

1. Set up your environment variables in the `.env` file
2. Run one of the automated scripts:
   - Windows: `.\migrate.bat` or `.\migrate.ps1`
   - Cross-platform: `dart run migrate_remote.dart`

**Note**: This approach is deprecated. Use the CLI Migration (Option 2) instead.

## Migration Details

This migration creates a comprehensive job order management system with the following components:

### Migration 1: Core Schema (20240101000001_create_core_schema.sql)
**What it creates:**
- 21 core tables for job order management
- 8 custom ENUM types for data consistency
- Functions and triggers for automated timestamp updates
- Multi-tenant structure with organizations

**Key tables created:**
- `organizations` - Company/organization management
- `branches` - Branch offices with hierarchical structure
- `user_profiles` - User account management
- `organization_users` - User-organization relationships
- `job_orders` - Main job order records
- `job_order_assignments` - Job order assignments to users
- `job_status_history` - Status change tracking
- `job_items` - Individual items within job orders
- `estimates` & `estimate_items` - Cost estimation system
- `invoices` & `invoice_items` - Billing system
- `payments` - Payment tracking
- `inventory_items` - Stock management
- `inventory_stock_movements` - Stock movement tracking
- `attachments` - File attachments
- `messages` - Communication system
- `schedules` - Job scheduling
- `time_entries` - Time tracking
- `signatures` - Digital signatures
- `event_log` - Audit trail

**Expected outcome:** Complete relational database schema with proper foreign key relationships and constraints.

### Migration 2: Service Reports Schema (20240101000002_create_service_reports_schema.sql)
**What it creates:**
- 6 service report tables
- Problem causes and job tasks lookup tables
- Service report numbering function
- Performance indexes

**Key tables created:**
- `service_reports` - Main service report records
- `service_report_causes` - Problem cause associations
- `service_report_tasks` - Task associations
- `problem_causes` - Standardized problem causes
- `job_tasks` - Standardized job tasks
- `service_report_sequences` - Report numbering sequences

**Expected outcome:** Complete service reporting system with standardized problem and task categorization.

### Migration 3: RLS Policies (20240101000003_create_rls_policies.sql)
**What it creates:**
- Row Level Security policies for all tables
- Helper functions for multi-tenant isolation
- Security policies for data access control

**Key components:**
- Multi-tenant isolation policies
- User role-based access control
- Data ownership verification
- Secure data filtering

**Expected outcome:** Complete security framework ensuring users can only access their organization's data.

### Migration 4: Seed Data (20240101000004_seed_lookup_data.sql)
**What it creates:**
- 44 problem causes
- 21 job tasks
- Demo organization and branch
- 8 demo inventory items

**Key data seeded:**
- Comprehensive problem cause categories
- Standardized job tasks by device type
- Demo company structure for testing
- Sample inventory items with pricing

**Expected outcome:** Ready-to-use database with sufficient reference data for immediate testing and development.

### Migration Summary
- **Total tables created:** 27 (21 core + 6 service)
- **Custom types:** 8 ENUM types
- **RLS policies:** 50+ policies across all tables
- **Helper functions:** 6 security and utility functions
- **Triggers:** 12+ automated triggers
- **Seed data:** 44 problem causes, 21 job tasks, 8 inventory items

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
3. **Use the verification scripts**:
   - Run `verify_auth.bat` for Phase 1 issues
   - Run `test_connection.bat` for network diagnostics
4. **Follow the checklists**:
   - Use `PHASE1_CHECKLIST.md` for Phase 1 issues
   - Use `PHASE2_CHECKLIST.md` for Phase 2 issues

### Common Issues

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| `supabase command not found` | CLI not installed or not in PATH | Run `setup_cli.bat` or install manually |
| Authentication fails | Network issues or browser problems | Check `CLI_TROUBLESHOOTING.md` Phase 1 section |
| Project not found | Incorrect project ref or no access | Verify project ref in config.toml and dashboard |
| Connection timeout | Network/firewall issues | Run `test_connection.bat` for diagnostics |
| Permission denied | Insufficient project permissions | Check user role in Supabase dashboard |
| Migration push fails | SQL errors or permission issues | Review error logs and check permissions |
| Migration verification fails | Schema or data issues | Run verify_migration.bat and check logs |
| Partial migration failure | Some migrations failed | Check which migration failed and fix issues |

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
   - Phase 1 issues: `PHASE1_CHECKLIST.md` and `CLI_TROUBLESHOOTING.md` Phase 1 section
   - Phase 2 issues: `PHASE2_CHECKLIST.md`, `test_connection.bat`, and `CLI_TROUBLESHOOTING.md` Phase 2 section
   - Phase 3 issues: `PHASE3_CHECKLIST.md`, `verify_migration.bat`, and `CLI_TROUBLESHOOTING.md` Phase 3 section
5. **Network Diagnostics**: Run `test_connection.bat` for connectivity issues

## When to Use Each Migration Option

- **CLI Migration (Recommended)**: For most users, provides automated process with excellent error handling and phased approach
- **Manual Migration**: When CLI has insurmountable issues or for users who prefer direct SQL execution
- **Legacy Scripts**: Only for backward compatibility with existing workflows

## When Phase 2 Might Fail and Manual Migration is Needed

Consider manual migration if:

- **Network connectivity issues are insurmountable**: Corporate firewall blocks all Supabase services
- **Project permissions cannot be resolved**: Cannot get appropriate access to the project
- **Persistent authentication issues**: Cannot complete Phase 1 despite troubleshooting

In these cases, use the manual migration approach with `combined_migration.sql` file as documented in `MIGRATION_INSTRUCTIONS.md`.

## Phase-Specific Troubleshooting Quick Reference

- **Authentication issues** → Phase 1 (`setup_cli.bat`, `verify_auth.bat`)
- **Connection/linking issues** → Phase 2 (`link_project.bat`, `test_connection.bat`)
- **Migration/SQL issues** → Phase 3 (`migrate_with_cli.bat`)