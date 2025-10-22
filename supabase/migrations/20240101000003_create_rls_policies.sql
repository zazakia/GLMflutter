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