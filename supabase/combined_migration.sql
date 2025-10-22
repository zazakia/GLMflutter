-- COMBINED MIGRATION SCRIPT FOR SUPABASE 
-- This file contains all migration scripts in the correct order 
-- Generated on Thu 10/23/2025 at  0:39:48.18 
 
-- ===================================================== 
-- 1. CREATE CORE SCHEMA 
-- ===================================================== 
-- Core multi-tenant schema for Job Order Management System
-- Migration: 20240101000001_create_core_schema.sql

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE org_role AS ENUM ('owner', 'admin', 'staff', 'technician', 'client');
CREATE TYPE job_status AS ENUM ('draft', 'assigned', 'in_progress', 'completed', 'cancelled');
CREATE TYPE estimate_status AS ENUM ('draft', 'sent', 'approved', 'rejected', 'expired');
CREATE TYPE invoice_status AS ENUM ('draft', 'sent', 'paid', 'overdue', 'cancelled');
CREATE TYPE payment_method AS ENUM ('cash', 'bank_transfer', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE device_type AS ENUM ('desktop', 'laptop', 'printer', 'monitor', 'projector', 'charger', 'ups', 'other');
CREATE TYPE signature_role AS ENUM ('customer', 'technician', 'staff', 'admin');

-- Organizations table for multi-tenancy
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    country TEXT NOT NULL DEFAULT 'PH',
    currency TEXT NOT NULL DEFAULT 'PHP',
    timezone TEXT NOT NULL DEFAULT 'Asia/Manila',
    tax_rate DECIMAL(5,4) DEFAULT 0.1200, -- 12% PH VAT
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Branches table for organization locations
CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User profiles linked to auth.users
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    role org_role NOT NULL,
    display_name TEXT NOT NULL,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Organization users mapping for explicit invites and status tracking
CREATE TABLE organization_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role org_role NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    invited_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(org_id, user_id)
);

-- Job orders table
CREATE TABLE job_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    client_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
    created_by UUID NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
    status job_status NOT NULL DEFAULT 'draft',
    title TEXT NOT NULL,
    description TEXT,
    location TEXT,
    scheduled_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'PHP',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job order assignments
CREATE TABLE job_order_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES job_orders(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    role org_role NOT NULL, -- staff or technician
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_by UUID REFERENCES user_profiles(id),
    notes TEXT,
    UNIQUE(job_id, user_id)
);

-- Job status history
CREATE TABLE job_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES job_orders(id) ON DELETE CASCADE,
    from_status job_status,
    to_status job_status NOT NULL,
    changed_by UUID NOT NULL REFERENCES user_profiles(id),
    notes TEXT,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job items (services and parts)
CREATE TABLE job_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    job_id UUID REFERENCES job_orders(id) ON DELETE CASCADE,
    report_id UUID, -- Will be linked to service_reports later
    description TEXT NOT NULL,
    part_serial_number TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    tax_rate DECIMAL(5,4) DEFAULT 0.1200,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    line_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    is_service BOOLEAN DEFAULT false,
    currency TEXT NOT NULL DEFAULT 'PHP',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Estimates table
CREATE TABLE estimates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    job_id UUID REFERENCES job_orders(id) ON DELETE CASCADE,
    status estimate_status NOT NULL DEFAULT 'draft',
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'PHP',
    valid_until TIMESTAMPTZ,
    notes TEXT,
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMPTZ,
    created_by UUID NOT NULL REFERENCES user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Estimate items
CREATE TABLE estimate_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    estimate_id UUID NOT NULL REFERENCES estimates(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    tax_rate DECIMAL(5,4) DEFAULT 0.1200,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    line_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoices table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    job_id UUID REFERENCES job_orders(id) ON DELETE CASCADE,
    estimate_id UUID REFERENCES estimates(id) ON DELETE SET NULL,
    status invoice_status NOT NULL DEFAULT 'draft',
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    balance_amount DECIMAL(12,2) DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'PHP',
    due_date TIMESTAMPTZ,
    notes TEXT,
    created_by UUID NOT NULL REFERENCES user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoice items
CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    tax_rate DECIMAL(5,4) DEFAULT 0.1200,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    line_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    method payment_method NOT NULL,
    status payment_status NOT NULL DEFAULT 'pending',
    reference_number TEXT,
    notes TEXT,
    processed_by UUID REFERENCES user_profiles(id),
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory items
CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    sku TEXT NOT NULL,
    barcode TEXT,
    name TEXT NOT NULL,
    category TEXT,
    description TEXT,
    cost_price DECIMAL(12,2) DEFAULT 0,
    selling_price DECIMAL(12,2) DEFAULT 0,
    stock_quantity INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    currency TEXT NOT NULL DEFAULT 'PHP',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(org_id, sku)
);

