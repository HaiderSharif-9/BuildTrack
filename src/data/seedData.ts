import { Client, Project, Labour, Supplier, Purchase, Transaction, AttendanceRecord, UserProfile } from '../types';
import { WageCalculator } from '../utils/wageCalculator';

export const initialProfiles: UserProfile[] = [
  {
    id: '11111111-1111-1111-1111-111111111111',
    fullName: 'Admin User',
    role: 'admin',
    loginId: 'admin@buildtrack.local',
    phone: '03001234567',
    active: true,
  },
  {
    id: '22222222-2222-2222-2222-222222222222',
    fullName: 'Accountant User',
    role: 'accountant',
    loginId: 'accountant@buildtrack.local',
    phone: '03002345678',
    active: true,
  },
  {
    id: '33333333-3333-3333-3333-333333333333',
    fullName: 'Site Manager',
    role: 'manager',
    loginId: 'manager@buildtrack.local',
    phone: '03003456789',
    active: true,
  },
];

export const initialClients: Client[] = [
  {
    id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    name: 'DHA Defence',
    phone: '03001234567',
    address: 'Karachi',
  },
  {
    id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    name: 'Gulberg Development',
    phone: '03009876543',
    address: 'Lahore',
  },
];

export const initialProjects: Project[] = [
  {
    id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    name: 'DHA Villa B-1 550',
    location: 'DHA Phase V',
    clientId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    startDate: new Date(Date.now() - 60 * 86400000).toISOString().split('T')[0],
    status: 'in_progress',
    budget: 2500000,
  },
  {
    id: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    name: 'DHA Villa B-1 790',
    location: 'DHA Phase V',
    clientId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    startDate: new Date(Date.now() - 60 * 86400000).toISOString().split('T')[0],
    status: 'in_progress',
    budget: 4500000,
  },
  {
    id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    name: 'Gulberg Residence',
    location: 'Gulberg III',
    clientId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    startDate: new Date(Date.now() - 60 * 86400000).toISOString().split('T')[0],
    status: 'in_progress',
    budget: 3500000,
  },
  {
    id: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
    name: 'Commercial Plaza',
    location: 'Gulberg III',
    clientId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    startDate: new Date(Date.now() - 60 * 86400000).toISOString().split('T')[0],
    status: 'in_progress',
    budget: 2000000,
  },
  {
    id: '99999999-9999-9999-9999-999999999999',
    name: 'Farm House Project',
    location: 'Outskirts',
    clientId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    startDate: new Date(Date.now() - 60 * 86400000).toISOString().split('T')[0],
    status: 'in_progress',
    budget: 1200000,
  },
];

export const initialLabour: Labour[] = [
  {
    id: '11111111-2222-2222-2222-222222222222',
    name: 'Muhammad Ali',
    trade: 'Mason',
    active: true,
    phone: '03101111111',
    cnic: '12345-1234567-1',
    defaultRate: 1200,
    projectIds: ['cccccccc-cccc-cccc-cccc-cccccccccccc'],
  },
  {
    id: '11111111-3333-3333-3333-333333333333',
    name: 'Rashid Khan',
    trade: 'Carpenter',
    active: true,
    phone: '03101111112',
    cnic: '12345-1234567-2',
    defaultRate: 1000,
    projectIds: ['dddddddd-dddd-dddd-dddd-dddddddddddd'],
  },
  {
    id: '11111111-4444-4444-4444-444444444444',
    name: 'Imran Ahmed',
    trade: 'Electrician',
    active: true,
    phone: '03101111113',
    cnic: '12345-1234567-3',
    defaultRate: 1000,
    projectIds: ['eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'],
  },
  {
    id: '11111111-5555-5555-5555-555555555555',
    name: 'Sajjad Hassan',
    trade: 'Plumber',
    active: true,
    phone: '03101111114',
    cnic: '12345-1234567-4',
    defaultRate: 1200,
    projectIds: ['ffffffff-ffff-ffff-ffff-ffffffffffff'],
  },
  {
    id: '11111111-6666-6666-6666-666666666666',
    name: 'Bilal Malik',
    trade: 'Helper',
    active: true,
    phone: '03101111115',
    cnic: '12345-1234567-5',
    defaultRate: 1000,
    projectIds: ['cccccccc-cccc-cccc-cccc-cccccccccccc', 'dddddddd-dddd-dddd-dddd-dddddddddddd'],
  },
  {
    id: '11111111-7777-7777-7777-777777777777',
    name: 'Asif Raza',
    trade: 'Helper',
    active: true,
    phone: '03101111116',
    cnic: '12345-1234567-6',
    defaultRate: 1000,
    projectIds: ['99999999-9999-9999-9999-999999999999'],
  },
];

export const initialSuppliers: Supplier[] = [
  {
    id: 'supplier1111-1111-1111-1111-111111111111',
    name: 'Ali Cement Co.',
    phone: '03001234560',
    address: 'Karachi',
  },
  {
    id: 'supplier2222-2222-2222-2222-222222222222',
    name: 'Steel Traders',
    phone: '03009876540',
    address: 'Karachi',
  },
  {
    id: 'supplier3333-3333-3333-3333-333333333333',
    name: 'Electrical Supplies',
    phone: '03105678900',
    address: 'Karachi',
  },
];

