# Phase 2: Project Linking and Connection Verification Checklist

## Overview

Phase 2 focuses on linking the Supabase CLI to your remote Supabase project and verifying all aspects of connectivity and permissions. This critical phase ensures that your local CLI can communicate with the remote project before attempting any database operations.

**Objective**: Establish a verified connection between the local CLI and the remote Supabase project with confirmed permissions and network accessibility.

## Prerequisites

Before starting Phase 2, verify the following requirements are met:

- [ ] **Phase 1 completed successfully**
  - Check: `setup_cli.bat` completed without errors
  - Check: `verify_auth.bat` returns success status
  - Required: Valid authentication token and API access

- [ ] **Authentication verified via `verify_auth.bat`**
  - Check: Run `verify_auth.bat` and confirm "VERIFICATION SUCCESSFUL"
  - Required: Working API access to Supabase projects
  - Check: `CLI_SETUP_LOG.txt` shows successful authentication

- [ ] **`config.toml` file exists with correct project reference**
  - Check: File exists in the supabase directory
  - Check: Contains `ref = "tzmpwqiaqalrdwdslmkx"`
  - Required: Exact project reference match for successful linking

- [ ] **Internet connection stable**
  - Check: Browser can access https://supabase.com
  - Required: Stable connection for CLI operations
  - Check: No intermittent connectivity issues

- [ ] **No firewall blocking Supabase domains**
  - Check: `test_connection.bat` shows port 443 accessible
  - Required: Access to api.supabase.com and project endpoints
  - Check: Corporate network allows Supabase connections

- [ ] **User has access to project in Supabase dashboard**
  - Check: Can access project at https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx
  - Required: At least Developer role permissions
  - Check: Project is active and not archived

## Pre-flight Checks

Complete these verification steps before running the Phase 2 script:

- [ ] **Phase 1 completed and verified**
  - Action: Run `verify_auth.bat`
  - Expected: "VERIFICATION SUCCESSFUL" message
  - Log: `CLI_SETUP_LOG.txt` shows successful authentication

- [ ] **`verify_auth.bat` returns success**
  - Check: Exit code 0 from verification script
  - Expected: No authentication errors
  - If failed: Complete Phase 1 before proceeding

- [ ] **`config.toml` contains project ref `tzmpwqiaqalrdwdslmkx`**
  - Action: Open `config.toml` and verify project reference
  - Expected: `ref = "tzmpwqiaqalrdwdslmkx"` exactly as shown
  - If incorrect: Copy project reference from Supabase dashboard URL

- [ ] **Internet connection stable**
  - Action: Open browser and visit https://api.supabase.com
  - Expected: Page loads without errors
  - If issues: Resolve network problems before proceeding

- [ ] **No firewall blocking Supabase domains**
  - Action: Run `test_connection.bat` for diagnostics
  - Expected: All network tests pass
  - If blocked: Configure firewall exceptions

- [ ] **User has access to project in Supabase dashboard**
  - Action: Login to Supabase dashboard and navigate to project
  - Expected: Project loads without permission errors
  - If denied: Contact project owner for access

## Network Connectivity Tests

Verify network readiness before attempting project linking:

- [ ] **Run `test_connection.bat` script**
  - Action: Execute the network diagnostic utility
  - Location: `supabase\test_connection.bat`
  - Expected: Script starts comprehensive network testing

- [ ] **Network connectivity test passes**
  - Check: "Network connectivity: [PASS]" in results
  - Expected: Basic internet connection verified
  - If failed: Resolve internet connectivity issues

- [ ] **DNS resolution successful**
  - Check: "DNS resolution: [PASS]" in results
  - Expected: All Supabase domains resolve correctly
  - If failed: Try changing DNS servers or flushing DNS cache

- [ ] **Port 443 accessible**
  - Check: "Port accessibility: [PASS]" in results
  - Expected: HTTPS connections to Supabase domains work
  - If blocked: Configure firewall to allow port 443

- [ ] **No proxy interference detected**
  - Check: "Proxy status: [NOT DETECTED]" or properly configured
  - Expected: Either no proxy or proxy works with Supabase
  - If interfering: Configure proxy settings for CLI

- [ ] **SSL/TLS verification passes**
  - Check: "SSL/TLS status: [PASS]" in results
  - Expected: Certificate validation works
  - If failed: Update system certificates or check date/time

- [ ] **Latency within acceptable range (<500ms)**
  - Check: Average latency measurement in results
  - Expected: Reasonable response times to Supabase API
  - If high: Consider network quality improvements

## Project Linking Steps

Execute the project linking process:

- [ ] **Run `link_project.bat` script**
  - Action: Execute the Phase 2 linking script
  - Location: `supabase\link_project.bat`
  - Expected: Script displays Phase 2 banner

- [ ] **Script displays Phase 2 banner**
  - Check: "Supabase CLI Project Linking and Verification (Phase 2)"
  - Expected: Correct script version and purpose displayed
  - If missing: Ensure running correct script file

- [ ] **Prerequisites verification passes**
  - Check: "[SUCCESS] Phase 1 verification passed"
  - Expected: No authentication errors reported
  - If failed: Complete Phase 1 requirements first

- [ ] **Config validation successful**
  - Check: "[SUCCESS] Project reference found in config.toml"
  - Expected: Configuration file contains correct project reference
  - If failed: Verify `config.toml` contents

- [ ] **`supabase link` command executes**
  - Check: "Running: supabase link --project-ref tzmpwqiaqalrdwdslmkx"
  - Expected: Command executes without immediate errors
  - If fails: Check network connectivity and authentication