-- Inventory stock movements
CREATE TABLE inventory_stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    movement_type TEXT NOT NULL, -- 'adjustment', 'issue', 'return', 'purchase'
    quantity INTEGER NOT NULL, -- positive for increase, negative for decrease
    reference_id UUID, -- Can reference job_id, purchase_id, etc.
    reason TEXT,
    created_by UUID REFERENCES user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attachments table
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    record_type TEXT NOT NULL, -- 'job_order', 'service_report', 'invoice', etc.
    record_id UUID NOT NULL,
    category TEXT, -- 'before_photo', 'during_photo', 'after_photo', 'document', etc.
    storage_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size BIGINT,
    uploaded_by UUID NOT NULL REFERENCES user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages table for job communications
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    job_id UUID NOT NULL REFERENCES job_orders(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES user_profiles(id),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Schedules table
CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    job_id UUID NOT NULL REFERENCES job_orders(id) ON DELETE CASCADE,
    technician_id UUID NOT NULL REFERENCES user_profiles(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'scheduled',
    notes TEXT,
    created_by UUID REFERENCES user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Time entries for technician tracking
CREATE TABLE time_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    job_id UUID NOT NULL REFERENCES job_orders(id) ON DELETE CASCADE,
    technician_id UUID NOT NULL REFERENCES user_profiles(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration_minutes INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Signatures table
CREATE TABLE signatures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    record_type TEXT NOT NULL, -- 'job_order', 'service_report', 'invoice'
    record_id UUID NOT NULL,
    role signature_role NOT NULL,
    signer_name TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    signed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event log for auditing
CREATE TABLE event_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    record_type TEXT,
    record_id UUID,
    user_id UUID REFERENCES user_profiles(id),
    details JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Update timestamp triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at columns
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON branches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_organization_users_updated_at BEFORE UPDATE ON organization_users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_job_orders_updated_at BEFORE UPDATE ON job_orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_job_items_updated_at BEFORE UPDATE ON job_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_estimates_updated_at BEFORE UPDATE ON estimates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_time_entries_updated_at BEFORE UPDATE ON time_entries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 
-- ===================================================== 
-- 2. CREATE SERVICE REPORTS SCHEMA 
-- ===================================================== 
-- Service Reports schema for Job Order Management System
-- Migration: 20240101000002_create_service_reports_schema.sql

-- Problem causes lookup table
CREATE TABLE problem_causes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job performed tasks lookup table
CREATE TABLE job_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    device_scope TEXT NOT NULL, -- 'desktop_laptop', 'printer', 'generic'
    result_type TEXT NOT NULL, -- 'pass_fail', 'good_bad', 'ok_not_ok', 'none'
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service reports numbering sequence
CREATE TABLE service_report_sequences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    year_month TEXT NOT NULL, -- Format: YYYYMM
    sequence_value INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(org_id, year_month)
);

-- Service reports table
CREATE TABLE service_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    job_id UUID NOT NULL REFERENCES job_orders(id) ON DELETE CASCADE,
    reference_no TEXT NOT NULL UNIQUE,
    
    -- Customer information
    customer_name TEXT NOT NULL,
    customer_contact TEXT,
    customer_address TEXT,
    branch_display_name TEXT,
    
    -- Dates
    date_received DATE NOT NULL,
    date_released DATE,
    
    -- Device information
    device_type device_type NOT NULL,
    device_type_other TEXT,
    serial_number TEXT,
    
    -- Problem and troubleshooting
    problem_reported TEXT,
    other_troubleshooting TEXT,
    issue_resolved BOOLEAN DEFAULT false,
    recommendation TEXT,
    
    -- Financial information
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'PHP',
    
    -- Metadata
    created_by UUID NOT NULL REFERENCES user_profiles(id),
    technician_id UUID REFERENCES user_profiles(id),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service report causes (many-to-many relationship)
CREATE TABLE service_report_causes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES service_reports(id) ON DELETE CASCADE,
    cause_id UUID NOT NULL REFERENCES problem_causes(id) ON DELETE CASCADE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(report_id, cause_id)
);

-- Service report tasks (many-to-many relationship with results)
CREATE TABLE service_report_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES service_reports(id) ON DELETE CASCADE,
    task_id UUID NOT NULL REFERENCES job_tasks(id) ON DELETE CASCADE,
    result_value TEXT, -- 'pass', 'fail', 'good', 'bad', 'ok', 'not_ok', 'na'
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(report_id, task_id)
);

