-- ================================================
-- Test Queries for Migration Verification
-- ================================================
--
-- This file contains sample queries to verify that the Phase 3 migration
-- was applied successfully. Run these queries in the Supabase Dashboard
-- SQL Editor to test all components of the migrated database.
--
-- Usage Instructions:
-- 1. Open Supabase Dashboard: https://supabase.com/dashboard/project/tzmpwqiaqalrdwdslmkx/sql
-- 2. Copy and paste each section into the SQL Editor
-- 3. Execute queries and verify expected results
-- 4. Check for any SQL errors or unexpected results
--
-- Expected Results Summary:
-- - 27 total tables created
-- - 44 problem causes
-- - 21 job tasks
-- - 8 inventory items
-- - 50+ RLS policies
-- - 6 custom types
-- - 6 helper functions
-- - 12+ triggers

-- ================================================
-- Section 1: Table Existence Verification
-- ================================================

-- Query 1.1: List all tables in the public schema
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
-- Expected: 27 tables including organizations, branches, user_profiles, job_orders, etc.

-- Query 1.2: Count total tables created
SELECT COUNT(*) as total_tables
FROM information_schema.tables 
WHERE table_schema = 'public';
-- Expected: 27

-- Query 1.3: Verify core tables exist
SELECT 
    CASE WHEN COUNT(*) = 21 THEN 'PASS' ELSE 'FAIL' END as core_tables_status,
    COUNT(*) as core_tables_found
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'organizations', 'branches', 'user_profiles', 'organization_users', 
    'job_orders', 'job_order_assignments', 'job_status_history', 'job_items',
    'estimates', 'estimate_items', 'invoices', 'invoice_items', 
    'payments', 'inventory_items', 'inventory_stock_movements', 'attachments',
    'messages', 'schedules', 'time_entries', 'signatures', 'event_log'
);
-- Expected: PASS, 21 core_tables_found

-- Query 1.4: Verify service report tables exist
SELECT 
    CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'FAIL' END as service_tables_status,
    COUNT(*) as service_tables_found
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'service_reports', 'service_report_causes', 'service_report_tasks',
    'problem_causes', 'job_tasks', 'service_report_sequences'
);
-- Expected: PASS, 6 service_tables_found

-- ================================================
-- Section 2: Core Schema Verification
-- ================================================

-- Query 2.1: Select from organizations table (should return demo company)
SELECT 
    id,
    name,
    slug,
    country,
    currency,
    timezone,
    tax_rate,
    created_at
FROM organizations 
WHERE name = 'Demo Company';
-- Expected: 1 row with demo organization data

-- Query 2.2: Select from branches table (should return main branch)
SELECT 
    id,
    org_id,
    name,
    address,
    contact_phone,
    contact_email,
    is_active,
    created_at
FROM branches 
WHERE name = 'Main Branch';
-- Expected: 1 row with main branch data

-- Query 2.3: Count rows in user_profiles (should be 0 initially)
SELECT 
    COUNT(*) as user_profiles_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM user_profiles;
-- Expected: 0, PASS

-- Query 2.4: Verify job_orders table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'job_orders'
ORDER BY ordinal_position;
-- Expected: All columns created with correct types

-- Query 2.5: Check foreign key constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'job_orders';
-- Expected: Foreign keys to organizations, branches, user_profiles

-- ================================================
-- Section 3: Service Reports Schema Verification
-- ================================================

-- Query 3.1: Select all from problem_causes (should return 44 rows)
SELECT 
    COUNT(*) as problem_causes_count,
    CASE WHEN COUNT(*) = 44 THEN 'PASS' ELSE 'FAIL' END as status
FROM problem_causes;
-- Expected: 44, PASS

-- Query 3.2: Select first 10 problem causes
SELECT 
    code,
    label,
    is_active,
    sort_order,
    created_at
FROM problem_causes 
ORDER BY sort_order 
LIMIT 10;
-- Expected: 10 rows with problem cause data

