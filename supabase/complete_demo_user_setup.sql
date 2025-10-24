-- Complete Demo User Setup
-- Run this script in Supabase SQL Editor after the fix_demo_user.dart script
-- This will create the user profile and organization associations

-- Create user profile for the demo user
INSERT INTO user_profiles (
    id,
    org_id,
    branch_id,
    role,
    display_name,
    phone,
    created_at,
    updated_at
) VALUES (
    'b3ccb488-3244-43b4-afae-d83f611a1ad2', -- Use the actual user ID from the auth.users table
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'owner',
    'Demo Admin',
    '+639123456789',
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Add the user to organization_users
INSERT INTO organization_users (
    id,
    org_id,
    user_id,
    role,
    status,
    invited_by,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000001',
    'b3ccb488-3244-43b4-afae-d83f611a1ad2', -- Use the actual user ID from the auth.users table
    'owner',
    'active',
    'b3ccb488-3244-43b4-afae-d83f611a1ad2',
    NOW(),
    NOW()
) ON CONFLICT (org_id, user_id) DO NOTHING;

-- Verify the setup
SELECT 
    u.email,
    u.id as user_id,
    up.display_name,
    up.role as user_role,
    o.name as organization,
    b.name as branch
FROM auth.users u
LEFT JOIN user_profiles up ON u.id = up.id
LEFT JOIN organization_users ou ON u.id = ou.user_id
LEFT JOIN organizations o ON ou.org_id = o.id
LEFT JOIN branches b ON up.branch_id = b.id
WHERE u.email = 'admin@demo-company.com';