-- Update timestamp trigger for service_reports and sequences
CREATE TRIGGER update_service_reports_updated_at BEFORE UPDATE ON service_reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_service_report_sequences_updated_at BEFORE UPDATE ON service_report_sequences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate service report reference number
CREATE OR REPLACE FUNCTION generate_service_report_number()
RETURNS TRIGGER AS $$
DECLARE
    year_month TEXT;
    sequence_record RECORD;
    new_reference_no TEXT;
BEGIN
    -- Get current year_month in YYYYMM format
    year_month := TO_CHAR(NOW(), 'YYYYMM');
    
    -- Try to get existing sequence for this org and month
    SELECT * INTO sequence_record 
    FROM service_report_sequences 
    WHERE org_id = NEW.org_id AND year_month = service_report_sequences.year_month
    FOR UPDATE;
    
    IF FOUND THEN
        -- Increment existing sequence
        UPDATE service_report_sequences 
        SET sequence_value = sequence_value + 1 
        WHERE id = sequence_record.id;
        new_reference_no := 'SR-' || year_month || '-' || LPAD(sequence_record.sequence_value::TEXT, 4, '0');
    ELSE
        -- Create new sequence starting from 1
        INSERT INTO service_report_sequences (org_id, year_month, sequence_value)
        VALUES (NEW.org_id, year_month, 1);
        new_reference_no := 'SR-' || year_month || '-0001';
    END IF;
    
    NEW.reference_no := new_reference_no;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate reference number
CREATE TRIGGER generate_service_report_reference_no
BEFORE INSERT ON service_reports
FOR EACH ROW
WHEN (NEW.reference_no IS NULL)
EXECUTE FUNCTION generate_service_report_number();

-- Function to calculate service report totals
CREATE OR REPLACE FUNCTION calculate_service_report_totals()
RETURNS TRIGGER AS $$
DECLARE
    total_subtotal DECIMAL(12,2);
    total_tax DECIMAL(12,2);
    total_discount DECIMAL(12,2);
    grand_total DECIMAL(12,2);
BEGIN
    -- Calculate totals from related job items
    SELECT 
        COALESCE(SUM(line_total), 0) as subtotal,
        COALESCE(SUM(tax_amount), 0) as tax,
        COALESCE(SUM(discount_amount), 0) as discount
    INTO total_subtotal, total_tax, total_discount
    FROM job_items 
    WHERE report_id = NEW.id;
    
    grand_total := total_subtotal + total_tax - total_discount;
    
    NEW.subtotal := total_subtotal;
    NEW.tax_amount := total_tax;
    NEW.discount_amount := total_discount;
    NEW.total_amount := grand_total;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to calculate totals when service report is updated
CREATE TRIGGER calculate_service_report_totals_trigger
BEFORE UPDATE ON service_reports
FOR EACH ROW
EXECUTE FUNCTION calculate_service_report_totals();

-- Indexes for performance
CREATE INDEX idx_service_reports_org_id ON service_reports(org_id);
CREATE INDEX idx_service_reports_branch_id ON service_reports(branch_id);
CREATE INDEX idx_service_reports_job_id ON service_reports(job_id);
CREATE INDEX idx_service_reports_reference_no ON service_reports(reference_no);
CREATE INDEX idx_service_reports_created_at ON service_reports(created_at);
CREATE INDEX idx_service_reports_technician_id ON service_reports(technician_id);

CREATE INDEX idx_service_report_causes_report_id ON service_report_causes(report_id);
CREATE INDEX idx_service_report_causes_cause_id ON service_report_causes(cause_id);

