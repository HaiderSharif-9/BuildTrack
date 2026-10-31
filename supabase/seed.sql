-- Seed data: 5 sites, 6 labourers, 30 days of attendance with golden test cases
-- Dates are relative to TODAY - use in Supabase SQL editor

-- Admin and accountant users (hashes are placeholder)
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'admin@buildtrack.local', 'placeholder', NOW()),
  ('22222222-2222-2222-2222-222222222222', 'accountant@buildtrack.local', 'placeholder', NOW());

INSERT INTO profiles (id, full_name, role, login_id, active)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Admin User', 'admin', 'admin@buildtrack.local', TRUE),
  ('22222222-2222-2222-2222-222222222222', 'Accountant User', 'accountant', 'accountant@buildtrack.local', TRUE);

-- Clients
INSERT INTO clients (id, name, phone, address)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'DHA Defence', '03001234567', 'Karachi'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Gulberg Development', '03009876543', 'Lahore');

-- Projects (5 sites)
INSERT INTO projects (id, name, location, client_id, start_date, status)
VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'DHA Villa B-1 550', 'DHA Phase V', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', (CURRENT_DATE - 60), 'in_progress'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'DHA Villa B-1 790', 'DHA Phase V', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', (CURRENT_DATE - 60), 'in_progress'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Gulberg Residence', 'Gulberg III', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', (CURRENT_DATE - 60), 'in_progress'),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'Commercial Plaza', 'Gulberg III', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', (CURRENT_DATE - 60), 'in_progress'),
  ('99999999-9999-9999-9999-999999999999', 'Farm House Project', 'Outskirts', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', (CURRENT_DATE - 60), 'in_progress');

-- Project finance (budgets)
INSERT INTO project_finance (project_id, budget)
VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 2500000),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 4500000),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 3500000),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 2000000),
  ('99999999-9999-9999-9999-999999999999', 1200000);

-- Labour (6 workers)
INSERT INTO labour (id, name, trade, active)
VALUES
  ('11111111-2222-2222-2222-222222222222', 'Muhammad Ali', 'Mason', TRUE),
  ('11111111-3333-3333-3333-333333333333', 'Rashid Khan', 'Carpenter', TRUE),
  ('11111111-4444-4444-4444-444444444444', 'Imran Ahmed', 'Electrician', TRUE),
  ('11111111-5555-5555-5555-555555555555', 'Sajjad Hassan', 'Plumber', TRUE),
  ('11111111-6666-6666-6666-666666666666', 'Bilal Malik', 'Helper', TRUE),
  ('11111111-7777-7777-7777-777777777777', 'Asif Raza', 'Helper', TRUE);

-- Labour private (rates for golden tests)
INSERT INTO labour_private (labour_id, phone, cnic, default_rate)
VALUES
  ('11111111-2222-2222-2222-222222222222', '03101111111', '12345-1234567-1', 1200),
  ('11111111-3333-3333-3333-333333333333', '03101111112', '12345-1234567-2', 1000),
  ('11111111-4444-4444-4444-444444444444', '03101111113', '12345-1234567-3', 1000),
  ('11111111-5555-5555-5555-555555555555', '03101111114', '12345-1234567-4', 1200),
  ('11111111-6666-6666-6666-666666666666', '03101111115', '12345-1234567-5', 1000),
  ('11111111-7777-7777-7777-777777777777', '03101111116', '12345-1234567-6', 1000);

-- Assign labour to projects
INSERT INTO project_labour (project_id, labour_id)
SELECT p.id, l.id FROM projects p, labour l;

-- Attendance: 30 days, varied statuses, includes golden test cases
-- Golden test: 1200 rate with:
-- - 08:00-18:00 (10h) = 1200 wage
-- - 08:00-13:00 (5h) = 600 wage
-- - 08:00-12:00 (4h) = 480 wage
-- - 08:00-20:00 (12h) = 1560 wage (1200 + 2h x 120 x 1.5)
-- - present no times = 1200 wage
-- - present no times, manual OT 2h = 1560 wage

-- Muhammad Ali (rate 1200): generate 30 days with golden cases
INSERT INTO attendance (project_id, labour_id, date, status, in_time, out_time, created_by)
SELECT
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '11111111-2222-2222-2222-222222222222',
  CURRENT_DATE - (30 - day),
  CASE
    WHEN day = 1 THEN 'present' -- 08:00-18:00 (10h) = 1200
    WHEN day = 2 THEN 'present' -- 08:00-13:00 (5h) = 600
    WHEN day = 3 THEN 'present' -- 08:00-12:00 (4h) = 480
    WHEN day = 4 THEN 'present' -- 08:00-20:00 (12h) = 1560
    WHEN day = 5 THEN 'present' -- no times = 1200
    WHEN day = 6 THEN 'absent'
    WHEN day = 7 THEN 'leave'
    ELSE 'present'
  END,
  CASE
    WHEN day = 1 THEN '08:00'::TIME
    WHEN day = 2 THEN '08:00'::TIME
    WHEN day = 3 THEN '08:00'::TIME
    WHEN day = 4 THEN '08:00'::TIME
    ELSE NULL
  END,
  CASE
    WHEN day = 1 THEN '18:00'::TIME
    WHEN day = 2 THEN '13:00'::TIME
    WHEN day = 3 THEN '12:00'::TIME
    WHEN day = 4 THEN '20:00'::TIME
    ELSE NULL
  END,
  '11111111-1111-1111-1111-111111111111'
