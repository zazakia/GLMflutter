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