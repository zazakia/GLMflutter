@echo off
setlocal enabledelayedexpansion

REM Read environment variables from .env file
for /f "tokens=2 delims==" %%a in ('findstr SUPABASE_URL ../.env') do set SUPABASE_URL=%%a
for /f "tokens=2 delims==" %%a in ('findstr SUPABASE_SERVICE_ROLE_KEY ../.env') do set SUPABASE_SERVICE_ROLE_KEY=%%a

echo Running migration...
echo SUPABASE_URL=%SUPABASE_URL%
echo SUPABASE_SERVICE_ROLE_KEY=%SUPABASE_SERVICE_ROLE_KEY%

REM Set environment variables
set SUPABASE_URL=%SUPABASE_URL%
set SUPABASE_SERVICE_ROLE_KEY=%SUPABASE_SERVICE_ROLE_KEY%

dart run migrate_remote.dart

pause