-- Query 3.3: Select all from job_tasks (should return 21 rows)
SELECT 
    COUNT(*) as job_tasks_count,
    CASE WHEN COUNT(*) = 21 THEN 'PASS' ELSE 'FAIL' END as status
FROM job_tasks;
-- Expected: 21, PASS

-- Query 3.4: Group job tasks by device scope
SELECT 
    device_scope,
    COUNT(*) as task_count,
    STRING_AGG(label, ', ' ORDER BY sort_order) as tasks
FROM job_tasks 
WHERE is_active = true
GROUP BY device_scope
ORDER BY device_scope;
-- Expected: 3 groups: desktop_laptop, printer, generic

-- Query 3.5: Verify service_reports table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'service_reports'
ORDER BY ordinal_position;
-- Expected: All service report columns created

-- Query 3.6: Test service report numbering sequence
SELECT 
    COUNT(*) as sequence_count
FROM service_report_sequences;
-- Expected: 0 (no sequences created until first service report)

-- ================================================
-- Section 4: Seed Data Verification
-- ================================================

-- Query 4.1: Count problem_causes rows (expected: 44)
SELECT 
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 44 THEN 'All problem causes seeded' 
         WHEN COUNT(*) > 0 THEN 'Some problem causes seeded' 
         ELSE 'No problem causes found' END as status
FROM problem_causes;
-- Expected: 44, All problem causes seeded

-- Query 4.2: Count job_tasks rows (expected: 21)
SELECT 
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 21 THEN 'All job tasks seeded' 
         WHEN COUNT(*) > 0 THEN 'Some job tasks seeded' 
         ELSE 'No job tasks found' END as status
FROM job_tasks;
-- Expected: 21, All job tasks seeded

-- Query 4.3: Verify demo organization exists
SELECT 
    id,
    name,
    slug,
    country,
    currency,
    timezone,
    tax_rate,
    CASE WHEN name = 'Demo Company' THEN 'Demo organization found' 
         ELSE 'Demo organization not found' END as status
FROM organizations 
WHERE name = 'Demo Company';
-- Expected: 1 row with demo organization data

-- Query 4.4: Verify demo branch exists
SELECT 
    id,
    org_id,
    name,
    address,
    contact_phone,
    contact_email,
    CASE WHEN name = 'Main Branch' THEN 'Demo branch found' 
         ELSE 'Demo branch not found' END as status
FROM branches 
WHERE name = 'Main Branch';
-- Expected: 1 row with demo branch data

-- Query 4.5: Count inventory_items (expected: 8)
SELECT 
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 8 THEN 'All inventory items seeded' 
         WHEN COUNT(*) > 0 THEN 'Some inventory items seeded' 
         ELSE 'No inventory items found' END as status
FROM inventory_items;
-- Expected: 8, All inventory items seeded

-- Query 4.6: List all inventory items with details
SELECT 
    sku,
    name,
    category,
    cost_price,
    selling_price,
    stock_quantity,
    currency
FROM inventory_items 
ORDER BY category, name;
-- Expected: 8 items with services and parts

-- Query 4.7: Verify inventory categories
SELECT 
    category,
    COUNT(*) as item_count,
    SUM(selling_price) as total_value
FROM inventory_items 
GROUP BY category
ORDER BY category;
-- Expected: 2 categories: Service, Parts

-- ================================================
-- Section 5: RLS Policy Verification
-- ================================================

-- Query 5.1: List all RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
-- Expected: 50+ policies across all tables

-- Query 5.2: Count policies per table
SELECT 
    tablename,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;
-- Expected: Multiple policies per table

-- Query 5.3: Verify RLS is enabled on all tables
SELECT 
    t.table_name,
    CASE WHEN c.relrowsecurity THEN 'ENABLED' ELSE 'DISABLED' END as rls_status
