-- Create a demo admin user for development
-- This script should be run in the Supabase SQL Editor after the migrations are complete

-- First, create the user in auth.users
INSERT INTO auth.users (
    id,
    email,
    email_confirmed_at,
    phone,
    phone_confirmed_at,
    created_at,
    updated_at,
    last_sign_in_at,
    raw_user_meta_data,
    is_super_admin,
    app_metadata
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'admin@demo-company.com',
    NOW(),
    NULL,
    NULL,
    NOW(),
    NOW(),
    NOW(),
    '{"name": "Demo Admin"}',
    false,
    '{"provider": "email", "providers": ["email"]}'
) ON CONFLICT (id) DO NOTHING;

-- Then create the user profile
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
    '00000000-0000-0000-0000-000000000001',
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
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'owner',
    'active',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    NOW()
) ON CONFLICT (org_id, user_id) DO NOTHING;

-- Set the password for the demo user
-- Note: This needs to be done through the Supabase Auth API or dashboard
-- The password should be: demo123456