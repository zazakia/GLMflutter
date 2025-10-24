# Supabase CLI Troubleshooting Guide

## Phase 1: CLI Setup and Authentication

This section covers the most common issues encountered during Phase 1 of the migration process - installing and authenticating the Supabase CLI.

### Before You Start

**Prerequisites for CLI Migration:**
- Windows 10/11 with latest updates
- Stable internet connection
- Supabase account with active project
- Default browser configured for OAuth login
- Firewall/antivirus allowing connections to supabase.com

### Common Error Scenarios

#### "CLI not found" Error
**Symptoms:**
- `supabase` command not recognized
- Script reports "Supabase CLI is not installed or not in PATH"

**Solutions for Windows:**
1. **Via npm (Recommended):**
   ```bash
   npm install -g supabase
   ```

2. **Via Scoop:**
   ```bash
   scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
   scoop install supabase
   ```

3. **Direct Download:**
   - Visit https://github.com/supabase/cli/releases
   - Download the latest Windows binary
   - Extract to a folder in your PATH (e.g., C:\Program Files\Supabase CLI)
   - Add to PATH: `setx PATH "%PATH%;C:\Program Files\Supabase CLI"`

4. **Verify Installation:**
   ```bash
   supabase --version
   ```

#### "Update failed" Error
**Symptoms:**
- Script reports "Failed to update Supabase CLI"
- Network timeout during update

**Solutions:**
1. **Check Internet Connection:**
   ```bash
   ping api.supabase.com
   ```

2. **Manual Update:**
   ```bash
   npm update -g supabase
   # or
   scoop update supabase
   ```

3. **Firewall Check:**
   - Temporarily disable firewall
   - Add exception for Supabase CLI
   - Check proxy settings

#### "Login failed" Error
**Symptoms:**
- Browser doesn't open for OAuth
- Login process hangs or fails
- Access token not created

**Solutions:**
1. **Browser Issues:**
   - Clear browser cache and cookies
   - Try a different browser
   - Check default browser settings

2. **Network Issues:**
   - Check if corporate network blocks OAuth
   - Try using a VPN
   - Verify DNS resolution

3. **Manual Login:**
   ```bash
   supabase login
   ```

#### "Access token not created" Error
**Symptoms:**
- Login completes but no token file
- `%USERPROFILE%\.supabase\access-token` missing

**Solutions:**
1. **Permission Issues:**
   - Run command prompt as administrator
   - Check folder permissions
   - Create `.supabase` folder manually

2. **Token Location:**
   - Verify correct path: `%USERPROFILE%\.supabase\`
   - Check if token exists in different location
   - Run `dir %USERPROFILE%\.supabase` to verify

#### "Network timeout during login" Error
**Symptoms:**
- Connection timeout errors
- SSL/TLS certificate issues

**Solutions:**
1. **Proxy/Firewall:**
   - Configure proxy settings
   - Add supabase.com to firewall whitelist
   - Check corporate network policies

2. **DNS Issues:**
   - Try different DNS servers
   - Flush DNS cache: `ipconfig /flushdns`
   - Verify DNS resolution

### Verification Checklist

Use this checklist to systematically verify CLI setup:

1. **Check CLI Version:**
   ```bash
   supabase --version
   ```
   Expected: Version number displayed

2. **Verify Access Token:**
   ```bash
   dir "%USERPROFILE%\.supabase\access-token"
   ```
   Expected: File exists with recent timestamp

3. **Test API Connectivity:**
   ```bash
   supabase projects list
   ```
   Expected: List of your projects displayed

4. **Check Environment Variables:**
   ```bash
   echo %PATH%
   ```
   Expected: Supabase CLI directory in PATH

### Error Code Reference Table

| Exit Code | Meaning | Solution |
|-----------|---------|----------|
| 0 | Success | Operation completed successfully |
| 1 | General Error | Check log for specific error message |
| 2 | File Not Found | CLI not installed or not in PATH |
| 3 | Network Error | Check internet connection, firewall |
| 4 | Authentication Error | Re-run `supabase login` |
| 5 | Permission Denied | Run as administrator |

### Log File Analysis Guide

**How to read `CLI_SETUP_LOG.txt`:**
1. **Timestamps:** Each entry shows when the operation occurred
2. **ERROR Keywords:** Look for "ERROR" to identify problems
3. **Exit Codes:** Note numeric codes for troubleshooting
4. **Success Messages:** Confirm completed operations

**Common Log Patterns:**
- `ERROR: Supabase CLI not found` → Installation issue
- `ERROR: Authentication verification failed` → Login issue
- `ERROR: API connectivity failed` → Network issue

### Quick Fix Commands

Copy and paste these commands for common issues:

```bash
# Reset authentication
del "%USERPROFILE%\.supabase\access-token"
supabase login

# Reinstall CLI (npm)
npm uninstall -g supabase
npm install -g supabase

# Test connectivity
ping api.supabase.com
nslookup api.supabase.com

