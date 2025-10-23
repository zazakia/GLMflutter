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