FROM information_schema.tables t
JOIN pg_class c ON c.relname = t.table_name
WHERE t.table_schema = 'public'
AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;
-- Expected: All tables show ENABLED

-- Query 5.4: Count total RLS policies
SELECT 
    COUNT(*) as total_policies,
    CASE WHEN COUNT(*) >= 50 THEN 'Sufficient policies' 
         WHEN COUNT(*) > 0 THEN 'Insufficient policies' 
         ELSE 'No policies found' END as status
FROM pg_policies 
WHERE schemaname = 'public';
-- Expected: 50+, Sufficient policies

-- ================================================
-- Section 6: Function Verification
-- ================================================

-- Query 6.1: List all custom functions
SELECT 
    proname,
    prosrc,
    prorettype::regtype as return_type,
    proargtypes::regtype[] as argument_types
FROM pg_proc 
WHERE pronamespace = 'public'::regnamespace
AND proname NOT LIKE 'pg_%'
ORDER BY proname;
-- Expected: 6+ helper functions

-- Query 6.2: Test is_org_member function (will return false without auth context)
SELECT 
    proname,
    'is_org_member' as function_name,
    'Function exists' as test_result
FROM pg_proc 
WHERE proname = 'is_org_member' 
AND pronamespace = 'public'::regnamespace;
-- Expected: 1 row confirming function exists

-- Query 6.3: Test user_org_role function
SELECT 
    proname,
    'user_org_role' as function_name,
    'Function exists' as test_result
FROM pg_proc 
WHERE proname = 'user_org_role' 
AND pronamespace = 'public'::regnamespace;
-- Expected: 1 row confirming function exists

-- Query 6.4: Test can_access_job function
SELECT 
    proname,
    'can_access_job' as function_name,
    'Function exists' as test_result
FROM pg_proc 
WHERE proname = 'can_access_job' 
AND pronamespace = 'public'::regnamespace;
-- Expected: 1 row confirming function exists

-- Query 6.5: Test update_updated_at_column function
SELECT 
    proname,
    'update_updated_at_column' as function_name,
    'Function exists' as test_result
FROM pg_proc 
WHERE proname = 'update_updated_at_column' 
AND pronamespace = 'public'::regnamespace;
-- Expected: 1 row confirming function exists

-- Query 6.6: Test generate_service_report_number function
SELECT 
    proname,
    'generate_service_report_number' as function_name,
    'Function exists' as test_result
FROM pg_proc 
WHERE proname = 'generate_service_report_number' 
AND pronamespace = 'public'::regnamespace;
-- Expected: 1 row confirming function exists

-- Query 6.7: Test calculate_service_report_totals function
SELECT 
    proname,
    'calculate_service_report_totals' as function_name,
    'Function exists' as test_result
FROM pg_proc 
WHERE proname = 'calculate_service_report_totals' 
AND pronamespace = 'public'::regnamespace;
-- Expected: 1 row confirming function exists

-- ================================================
-- Section 7: Trigger Verification
-- ================================================

-- Query 7.1: List all triggers
SELECT 
    tgname as trigger_name,
    tgrelid::regclass as table_name,
    tgfoid::regproc as function_name,
    tgtype as trigger_type,
    tgenabled as enabled_status
FROM pg_trigger 
WHERE tgisinternal = false
ORDER BY table_name, trigger_name;
-- Expected: 12+ triggers for updated_at columns and other functions

-- Query 7.2: Count triggers per table
SELECT 
    tgrelid::regclass as table_name,
    COUNT(*) as trigger_count
FROM pg_trigger 
WHERE tgisinternal = false
GROUP BY table_name
ORDER BY table_name;
-- Expected: Multiple tables with triggers

-- Query 7.3: Count total triggers
SELECT 
    COUNT(*) as total_triggers,
    CASE WHEN COUNT(*) >= 12 THEN 'Sufficient triggers' 
         WHEN COUNT(*) > 0 THEN 'Insufficient triggers' 
         ELSE 'No triggers found' END as status
