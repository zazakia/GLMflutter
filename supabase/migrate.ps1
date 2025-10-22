# Read environment variables from .env file
$envContent = Get-Content ../.env
$supabaseUrl = ($envContent | Where-Object { $_ -match "SUPABASE_URL=" }).Split("=")[1]
$supabaseServiceRoleKey = ($envContent | Where-Object { $_ -match "SUPABASE_SERVICE_ROLE_KEY=" }).Split("=")[1]

# Set environment variables
$env:SUPABASE_URL = $supabaseUrl
$env:SUPABASE_SERVICE_ROLE_KEY = $supabaseServiceRoleKey

Write-Host "Running migration..."
Write-Host "SUPABASE_URL=$supabaseUrl"
Write-Host "SUPABASE_SERVICE_ROLE_KEY=$supabaseServiceRoleKey"

# Run the migration script
dart run migrate_remote.dart

Read-Host -Prompt "Press Enter to exit..."