# Check version and update
supabase --version
supabase update
```

## Previous Issues We Encountered

1. **Config.toml parsing errors**
2. **Connection timeouts to the remote database**
3. **Authentication/permission issues**

## Solutions to Make the CLI Work

### 1. Fix the Config.toml File

The current config.toml has issues with the format. Here's a corrected version:

```toml
# Supabase Configuration
[project]
ref = "tzmpwqiaqalrdwdslmkx"

[api]
port = 54321
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
max_rows = 1000

[db]
port = 54322
shadow_port = 54320
major_version = 15

[studio]
port = 54323

[storage]
file_size_limit = "50MiB"

[auth]
site_url = "http://localhost:3000"
additional_redirect_urls = ["https://localhost:3000"]
jwt_expiry = 3600

[analytics]
enabled = false

[edge_functions]
```

### 2. Fix Connection Issues

The connection errors are likely due to:

1. **Network connectivity issues**: The CLI is trying to connect to a region that might not be accessible from your location
2. **Firewall/proxy issues**: Your network might be blocking the connection
3. **Incorrect project reference**: The project reference might be incorrect

### 3. Steps to Make CLI Migration Work

**Important:** Complete Phase 1 first by running `setup_cli.bat` before proceeding with these steps.

#### Step 1: Update the Supabase CLI
```bash
supabase update
```
*This is handled by setup_cli.bat*

#### Step 2: Login to Supabase
```bash
supabase login
```
*This is handled by setup_cli.bat - use verify_auth.bat to confirm*

#### Step 3: Link to Your Project
```bash
supabase link --project-ref tzmpwqiaqalrdwdslmkx
```
*Ensure config.toml exists and contains the project ref*

#### Step 4: Check Status
```bash
supabase status
```
*Verify successful connection before proceeding*

#### Step 5: Push Migrations
```bash
supabase db push
```
*Execute migration to remote database*

### 4. Alternative: Use a Different Region

If connection issues persist, the project might be in a region that's not accessible from your location. Consider:

1. Creating a new project in a different region (closer to your location)
2. Using a VPN to connect to a different region

### 5. Check Project Permissions

Ensure your account has the necessary permissions to access the project:

1. Go to the Supabase Dashboard
2. Check your account settings
3. Verify you have the right permissions for the project

### 6. Use Local Development

If remote connection continues to fail, you can:

1. Start a local Supabase instance:
   ```bash
   supabase start
   ```
2. Apply migrations locally:
   ```bash
   supabase db reset
   ```
3. Export the schema and import it manually to the remote project

### 7. Direct Database Connection

As a last resort, you can connect directly to the database:

1. Get the connection string from the Supabase Dashboard
2. Use a PostgreSQL client (like pgAdmin or DBeaver) to connect
3. Run the migration scripts manually

## Recommended Approach

Given the connection issues we encountered, I recommend:

1. **Use the manual migration approach** with the combined_migration.sql file
2. **Or try creating a new Supabase project** in a different region
3. **Or use a VPN** to connect to a different region if the issue is network-related

## If You Still Want to Use the CLI

If you prefer to use the CLI despite the issues, try these steps:

1. Update your config.toml with the corrected version above
2. Update the Supabase CLI to the latest version
3. Try linking to the project again
4. If connection issues persist, consider creating a new project in a different region

## Phase 2: Project Linking and Connection Verification

This section covers issues related to linking the CLI to the remote Supabase project and verifying connectivity. Phase 2 must be completed after successful Phase 1 authentication.

### Prerequisites Reminder

**Phase 1 must be completed successfully before attempting Phase 2:**
- Run `setup_cli.bat` to install and authenticate the CLI
- Run `verify_auth.bat` to confirm authentication is working
- Ensure `CLI_SETUP_LOG.txt` shows successful Phase 1 completion

### Common Error Scenarios

#### "Project not found" Error
**Symptoms:**
- `supabase link` fails with "Project not found" message
- Error indicates project reference is invalid or inaccessible
- Exit code from linking command is non-zero

**Solutions:**
1. **Verify Project Reference in config.toml:**
   ```bash
   type config.toml
   ```
   Expected: `ref = "tzmpwqiaqalrdwdslmkx"`

2. **Check Project Exists in Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx
   - Confirm project loads without "404 Not Found" error

3. **Verify User Has Access to Project:**
   ```bash
   supabase projects list
   ```
   Look for `tzmpwqiaqalrdwdslmkx` in the output

4. **Confirm Project is Not Deleted or Archived:**
   - Check project status in Supabase dashboard
   - Ensure project is active and not suspended

5. **Copy Project Reference Directly from Dashboard:**
   - Navigate to project settings in Supabase dashboard
   - Copy the project reference from the URL or settings page

#### "Connection timeout" Error
**Symptoms:**
- Commands hang or timeout when connecting to remote project
- Network-related errors during linking or status checks
- SSL/TLS handshake failures

**Solutions:**
1. **Run Network Diagnostics:**
   ```bash
   test_connection.bat
   ```
   Review all test results for network issues

2. **Check Internet Connection Stability:**
   ```bash
   ping api.supabase.com -t
   ```
   Look for packet loss or high latency

3. **Verify Firewall is Not Blocking Supabase Domains:**
   - Add exceptions for `*.supabase.com` and `*.supabase.co`
   - Check both Windows Firewall and any antivirus software

4. **Test with Different Network:**
   - Try mobile hotspot or different WiFi network
   - Check if corporate network has restrictions

5. **Check for Corporate Network Restrictions:**
   - Contact IT department about Supabase access
   - Verify no proxy is blocking connections

6. **Increase Timeout Settings if on Slow Connection:**
   ```bash
   set SUPABASE_DB_TIMEOUT=60
   ```

#### "Permission denied" Error
**Symptoms:**
- Link succeeds but cannot access database or project resources
- "Access denied" or "Permission denied" messages
- Database operations fail with authorization errors

**Solutions:**
1. **Verify User Role in Supabase Dashboard:**
   - Check if you have Owner, Admin, or Developer role
   - Contact project owner to upgrade permissions if needed

2. **Check Project Permissions in Dashboard Settings:**
   - Navigate to Settings > Permissions
   - Verify your account has necessary access levels

3. **Confirm Authentication Token Has Necessary Scopes:**
   ```bash
   supabase login
   ```
   Re-authenticate to refresh token permissions

4. **Check if Project is Paused (Free Tier Limitation):**
   - Verify database is active in Supabase dashboard
   - Resume project if it's paused due to inactivity

5. **Verify Database is Running:**
   - Check database status in dashboard
   - Restart database if needed

#### "Invalid project reference" Error
**Symptoms:**
- Project ref format is rejected or not recognized
- "Invalid project ID" or similar error messages
- Configuration parsing errors

**Solutions:**
1. **Verify Project Reference Format:**
   - Should be alphanumeric string (no special characters except hyphens)
   - Example: `tzmpwqiaqalrdwdslmkx`

2. **Check for Typos in config.toml:**
   ```bash
   findstr "ref =" config.toml
   ```
   Ensure exact match with expected value

3. **Copy Project Reference Directly from Dashboard:**
   - Get reference from project URL: `https://supabase.com/dashboard/project/[REF]`
   - Paste directly into config.toml