FROM pg_trigger 
WHERE tgisinternal = false;
-- Expected: 12+, Sufficient triggers

-- Query 7.4: Verify updated_at triggers exist on key tables
SELECT 
    tgrelid::regclass as table_name,
    tgname as trigger_name,
    CASE WHEN tgname LIKE '%updated_at%' THEN 'Update trigger' ELSE 'Other trigger' END as trigger_type
FROM pg_trigger 
WHERE tgisinternal = false
AND tgrelid::regclass IN ('organizations', 'branches', 'user_profiles', 'job_orders', 'service_reports')
ORDER BY table_name, trigger_name;
-- Expected: Update triggers on all listed tables

-- ================================================
-- Section 8: Custom Type Verification
-- ================================================

-- Query 8.1: List all custom ENUM types
SELECT 
    typname as type_name,
    typtype as type_category,
    'ENUM' as type_classification
FROM pg_type 
WHERE typtype = 'e'
AND typnamespace = 'public'::regnamespace
ORDER BY typname;
-- Expected: 8 custom ENUM types

-- Query 8.2: Show enum values for org_role type
SELECT 
    unnest(enum_range(NULL::org_role)) as org_role_values;
-- Expected: owner, admin, staff, technician, client

-- Query 8.3: Show enum values for job_status type
SELECT 
    unnest(enum_range(NULL::job_status)) as job_status_values;
-- Expected: draft, assigned, in_progress, completed, cancelled

-- Query 8.4: Show enum values for device_type type
SELECT 
    unnest(enum_range(NULL::device_type)) as device_type_values;
-- Expected: desktop, laptop, printer, monitor, projector, charger, ups, other

-- Query 8.5: Count all custom types
SELECT 
    COUNT(*) as total_types,
    CASE WHEN COUNT(*) = 8 THEN 'All expected types found' 
         WHEN COUNT(*) > 0 THEN 'Some types found' 
         ELSE 'No types found' END as status
FROM pg_type 
WHERE typtype = 'e'
AND typnamespace = 'public'::regnamespace;
-- Expected: 8, All expected types found

-- ================================================
-- Section 9: Index Verification
-- ================================================

-- Query 9.1: List all indexes
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- Expected: Multiple indexes for performance

-- Query 9.2: Count indexes on service_reports table
SELECT 
    COUNT(*) as index_count
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename = 'service_reports';
-- Expected: 6+ indexes for service reports

-- Query 9.3: Count total indexes
SELECT 
    COUNT(*) as total_indexes,
    CASE WHEN COUNT(*) >= 20 THEN 'Sufficient indexes' 
         WHEN COUNT(*) > 0 THEN 'Some indexes found' 
         ELSE 'No indexes found' END as status
FROM pg_indexes 
WHERE schemaname = 'public';
-- Expected: 20+, Sufficient indexes

-- Query 9.4: Verify primary key indexes exist
SELECT 
    tablename,
    COUNT(*) as pk_indexes
FROM pg_indexes 
WHERE schemaname = 'public'
AND indexname LIKE '%_pkey'
GROUP BY tablename
ORDER BY tablename;
-- Expected: PK indexes on all tables

-- ================================================
-- Section 10: Sample Data Queries
-- ================================================

-- Query 10.1: Show all problem causes with labels
SELECT 
    code,
    label,
    is_active,
    sort_order
FROM problem_causes 
ORDER BY sort_order
LIMIT 10;
-- Expected: First 10 problem causes in order

-- Query 10.2: Show job tasks grouped by device_scope
SELECT 
    device_scope,
    STRING_AGG(
        label || ' (' || result_type || ')', 
        ', ' 
        ORDER BY sort_order
    ) as tasks
FROM job_tasks 
WHERE is_active = true
GROUP BY device_scope
ORDER BY device_scope;
-- Expected: Formatted list of tasks by device type

