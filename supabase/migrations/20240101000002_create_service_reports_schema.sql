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