CREATE INDEX idx_service_report_tasks_report_id ON service_report_tasks(report_id);
CREATE INDEX idx_service_report_tasks_task_id ON service_report_tasks(task_id);

CREATE INDEX idx_problem_causes_is_active ON problem_causes(is_active);
CREATE INDEX idx_problem_causes_sort_order ON problem_causes(sort_order);

CREATE INDEX idx_job_tasks_device_scope ON job_tasks(device_scope);
CREATE INDEX idx_job_tasks_is_active ON job_tasks(is_active);
CREATE INDEX idx_job_tasks_sort_order ON job_tasks(sort_order); 
-- ===================================================== 
-- 3. CREATE RLS POLICIES 
-- ===================================================== 
-- Row Level Security (RLS) policies for multi-tenant isolation
-- Migration: 20240101000003_create_rls_policies.sql

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_order_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimates ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimate_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_report_causes ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_report_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE problem_causes ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_report_sequences ENABLE ROW LEVEL SECURITY;

-- Helper function to check if user is member of organization
CREATE OR REPLACE FUNCTION is_org_member(org_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM organization_users 
        WHERE org_id = org_uuid AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to get user role in organization
CREATE OR REPLACE FUNCTION user_org_role(org_uuid UUID)
RETURNS TEXT AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT role INTO user_role
    FROM organization_users 
    WHERE org_id = org_uuid AND user_id = auth.uid();
    
    RETURN COALESCE(user_role, 'none');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check if user can access job
CREATE OR REPLACE FUNCTION can_access_job(job_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    job_org_id UUID;
    job_client_id UUID;
    user_role TEXT;
BEGIN
    -- Get job organization and client
    SELECT org_id, client_id INTO job_org_id, job_client_id
    FROM job_orders WHERE id = job_uuid;
    
    -- Get user role in organization
    user_role := user_org_role(job_org_id);
    
    -- Owner and Admin can access all jobs in org
    IF user_role IN ('owner', 'admin') THEN
        RETURN true;
    END IF;
    
    -- Staff can access all jobs in org
    IF user_role = 'staff' THEN
        RETURN true;
    END IF;
    
    -- Technician can access assigned jobs
    IF user_role = 'technician' THEN
        RETURN EXISTS (
            SELECT 1 FROM job_order_assignments 
            WHERE job_id = job_uuid AND user_id = auth.uid()
        );
    END IF;
    
    -- Client can access own jobs
    IF user_role = 'client' THEN
        RETURN job_client_id = auth.uid();
    END IF;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Organizations policies
CREATE POLICY "Organizations insert for service users" ON organizations
    FOR INSERT WITH CHECK (false); -- Only service role can create orgs

CREATE POLICY "Organizations select for members" ON organizations
    FOR SELECT USING (is_org_member(id));

CREATE POLICY "Organizations update for owners and admins" ON organizations
    FOR UPDATE USING (user_org_role(id) IN ('owner', 'admin'));

-- Branches policies
CREATE POLICY "Branches select for org members" ON branches
    FOR SELECT USING (is_org_member(org_id));

CREATE POLICY "Branches insert for owners and admins" ON branches
    FOR INSERT WITH CHECK (user_org_role(org_id) IN ('owner', 'admin'));

CREATE POLICY "Branches update for owners and admins" ON branches
    FOR UPDATE USING (user_org_role(org_id) IN ('owner', 'admin'));

-- User profiles policies
CREATE POLICY "User profiles select for org members" ON user_profiles
    FOR SELECT USING (is_org_member(org_id) OR id = auth.uid());

CREATE POLICY "User profiles insert for new users" ON user_profiles
    FOR INSERT WITH CHECK (id = auth.uid());

CREATE POLICY "User profiles update for own profile" ON user_profiles
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "User profiles update for owners and admins" ON user_profiles
    FOR UPDATE USING (user_org_role(org_id) IN ('owner', 'admin'));

-- Organization users policies
CREATE POLICY "Organization users select for org members" ON organization_users
    FOR SELECT USING (is_org_member(org_id));

CREATE POLICY "Organization users insert for owners and admins" ON organization_users
    FOR INSERT WITH CHECK (user_org_role(org_id) IN ('owner', 'admin'));

CREATE POLICY "Organization users update for owners and admins" ON organization_users
    FOR UPDATE USING (user_org_role(org_id) IN ('owner', 'admin'));

CREATE POLICY "Organization users delete for owners and admins" ON organization_users
    FOR DELETE USING (user_org_role(org_id) IN ('owner', 'admin'));

-- Job orders policies
CREATE POLICY "Job orders select for accessible jobs" ON job_orders
    FOR SELECT USING (can_access_job(id));

CREATE POLICY "Job orders insert for staff and above" ON job_orders
    FOR INSERT WITH CHECK (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

CREATE POLICY "Job orders update for staff and above" ON job_orders
    FOR UPDATE USING (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

-- Job order assignments policies
CREATE POLICY "Job order assignments select for accessible jobs" ON job_order_assignments
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Job order assignments insert for staff and above" ON job_order_assignments
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        user_org_role((SELECT org_id FROM job_orders WHERE id = job_id)) IN ('owner', 'admin', 'staff')
    );

CREATE POLICY "Job order assignments update for staff and above" ON job_order_assignments
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        user_org_role((SELECT org_id FROM job_orders WHERE id = job_id)) IN ('owner', 'admin', 'staff')
    );

-- Job status history policies
CREATE POLICY "Job status history select for accessible jobs" ON job_status_history
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Job status history insert for job participants" ON job_status_history
    FOR INSERT WITH CHECK (can_access_job(job_id));

-- Job items policies
CREATE POLICY "Job items select for accessible jobs" ON job_items
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Job items insert for staff and above" ON job_items
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

CREATE POLICY "Job items update for staff and above" ON job_items
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

-- Estimates policies
CREATE POLICY "Estimates select for accessible jobs" ON estimates
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Estimates insert for staff and above" ON estimates
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

CREATE POLICY "Estimates update for staff and above" ON estimates
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

-- Estimate items policies
CREATE POLICY "Estimate items select for accessible estimates" ON estimate_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM estimates 
            WHERE estimates.id = estimate_items.estimate_id 
            AND can_access_job(estimates.job_id)
        )
    );