4. **Ensure No Extra Spaces or Special Characters:**
   - Check for leading/trailing spaces
   - Remove any quotes beyond the required ones

5. **Validate Against Pattern in Dashboard URL:**
   - Compare with URL in browser address bar
   - Ensure character-for-character match

#### "SSL/TLS certificate" Error
**Symptoms:**
- SSL verification fails when connecting to Supabase
- Certificate validation errors
- Secure connection establishment failures

**Solutions:**
1. **Update System Certificates:**
   - Run Windows Update to get latest certificate store
   - Update browser certificates

2. **Check System Date/Time is Correct:**
   ```bash
   date /t && time /t
   ```
   Ensure system clock is accurate

3. **Verify Antivirus is Not Intercepting SSL:**
   - Disable SSL scanning in antivirus temporarily
   - Add Supabase domains to antivirus whitelist

4. **Try with Insecure Flag for Testing (Not Recommended for Production):**
   ```bash
   set NODE_TLS_REJECT_UNAUTHORIZED=0
   ```
   Remember to unset this after testing

5. **Update Supabase CLI to Latest Version:**
   ```bash
   supabase update
   ```

#### "Database connection failed" Error
**Symptoms:**
- Link succeeds but database status check fails
- Cannot connect to database endpoint
- Database URL appears invalid or inaccessible

**Solutions:**
1. **Verify Database is Running in Supabase Dashboard:**
   - Check database status in project settings
   - Look for "Database is active" indicator

2. **Check if Database is Paused (Free Tier Limitation):**
   - Free tier databases pause after inactivity
   - Resume database from dashboard if needed

3. **Confirm Database URL is Accessible:**
   ```bash
   supabase status
   ```
   Verify database URL format and accessibility

4. **Test Database Connectivity from Dashboard SQL Editor:**
   - Open SQL Editor in Supabase dashboard
   - Try running a simple query like `SELECT 1`

5. **Check if IP is Whitelisted (If IP Restrictions Enabled):**
   - Review network restrictions in dashboard
   - Add your IP to whitelist if required

### Network Diagnostics

#### How to Use test_connection.bat for Diagnostics

1. **Run the Diagnostic Utility:**
   ```bash
   test_connection.bat
   ```
   This will perform comprehensive network testing

2. **Interpreting Network Test Results:**
   - **PASS**: All tests successful - network ready for CLI operations
   - **FAIL**: Specific issues identified - review troubleshooting section
   - **DETECTED**: Proxy or other network configuration found

3. **Common Network Issues and Solutions:**
   - **DNS Resolution Failures**: Try Google DNS (8.8.8.8, 8.8.4.4)
   - **Port Blocking**: Configure firewall for port 443 (HTTPS)
   - **Proxy Issues**: Set HTTP_PROXY and HTTPS_PROXY environment variables
   - **High Latency**: Consider VPN or different network

4. **Firewall Configuration Guidance:**
   - Add exceptions for `*.supabase.com` and `*.supabase.co`
   - Allow outbound connections on port 443 (HTTPS)
   - Check both Windows Firewall and corporate firewalls

