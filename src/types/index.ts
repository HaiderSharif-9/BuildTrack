export type UserRole = 'admin' | 'accountant' | 'manager';

export interface UserProfile {
  id: string;
  fullName: string;
  role: UserRole;
  loginId: string;
  phone?: string;
  active: boolean;
}

export interface Client {
  id: string;
  name: string;
  phone: string;
  address: string;
}

export type ProjectStatus = 'planning' | 'in_progress' | 'on_hold' | 'completed';

export interface Project {
  id: string;
  name: string;
  location: string;
  clientId?: string;
  startDate?: string;
  endDate?: string;
  status: ProjectStatus;
  budget: number;
}

export interface Labour {
  id: string;
  name: string;
  trade: string;
  active: boolean;
  phone?: string;
  cnic?: string;
  defaultRate: number;
  projectIds?: string[];
}

export type AttendanceStatus = 'present' | 'absent' | 'leave';

export interface AttendanceRecord {
  id: string;
  projectId: string;
  labourId: string;
  date: string; // YYYY-MM-DD
  status: AttendanceStatus;
  inTime?: string; // HH:mm
  outTime?: string; // HH:mm
  hoursWorked?: number | null;
  overtimeHours?: number;
  remarks?: string;
  locked: boolean;
  rate?: number;
  wageAmount?: number;
}

export type TransactionType = 'income' | 'expense';

export interface Transaction {
  id: string;
  projectId?: string | null; // null = company-wide
  date: string;
  type: TransactionType;
  categoryId: string;
  categoryName?: string;
  description: string;
  amount: number;
  source: 'manual' | 'purchase' | 'wage';
  sourceId?: string;
  attachmentPath?: string;
}

export interface Purchase {
  id: string;
  projectId: string;
  date: string;
  item: string;
  qty: number;
  unit: string;
  rate: number;
  amount: number;
  supplierId?: string;
  supplierName?: string;
  attachmentPath?: string;
}

export interface Supplier {
  id: string;
  name: string;
  phone: string;
  address: string;
}

export interface WagePayment {
  id: string;
  labourId: string;
  projectId: string;
  periodStart: string;
  periodEnd: string;
  gross: number;
  advancesDeducted: number;
  net: number;
  paidOn: string;
  method: 'cash' | 'bank' | 'easypaisa' | 'jazzcash';
}

export interface LabourAdvance {
  id: string;
  labourId: string;
  projectId: string;
  date: string;
  amount: number;
  note?: string;
}

export interface WageCalculationResult {
  hoursWorked: number | null;
  overtimeHours: number;
  basePay: number;
  overtimePay: number;
  wageAmount: number;
}