CREATE POLICY "Estimate items insert for staff and above" ON estimate_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM estimates 
            WHERE estimates.id = estimate_items.estimate_id 
            AND can_access_job(estimates.job_id)
            AND user_org_role(estimates.org_id) IN ('owner', 'admin', 'staff')
        )
    );

-- Invoices policies
CREATE POLICY "Invoices select for accessible jobs" ON invoices
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Invoices insert for staff and above" ON invoices
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

CREATE POLICY "Invoices update for staff and above" ON invoices
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

-- Invoice items policies
CREATE POLICY "Invoice items select for accessible invoices" ON invoice_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND can_access_job(invoices.job_id)
        )
    );

-- Payments policies
CREATE POLICY "Payments select for org members" ON payments
    FOR SELECT USING (is_org_member(org_id));

CREATE POLICY "Payments insert for staff and above" ON payments
    FOR INSERT WITH CHECK (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

CREATE POLICY "Payments update for staff and above" ON payments
    FOR UPDATE USING (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

-- Inventory items policies
CREATE POLICY "Inventory items select for staff and above" ON inventory_items
    FOR SELECT USING (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

CREATE POLICY "Inventory items insert for staff and above" ON inventory_items
    FOR INSERT WITH CHECK (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

CREATE POLICY "Inventory items update for staff and above" ON inventory_items
    FOR UPDATE USING (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

-- Inventory stock movements policies
CREATE POLICY "Inventory stock movements select for staff and above" ON inventory_stock_movements
    FOR SELECT USING (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

CREATE POLICY "Inventory stock movements insert for staff and above" ON inventory_stock_movements
    FOR INSERT WITH CHECK (user_org_role(org_id) IN ('owner', 'admin', 'staff'));

-- Attachments policies
CREATE POLICY "Attachments select for accessible records" ON attachments
    FOR SELECT USING (
        is_org_member(org_id) AND (
            record_type = 'service_report' AND 
            EXISTS (
                SELECT 1 FROM service_reports 
                WHERE service_reports.id = record_id 
                AND can_access_job(service_reports.job_id)
            )
            OR
            record_type = 'job_order' AND 
            can_access_job(record_id)
            OR
            record_type = 'invoice' AND 
            EXISTS (
                SELECT 1 FROM invoices 
                WHERE invoices.id = record_id 
                AND can_access_job(invoices.job_id)
            )
        )
    );

CREATE POLICY "Attachments insert for job participants" ON attachments
    FOR INSERT WITH CHECK (
        is_org_member(org_id) AND (
            (record_type = 'service_report' AND 
             EXISTS (
                 SELECT 1 FROM service_reports 
                 WHERE service_reports.id = record_id 
                 AND can_access_job(service_reports.job_id)
             ))
            OR
            (record_type = 'job_order' AND can_access_job(record_id))
            OR
            (record_type = 'invoice' AND 
             EXISTS (
                 SELECT 1 FROM invoices 
                 WHERE invoices.id = record_id 
                 AND can_access_job(invoices.job_id)
             ))
        )
    );

-- Messages policies
CREATE POLICY "Messages select for job participants" ON messages
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Messages insert for job participants" ON messages
    FOR INSERT WITH CHECK (can_access_job(job_id));

CREATE POLICY "Messages update for own messages" ON messages
    FOR UPDATE USING (sender_id = auth.uid());

-- Schedules policies
CREATE POLICY "Schedules select for accessible jobs" ON schedules
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Schedules insert for staff and above" ON schedules
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

CREATE POLICY "Schedules update for staff and above" ON schedules
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

-- Time entries policies
CREATE POLICY "Time entries select for accessible jobs" ON time_entries
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Time entries insert for technicians and staff" ON time_entries
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        (technician_id = auth.uid() OR user_org_role(org_id) IN ('owner', 'admin', 'staff'))
    );

CREATE POLICY "Time entries update for own entries or staff" ON time_entries
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        (technician_id = auth.uid() OR user_org_role(org_id) IN ('owner', 'admin', 'staff'))
    );

-- Signatures policies
CREATE POLICY "Signatures select for accessible records" ON signatures
    FOR SELECT USING (
        is_org_member(org_id) AND (
            record_type = 'service_report' AND 
            EXISTS (
                SELECT 1 FROM service_reports 
                WHERE service_reports.id = record_id 
                AND can_access_job(service_reports.job_id)
            )
            OR
            record_type = 'job_order' AND 
            can_access_job(record_id)
            OR
            record_type = 'invoice' AND 
            EXISTS (
                SELECT 1 FROM invoices 
                WHERE invoices.id = record_id 
                AND can_access_job(invoices.job_id)
            )
        )
    );

CREATE POLICY "Signatures insert for job participants" ON signatures
    FOR INSERT WITH CHECK (
        is_org_member(org_id) AND (
            (record_type = 'service_report' AND 
             EXISTS (
                 SELECT 1 FROM service_reports 
                 WHERE service_reports.id = record_id 
                 AND can_access_job(service_reports.job_id)
             ))
            OR
            (record_type = 'job_order' AND can_access_job(record_id))
            OR
            (record_type = 'invoice' AND 
             EXISTS (
                 SELECT 1 FROM invoices 
                 WHERE invoices.id = record_id 
                 AND can_access_job(invoices.job_id)
             ))
        )
    );

-- Event log policies
CREATE POLICY "Event log select for org members" ON event_log
    FOR SELECT USING (is_org_member(org_id));

CREATE POLICY "Event log insert for system" ON event_log
    FOR INSERT WITH CHECK (false); -- Only service role can insert events

-- Service reports policies
CREATE POLICY "Service reports select for accessible jobs" ON service_reports
    FOR SELECT USING (can_access_job(job_id));

CREATE POLICY "Service reports insert for staff and above" ON service_reports
    FOR INSERT WITH CHECK (
        can_access_job(job_id) AND 
        user_org_role(org_id) IN ('owner', 'admin', 'staff')
    );

CREATE POLICY "Service reports update for technicians and staff" ON service_reports
    FOR UPDATE USING (
        can_access_job(job_id) AND 
        (technician_id = auth.uid() OR user_org_role(org_id) IN ('owner', 'admin', 'staff'))
    );

-- Service report causes policies
CREATE POLICY "Service report causes select for accessible reports" ON service_report_causes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM service_reports 
            WHERE service_reports.id = report_id 
            AND can_access_job(service_reports.job_id)
        )
    );

CREATE POLICY "Service report causes insert for report participants" ON service_report_causes
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM service_reports 
            WHERE service_reports.id = report_id 
            AND can_access_job(service_reports.job_id)
            AND user_org_role(service_reports.org_id) IN ('owner', 'admin', 'staff', 'technician')
        )
    );