5. **Proxy Configuration for Supabase CLI:**
   ```bash
   set HTTP_PROXY=http://proxy.company.com:8080
   set HTTPS_PROXY=http://proxy.company.com:8080
   ```
   Replace with your actual proxy settings

### Verification Checklist

#### Step-by-Step Verification Commands

1. **Check Authentication Status:**
   ```bash
   verify_auth.bat
   ```
   Expected: "VERIFICATION SUCCESSFUL"

2. **Validate Configuration:**
   ```bash
   type config.toml | findstr "ref ="
   ```
   Expected: `ref = "tzmpwqiaqalrdwdslmkx"`

3. **Test Network Connectivity:**
   ```bash
   test_connection.bat
   ```
   Expected: All tests show [PASS]

4. **Link to Project:**
   ```bash
   supabase link --project-ref tzmpwqiaqalrdwdslmkx
   ```
   Expected: "Successfully linked to project"

5. **Check Connection Status:**
   ```bash
   supabase status
   ```
   Expected: All service URLs displayed without errors

6. **Test Database Access:**
   ```bash
   supabase db remote list
   ```
   Expected: Database information displayed without permission errors

#### Expected Output for Each Command

- **verify_auth.bat**: Should show "VERIFICATION SUCCESSFUL" and exit with code 0
- **supabase link**: Should complete without error messages and show success confirmation
- **supabase status**: Should display API URL, Database URL, and Studio URL
- **supabase db remote list**: Should show database connection details without authorization errors

#### How to Confirm Successful Linking

1. **Check Log File:**
   ```bash
   type CLI_SETUP_LOG.txt | findstr "Phase 2 completed"
   ```
   Should show successful completion message

2. **Verify Status Command Works:**
   ```bash
   supabase status
   ```
   Should display project information without errors

3. **Confirm Database Access:**
   ```bash
   supabase db remote list
   ```
   Should return database connection details

### Error Code Reference Table for Phase 2

| Exit Code | Meaning | Solution |
|-----------|---------|----------|
| 0 | Success | Phase 2 completed successfully |
| 1 | Authentication Error | Re-run Phase 1 authentication |
| 2 | Configuration Error | Verify config.toml contents |
| 3 | Network Error | Run test_connection.bat and fix network issues |
| 4 | Permission Error | Check user role in Supabase dashboard |
| 5 | Project Not Found | Verify project reference and access |
| 6 | Database Error | Check database status and permissions |
| 7 | SSL/TLS Error | Update certificates or check system time |

### Quick Fix Commands for Phase 2

```bash
# Re-link to project
supabase unlink
supabase link --project-ref tzmpwqiaqalrdwdslmkx

# Check connection status
supabase status

# Test network connectivity
test_connection.bat

# Verify project access
supabase projects list

# Reset authentication and try again
supabase login
supabase link --project-ref tzmpwqiaqalrdwdslmkx

# Test database permissions
supabase db remote list

# Check configuration
type config.toml | findstr "ref ="
```

### Log Analysis Guide for Phase 2

**What to look for in CLI_SETUP_LOG.txt for Phase 2 issues:**

1. **Authentication Errors:**
   - Search for "ERROR: Phase 1 verification failed"
   - Indicates need to complete Phase 1 first

2. **Configuration Issues:**
   - Search for "ERROR: Project reference not found"
   - Check config.toml contents

3. **Network Failures:**
   - Search for "ERROR: Cannot reach api.supabase.com"
   - Run test_connection.bat for detailed diagnostics

4. **Linking Failures:**
   - Search for "ERROR: Project linking failed"
   - Review specific error messages in log

5. **Database Permission Issues:**
   - Search for "WARNING: Database permission test failed"
   - Check user role in Supabase dashboard

**Common Log Patterns Indicating Specific Problems:**

- `ERROR: Phase 1 verification failed` → Complete Phase 1 first
- `ERROR: Project reference not found` → Fix config.toml
- `ERROR: Cannot reach api.supabase.com` → Network connectivity issues
- `ERROR: Project linking failed` → Authentication or permission issues
- `WARNING: Database permission test failed` → Check database access

### When to Use Manual Migration

Consider manual migration via SQL editor if Phase 2 issues are insurmountable:

1. **Persistent Network/Firewall Issues:**
   - Corporate network blocks all Supabase connections
   - Firewall cannot be configured to allow necessary ports
   - Proxy configuration is not possible

2. **Unresolvable Permission Issues:**
   - Cannot get appropriate role in Supabase project
   - Project owner cannot be contacted for access
   - Organization policies prevent CLI access

3. **Technical Limitations:**
   - Windows environment restrictions prevent CLI installation
   - System policies prevent command-line tool usage
   - Irreconcilable SSL/TLS certificate issues

In these cases, use the manual migration approach with `combined_migration.sql` file as documented in `MIGRATION_INSTRUCTIONS.md`.

## Phase 3: Migration Push and Verification

This section covers issues related to pushing migration files to the remote database and verifying successful application. Phase 3 must be completed after successful Phase 1 authentication and Phase 2 project linking.

### Prerequisites Reminder

