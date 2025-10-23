# Phase 1: CLI Setup and Authentication Checklist

## Overview

Phase 1 focuses on installing/updating the Supabase CLI and establishing authentication with your Supabase account. This is a critical first step before attempting any database migrations.

**Objective**: Ensure the Supabase CLI is properly installed, updated, and authenticated so you can successfully connect to your Supabase project.

## Pre-flight Checks

Before starting Phase 1, verify the following prerequisites:

- [ ] **Windows OS version compatible** (Windows 10/11)
  - Check: Press Win+R, type `winver`, and press Enter
  - Required: Windows 10 version 1903 or later, or Windows 11

- [ ] **Internet connection active**
  - Check: Open a browser and visit https://supabase.com
  - Required: Stable internet connection for CLI operations

- [ ] **Supabase account created and accessible**
  - Check: Login to https://supabase.com/dashboard
  - Required: Active Supabase account with project access

- [ ] **Default browser configured for OAuth**
  - Check: Default browser opens when clicking links
  - Required: Browser that can handle OAuth redirects

- [ ] **Firewall/antivirus not blocking Supabase domains**
  - Check: No security software blocking supabase.com domains
  - Required: Access to api.supabase.com and related services

## Installation Steps

Follow these steps to install or update the Supabase CLI:

- [ ] **Run `setup_cli.bat` script**
  - Action: Double-click the file or run from command prompt
  - Location: `supabase\setup_cli.bat`
  - Expected: Script starts and displays Phase 1 banner

- [ ] **Verify CLI version displayed**
  - Check: Script shows current Supabase CLI version
  - Expected: Version number like "1.50.0" or similar
  - If missing: CLI not installed or not in PATH

- [ ] **Confirm update completed successfully**
  - Check: Script reports successful update or continues with current version
  - Expected: "Supabase CLI updated successfully" or continuation message
  - If failed: Note error message in log

- [ ] **Note any error messages in the log**
  - Check: Review `CLI_SETUP_LOG.txt` for any ERROR entries
  - Expected: No critical errors during update process
  - If errors: Document them for troubleshooting

## Authentication Steps

Complete the authentication process:

- [ ] **`supabase login` command executed**
  - Action: Script prompts you to run login command
  - Expected: Browser opens for Supabase login
  - Action: Complete login in browser

- [ ] **Browser opened for OAuth flow**
  - Check: Default browser opens to Supabase login page
  - Expected: Supabase dashboard login screen appears
  - If blocked: Check browser settings and security software

- [ ] **Successfully logged in via browser**
  - Action: Enter credentials and complete authentication
  - Expected: Success message in browser
  - Expected: Script reports "Login command completed"

- [ ] **Access token file created at `%USERPROFILE%\.supabase\access-token`**
  - Check: File exists at the specified path
  - Action: Open File Explorer, navigate to `%USERPROFILE%\.supabase\`
  - Expected: `access-token` file present

- [ ] **Token file has recent timestamp**
  - Check: File modification date is current
  - Expected: Today's date and recent time
  - If old: Token may be expired, re-run authentication

## Verification Steps

Verify that authentication is working correctly:

- [ ] **Run `verify_auth.bat` script**
  - Action: Execute the verification script
  - Location: `supabase\verify_auth.bat`
  - Expected: Script starts authentication verification

- [ ] **`supabase projects list` returns project list**
  - Check: Script reports successful API connectivity
  - Expected: "API connectivity verified" message
  - Expected: Shows count of projects in your account

- [ ] **No authentication errors displayed**
  - Check: No ERROR messages in verification output
  - Expected: Clean verification process
  - If errors: Document specific error messages

- [ ] **Log file shows successful verification**
  - Check: `CLI_SETUP_LOG.txt` shows success entries
  - Expected: "Overall verification: SUCCESS" entry
  - Expected: No authentication-related errors

## Troubleshooting Reference

If you encounter issues, refer to these resources:

### Quick Links
- **CLI Troubleshooting Guide**: `CLI_TROUBLESHOOTING.md`
- **Log File Location**: `CLI_SETUP_LOG.txt`
- **Supabase CLI Documentation**: https://supabase.com/docs/guides/cli

### Common Issues and Solutions

1. **CLI not found**
   - Solution: Install via npm (`npm install -g supabase`) or Scoop
   - Reference: CLI_TROUBLESHOOTING.md Phase 1 section

2. **Authentication fails**
   - Solution: Check browser, clear cache, try again
   - Reference: CLI_TROUBLESHOOTING.md troubleshooting steps

3. **Network connectivity issues**
   - Solution: Check firewall, try different network, use VPN
   - Reference: CLI_TROUBLESHOOTING.md network section

4. **Access token not created**
   - Solution: Check permissions, re-run login command
   - Reference: CLI_TROUBLESHOOTING.md permission issues

## Sign-off

Complete this section to confirm Phase 1 completion:

- [ ] **All checks passed**
  - Verification: Review all checkboxes above
  - Requirement: All critical items checked

- [ ] **Ready to proceed to Phase 2**
  - Confirmation: CLI is authenticated and working
  - Next step: Run `migrate_with_cli.bat` for Phase 2

- **Date and time of completion**: ________________________
- **Completed by**: ______________________________________

## Common Failure Points

Be aware of these typical issues where users encounter problems:

### 1. Network/Firewall Issues
- **Symptom**: Commands timeout or fail with network errors
- **Quick Fix**: Temporarily disable firewall or add exception
- **Reference**: CLI_TROUBLESHOOTING.md network section

### 2. Browser OAuth Issues
- **Symptom**: Browser doesn't open or login fails
- **Quick Fix**: Clear browser cache, try different browser
- **Reference**: CLI_TROUBLESHOOTING.md browser section

### 3. Permission Issues
- **Symptom**: Cannot create access token file
- **Quick Fix**: Run command prompt as administrator
- **Reference**: CLI_TROUBLESHOOTING.md permissions section

### 4. CLI PATH Issues
- **Symptom**: `supabase` command not found
- **Quick Fix**: Reinstall CLI or add to PATH manually
- **Reference**: CLI_TROUBLESHOOTING.md installation section

## Next Steps

After completing Phase 1 successfully:

1. **Phase 2**: Run `migrate_with_cli.bat` to link project and push migrations
2. **Verification**: Test your Flutter app connection to the database
3. **Documentation**: Review `README.md` for complete migration workflow

---

**Note**: If any step fails, document the issue in `CLI_SETUP_LOG.txt` and refer to `CLI_TROUBLESHOOTING.md` before proceeding.