-- Query 10.3: Show inventory items with pricing
SELECT 
    category,
    sku,
    name,
    cost_price,
    selling_price,
    selling_price - cost_price as profit,
    stock_quantity,
    currency
FROM inventory_items 
ORDER BY category, selling_price DESC;
-- Expected: 8 items with profit calculations

-- Query 10.4: Verify demo organization structure
SELECT 
    o.name as organization_name,
    o.country,
    o.currency,
    o.timezone,
    b.name as branch_name,
    b.address,
    b.contact_phone,
    b.contact_email
FROM organizations o
LEFT JOIN branches b ON o.id = b.org_id
WHERE o.name = 'Demo Company';
-- Expected: Demo organization with main branch

-- Query 10.5: Show sample data summary
SELECT 
    'Problem Causes' as data_type,
    COUNT(*) as record_count
FROM problem_causes
UNION ALL
SELECT 
    'Job Tasks',
    COUNT(*)
FROM job_tasks
UNION ALL
SELECT 
    'Organizations',
    COUNT(*)
FROM organizations
UNION ALL
SELECT 
    'Branches',
    COUNT(*)
FROM branches
UNION ALL
SELECT 
    'Inventory Items',
    COUNT(*)
FROM inventory_items;
-- Expected: Summary of all seed data

-- ================================================
-- Section 11: Relationship Verification
-- ================================================

-- Query 11.1: Verify foreign key constraints exist
SELECT 
    tc.constraint_name,
    tc.table_name as source_table,
    kcu.column_name as source_column,
    ccu.table_name as target_table,
    ccu.column_name as target_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;
-- Expected: List of all foreign key relationships

-- Query 11.2: Test cascade delete behavior (without actually deleting)
SELECT
    tc.table_name as child_table,
    rc.delete_rule as delete_action,
    ccu.table_name as parent_table
FROM information_schema.table_constraints tc
JOIN information_schema.referential_constraints rc
  ON tc.constraint_name = rc.constraint_name
  AND tc.constraint_schema = rc.constraint_schema
JOIN information_schema.constraint_column_usage ccu
  ON rc.unique_constraint_name = ccu.constraint_name
  AND rc.unique_constraint_schema = ccu.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.constraint_schema = 'public'
  AND tc.table_name = 'branches'
  AND ccu.table_name = 'organizations';
-- Expected: 1 row showing branches → organizations with CASCADE delete

-- Query 11.3: Verify referential integrity
SELECT 
    c.table_name,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'public'
AND c.table_name = 'job_orders'
AND c.column_name IN ('org_id', 'branch_id', 'client_id', 'created_by')
ORDER BY c.ordinal_position;
-- Expected: Foreign key columns with proper types

-- ================================================
-- Section 12: Performance Test Queries
-- ================================================

-- Query 12.1: Test index usage on service_reports (EXPLAIN ANALYZE)
EXPLAIN ANALYZE
SELECT * FROM service_reports 
WHERE created_at >= NOW() - INTERVAL '30 days'
ORDER BY created_at DESC
LIMIT 10;
-- Expected: Index scan on created_at index

-- Query 12.2: Test RLS policy performance (EXPLAIN ANALYZE)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM organizations;
-- Expected: Efficient query with RLS policy evaluation

-- Query 12.3: Test join performance
EXPLAIN ANALYZE
SELECT 
    o.name as org_name,
    b.name as branch_name,
    COUNT(*) as report_count
FROM organizations o
LEFT JOIN branches b ON o.id = b.org_id
LEFT JOIN service_reports sr ON b.id = sr.branch_id
GROUP BY o.id, b.id
ORDER BY org_name, branch_name;
-- Expected: Efficient join using indexes

-- ================================================
-- Section 13: Quick Verification Summary
-- ================================================