-- Service report tasks policies
CREATE POLICY "Service report tasks select for accessible reports" ON service_report_tasks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM service_reports 
            WHERE service_reports.id = report_id 
            AND can_access_job(service_reports.job_id)
        )
    );

CREATE POLICY "Service report tasks insert for report participants" ON service_report_tasks
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM service_reports 
            WHERE service_reports.id = report_id 
            AND can_access_job(service_reports.job_id)
            AND user_org_role(service_reports.org_id) IN ('owner', 'admin', 'staff', 'technician')
        )
    );

-- Problem causes policies (global lookup)
CREATE POLICY "Problem causes select for all users" ON problem_causes
    FOR SELECT USING (is_active = true);

-- Job tasks policies (global lookup)
CREATE POLICY "Job tasks select for all users" ON job_tasks
    FOR SELECT USING (is_active = true);

-- Service report sequences policies
CREATE POLICY "Service report sequences select for org members" ON service_report_sequences
    FOR SELECT USING (is_org_member(org_id));

CREATE POLICY "Service report sequences insert for system" ON service_report_sequences
    FOR INSERT WITH CHECK (false); -- Only trigger can insert

CREATE POLICY "Service report sequences update for system" ON service_report_sequences
    FOR UPDATE WITH CHECK (false); -- Only trigger can update 