export const initialPurchases: Purchase[] = [
  {
    id: 'pur-1',
    projectId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    date: new Date(Date.now() - 20 * 86400000).toISOString().split('T')[0],
    item: 'Cement',
    qty: 100,
    unit: 'Bag',
    rate: 600,
    amount: 60000,
    supplierId: 'supplier1111-1111-1111-1111-111111111111',
    supplierName: 'Ali Cement Co.',
  },
  {
    id: 'pur-2',
    projectId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    date: new Date(Date.now() - 18 * 86400000).toISOString().split('T')[0],
    item: 'Steel Rods',
    qty: 500,
    unit: 'Kg',
    rate: 150,
    amount: 75000,
    supplierId: 'supplier2222-2222-2222-2222-222222222222',
    supplierName: 'Steel Traders',
  },
  {
    id: 'pur-3',
    projectId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    date: new Date(Date.now() - 15 * 86400000).toISOString().split('T')[0],
    item: 'Bricks',
    qty: 5000,
    unit: 'Pcs',
    rate: 8,
    amount: 40000,
    supplierId: 'supplier1111-1111-1111-1111-111111111111',
    supplierName: 'Ali Cement Co.',
  },
  {
    id: 'pur-4',
    projectId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    date: new Date(Date.now() - 19 * 86400000).toISOString().split('T')[0],
    item: 'Cement',
    qty: 150,
    unit: 'Bag',
    rate: 600,
    amount: 90000,
    supplierId: 'supplier1111-1111-1111-1111-111111111111',
    supplierName: 'Ali Cement Co.',
  },
  {
    id: 'pur-5',
    projectId: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    date: new Date(Date.now() - 17 * 86400000).toISOString().split('T')[0],
    item: 'Electrical Wire',
    qty: 1000,
    unit: 'Ft',
    rate: 5,
    amount: 5000,
    supplierId: 'supplier3333-3333-3333-3333-333333333333',
    supplierName: 'Electrical Supplies',
  },
  {
    id: 'pur-6',
    projectId: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
    date: new Date(Date.now() - 16 * 86400000).toISOString().split('T')[0],
    item: 'Sand',
    qty: 10,
    unit: 'Ton',
    rate: 2000,
    amount: 20000,
    supplierId: 'supplier1111-1111-1111-1111-111111111111',
    supplierName: 'Ali Cement Co.',
  },
];