-- Query 13.1: Complete verification summary
WITH table_counts AS (
    SELECT 
        COUNT(*) as total_tables
    FROM information_schema.tables 
    WHERE table_schema = 'public'
),
policy_counts AS (
    SELECT 
        COUNT(*) as total_policies
    FROM pg_policies 
    WHERE schemaname = 'public'
),
function_counts AS (
    SELECT 
        COUNT(*) as total_functions
    FROM pg_proc 
    WHERE pronamespace = 'public'::regnamespace
    AND proname NOT LIKE 'pg_%'
),
trigger_counts AS (
    SELECT 
        COUNT(*) as total_triggers
    FROM pg_trigger 
    WHERE tgisinternal = false
),
type_counts AS (
    SELECT 
        COUNT(*) as total_types
    FROM pg_type 
    WHERE typtype = 'e'
    AND typnamespace = 'public'::regnamespace
),
data_counts AS (
    SELECT 
        (SELECT COUNT(*) FROM problem_causes) as problem_causes,
        (SELECT COUNT(*) FROM job_tasks) as job_tasks,
        (SELECT COUNT(*) FROM organizations) as organizations,
        (SELECT COUNT(*) FROM branches) as branches,
        (SELECT COUNT(*) FROM inventory_items) as inventory_items
)
SELECT 
    'Migration Verification Summary' as metric_type,
    tc.total_tables as tables_created,
    pc.total_policies as rls_policies,
    fc.total_functions as functions_created,
    tr.total_triggers as triggers_created,
    ty.total_types as types_created,
    dc.problem_causes as problem_causes_data,
    dc.job_tasks as job_tasks_data,
    dc.organizations as organizations_data,
    dc.branches as branches_data,
    dc.inventory_items as inventory_items_data,
    CASE 
        WHEN tc.total_tables = 27
             AND pc.total_policies >= 50 
             AND fc.total_functions >= 6 
             AND tr.total_triggers >= 12 
             AND ty.total_types = 8 
             AND dc.problem_causes = 44 
             AND dc.job_tasks = 21 
             AND dc.organizations = 1 
             AND dc.branches = 1 
             AND dc.inventory_items = 8 
        THEN 'VERIFICATION SUCCESSFUL'
        ELSE 'VERIFICATION FAILED'
    END as overall_status
FROM table_counts tc, policy_counts pc, function_counts fc, trigger_counts tr, type_counts ty, data_counts dc;
-- Expected: All metrics match expected values with VERIFICATION SUCCESSFUL

-- ================================================
-- Usage Instructions
-- ================================================
/*
HOW TO USE THESE TEST QUERIES:

1. BASIC VERIFICATION (Required):
   - Run Query 1.2: Should return 27 tables
   - Run Query 4.1: Should return 44 problem causes
   - Run Query 4.2: Should return 21 job tasks
   - Run Query 4.5: Should return 8 inventory items
   - Run Query 13.1: Should show VERIFICATION SUCCESSFUL

2. DETAILED VERIFICATION (Optional but Recommended):
   - Run Section 1: Verify all tables exist
   - Run Section 2: Check core schema structure
   - Run Section 3: Verify service reports schema
   - Run Section 4: Confirm seed data is present
   - Run Section 5: Check RLS policies
   - Run Section 6: Verify helper functions
   - Run Section 7: Check triggers
   - Run Section 8: Verify custom types
   - Run Section 9: Check indexes

3. TROUBLESHOOTING:
   - If any query fails, check the specific section related to the failure
   - Review error messages in the SQL Editor
   - Check CLI_SETUP_LOG.txt for detailed migration logs
   - Refer to CLI_TROUBLESHOOTING.md Phase 3 section

4. EXPECTED RESULTS:
   - All queries should execute without SQL errors
   - Row counts should match expected values in comments
   - Overall status should be "VERIFICATION SUCCESSFUL"

5. NEXT STEOPS AFTER SUCCESS:
   - Configure Flutter app with Supabase credentials
   - Test authentication from Flutter app
   - Test CRUD operations on all tables
   - Verify RLS policies work correctly
   - Begin application development
*/