- [ ] **Linking completes without errors**
  - Check: "[SUCCESS] Successfully linked to project"
  - Expected: No error messages during linking process
  - If failed: Review error details in log file

- [ ] **Link confirmation message displayed**
  - Check: Clear success message from linking operation
  - Expected: Confirmation that CLI is now linked to project
  - If missing: Check `CLI_SETUP_LOG.txt` for details

## Connection Verification Steps

Verify the established connection is working properly:

- [ ] **`supabase status` command executes**
  - Check: Status command runs without errors
  - Expected: Command completes successfully
  - If fails: Link may not have been established correctly

- [ ] **API URL displayed and accessible**
  - Check: API URL shown in status output
  - Expected: URL format is correct and accessible
  - If missing: Connection to project services may be incomplete

- [ ] **Database URL displayed and accessible**
  - Check: Database URL shown in status output
  - Expected: URL format is correct and accessible
  - If missing: Database connection may have issues

- [ ] **Studio URL displayed and accessible**
  - Check: Studio URL shown in status output
  - Expected: URL format is correct and accessible
  - If missing: Studio service may not be available

- [ ] **All service endpoints respond**
  - Check: No timeout errors in status output
  - Expected: All services are reachable and responding
  - If errors: Network or service issues need resolution

- [ ] **No connection timeout errors**
  - Check: Status operation completes in reasonable time
  - Expected: Quick response from all services
  - if timeouts: Network latency or firewall issues

## Database Permission Tests

Verify database access and permissions:

- [ ] **Database connectivity test passes**
  - Check: "[SUCCESS] Database permission test passed"
  - Expected: CLI can access the database
  - If failed: Check database status and user permissions

- [ ] **Can list database schemas**
  - Check: Database operations return expected results
  - Expected: At least basic database access confirmed
  - If denied: User may lack necessary database permissions

- [ ] **User has necessary permissions**
  - Check: No permission denied errors
  - Expected: User can perform basic database operations
  - If insufficient: Check user role in Supabase dashboard

- [ ] **No permission denied errors**
  - Check: Clean database access without authorization errors
  - Expected: All database commands execute successfully
  - If errors: Verify project membership and role

## Troubleshooting Reference

Use these resources if issues occur during Phase 2:

### Quick Links
- **Network Diagnostics**: `test_connection.bat`
- **Phase 2 Troubleshooting**: `CLI_TROUBLESHOOTING.md` Phase 2 section
- **Log File Location**: `CLI_SETUP_LOG.txt`
- **Configuration Reference**: `config.toml`

### Common Issues and Solutions

1. **"Project not found" Error**
   - Solution: Verify project reference in `config.toml`
   - Check: Copy project ref from Supabase dashboard URL
   - Reference: CLI_TROUBLESHOOTING.md Phase 2 section

2. **"Connection timeout" Error**
   - Solution: Run `test_connection.bat` for network diagnostics
   - Check: Firewall settings and network connectivity
   - Reference: CLI_TROUBLESHOOTING.md network section

3. **"Permission denied" Error**
   - Solution: Verify user role in Supabase dashboard
   - Check: Project membership and access level
   - Reference: CLI_TROUBLESHOOTING.md permission section

4. **"Invalid project reference" Error**
   - Solution: Validate project reference format
   - Check: No extra spaces or special characters
   - Reference: CLI_TROUBLESHOOTING.md configuration section

## Sign-off

Complete this section to confirm Phase 2 completion:

- [ ] **All checks passed**
  - Verification: Review all checkboxes above
  - Requirement: All critical items checked and successful

- [ ] **Project successfully linked**
  - Confirmation: `supabase link` completed without errors
  - Verification: `supabase status` shows project information

- [ ] **Connection verified**
  - Confirmation: All service endpoints accessible
  - Verification: Database permissions confirmed

- [ ] **Ready to proceed to Phase 3**
  - Confirmation: Phase 2 objectives achieved
  - Next step: Run `migrate_with_cli.bat` for migration push

- **Date and time of completion**: ________________________
- **Completed by**: ______________________________________

## Common Failure Points

Be aware of these typical issues where users encounter problems:

### 1. Network/Firewall Issues
- **Symptom**: Connection timeouts or refused connections
- **Quick Fix**: Run `test_connection.bat` and configure firewall
- **Reference**: CLI_TROUBLESHOOTING.md network section

### 2. Incorrect Project Reference
- **Symptom**: "Project not found" or linking failures
- **Quick Fix**: Copy project ref directly from dashboard URL
- **Reference**: CLI_TROUBLESHOOTING.md configuration section

### 3. Insufficient Permissions
- **Symptom**: "Permission denied" during database operations
- **Quick Fix**: Verify user role in Supabase dashboard
- **Reference**: CLI_TROUBLESHOOTING.md permission section

### 4. Authentication Token Issues
- **Symptom**: Linking fails with authentication errors
- **Quick Fix**: Re-run Phase 1 authentication process
- **Reference**: CLI_TROUBLESHOOTING.md authentication section

### 5. Proxy/Corporate Network Issues
- **Symptom**: Connections blocked or redirected
- **Quick Fix**: Configure proxy settings or use different network
- **Reference**: CLI_TROUBLESHOOTING.md proxy section

## Next Steps

After completing Phase 2 successfully:

1. **Phase 3**: Run `migrate_with_cli.bat` to push migrations to the database
2. **Verification**: Test your Flutter app connection to the database
3. **Validation**: Verify that all tables were created correctly
4. **Testing**: Test authentication and CRUD operations
5. **Documentation**: Review `README.md` for complete workflow

---

**Note**: If any step fails, document the issue in `CLI_SETUP_LOG.txt` and refer to `CLI_TROUBLESHOOTING.md` before proceeding to Phase 3.