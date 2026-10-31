-- Migration: 007_audit_log
-- Creates immutable audit log for financial and admin actions

CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL, -- INSERT, UPDATE, DELETE, soft-delete
  old_data JSONB,
  new_data JSONB,
  user_id UUID REFERENCES auth.users(id),
  at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX audit_log_table_record_idx ON audit_log(table_name, record_id);
CREATE INDEX audit_log_user_idx ON audit_log(user_id);
CREATE INDEX audit_log_at_idx ON audit_log(at);

-- RLS
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- RLS: audit_log only visible to admin
CREATE POLICY audit_log_select ON audit_log
  FOR SELECT USING (app_role() = 'admin');

-- Create audit log for critical tables
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
  VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
    auth.uid()
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Audit on projects, labour, purchases, transactions, wage_payments
CREATE TRIGGER audit_projects_trigger AFTER INSERT OR UPDATE OR DELETE ON projects
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_labour_trigger AFTER INSERT OR UPDATE OR DELETE ON labour
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_purchases_trigger AFTER INSERT OR UPDATE OR DELETE ON purchases
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_transactions_trigger AFTER INSERT OR UPDATE OR DELETE ON transactions
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_wage_payments_trigger AFTER INSERT OR UPDATE OR DELETE ON wage_payments
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_labour_advances_trigger AFTER INSERT OR UPDATE OR DELETE ON labour_advances
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_attendance_trigger AFTER INSERT OR UPDATE OR DELETE ON attendance
  FOR EACH ROW EXECUTE FUNCTION audit_trigger();
