-- Migration: 006_advances_and_payments
-- Creates labour advances and wage payments (payroll)

CREATE TABLE labour_advances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  labour_id UUID NOT NULL REFERENCES labour(id),
  project_id UUID NOT NULL REFERENCES projects(id),
  date DATE NOT NULL,
  amount NUMERIC(14,2) NOT NULL,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT amount_positive CHECK (amount > 0),
  CONSTRAINT amount_reasonable CHECK (amount < 100000000)
);

-- Wage payments: marks labourers as paid for a period
CREATE TABLE wage_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  labour_id UUID NOT NULL REFERENCES labour(id),
  project_id UUID NOT NULL REFERENCES projects(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  gross NUMERIC(14,2) NOT NULL, -- sum of wages in period
  advances_deducted NUMERIC(14,2) NOT NULL DEFAULT 0, -- amount deducted from advances
  net NUMERIC(14,2) GENERATED ALWAYS AS (gross - advances_deducted) STORED, -- never negative
  paid_on DATE NOT NULL,
  method TEXT NOT NULL, -- cash, bank, easypaisa, jazzcash
  reopen_reason TEXT, -- reason if payment is reversed
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,
  UNIQUE (labour_id, project_id, period_start, period_end),
  CONSTRAINT gross_nonnegative CHECK (gross >= 0),
  CONSTRAINT advances_deducted_nonnegative CHECK (advances_deducted >= 0),
  CONSTRAINT advances_not_more_than_gross CHECK (advances_deducted <= gross),
  CONSTRAINT period_valid CHECK (period_end >= period_start)
);

-- Indexes
CREATE INDEX labour_advances_labour_project_idx ON labour_advances(labour_id, project_id);
CREATE INDEX wage_payments_labour_idx ON wage_payments(labour_id);
CREATE INDEX wage_payments_period_idx ON wage_payments(period_start, period_end);

-- Triggers
CREATE OR REPLACE FUNCTION update_advances_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER labour_advances_updated_at_trigger
BEFORE UPDATE ON labour_advances FOR EACH ROW EXECUTE FUNCTION update_advances_updated_at();

CREATE TRIGGER wage_payments_updated_at_trigger
BEFORE UPDATE ON wage_payments FOR EACH ROW EXECUTE FUNCTION update_advances_updated_at();

-- TRIGGER: Lock attendance and create Labour Wages transaction on payment
CREATE OR REPLACE FUNCTION mark_period_paid()
RETURNS TRIGGER AS $$
DECLARE
  v_wages_cat_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Lock all attendance for this labour+project+period
    UPDATE attendance SET locked = TRUE
    WHERE labour_id = NEW.labour_id
      AND project_id = NEW.project_id
      AND date >= NEW.period_start
      AND date <= NEW.period_end
      AND status = 'present';

    -- Create Labour Wages transaction
    SELECT id INTO v_wages_cat_id FROM categories WHERE name = 'Labour Wages' LIMIT 1;
    INSERT INTO transactions (project_id, date, type, category_id, description, amount, source, source_id, created_by)
    VALUES (NEW.project_id, NEW.paid_on, 'expense', v_wages_cat_id,
      'Labour Wages: ' || NEW.period_start || ' to ' || NEW.period_end, NEW.gross, 'wage', NEW.id, NEW.created_by);
  ELSIF TG_OP = 'DELETE' AND NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    -- Reopen: unlock attendance
    UPDATE attendance SET locked = FALSE
    WHERE labour_id = NEW.labour_id
      AND project_id = NEW.project_id
      AND date >= NEW.period_start
      AND date <= NEW.period_end;

    -- Soft delete the transaction
    UPDATE transactions SET deleted_at = NOW() WHERE source = 'wage' AND source_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER mark_period_paid_trigger
AFTER INSERT ON wage_payments
FOR EACH ROW
EXECUTE FUNCTION mark_period_paid();

-- RLS
ALTER TABLE labour_advances ENABLE ROW LEVEL SECURITY;
ALTER TABLE wage_payments ENABLE ROW LEVEL SECURITY;

-- RLS: advances visible to assigned managers (read own entries < 24h old) and admin/accountant
CREATE POLICY labour_advances_select ON labour_advances
  FOR SELECT USING (
    CASE WHEN app_role() = 'manager' THEN
      created_by = auth.uid() AND (NOW() - created_at) < INTERVAL '24 hours'
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: wage_payments only visible to admin/accountant
CREATE POLICY wage_payments_select ON wage_payments
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));