FROM GENERATE_SERIES(1, 30) AS t(day);

-- Other labourers: simpler attendance (8-10 hours mostly)
INSERT INTO attendance (project_id, labour_id, date, status, in_time, out_time, created_by)
SELECT
  CASE (labour_num + day) % 5
    WHEN 0 THEN 'cccccccc-cccc-cccc-cccc-cccccccccccc'
    WHEN 1 THEN 'dddddddd-dddd-dddd-dddd-dddddddddddd'
    WHEN 2 THEN 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'
    WHEN 3 THEN 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    ELSE '99999999-9999-9999-9999-999999999999'
  END,
  labour_ids[labour_num],
  CURRENT_DATE - (30 - day),
  CASE WHEN day % 7 = 6 THEN 'leave' WHEN day % 7 = 0 THEN 'absent' ELSE 'present' END,
  CASE WHEN day % 7 NOT IN (0, 6) THEN '08:00'::TIME ELSE NULL END,
  CASE WHEN day % 7 NOT IN (0, 6) THEN '18:00'::TIME ELSE NULL END,
  '11111111-1111-1111-1111-111111111111'
FROM GENERATE_SERIES(1, 30) AS t(day),
     LATERAL UNNEST(ARRAY[
       '11111111-3333-3333-3333-333333333333',
       '11111111-4444-4444-4444-444444444444',
       '11111111-5555-5555-5555-555555555555',
       '11111111-6666-6666-6666-666666666666',
       '11111111-7777-7777-7777-777777777777'
     ]) WITH ORDINALITY AS u(labour_ids, labour_num);

-- Suppliers
INSERT INTO suppliers (id, name, phone, address)
VALUES
  ('supplier1111-1111-1111-1111-111111111111', 'Ali Cement Co.', '03001234560', 'Karachi'),
  ('supplier2222-2222-2222-2222-222222222222', 'Steel Traders', '03009876540', 'Karachi'),
  ('supplier3333-3333-3333-3333-333333333333', 'Electrical Supplies', '03105678900', 'Karachi');

-- Purchases (generates Materials expenses automatically)
INSERT INTO purchases (project_id, date, item, qty, unit, rate, supplier_id, created_by)
VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', CURRENT_DATE - 20, 'Cement', 100, 'Bag', 600, 'supplier1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', CURRENT_DATE - 18, 'Steel Rods', 500, 'Kg', 150, 'supplier2222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', CURRENT_DATE - 15, 'Bricks', 5000, 'Pcs', 8, 'supplier1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', CURRENT_DATE - 19, 'Cement', 150, 'Bag', 600, 'supplier1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', CURRENT_DATE - 17, 'Electrical Wire', 1000, 'Ft', 5, 'supplier3333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111'),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', CURRENT_DATE - 16, 'Sand', 10, 'Ton', 2000, 'supplier1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111');

-- Income transactions (client payments)
INSERT INTO transactions (project_id, date, type, category_id, description, amount, created_by)
SELECT
  project_id,
  CURRENT_DATE - 30,
  'income',
  (SELECT id FROM categories WHERE name = 'Client Payment'),
  'Payment received',
  amount,
  '11111111-1111-1111-1111-111111111111'
FROM (VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 2450000),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 4200000),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 3100000),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', 1800000),
  ('99999999-9999-9999-9999-999999999999', 900000)
) AS t(project_id, amount);

-- Company-level expenses (office, transport, utilities)
INSERT INTO transactions (project_id, date, type, category_id, description, amount, created_by)
VALUES
  (NULL, CURRENT_DATE - 25, 'expense', (SELECT id FROM categories WHERE name = 'Office'), 'Office rent', 150000, '11111111-1111-1111-1111-111111111111'),
  (NULL, CURRENT_DATE - 22, 'expense', (SELECT id FROM categories WHERE name = 'Transport'), 'Fuel and transport', 120000, '11111111-1111-1111-1111-111111111111'),
  (NULL, CURRENT_DATE - 20, 'expense', (SELECT id FROM categories WHERE name = 'Utilities'), 'Electricity and water', 80000, '11111111-1111-1111-1111-111111111111'),
  (NULL, CURRENT_DATE - 10, 'expense', (SELECT id FROM categories WHERE name = 'Office'), 'Supplies', 70000, '11111111-1111-1111-1111-111111111111');