-- ===================================================== 
-- 4. SEED LOOKUP DATA 
-- ===================================================== 
-- Seed lookup data for Service Reports
-- Migration: 20240101000004_seed_lookup_data.sql

-- Seed problem causes from the form
INSERT INTO problem_causes (code, label, sort_order) VALUES
('electrical_surge', 'Electrical Surge', 1),
('corrupted_system_files', 'Corrupted System Files', 2),
('backlight_failure', 'Backlight Failure', 3),
('high_temperature', 'High Temperature', 4),
('burn_components', 'Burn Components', 5),
('driver_issue', 'Driver Issue', 6),
('used_fake_inks', 'Used Fake Inks', 7),
('scanner_sensor_failure', 'Scanner Sensor Failure', 8),
('damaged_wire', 'Damaged Wire', 9),
('overheating', 'Overheating', 10),
('malware_virus', 'Malware/Virus', 11),
('fan_failure', 'Fan Failure', 12),
('moisture_humidity', 'Moisture/Humidity', 13),
('firmware_bug', 'Firmware Bug', 14),
('poor_ventilation', 'Poor Ventilation', 15),
('clogged_printhead', 'Clogged Printhead', 16),
('flatbed_cable_damage', 'Flatbed Cable Damage', 17),
('power_supply_failure', 'Power Supply Failure', 18),
('liquid_damage', 'Liquid Damage', 19),
('hdd_ssd_failure', 'HDD/SSD Failure', 20),
('blown_capacitor', 'Blown Capacitor', 21),
('improper_handling', 'Improper Handling', 22),
('corrupted_bios', 'Corrupted BIOS', 23),
('user_error', 'User Error', 24),
('worn_out_rollers', 'Worn Out Rollers', 25),
('corrupted_firmware', 'Corrupted Firmware', 26),
('manufacturing_defect', 'Manufacturing Defect', 27),
('physical_damage', 'Physical Damage', 28),
('loose_cable', 'Loose Cable', 29),
('aging_battery_cycle', 'Aging Battery Cycle', 30),
('dust_buildup', 'Dust Buildup', 31),
('wire_breakage', 'Wire Breakage', 32),
('hardware_conflicts', 'Hardware Conflicts', 33),
('insect_infestation', 'Insect Infestation', 34),
('shorted_mb_printhead', 'Shorted MB/Printhead', 35),
('ink_spill_inside', 'Ink Spill Inside', 36),
('dirty_contacts_or_corrosion', 'Dirty Contacts or Corrosion', 37),
('failed_updates_software_conflicts', 'Failed Updates/Software Conflicts', 38),
('short_circuit', 'Short Circuit', 39),
('loose_solder', 'Loose Solder', 40),
('overcharging_deep_discharging', 'Overcharging/Deep Discharging', 41),
('obstruction_inside', 'Obstruction Inside', 42),
('dirty_sensors_and_encoder', 'Dirty Sensors and Encoder', 43),
('damaged_gear', 'Damaged Gear', 44);

