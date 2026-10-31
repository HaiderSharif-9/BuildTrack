-- Migration: 003_labour_and_rates
-- Creates labour tables with rates (sensitive data hidden from managers)

CREATE TABLE labour (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  trade TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ
);

-- Labour private data (CNIC, phone, default rate - admin/accountant only)
CREATE TABLE labour_private (
  labour_id UUID PRIMARY KEY REFERENCES labour(id) ON DELETE CASCADE,
  phone TEXT,
  cnic TEXT,
  default_rate NUMERIC(14,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT default_rate_positive CHECK (default_rate IS NULL OR default_rate > 0)
);

-- Project labour (which labourers work on which sites)
CREATE TABLE project_labour (
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  labour_id UUID REFERENCES labour(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (project_id, labour_id)
);

-- Project labour rate override (site-specific rate)
CREATE TABLE project_labour_rate (
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  labour_id UUID REFERENCES labour(id) ON DELETE CASCADE,
  rate_override NUMERIC(14,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  PRIMARY KEY (project_id, labour_id),
  CONSTRAINT rate_override_positive CHECK (rate_override > 0)
);

-- Triggers: update updated_at
CREATE OR REPLACE FUNCTION update_labour_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER labour_updated_at_trigger
BEFORE UPDATE ON labour FOR EACH ROW EXECUTE FUNCTION update_labour_updated_at();

CREATE TRIGGER labour_private_updated_at_trigger
BEFORE UPDATE ON labour_private FOR EACH ROW EXECUTE FUNCTION update_labour_updated_at();

CREATE TRIGGER project_labour_rate_updated_at_trigger
BEFORE UPDATE ON project_labour_rate FOR EACH ROW EXECUTE FUNCTION update_labour_updated_at();

-- Indexes
CREATE INDEX labour_active_idx ON labour(active) WHERE deleted_at IS NULL;
CREATE INDEX project_labour_labour_id_idx ON project_labour(labour_id);
CREATE INDEX project_labour_rate_labour_id_idx ON project_labour_rate(labour_id);

-- RLS
ALTER TABLE labour ENABLE ROW LEVEL SECURITY;
ALTER TABLE labour_private ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_labour ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_labour_rate ENABLE ROW LEVEL SECURITY;

-- RLS: labour visible to assigned managers and admin/accountant
CREATE POLICY labour_select ON labour
  FOR SELECT USING (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_labour pl
        JOIN project_members pm ON pl.project_id = pm.project_id
        WHERE pl.labour_id = id AND pm.user_id = auth.uid()
      )
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: labour_private only visible to admin/accountant
CREATE POLICY labour_private_select ON labour_private
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));

-- RLS: project_labour visible to assigned managers and admin/accountant
CREATE POLICY project_labour_select ON project_labour
  FOR SELECT USING (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (
        SELECT 1 FROM project_members
        WHERE project_id = project_labour.project_id AND user_id = auth.uid()
      )
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: project_labour_rate only visible to admin/accountant
CREATE POLICY project_labour_rate_select ON project_labour_rate
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));
