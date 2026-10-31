-- Migration: 002_projects_and_clients
-- Creates clients, projects, and project_finance tables

CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  location TEXT,
  client_id UUID REFERENCES clients(id),
  start_date DATE,
  end_date DATE,
  status project_status NOT NULL DEFAULT 'planning',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ
);

-- Project finance (budget, sensitive data - managers cannot see)
CREATE TABLE project_finance (
  project_id UUID PRIMARY KEY REFERENCES projects(id) ON DELETE CASCADE,
  budget NUMERIC(14,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT budget_positive CHECK (budget IS NULL OR budget > 0)
);

-- Project members (which managers see which sites)
CREATE TABLE project_members (
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (project_id, user_id)
);

-- Suppliers
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ
);

-- Triggers: update updated_at
CREATE OR REPLACE FUNCTION update_projects_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER projects_updated_at_trigger
BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_projects_updated_at();

CREATE TRIGGER project_finance_updated_at_trigger
BEFORE UPDATE ON project_finance FOR EACH ROW EXECUTE FUNCTION update_projects_updated_at();

CREATE TRIGGER clients_updated_at_trigger
BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_projects_updated_at();

CREATE TRIGGER suppliers_updated_at_trigger
BEFORE UPDATE ON suppliers FOR EACH ROW EXECUTE FUNCTION update_projects_updated_at();

-- Indexes for common queries
CREATE INDEX projects_client_id_idx ON projects(client_id) WHERE deleted_at IS NULL;
CREATE INDEX projects_status_idx ON projects(status) WHERE deleted_at IS NULL;
CREATE INDEX project_members_user_id_idx ON project_members(user_id);

-- RLS on projects and project_finance
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_finance ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;

-- RLS: projects visible to assigned managers and admins/accountants
CREATE POLICY projects_select ON projects
  FOR SELECT USING (
    CASE WHEN app_role() = 'manager' THEN
      EXISTS (SELECT 1 FROM project_members WHERE project_id = id AND user_id = auth.uid())
    ELSE
      app_role() IN ('admin', 'accountant')
    END
  );

-- RLS: project_finance only visible to admin/accountant
CREATE POLICY project_finance_select ON project_finance
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));

-- RLS: project_members visible to admin/accountant
CREATE POLICY project_members_select ON project_members
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));

-- RLS: clients and suppliers visible to all authenticated
CREATE POLICY clients_select ON clients
  FOR SELECT USING (auth.role() = 'authenticated_user');

CREATE POLICY suppliers_select ON suppliers
  FOR SELECT USING (auth.role() = 'authenticated_user');