**Phase 1 and Phase 2 must be completed successfully before attempting Phase 3:**
- Run `setup_cli.bat` to install and authenticate the CLI
- Run `verify_auth.bat` to confirm authentication is working
- Run `link_project.bat` to link to the remote project
- Ensure `supabase status` shows active project connection
- Verify all migration files exist in `migrations/` directory

### Common Error Scenarios

#### "SQL syntax error" Error
**Symptoms:**
- Migration push fails with SQL parsing errors
- Specific line numbers reported in error messages
- Syntax error messages pointing to migration files
- "ERROR: syntax error at or near" messages

**Solutions:**
1. **Review the Specific Migration File:**
   - Check the error message for the exact migration file name
   - Open the mentioned file in the migrations/ directory
   - Look for syntax issues around the reported line number

2. **Check for Common SQL Syntax Issues:**
   - Missing semicolons at end of statements
   - Incorrect PostgreSQL syntax (version 15)
   - Unmatched parentheses or quotes
   - Reserved keywords used as identifiers (use quotes)

3. **Test Problematic SQL in Dashboard:**
   - Copy the problematic SQL to Supabase Dashboard SQL Editor
   - Execute to identify specific syntax issues
   - Fix syntax and retry migration

4. **Verify PostgreSQL Compatibility:**
   - Ensure SQL is compatible with PostgreSQL 15
   - Check for MySQL-specific syntax that needs conversion
   - Verify function and trigger syntax

5. **Fix and Re-run Migration:**
   - Correct syntax errors in migration file
   - Save changes and run `migrate_with_cli.bat` again
   - Check `CLI_SETUP_LOG.txt` for updated results

**Reference:** Migration files in `migrations/` directory, specifically:
- `20240101000001_create_core_schema.sql`
- `20240101000002_create_service_reports_schema.sql`
- `20240101000003_create_rls_policies.sql`
- `20240101000004_seed_lookup_data.sql`

#### "Permission denied" Error
**Symptoms:**
- Migration fails with "permission denied for schema" errors
- "must be owner of table" or "permission denied for relation" messages
- DDL operations fail with authorization errors
- Access denied errors during migration push

**Solutions:**
1. **Verify User Role in Supabase Dashboard:**
   - Login to Supabase Dashboard
   - Navigate to Settings > Database > Roles
   - Check if your role is Owner, Admin, or Developer

2. **Check DDL Permissions:**
   - Verify user has CREATE, ALTER, DROP permissions
   - Check if user can create tables and functions
   - Ensure role has necessary schema privileges

3. **Confirm Project Membership:**
   - Check if you're a member of the project
   - Verify your access level in project settings
   - Contact project owner if permissions insufficient

4. **Check Database Status:**
   - Verify database is not in read-only mode
   - Ensure database is active (not paused)
   - Check for maintenance mode status

5. **Re-authenticate if Needed:**
   ```bash
   supabase login
   supabase link --project-ref tzmpwqiaqalrdwdslmkx
   ```
   - Refresh authentication tokens
   - Re-establish project connection

**Reference:** Supabase Dashboard > Settings > Database > Roles

#### "Migration conflict" Error
**Symptoms:**
- "relation already exists" or "type already exists" errors
- "column already exists" or "constraint already exists" messages
- Conflicts with existing schema objects
- Migration fails partway through

**Solutions:**
1. **Check Previous Migration Attempts:**
   - Review `CLI_SETUP_LOG.txt` for earlier migration attempts
   - Check if migrations were partially applied
   - Verify database state in Supabase Dashboard

2. **Identify Conflicting Objects:**
   - Note specific objects mentioned in error messages
   - Check Table Editor in Supabase Dashboard
   - List existing tables, types, and functions

3. **Resolve Conflicts (Choose One Approach):**
   
   **Option A: Drop Conflicting Objects (CAUTION: Data Loss)**
   - Drop tables in reverse dependency order
   - Remove conflicting types and functions
   - Use clean database approach if possible

   **Option B: Use Fresh Database**
   - Create new Supabase project
   - Apply migrations to clean database
   - Migrate any existing data manually

   **Option C: Manual Conflict Resolution**
   - Edit migration files to skip existing objects
   - Use `IF NOT EXISTS` clauses where appropriate
   - Handle edge cases individually

4. **Check Migration History:**
   ```bash
   supabase migration list
   ```
   - Review which migrations were applied
   - Identify where migration failed
   - Plan appropriate recovery strategy

5. **Reset and Retry (Last Resort):**
   ```bash
   supabase db reset
   supabase db push
   ```
   - WARNING: This will delete all existing data
   - Only use if data loss is acceptable

**Reference:** Supabase Dashboard > Database > Tables

#### "Database paused" Error
**Symptoms:**
- Connection timeout errors during migration
- "database is paused" messages
- Unable to establish database connection
- Migration fails with connection errors

**Solutions:**
1. **Check Database Status in Dashboard:**
   - Login to Supabase Dashboard
   - Navigate to project settings
   - Look for "Database is paused" indicator

2. **Resume Database:**
   - Click "Resume database" button in dashboard
   - Wait for database to fully initialize
   - Verify database is active before proceeding

3. **Consider Free Tier Limitations:**
   - Free tier databases auto-pause after inactivity
   - Plan for potential pauses during development
   - Consider upgrading to paid tier for consistent access

