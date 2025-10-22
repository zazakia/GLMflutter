@echo off
echo Supabase CLI Migration Script
echo ============================
echo.

echo Step 1: Updating Supabase CLI...
supabase update
echo.

echo Step 2: Logging in to Supabase...
supabase login
echo.

echo Step 3: Linking to project...
supabase link --project-ref tzmpwqiaqalrdwdslmkx
echo.

echo Step 4: Checking status...
supabase status
echo.

echo Step 5: Pushing migrations to remote database...
supabase db push
echo.

echo Migration completed!
echo.
pause