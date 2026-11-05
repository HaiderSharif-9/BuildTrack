-- Migration: 009_dashboard_reporting_functions
-- Server-side dashboard aggregates. Functions run as the caller so existing
-- RLS policies continue to restrict managers to their assigned sites and
-- prevent them from reading financial rows.

CREATE OR REPLACE FUNCTION dashboard_summary(
  "from" DATE,
  "to" DATE,
  "project" UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE SQL
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  WITH transaction_totals AS (
    SELECT
      COALESCE(SUM(amount) FILTER (WHERE type = 'income'), 0) AS total_income,
      COALESCE(SUM(amount) FILTER (WHERE type = 'expense' AND project_id IS NOT NULL), 0) AS site_expenses,
      COALESCE(SUM(amount) FILTER (WHERE type = 'expense' AND project_id IS NULL), 0) AS other_expenses
    FROM transactions
    WHERE date BETWEEN "from" AND "to"
      AND deleted_at IS NULL
      AND ("project" IS NULL OR project_id = "project")
  ),
  project_totals AS (
    SELECT
      COUNT(*)::INTEGER AS total_projects,
      COUNT(*) FILTER (WHERE status = 'in_progress')::INTEGER AS in_progress_projects
    FROM projects
    WHERE deleted_at IS NULL
      AND ("project" IS NULL OR id = "project")
  )
  SELECT jsonb_build_object(
    'total_income', transaction_totals.total_income,
    'site_expenses', transaction_totals.site_expenses,
    'other_expenses', transaction_totals.other_expenses,
    'gross_profit', transaction_totals.total_income - transaction_totals.site_expenses,
    'net_profit', transaction_totals.total_income - transaction_totals.site_expenses - transaction_totals.other_expenses,
    'total_projects', project_totals.total_projects,
    'in_progress_projects', project_totals.in_progress_projects,
    'generated_at', NOW()
  )
  FROM transaction_totals CROSS JOIN project_totals;
$$;

CREATE OR REPLACE FUNCTION daily_trend(
  "from" DATE,
  "to" DATE,
  "project" UUID DEFAULT NULL
)
RETURNS TABLE (
  date DATE,
  income NUMERIC,
  expenses NUMERIC,
  profit NUMERIC
)
LANGUAGE SQL
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    t.date,
    COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'income'), 0) AS income,
    COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'expense'), 0) AS expenses,
    COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'income'), 0)
      - COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'expense'), 0) AS profit
  FROM transactions t
  WHERE t.date BETWEEN "from" AND "to"
    AND t.deleted_at IS NULL
    AND ("project" IS NULL OR t.project_id = "project")
  GROUP BY t.date
  ORDER BY t.date;
$$;

CREATE OR REPLACE FUNCTION site_totals(
  "from" DATE,
  "to" DATE,
  "project" UUID DEFAULT NULL
)
RETURNS TABLE (
  site_id UUID,
  site_name TEXT,
  income NUMERIC,
  expenses NUMERIC,
  profit NUMERIC,
  budget NUMERIC
)
LANGUAGE SQL
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    p.id AS site_id,
    p.name AS site_name,
    COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'income'), 0) AS income,
    COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'expense'), 0) AS expenses,
    COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'income'), 0)
      - COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'expense'), 0) AS profit,
    COALESCE(pf.budget, 0) AS budget
  FROM projects p
  LEFT JOIN project_finance pf ON pf.project_id = p.id
  LEFT JOIN transactions t
    ON t.project_id = p.id
    AND t.date BETWEEN "from" AND "to"
    AND t.deleted_at IS NULL
  WHERE p.deleted_at IS NULL
    AND ("project" IS NULL OR p.id = "project")
  GROUP BY p.id, p.name, pf.budget
  ORDER BY p.name;
$$;

REVOKE ALL ON FUNCTION dashboard_summary(DATE, DATE, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION daily_trend(DATE, DATE, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION site_totals(DATE, DATE, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION dashboard_summary(DATE, DATE, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION daily_trend(DATE, DATE, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION site_totals(DATE, DATE, UUID) TO authenticated;