4. **Wait for Full Resume:**
   - Database may take 1-2 minutes to fully resume
   - Test connection with simple query first
   - Verify all services are accessible

5. **Monitor Database Activity:**
   - Check database metrics in dashboard
   - Ensure no maintenance operations in progress
   - Verify all services are running

**Reference:** Supabase Dashboard > Settings > General

#### "Partial migration failure" Error
**Symptoms:**
- Some migrations apply successfully, others fail
- Database in inconsistent state
- Later migrations fail due to missing dependencies
- Mixed success/failure status in logs

**Solutions:**
1. **Identify Failed Migration:**
   - Review `CLI_SETUP_LOG.txt` for specific failure point
   - Note which migration file caused the issue
   - Check error messages for root cause

2. **Analyze Error Context:**
   - Determine if earlier migrations succeeded
   - Check if database objects from failed migration exist
   - Assess current database state

3. **Choose Recovery Strategy:**
   
   **Option A: Fix and Continue**
   - Fix the specific issue in failed migration
   - Manually apply remaining migrations
   - Use `supabase db push` to continue

   **Option B: Rollback and Retry**
   - Manually drop objects created by failed migration
   - Fix migration file
   - Re-run complete migration process

   **Option C: Manual Completion**
   - Apply remaining migrations manually in SQL Editor
   - Fix any issues with manual application
   - Verify final database state

4. **Manual Intervention in Dashboard:**
   - Open SQL Editor in Supabase Dashboard
   - Check which objects were created
   - Manually apply or fix missing components

5. **Verify Final State:**
   - Run `verify_migration.bat` for comprehensive check
   - Use `test_queries.sql` for manual verification
   - Ensure all expected objects exist

**Rollback Guidance:**
- Drop objects in reverse dependency order
- Remove foreign key constraints before tables
- Drop types and functions after tables
- Test rollback in development environment first

**Reference:** `CLI_SETUP_LOG.txt` for detailed error information

#### "Function or trigger creation failed" Error
**Symptoms:**
- Tables created successfully but functions/triggers fail
- PL/pgSQL syntax errors in function definitions
- "function already exists" or trigger creation errors
- Migration reports partial success

**Solutions:**
1. **Check PL/pgSQL Syntax:**
   - Verify function syntax matches PostgreSQL requirements
   - Check for proper BEGIN/END blocks
   - Ensure RETURN statements are correct
   - Validate parameter and variable declarations

