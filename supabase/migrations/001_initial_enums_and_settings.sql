-- Migration: 001_initial_enums_and_settings
-- Creates enum types and the single app_settings row

-- User role enum
CREATE TYPE user_role AS ENUM ('admin', 'accountant', 'manager');

-- Project status enum
CREATE TYPE project_status AS ENUM ('planning', 'in_progress', 'on_hold', 'completed');

-- Attendance status enum
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'leave');

-- Transaction type enum
CREATE TYPE tx_type AS ENUM ('income', 'expense');

-- Transaction source enum
CREATE TYPE tx_source AS ENUM ('manual', 'purchase', 'wage');

-- App settings table (single row, updated by admin)
CREATE TABLE app_settings (
  id BIGINT PRIMARY KEY DEFAULT 1,
  company_name TEXT NOT NULL DEFAULT 'Care Constructiona Pvt Ltd',
  currency TEXT NOT NULL DEFAULT 'PKR',
  full_day_hours NUMERIC(5,2) NOT NULL DEFAULT 10.00,
  overtime_multiplier NUMERIC(5,2) NOT NULL DEFAULT 1.50,
  week_start_day INT NOT NULL DEFAULT 5, -- ISO 8601: Friday=5
  pay_day INT NOT NULL DEFAULT 4, -- ISO 8601: Thursday=4
  default_language TEXT NOT NULL DEFAULT 'en',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT settings_single_row CHECK (id = 1),
  CONSTRAINT full_day_hours_positive CHECK (full_day_hours > 0),
  CONSTRAINT overtime_multiplier_positive CHECK (overtime_multiplier > 0),
  CONSTRAINT week_start_day_valid CHECK (week_start_day BETWEEN 1 AND 7),
  CONSTRAINT pay_day_valid CHECK (pay_day BETWEEN 1 AND 7)
);

-- Profiles table (auth users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'manager',
  phone TEXT,
  login_id TEXT UNIQUE, -- phone or email used for login
  active BOOLEAN NOT NULL DEFAULT TRUE,
  must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
  temp_password_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ
);

-- Trigger: update updated_at timestamp on profiles
CREATE OR REPLACE FUNCTION update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at_trigger
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_profiles_updated_at();

-- Trigger: create profile when auth user signs up
CREATE OR REPLACE FUNCTION create_profile_on_signup()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, login_id, role, active)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.phone, NEW.email),
    'manager', -- default role for signup (disabled in prod)
    TRUE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_profile_on_signup_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION create_profile_on_signup();

-- Helper function: get current user's role
CREATE OR REPLACE FUNCTION app_role()
RETURNS user_role AS $$
  SELECT role FROM profiles
  WHERE id = auth.uid() AND active = TRUE
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

-- Enable RLS on app_settings and profiles
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS: app_settings readable by all authenticated users
CREATE POLICY app_settings_select ON app_settings
  FOR SELECT USING (auth.role() = 'authenticated_user');

-- RLS: profiles readable by admin/accountant, self-readable by manager
CREATE POLICY profiles_select_admin ON profiles
  FOR SELECT USING (app_role() IN ('admin', 'accountant'));

CREATE POLICY profiles_select_self ON profiles
  FOR SELECT USING (id = auth.uid());

CREATE POLICY profiles_update_admin ON profiles
  FOR UPDATE USING (app_role() = 'admin');
