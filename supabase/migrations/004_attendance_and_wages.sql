-- Migration: 004_attendance_and_wages
-- Creates attendance and computed wage columns (critical for hourly logic)

CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  labour_id UUID NOT NULL REFERENCES labour(id),
  date DATE NOT NULL,
  status attendance_status NOT NULL,
  in_time TIME,
  out_time TIME,
  remarks TEXT,
  locked BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,
  UNIQUE (project_id, labour_id, date),
  CONSTRAINT in_out_times_same_day CHECK (
    (status = 'present' AND in_time IS NOT NULL AND out_time IS NOT NULL AND out_time > in_time)
    OR (status IN ('absent', 'leave') AND in_time IS NULL AND out_time IS NULL)
    OR (status = 'present' AND in_time IS NULL AND out_time IS NULL)
  )
);

-- Attendance wage details (computed by trigger, admin/accountant only)
CREATE TABLE attendance_pay (
  attendance_id UUID PRIMARY KEY REFERENCES attendance(id) ON DELETE CASCADE,
  rate NUMERIC(14,2), -- snapshot of rate at time of attendance
  hours_worked NUMERIC(5,2), -- computed: out_time - in_time or NULL if no times
  overtime_hours NUMERIC(5,2), -- computed or manual if no times
  wage_amount NUMERIC(14,2), -- computed by trigger: base_pay + overtime_pay
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT rate_positive CHECK (rate > 0),
  CONSTRAINT hours_nonnegative CHECK (hours_worked IS NULL OR hours_worked >= 0),
  CONSTRAINT overtime_nonnegative CHECK (overtime_hours IS NULL OR overtime_hours >= 0),
  CONSTRAINT wage_nonnegative CHECK (wage_amount IS NULL OR wage_amount >= 0)
);

-- One labourer per date per site constraint (partial unique index)
CREATE UNIQUE INDEX attendance_present_unique_idx
  ON attendance (labour_id, date)
  WHERE status = 'present' AND deleted_at IS NULL;

-- Indexes for common queries
CREATE INDEX attendance_project_date_idx ON attendance(project_id, date) WHERE deleted_at IS NULL;
CREATE INDEX attendance_labour_date_idx ON attendance(labour_id, date) WHERE deleted_at IS NULL;
CREATE INDEX attendance_pay_rate_idx ON attendance_pay(rate);

-- Triggers: update updated_at
CREATE OR REPLACE FUNCTION update_attendance_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER attendance_updated_at_trigger
BEFORE UPDATE ON attendance FOR EACH ROW EXECUTE FUNCTION update_attendance_updated_at();

CREATE TRIGGER attendance_pay_updated_at_trigger
BEFORE UPDATE ON attendance_pay FOR EACH ROW EXECUTE FUNCTION update_attendance_updated_at();

-- CRITICAL TRIGGER: Compute wages on attendance insert/update
-- This is the single source of truth for wage calculation
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
  -- Get settings
  SELECT full_day_hours, overtime_multiplier INTO v_full_day_hours, v_overtime_multiplier
  FROM app_settings WHERE id = 1;

  -- Get rate: use project override if set, else default
  SELECT COALESCE(plr.rate_override, lp.default_rate) INTO v_rate
  FROM labour_private lp
  LEFT JOIN project_labour_rate plr ON plr.labour_id = lp.labour_id AND plr.project_id = NEW.project_id
  WHERE lp.labour_id = NEW.labour_id;

  -- Initialize attendance_pay if not exists
  IF NOT EXISTS (SELECT 1 FROM attendance_pay WHERE attendance_id = NEW.id) THEN
    INSERT INTO attendance_pay (attendance_id, rate, hours_worked, overtime_hours, wage_amount)
    VALUES (NEW.id, v_rate, NULL, 0, 0);
  END IF;

  -- Calculate wages based on status
  IF NEW.status IN ('absent', 'leave') THEN
    -- No wages for absent/leave
    UPDATE attendance_pay SET
      rate = v_rate,
      hours_worked = NULL,
      overtime_hours = 0,
      wage_amount = 0
    WHERE attendance_id = NEW.id;
  ELSIF NEW.status = 'present' THEN
    IF NEW.in_time IS NOT NULL AND NEW.out_time IS NOT NULL THEN
      -- Calculate from times
      v_hours_worked := EXTRACT(EPOCH FROM (NEW.out_time - NEW.in_time)) / 3600.0;
      v_hours_worked := ROUND(v_hours_worked::NUMERIC, 2);

      -- Base pay: rate * min(hours, full_day) / full_day
      v_base_pay := v_rate * LEAST(v_hours_worked, v_full_day_hours) / v_full_day_hours;

      -- Overtime: max(hours - full_day, 0)
      v_overtime_hours := GREATEST(v_hours_worked - v_full_day_hours, 0);

      -- Overtime pay: overtime_hours * (rate / full_day) * multiplier
      v_overtime_pay := v_overtime_hours * (v_rate / v_full_day_hours) * v_overtime_multiplier;

      -- Total wage (round half up to nearest rupee)
      v_wage_amount := ROUND(v_base_pay + v_overtime_pay);

      UPDATE attendance_pay SET
        rate = v_rate,
        hours_worked = v_hours_worked,
        overtime_hours = v_overtime_hours,
        wage_amount = v_wage_amount
      WHERE attendance_id = NEW.id;
    ELSE
      -- Full day: rate + any manual overtime
      v_base_pay := v_rate;
      v_overtime_hours := COALESCE((SELECT overtime_hours FROM attendance_pay WHERE attendance_id = NEW.id), 0);
      v_overtime_pay := v_overtime_hours * (v_rate / v_full_day_hours) * v_overtime_multiplier;
      v_wage_amount := ROUND(v_base_pay + v_overtime_pay);

      UPDATE attendance_pay SET
        rate = v_rate,
        hours_worked = NULL,
        wage_amount = v_wage_amount
      WHERE attendance_id = NEW.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER compute_attendance_pay_trigger
AFTER INSERT OR UPDATE ON attendance
FOR EACH ROW
EXECUTE FUNCTION compute_attendance_pay();

-- RLS
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_pay ENABLE ROW LEVEL SECURITY;

-- RLS: attendance visible to assigned managers and admin/accountant
CREATE POLICY attendance_select ON attendance
  FOR SELECT USING (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = attendance.project_id AND user_id = auth.uid()
      )
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: managers can read/write their assigned sites while unlocked
CREATE POLICY attendance_insert ON attendance
  FOR INSERT WITH CHECK (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = attendance.project_id AND user_id = auth.uid()
      ) AND locked = FALSE
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

CREATE POLICY attendance_update ON attendance
  FOR UPDATE USING (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = attendance.project_id AND user_id = auth.uid()
      ) AND locked = FALSE
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: attendance_pay only visible to admin/accountant
CREATE POLICY attendance_pay_select ON attendance_pay
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));