2. **Verify Required Extensions:**
   - Check if `uuid-ossp` extension is enabled
   - Verify all required extensions are installed
   - Install missing extensions in dashboard:
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   ```

3. **Test Function Creation Separately:**
   - Copy function definition to SQL Editor
   - Test creation in isolation
   - Fix syntax issues before re-running migration

4. **Check Trigger Dependencies:**
   - Verify trigger function exists before creating trigger
   - Check that referenced tables exist
   - Ensure proper trigger timing and events

5. **Review Migration File Order:**
   - Functions must be created before triggers
   - Types must be created before tables that use them
   - Dependencies must be resolved in correct order

**Reference:** Migration file `20240101000001_create_core_schema.sql`

#### "RLS policy creation failed" Error
**Symptoms:**
- Tables and functions created but RLS policies fail
- Policy syntax errors or missing references
- "function does not exist" errors in policies
- Security policies not applied correctly

**Solutions:**
1. **Verify Helper Functions Exist:**
   - Check that `is_org_member` function exists
   - Verify `user_org_role` function is created
   - Confirm `can_access_job` function is available
   - Test functions manually in SQL Editor

2. **Check Policy Syntax:**
   - Verify policy expressions are valid SQL
   - Check for proper use of auth.uid()
   - Ensure quoted identifiers are correct
   - Validate Boolean expressions in policies

3. **Test Policy Expressions:**
   - Copy policy conditions to SQL Editor
   - Test with sample data
   - Verify expressions return expected results

4. **Check RLS Enablement:**
   - Ensure RLS is enabled on target tables
   - Verify table structure supports policies
   - Check that all required columns exist

5. **Review Policy Dependencies:**
   - Policies depend on functions and table structure
   - Ensure all dependencies are created first
   - Check for circular references

**Reference:** Migration file `20240101000003_create_rls_policies.sql`

#### "Seed data insertion failed" Error
**Symptoms:**
- Schema created successfully but seed data fails
- Foreign key constraint violations
- "duplicate key value violates unique constraint" errors
- Data type mismatches during insertion

**Solutions:**
1. **Check Foreign Key Constraints:**
   - Verify referenced tables have expected data
   - Check that demo organization exists before inserting related data
   - Ensure proper UUID format for foreign keys

2. **Verify Data Types:**
   - Check that data matches column types
   - Verify UUID format is correct
   - Ensure numeric values are in valid range
   - Check text length constraints

3. **Handle Duplicate Key Issues:**
   - Check if data already exists in tables
   - Use `INSERT ... ON CONFLICT` if appropriate
   - Clear existing data if clean insertion needed

4. **Check Constraint Validations:**
   - Verify all CHECK constraints are satisfied
   - Ensure NOT NULL constraints are respected
   - Validate UNIQUE constraints

5. **Insert Data Manually if Needed:**
   - Copy seed data statements to SQL Editor
   - Execute individually to identify issues
   - Fix problems and retry migration

**Reference:** Migration file `20240101000004_seed_lookup_data.sql`

### Migration Verification

#### How to Use verify_migration.bat for Automated Verification

1. **Run the Verification Script:**
   ```bash
   .\verify_migration.bat
   ```
   This will perform comprehensive verification of all migration components

2. **Interpreting Verification Results:**
   - **PASS**: Component verified successfully
   - **FAIL**: Component missing or incorrect
   - **ERROR**: Could not verify component (connection issues)

3. **Expected Verification Results:**
   - Tables: 27/27 expected
   - RLS policies: 50+ expected
   - Functions: 6/6 expected
   - Triggers: 12+ expected
   - Seed data: problem_causes (44), job_tasks (21), etc.

4. **What to Do if Verification Fails:**
   - Review specific failures in verification output
   - Check `CLI_SETUP_LOG.txt` for detailed error information
   - Use manual verification steps in Supabase Dashboard
   - Re-run migration if necessary

#### Manual Testing with test_queries.sql

1. **How to Use Sample Queries:**
   - Open Supabase Dashboard SQL Editor
   - Copy sections from `test_queries.sql`
   - Execute queries and verify results

2. **Running Queries in Supabase Dashboard:**
   - Navigate to: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx/sql
   - Copy query text and paste into editor
   - Click "Run" to execute
   - Review results for expected values

3. **Interpreting Query Results:**
   - Check row counts match expected values in comments
   - Verify no SQL errors occur
   - Confirm data integrity and relationships

4. **Essential Queries to Run:**
   - Query 1.2: Count total tables (expected: 27)
   - Query 4.1: Count problem causes (expected: 44)
   - Query 4.2: Count job tasks (expected: 21)
   - Query 13.1: Complete verification summary

### Rollback Procedures

#### When to Consider Rollback vs. Forward Fixes

1. **Consider Rollback When:**
   - Migration failed early with minimal changes
   - Database can be safely reset
   - Data loss is acceptable
   - Migration issues are complex and hard to fix

2. **Consider Forward Fixes When:**
   - Migration is mostly successful
   - Only specific components need fixing
   - Data must be preserved
   - Issues are well-understood and fixable

#### How to Identify Which Migrations Were Applied

1. **Check Migration History:**
   ```bash
   supabase migration list
   ```
   - Shows which migrations were applied
   - Displays migration timestamps
   - Identifies any failed migrations

2. **Review Database Objects:**
   - Check Table Editor in Supabase Dashboard
   - List all tables, functions, and types
   - Compare with expected migration results

3. **Analyze Log Files:**
   - Review `CLI_SETUP_LOG.txt` for migration details
   - Check success/failure status for each migration
   - Note specific error messages

#### Order for Dropping Objects (Reverse Dependency Order)

1. **Drop Seed Data First:**
   ```sql
   DELETE FROM inventory_items WHERE org_id = '00000000-0000-0000-0000-000000000001';
   DELETE FROM organizations WHERE id = '00000000-0000-0000-0000-000000000001';
   ```

2. **Drop Functions and Triggers:**
   ```sql
   DROP TRIGGER IF EXISTS trigger_name ON table_name;
   DROP FUNCTION IF EXISTS function_name;
   ```

3. **Drop Tables in Reverse Order:**
   - Drop child tables before parent tables
   - Remove junction tables before main tables
   - Drop tables with foreign keys last

4. **Drop Types and Extensions:**
   ```sql
   DROP TYPE IF EXISTS type_name;
   DROP EXTENSION IF EXISTS "uuid-ossp";
   ```

#### SQL Commands for Clean Rollback

```sql
-- Drop service report objects
DROP TABLE IF EXISTS service_report_tasks CASCADE;
DROP TABLE IF EXISTS service_report_causes CASCADE;
DROP TABLE IF EXISTS service_reports CASCADE;
DROP TABLE IF EXISTS service_report_sequences CASCADE;

-- Drop lookup tables
DROP TABLE IF EXISTS job_tasks CASCADE;
DROP TABLE IF EXISTS problem_causes CASCADE;

