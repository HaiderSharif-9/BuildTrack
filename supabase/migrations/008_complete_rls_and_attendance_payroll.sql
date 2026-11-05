-- Migration: 008_complete_rls_and_attendance_payroll
-- Completes the RLS policies required by the app's CRUD screens and
-- makes attendance overtime a persisted, server-calculated input.

-- Supabase's authenticated Postgres role is named 'authenticated', not
-- 'authenticated_user'. Replace the old read policies that used the latter.
DROP POLICY IF EXISTS app_settings_select ON app_settings;
CREATE POLICY app_settings_select ON app_settings
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY app_settings_update_admin ON app_settings
  FOR UPDATE USING (app_role() = 'admin')
  WITH CHECK (app_role() = 'admin');

DROP POLICY IF EXISTS clients_select ON clients;
CREATE POLICY clients_select ON clients
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY clients_insert_admin ON clients
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY clients_update_admin ON clients
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

DROP POLICY IF EXISTS suppliers_select ON suppliers;
CREATE POLICY suppliers_select ON suppliers
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY suppliers_insert_admin ON suppliers
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY suppliers_update_admin ON suppliers
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY projects_insert_admin ON projects
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY projects_update_admin ON projects
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY project_finance_insert_admin ON project_finance
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY project_finance_update_admin ON project_finance
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY project_members_select_self ON project_members
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY project_members_insert_admin ON project_members
  FOR INSERT WITH CHECK (app_role() = 'admin');
CREATE POLICY project_members_update_admin ON project_members
  FOR UPDATE USING (app_role() = 'admin')
  WITH CHECK (app_role() = 'admin');
CREATE POLICY project_members_delete_admin ON project_members
  FOR DELETE USING (app_role() = 'admin');

CREATE POLICY labour_insert_admin ON labour
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY labour_update_admin ON labour
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY labour_private_insert_admin ON labour_private
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY labour_private_update_admin ON labour_private
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY project_labour_insert_admin ON project_labour
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY project_labour_delete_admin ON project_labour
  FOR DELETE USING (app_role() IN ('admin', 'accountant'));
CREATE POLICY project_labour_update_admin ON project_labour
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY project_labour_rate_insert_admin ON project_labour_rate
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY project_labour_rate_update_admin ON project_labour_rate
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY project_labour_rate_delete_admin ON project_labour_rate
  FOR DELETE USING (app_role() IN ('admin', 'accountant'));

DROP POLICY IF EXISTS categories_select ON categories;
CREATE POLICY categories_select ON categories
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY purchases_update_assigned ON purchases
  FOR UPDATE USING (
    app_role() IN ('admin', 'accountant')
    OR (
      app_role() = 'manager'
      AND EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = purchases.project_id AND user_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    app_role() IN ('admin', 'accountant')
    OR (
      app_role() = 'manager'
      AND EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = purchases.project_id AND user_id = auth.uid()
      )
    )
  );

CREATE POLICY transactions_insert_finance ON transactions
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY transactions_update_finance ON transactions
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY labour_advances_insert_assigned ON labour_advances
  FOR INSERT WITH CHECK (
    app_role() IN ('admin', 'accountant')
    OR (
      app_role() = 'manager'
      AND created_by = auth.uid()
      AND EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = labour_advances.project_id AND user_id = auth.uid()
      )
    )
  );
CREATE POLICY labour_advances_update_finance ON labour_advances
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

CREATE POLICY wage_payments_insert_finance ON wage_payments
  FOR INSERT WITH CHECK (app_role() IN ('admin', 'accountant'));
CREATE POLICY wage_payments_update_finance ON wage_payments
  FOR UPDATE USING (app_role() IN ('admin', 'accountant'))
  WITH CHECK (app_role() IN ('admin', 'accountant'));

