-- Migration: 005_purchases_and_transactions
-- Creates purchases, transactions, and ledger system

CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  type tx_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, type) VALUES
  ('Client Payment', 'income'),
  ('Advance from Client', 'income'),
  ('Other Income', 'income'),
  ('Materials', 'expense'),
  ('Labour Wages', 'expense'),
  ('Equipment Rental', 'expense'),
  ('Subcontractor', 'expense'),
  ('Transport', 'expense'),
  ('Office', 'expense'),
  ('Utilities', 'expense'),
  ('Other Expense', 'expense');

-- Purchases (generates Materials expense automatically)
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  date DATE NOT NULL,
  item TEXT NOT NULL,
  qty NUMERIC(14,4) NOT NULL,
  unit TEXT, -- Bag, Pcs, Kg, Trolley, Ton, Ft, Lot, or custom
  rate NUMERIC(14,2) NOT NULL,
  amount NUMERIC(14,2) GENERATED ALWAYS AS (qty * rate) STORED,
  supplier_id UUID REFERENCES suppliers(id),
  attachment_path TEXT, -- Storage path to bill photo
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT qty_positive CHECK (qty > 0),
  CONSTRAINT rate_positive CHECK (rate > 0)
);

-- Transactions (ledger: manual, purchase-generated, wage-generated)
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id), -- NULL for company-level (office, transport, etc.)
  date DATE NOT NULL,
  type tx_type NOT NULL,
  category_id UUID NOT NULL REFERENCES categories(id),
  description TEXT,
  amount NUMERIC(14,2) NOT NULL,
  source tx_source NOT NULL DEFAULT 'manual',
  source_id UUID, -- reference to purchase, wage_payment, etc.
  attachment_path TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT amount_positive CHECK (amount > 0),
  CONSTRAINT amount_reasonable CHECK (amount < 100000000)
);

-- Unique index: source + source_id (for upsert logic)
CREATE UNIQUE INDEX transactions_source_idx
  ON transactions (source, source_id) WHERE source_id IS NOT NULL;

-- Indexes
CREATE INDEX purchases_project_date_idx ON purchases(project_id, date) WHERE deleted_at IS NULL;
CREATE INDEX purchases_supplier_idx ON purchases(supplier_id);
CREATE INDEX transactions_project_date_idx ON transactions(project_id, date) WHERE deleted_at IS NULL;
CREATE INDEX transactions_date_type_idx ON transactions(date, type) WHERE deleted_at IS NULL;
CREATE INDEX transactions_category_idx ON transactions(category_id);

-- Triggers
CREATE OR REPLACE FUNCTION update_purchases_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER purchases_updated_at_trigger
BEFORE UPDATE ON purchases FOR EACH ROW EXECUTE FUNCTION update_purchases_updated_at();

CREATE TRIGGER transactions_updated_at_trigger
BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_purchases_updated_at();

-- TRIGGER: Create Materials transaction from purchase
CREATE OR REPLACE FUNCTION sync_purchase_transaction()
RETURNS TRIGGER AS $$
DECLARE
  v_materials_cat_id UUID;
BEGIN
  SELECT id INTO v_materials_cat_id FROM categories WHERE name = 'Materials' LIMIT 1;

  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    -- Upsert transaction
    INSERT INTO transactions (project_id, date, type, category_id, description, amount, source, source_id, created_by)
    VALUES (NEW.project_id, NEW.date, 'expense', v_materials_cat_id, NEW.item, NEW.amount, 'purchase', NEW.id, NEW.created_by)
    ON CONFLICT (source, source_id) DO UPDATE SET
      date = EXCLUDED.date,
      amount = EXCLUDED.amount,
      description = EXCLUDED.description,
      updated_at = NOW();
  ELSIF TG_OP = 'DELETE' THEN
    -- Soft delete the transaction
    UPDATE transactions SET deleted_at = NOW() WHERE source = 'purchase' AND source_id = OLD.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER sync_purchase_transaction_trigger
AFTER INSERT OR UPDATE OR DELETE ON purchases
FOR EACH ROW
EXECUTE FUNCTION sync_purchase_transaction();

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- RLS: categories readable by all
CREATE POLICY categories_select ON categories
  FOR SELECT USING (TRUE);

-- RLS: purchases visible to assigned managers and admin/accountant
CREATE POLICY purchases_select ON purchases
  FOR SELECT USING (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = purchases.project_id AND user_id = auth.uid()
      )
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

CREATE POLICY purchases_insert ON purchases
  FOR INSERT WITH CHECK (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = purchases.project_id AND user_id = auth.uid()
      )
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: transactions only visible to admin/accountant (managers never see money)
CREATE POLICY transactions_select ON transactions
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));