-- Drop main schema tables (in dependency order)
DROP TABLE IF EXISTS signatures CASCADE;
DROP TABLE IF EXISTS time_entries CASCADE;
DROP TABLE IF EXISTS schedules CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS attachments CASCADE;
DROP TABLE IF EXISTS event_log CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS estimate_items CASCADE;
DROP TABLE IF EXISTS estimates CASCADE;
DROP TABLE IF EXISTS job_items CASCADE;
DROP TABLE IF EXISTS job_status_history CASCADE;
DROP TABLE IF EXISTS job_order_assignments CASCADE;
DROP TABLE IF EXISTS job_orders CASCADE;
DROP TABLE IF EXISTS organization_users CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS branches CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS calculate_service_report_totals();
DROP FUNCTION IF EXISTS generate_service_report_number();
DROP FUNCTION IF EXISTS can_access_job();
DROP FUNCTION IF EXISTS user_org_role();
DROP FUNCTION IF EXISTS is_org_member();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop types
DROP TYPE IF EXISTS signature_role;
DROP TYPE IF EXISTS device_type;
DROP TYPE IF EXISTS payment_status;
DROP TYPE IF EXISTS payment_method;
DROP TYPE IF EXISTS invoice_status;
DROP TYPE IF EXISTS estimate_status;
DROP TYPE IF EXISTS job_status;
DROP TYPE IF EXISTS org_role;
```

**CAUTION**: Rollback will delete all data. Backup important data before proceeding.

### Error Code Reference Table for Phase 3

| Exit Code | Meaning | Solution |
|-----------|---------|----------|
| 0 | Success | Migration completed successfully |
| 1 | General Error | Check log for specific error message |
| 2 | SQL Syntax Error | Review migration files for syntax issues |
| 3 | Permission Error | Check user role and DDL permissions |
| 4 | Connection Error | Verify database is active and accessible |
| 5 | Migration Conflict | Handle existing schema objects |
| 6 | Database Paused | Resume database from dashboard |
| 7 | Partial Failure | Check which migration failed and fix |

### Quick Fix Commands for Phase 3

```bash
# Re-run migration push
supabase db push

# Verify migration status
.\verify_migration.bat

# Check database status
supabase status

# Test with sample queries
# (Copy test_queries.sql to SQL Editor)

# Check migration history
supabase migration list

# Reset and retry (CAUTION: data loss)
supabase db reset
supabase db push

# Resume paused database
# (Use Supabase Dashboard > Settings)

# Check specific migration file
type migrations\20240101000001_create_core_schema.sql
```

### Log Analysis Guide for Phase 3

**What to look for in CLI_SETUP_LOG.txt for Phase 3 issues:**

1. **SQL Syntax Errors:**
   - Search for "ERROR: syntax error at or near"
   - Note specific line numbers and migration files
   - Identify problematic SQL statements

2. **Permission Issues:**
   - Search for "ERROR: permission denied"
   - Check which operations were denied
   - Review user role and permissions

3. **Migration Conflicts:**
   - Search for "ERROR: relation already exists"
   - Note which objects already exist
   - Plan conflict resolution strategy

4. **Database Status Issues:**
   - Search for "ERROR: database is paused"
   - Check for connection timeout errors
   - Verify database accessibility

5. **Partial Migration Failures:**
   - Search for migration completion status
   - Identify which migrations succeeded/failed
   - Plan recovery strategy

**Common Log Patterns Indicating Specific Problems:**

- `ERROR: syntax error at or near` → SQL syntax issue in migration file
- `ERROR: permission denied for schema` → Insufficient database permissions
- `ERROR: relation already exists` → Schema conflict with existing objects
- `ERROR: database is paused` → Database inactive (free tier limitation)
- `Migration push failed with exit code` → Migration process failed

### Dashboard Verification Guide

#### Step-by-Step Guide to Verify Migration in Supabase Dashboard

1. **Access the Dashboard:**
   - Navigate to: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx
   - Login with your Supabase account credentials

2. **Check Table Editor:**
   - Click "Table Editor" in left sidebar
   - Verify all 27 tables are listed
   - Check that table names match expected schema

3. **Verify Seed Data:**
   - Open `organizations` table
   - Look for "Demo Company" record
   - Open `problem_causes` table
   - Verify 44 rows are present
   - Open `job_tasks` table
   - Verify 21 rows are present
   - Open `inventory_items` table
   - Verify 8 demo items exist

4. **Check RLS Policies:**
   - Navigate to Database > Policies
   - Verify policies exist for all tables
   - Check that policy count is 50+
   - Review policy names and conditions

5. **Verify Functions:**
   - Navigate to Database > Functions
   - Check for helper functions: is_org_member, user_org_role, can_access_job
   - Verify update_updated_at_column function exists
   - Check service report functions

6. **Check Triggers:**
   - Navigate to Database > Triggers
   - Verify triggers exist for updated_at columns
   - Check service report triggers
   - Confirm trigger count is 12+

7. **Test SQL Editor:**
   - Navigate to Database > SQL Editor
   - Run basic test queries from test_queries.sql
   - Verify queries execute without errors
   - Check expected results match

### When to Use Manual Migration

Consider manual migration via SQL Editor if Phase 3 issues are insurmountable:

1. **Persistent SQL Syntax Errors:**
   - Migration files have unfixable syntax issues
   - PostgreSQL version incompatibilities
   - Complex dependency issues

2. **Schema Conflicts:**
   - Existing database objects cannot be resolved
   - Conflicts are too complex to manage automatically
   - Manual intervention required for careful data preservation

3. **Partial Migration Issues:**
   - Some migrations applied successfully, others failed
   - Manual completion is more reliable than rollback
   - Need for precise control over migration process

4. **Database Access Limitations:**
   - CLI access is blocked or unreliable
   - SQL Editor access is available and working
   - Direct SQL execution is more reliable

In these cases, use the manual migration approach with `combined_migration.sql` file as documented in `MIGRATION_INSTRUCTIONS.md`.