-- Persist hours and manual overtime on the attendance row. The previous app
-- queried these fields although migration 004 had only put them in attendance_pay.
ALTER TABLE attendance
  ADD COLUMN IF NOT EXISTS hours_worked NUMERIC(5,2),
  ADD COLUMN IF NOT EXISTS overtime_hours NUMERIC(5,2) NOT NULL DEFAULT 0;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'attendance_overtime_nonnegative'
      AND conrelid = 'attendance'::regclass
  ) THEN
    ALTER TABLE attendance
      ADD CONSTRAINT attendance_overtime_nonnegative CHECK (overtime_hours >= 0);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION set_attendance_hours()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'present' AND NEW.in_time IS NOT NULL AND NEW.out_time IS NOT NULL THEN
    NEW.hours_worked := ROUND(
      (EXTRACT(EPOCH FROM (NEW.out_time - NEW.in_time)) / 3600.0)::NUMERIC,
      2
    );
  ELSE
    NEW.hours_worked := NULL;
  END IF;
  NEW.overtime_hours := COALESCE(NEW.overtime_hours, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_attendance_hours_trigger ON attendance;
CREATE TRIGGER set_attendance_hours_trigger
BEFORE INSERT OR UPDATE OF status, in_time, out_time, overtime_hours ON attendance
FOR EACH ROW EXECUTE FUNCTION set_attendance_hours();

-- Server-side wage calculation remains authoritative. Manual OT is persisted
-- on attendance and is combined with OT inferred from the time range.
CREATE OR REPLACE FUNCTION compute_attendance_pay()
RETURNS TRIGGER AS $$
DECLARE
  v_rate NUMERIC(14,2);
  v_full_day_hours NUMERIC(5,2);
  v_overtime_multiplier NUMERIC(5,2);
  v_hours_worked NUMERIC(5,2);
  v_base_pay NUMERIC(14,2);
  v_overtime_hours NUMERIC(5,2);
  v_overtime_pay NUMERIC(14,2);
  v_wage_amount NUMERIC(14,2);
BEGIN
  SELECT COALESCE(full_day_hours, 10), COALESCE(overtime_multiplier, 1.5)
    INTO v_full_day_hours, v_overtime_multiplier
  FROM app_settings WHERE id = 1;

  v_full_day_hours := COALESCE(v_full_day_hours, 10);
  v_overtime_multiplier := COALESCE(v_overtime_multiplier, 1.5);

  SELECT COALESCE(plr.rate_override, lp.default_rate)
    INTO v_rate
  FROM labour_private lp
  LEFT JOIN project_labour_rate plr
    ON plr.labour_id = lp.labour_id AND plr.project_id = NEW.project_id
  WHERE lp.labour_id = NEW.labour_id;

  IF v_rate IS NULL OR v_rate <= 0 THEN
    RAISE EXCEPTION 'No valid wage rate configured for labourer %', NEW.labour_id;
  END IF;

  INSERT INTO attendance_pay (attendance_id, rate, hours_worked, overtime_hours, wage_amount)
  VALUES (NEW.id, v_rate, NEW.hours_worked, 0, 0)
  ON CONFLICT (attendance_id) DO NOTHING;

  IF NEW.status IN ('absent', 'leave') THEN
    UPDATE attendance_pay SET
      rate = v_rate,
      hours_worked = NULL,
      overtime_hours = 0,
      wage_amount = 0
    WHERE attendance_id = NEW.id;
  ELSE
    v_hours_worked := NEW.hours_worked;
    v_overtime_hours := COALESCE(NEW.overtime_hours, 0);

    IF v_hours_worked IS NOT NULL THEN
      v_overtime_hours := GREATEST(
        v_overtime_hours,
        GREATEST(v_hours_worked - v_full_day_hours, 0)
      );
      v_base_pay := v_rate * LEAST(v_hours_worked, v_full_day_hours) / v_full_day_hours;
    ELSE
      v_base_pay := v_rate;
    END IF;

    v_overtime_pay := v_overtime_hours * (v_rate / v_full_day_hours) * v_overtime_multiplier;
    v_wage_amount := ROUND(v_base_pay + v_overtime_pay);

    UPDATE attendance_pay SET
      rate = v_rate,
      hours_worked = v_hours_worked,
      overtime_hours = v_overtime_hours,
      wage_amount = v_wage_amount
    WHERE attendance_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Keep the generated wage-payment transaction in sync with the net amount,
-- and support the existing soft-delete/reopen workflow.
CREATE OR REPLACE FUNCTION mark_period_paid()
RETURNS TRIGGER AS $$
DECLARE
  v_wages_cat_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE attendance SET locked = TRUE
    WHERE labour_id = NEW.labour_id
      AND project_id = NEW.project_id
      AND date BETWEEN NEW.period_start AND NEW.period_end
      AND status = 'present';

    SELECT id INTO v_wages_cat_id
    FROM categories WHERE name = 'Labour Wages' LIMIT 1;

    IF NEW.net > 0 THEN
      IF v_wages_cat_id IS NULL THEN
        RAISE EXCEPTION 'Labour Wages transaction category is missing';
      END IF;

      INSERT INTO transactions (
        project_id, date, type, category_id, description, amount, source, source_id, created_by
      )
      VALUES (
        NEW.project_id, NEW.paid_on, 'expense', v_wages_cat_id,
        'Net wage payment: ' || NEW.period_start || ' to ' || NEW.period_end,
        NEW.net, 'wage', NEW.id, NEW.created_by
      )
      ON CONFLICT (source, source_id) DO UPDATE SET
        amount = EXCLUDED.amount,
        date = EXCLUDED.date,
        description = EXCLUDED.description,
        deleted_at = NULL,
        updated_at = NOW();
    END IF;
  ELSIF TG_OP = 'UPDATE' AND OLD.deleted_at IS DISTINCT FROM NEW.deleted_at THEN
    IF NEW.deleted_at IS NOT NULL THEN
      UPDATE attendance SET locked = FALSE
      WHERE labour_id = NEW.labour_id
        AND project_id = NEW.project_id
        AND date BETWEEN NEW.period_start AND NEW.period_end;

      UPDATE transactions SET deleted_at = NOW()
      WHERE source = 'wage' AND source_id = NEW.id;
    ELSE
      UPDATE attendance SET locked = TRUE
      WHERE labour_id = NEW.labour_id
        AND project_id = NEW.project_id
        AND date BETWEEN NEW.period_start AND NEW.period_end
        AND status = 'present';

      UPDATE transactions SET deleted_at = NULL
      WHERE source = 'wage' AND source_id = NEW.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS mark_period_paid_update_trigger ON wage_payments;
CREATE TRIGGER mark_period_paid_update_trigger
AFTER UPDATE OF deleted_at ON wage_payments
FOR EACH ROW EXECUTE FUNCTION mark_period_paid();

-- Keep purchase-generated ledger entries synchronized on insert, edit,
-- soft-delete and restore. This avoids requiring a second client-side write
-- (which managers are intentionally not allowed to perform on transactions).
CREATE OR REPLACE FUNCTION sync_purchase_transaction()
RETURNS TRIGGER AS $$
DECLARE
  v_materials_cat_id UUID;
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE transactions
      SET deleted_at = COALESCE(deleted_at, NOW())
    WHERE source = 'purchase' AND source_id = OLD.id;
    RETURN OLD;
  END IF;

  IF NEW.deleted_at IS NOT NULL THEN
    UPDATE transactions
      SET deleted_at = COALESCE(NEW.deleted_at, NOW())
    WHERE source = 'purchase' AND source_id = NEW.id;
    RETURN NEW;
  END IF;

  SELECT id INTO v_materials_cat_id
  FROM categories WHERE name = 'Materials' LIMIT 1;

  IF v_materials_cat_id IS NULL THEN
    RAISE EXCEPTION 'Materials transaction category is missing';
  END IF;

  INSERT INTO transactions (
    project_id, date, type, category_id, description, amount, source, source_id, created_by
  )
  VALUES (
    NEW.project_id, NEW.date, 'expense', v_materials_cat_id,
    NEW.item, NEW.amount, 'purchase', NEW.id, NEW.created_by
  )
  ON CONFLICT (source, source_id) DO UPDATE SET
    project_id = EXCLUDED.project_id,
    date = EXCLUDED.date,
    category_id = EXCLUDED.category_id,
    description = EXCLUDED.description,
    amount = EXCLUDED.amount,
    deleted_at = NULL,
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Allow a signed-in user to clear only their own forced-password-change flag.
-- This avoids granting general UPDATE access to the profiles table.
CREATE OR REPLACE FUNCTION clear_own_must_change_password()
RETURNS VOID AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  UPDATE profiles
  SET must_change_password = FALSE,
      temp_password_expires_at = NULL
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION clear_own_must_change_password() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION clear_own_must_change_password() TO authenticated;