-- Seed job tasks for Desktop/Laptop
INSERT INTO job_tasks (code, label, device_scope, result_type, sort_order) VALUES
('reseat_clean_internal_components', 'Reseat/Clean Internal Components', 'desktop_laptop', 'pass_fail', 1),
('update_reflash_bios_firmware', 'Update/Reflash BIOS/Firmware', 'desktop_laptop', 'none', 2),
('reinstall_os_or_factory_reset', 'Reinstall OS or Factory Reset', 'desktop_laptop', 'none', 3),
('memory_test', 'Memory Test', 'desktop_laptop', 'pass_fail', 4),
('ssd_test', 'SSD Test', 'desktop_laptop', 'pass_fail', 5),
('test_isolate_parts_desktop', 'Test/Isolate Parts', 'desktop_laptop', 'none', 6),
('check_ac_adapter_psu', 'Check AC Adapter/PSU', 'desktop_laptop', 'good_bad', 7),
('upgrade_replace_parts', 'Upgrade/Replace Parts', 'desktop_laptop', 'none', 8),
('burn_in_test', 'Burn-in Test', 'desktop_laptop', 'pass_fail', 9),
('component_test', 'Component Test', 'desktop_laptop', 'pass_fail', 10);

-- Seed job tasks for Printer
INSERT INTO job_tasks (code, label, device_scope, result_type, sort_order) VALUES
('remove_foreign_objects_paper_dust', 'Remove Foreign Objects/Paper/Dust', 'printer', 'none', 11),
('head_cleaning', 'Head Cleaning', 'printer', 'none', 12),
('ink_flush_power_cleaning', 'Ink Flush/Power Cleaning', 'printer', 'none', 13),
('clean_encoder_strip_and_disk', 'Clean Encoder Strip and Disk', 'printer', 'none', 14),
('clean_internal_hardware', 'Clean Internal Hardware', 'printer', 'none', 15),
('update_firmware', 'Update Firmware', 'printer', 'none', 16),
('test_isolate_parts_printer', 'Test/Isolate Parts', 'printer', 'none', 17),
('reset_ink_counter', 'Reset Ink Counter', 'printer', 'none', 18),
('replace_parts', 'Replace Parts', 'printer', 'none', 19),
('print_scan_copy_test', 'Print/Scan/Copy Test', 'printer', 'ok_not_ok', 20),
('component_test', 'Component Test', 'printer', 'good_bad', 21);

-- Seed default organization for development
INSERT INTO organizations (id, name, slug, country, currency, timezone, tax_rate, metadata) VALUES
('00000000-0000-0000-0000-000000000001', 'Demo Company', 'demo-company', 'PH', 'PHP', 'Asia/Manila', 0.1200, '{"is_demo": true}');

-- Seed default branch for demo organization
INSERT INTO branches (id, org_id, name, address, contact_phone, contact_email) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Main Branch', '123 Demo Street, Manila, Philippines', '+632-1234-5678', 'info@demo-company.com');

-- Seed default service categories for inventory
INSERT INTO inventory_items (id, org_id, sku, name, category, cost_price, selling_price, stock_quantity, currency) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'SRV-001', 'Diagnostic Service', 'Service', 0.00, 500.00, 999999, 'PHP'),
('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'SRV-002', 'Cleaning Service', 'Service', 0.00, 300.00, 999999, 'PHP'),
('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'SRV-003', 'Repair Service', 'Service', 0.00, 800.00, 999999, 'PHP'),
('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'PART-001', 'Ink Cartridge (Black)', 'Parts', 800.00, 1200.00, 50, 'PHP'),
('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', 'PART-002', 'Ink Cartridge (Color)', 'Parts', 1000.00, 1500.00, 30, 'PHP'),
('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', 'PART-003', 'Power Supply', 'Parts', 1200.00, 1800.00, 15, 'PHP'),
('00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000001', 'PART-004', 'RAM 4GB DDR4', 'Parts', 1500.00, 2200.00, 20, 'PHP'),
('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000001', 'PART-005', 'SSD 256GB', 'Parts', 2000.00, 3000.00, 10, 'PHP');