export const initialTransactions: Transaction[] = [
  {
    id: 'tx-1',
    projectId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    date: new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0],
    type: 'income',
    categoryId: 'cat-client-pay',
    categoryName: 'Client Payment',
    description: 'Advance payment received - DHA Villa B-1 550',
    amount: 2450000,
    source: 'manual',
  },
  {
    id: 'tx-2',
    projectId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    date: new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0],
    type: 'income',
    categoryId: 'cat-client-pay',
    categoryName: 'Client Payment',
    description: 'Advance payment received - DHA Villa B-1 790',
    amount: 4200000,
    source: 'manual',
  },
  {
    id: 'tx-3',
    projectId: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    date: new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0],
    type: 'income',
    categoryId: 'cat-client-pay',
    categoryName: 'Client Payment',
    description: 'Payment received - Gulberg Residence',
    amount: 3100000,
    source: 'manual',
  },
  {
    id: 'tx-4',
    projectId: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
    date: new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0],
    type: 'income',
    categoryId: 'cat-client-pay',
    categoryName: 'Client Payment',
    description: 'Milestone 1 Payment - Commercial Plaza',
    amount: 1800000,
    source: 'manual',
  },
  {
    id: 'tx-5',
    projectId: '99999999-9999-9999-9999-999999999999',
    date: new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0],
    type: 'income',
    categoryId: 'cat-client-pay',
    categoryName: 'Client Payment',
    description: 'Initial deposit - Farm House Project',
    amount: 900000,
    source: 'manual',
  },
  // Company-wide expenses
  {
    id: 'tx-6',
    projectId: null,
    date: new Date(Date.now() - 25 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-office',
    categoryName: 'Office',
    description: 'Office rent - Multan headquarters',
    amount: 150000,
    source: 'manual',
  },
  {
    id: 'tx-7',
    projectId: null,
    date: new Date(Date.now() - 22 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-transport',
    categoryName: 'Transport',
    description: 'Fuel and site transportation fleet',
    amount: 120000,
    source: 'manual',
  },
  {
    id: 'tx-8',
    projectId: null,
    date: new Date(Date.now() - 20 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-utilities',
    categoryName: 'Utilities',
    description: 'Electricity, water, and generator bills',
    amount: 80000,
    source: 'manual',
  },
  {
    id: 'tx-9',
    projectId: null,
    date: new Date(Date.now() - 10 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-office',
    categoryName: 'Office',
    description: 'Stationery and site safety equipment supplies',
    amount: 70000,
    source: 'manual',
  },
  // Material purchases auto-transactions
  {
    id: 'tx-10',
    projectId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    date: new Date(Date.now() - 20 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-materials',
    categoryName: 'Materials',
    description: 'Purchase: 100 Bag Cement (Ali Cement Co.)',
    amount: 60000,
    source: 'purchase',
    sourceId: 'pur-1',
  },
  {
    id: 'tx-11',
    projectId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    date: new Date(Date.now() - 18 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-materials',
    categoryName: 'Materials',
    description: 'Purchase: 500 Kg Steel Rods (Steel Traders)',
    amount: 75000,
    source: 'purchase',
    sourceId: 'pur-2',
  },
  {
    id: 'tx-12',
    projectId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    date: new Date(Date.now() - 19 * 86400000).toISOString().split('T')[0],
    type: 'expense',
    categoryId: 'cat-materials',
    categoryName: 'Materials',
    description: 'Purchase: 150 Bag Cement (Ali Cement Co.)',
    amount: 90000,
    source: 'purchase',
    sourceId: 'pur-4',
  },
];

/**
 * Generate 30 days of attendance including golden cases for Muhammad Ali and others
 */
export function generateSeedAttendance(): AttendanceRecord[] {
  const records: AttendanceRecord[] = [];
  const calc1200 = new WageCalculator({ rate: 1200 });
  const calc1000 = new WageCalculator({ rate: 1000 });

  const muhammadAliId = '11111111-2222-2222-2222-222222222222';
  const site1 = 'cccccccc-cccc-cccc-cccc-cccccccccccc';

  // Generate 30 days for Muhammad Ali
  for (let day = 1; day <= 30; day++) {
    const d = new Date(Date.now() - (30 - day) * 86400000);
    const dateStr = d.toISOString().split('T')[0];

    let status: 'present' | 'absent' | 'leave' = 'present';
    let inTime: string | undefined = undefined;
    let outTime: string | undefined = undefined;

    if (day === 1) {
      status = 'present';
      inTime = '08:00';
      outTime = '18:00'; // 10h = 1200
    } else if (day === 2) {
      status = 'present';
      inTime = '08:00';
      outTime = '13:00'; // 5h = 600
    } else if (day === 3) {
      status = 'present';
      inTime = '08:00';
      outTime = '12:00'; // 4h = 480
    } else if (day === 4) {
      status = 'present';
      inTime = '08:00';
      outTime = '20:00'; // 12h = 1560
    } else if (day === 5) {
      status = 'present';
      inTime = undefined;
      outTime = undefined; // full day = 1200
    } else if (day === 6) {
      status = 'absent';
    } else if (day === 7) {
      status = 'leave';
    } else {
      status = 'present';
      inTime = '08:00';
      outTime = '18:00';
    }

    const wageRes = calc1200.calculateDay({ status, inTime, outTime });

    records.push({
      id: `att-ali-${day}`,
      projectId: site1,
      labourId: muhammadAliId,
      date: dateStr,
      status,
      inTime,
      outTime,
      hoursWorked: wageRes.hoursWorked,
      overtimeHours: wageRes.overtimeHours,
      locked: day < 25,
      rate: 1200,
      wageAmount: wageRes.wageAmount,
    });
  }

  // Other 5 labourers over the past 14 days
  const otherLabourers = [
    { id: '11111111-3333-3333-3333-333333333333', rate: 1000, site: 'dddddddd-dddd-dddd-dddd-dddddddddddd' },
    { id: '11111111-4444-4444-4444-444444444444', rate: 1000, site: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee' },
    { id: '11111111-5555-5555-5555-555555555555', rate: 1200, site: 'ffffffff-ffff-ffff-ffff-ffffffffffff' },
    { id: '11111111-6666-6666-6666-666666666666', rate: 1000, site: 'cccccccc-cccc-cccc-cccc-cccccccccccc' },
    { id: '11111111-7777-7777-7777-777777777777', rate: 1000, site: '99999999-9999-9999-9999-999999999999' },
  ];

  for (const lab of otherLabourers) {
    const calc = lab.rate === 1200 ? calc1200 : calc1000;
    for (let day = 1; day <= 14; day++) {
      const d = new Date(Date.now() - (14 - day) * 86400000);
      const dateStr = d.toISOString().split('T')[0];

      let status: 'present' | 'absent' | 'leave' = 'present';
      if (day % 7 === 6) status = 'leave';
      else if (day % 7 === 0) status = 'absent';

      const inTime = status === 'present' ? '08:00' : undefined;
      const outTime = status === 'present' ? '18:00' : undefined;
      const wageRes = calc.calculateDay({ status, inTime, outTime });

      records.push({
        id: `att-${lab.id}-${day}`,
        projectId: lab.site,
        labourId: lab.id,
        date: dateStr,
        status,
        inTime,
        outTime,
        hoursWorked: wageRes.hoursWorked,
        overtimeHours: wageRes.overtimeHours,
        locked: day < 10,
        rate: lab.rate,
        wageAmount: wageRes.wageAmount,
      });
    }
  }

  return records;
}
