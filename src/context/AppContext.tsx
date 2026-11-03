import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import {
  UserProfile,
  Project,
  Labour,
  AttendanceRecord,
  Transaction,
  Purchase,
  Supplier,
  Client,
  UserRole,
} from '../types';
import {
  initialProfiles,
  initialProjects,
  initialLabour,
  initialSuppliers,
  initialPurchases,
  initialTransactions,
  initialClients,
  generateSeedAttendance,
} from '../data/seedData';
import { translations, Language } from '../l10n/translations';
import { WageCalculator } from '../utils/wageCalculator';

export type PeriodFilter = 'today' | 'thisWeek' | 'thisMonth' | 'thisYear' | 'custom';
export type ThemeMode = 'light' | 'dark' | 'system';

interface AppContextType {
  // Localization
  language: Language;
  setLanguage: (lang: Language) => void;
  t: typeof translations['en'];
  isRtl: boolean;

  // Theme
  themeMode: ThemeMode;
  setThemeMode: (mode: ThemeMode) => void;
  isDark: boolean;

  // Auth & Roles
  currentUser: UserProfile | null;
  userRole: UserRole | null;
  signIn: (loginId: string, password?: string) => Promise<boolean>;
  signUp: (fullName: string, email: string, phone?: string) => Promise<boolean>;
  signOut: () => void;
  switchUserRole: (role: UserRole) => void;
  changePassword: (oldPass: string, newPass: string) => Promise<boolean>;

  // Filter State
  selectedPeriod: PeriodFilter;
  setSelectedPeriod: (p: PeriodFilter) => void;
  selectedSiteId: string | null;
  setSelectedSiteId: (id: string | null) => void;

  // Core Data
  projects: Project[];
  labourList: Labour[];
  attendance: AttendanceRecord[];
  transactions: Transaction[];
  purchases: Purchase[];
  suppliers: Supplier[];
  clients: Client[];

  // CRUD Actions
  addProject: (p: Omit<Project, 'id'>) => void;
  updateProject: (id: string, p: Partial<Project>) => void;
  addLabour: (l: Omit<Labour, 'id'>) => void;
  updateLabour: (id: string, l: Partial<Labour>) => void;
  recordAttendance: (record: Omit<AttendanceRecord, 'id' | 'wageAmount' | 'hoursWorked' | 'overtimeHours'>) => void;
  addPurchase: (p: Omit<Purchase, 'id' | 'amount'>) => void;
  addTransaction: (tx: Omit<Transaction, 'id'>) => void;

  // Computed Summaries
  summary: {
    totalIncome: number;
    totalExpense: number;
    netProfit: number;
    activeSitesCount: number;
    totalLabourCount: number;
    todayPresentCount: number;
  };
}

const AppContext = createContext<AppContextType | null>(null);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Localization
  const [language, setLanguageState] = useState<Language>(() => {
    return (localStorage.getItem('buildtrack_lang') as Language) || 'en';
  });

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    localStorage.setItem('buildtrack_lang', lang);
  };

  const isRtl = language === 'ur';

  useEffect(() => {
    document.documentElement.dir = isRtl ? 'rtl' : 'ltr';
    document.documentElement.lang = language;
  }, [language, isRtl]);

  const t = translations[language] || translations.en;

  // Theme
  const [themeMode, setThemeModeState] = useState<ThemeMode>(() => {
    return (localStorage.getItem('buildtrack_theme') as ThemeMode) || 'light';
  });

  const setThemeMode = (mode: ThemeMode) => {
    setThemeModeState(mode);
    localStorage.setItem('buildtrack_theme', mode);
  };

  const [isSystemDark, setIsSystemDark] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    setIsSystemDark(mq.matches);
    const handler = (e: MediaQueryListEvent) => setIsSystemDark(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  const isDark = themeMode === 'dark' || (themeMode === 'system' && isSystemDark);

  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDark]);

  // Auth
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(() => {
    const stored = localStorage.getItem('buildtrack_user');
    if (stored) {
      try {
        return JSON.parse(stored);
      } catch {
        return initialProfiles[0];
      }
    }
    return initialProfiles[0]; // Default logged-in as Admin for smooth developer & preview experience
  });

  const userRole = currentUser?.role || null;

  const signIn = async (loginId: string, _password?: string): Promise<boolean> => {
    const trimmed = loginId.trim().toLowerCase();
    const found = initialProfiles.find(
      p => p.loginId.toLowerCase() === trimmed || p.phone === trimmed || p.fullName.toLowerCase().includes(trimmed)
    );
    if (found) {
      setCurrentUser(found);
      localStorage.setItem('buildtrack_user', JSON.stringify(found));
      return true;
    }
    // Generic match fallback
    const generic: UserProfile = {
      id: 'usr-' + Date.now(),
      fullName: loginId.includes('@') ? loginId.split('@')[0] : loginId,
      role: 'manager',
      loginId,
      active: true,
    };
    setCurrentUser(generic);
    localStorage.setItem('buildtrack_user', JSON.stringify(generic));
    return true;
  };

  const signUp = async (fullName: string, email: string, phone?: string): Promise<boolean> => {
    const newProf: UserProfile = {
      id: 'usr-' + Date.now(),
      fullName,
      email: email,
      loginId: email,
      phone,
      role: 'manager', // Non-first users default to manager
      active: true,
    } as UserProfile;
    setCurrentUser(newProf);
    localStorage.setItem('buildtrack_user', JSON.stringify(newProf));
    return true;
  };

  const signOut = () => {
    setCurrentUser(null);
    localStorage.removeItem('buildtrack_user');
  };

  const switchUserRole = (role: UserRole) => {
    if (currentUser) {
      const updated = { ...currentUser, role };
      setCurrentUser(updated);
      localStorage.setItem('buildtrack_user', JSON.stringify(updated));
    }
  };

  const changePassword = async (_oldPass: string, _newPass: string): Promise<boolean> => {
    return true;
  };

  // Data State
  const [projects, setProjects] = useState<Project[]>(() => {
    const saved = localStorage.getItem('buildtrack_projects');
    return saved ? JSON.parse(saved) : initialProjects;
  });

  const [labourList, setLabourList] = useState<Labour[]>(() => {
    const saved = localStorage.getItem('buildtrack_labour');
    return saved ? JSON.parse(saved) : initialLabour;
  });

  const [attendance, setAttendance] = useState<AttendanceRecord[]>(() => {
    const saved = localStorage.getItem('buildtrack_attendance');
    return saved ? JSON.parse(saved) : generateSeedAttendance();
  });

  const [purchases, setPurchases] = useState<Purchase[]>(() => {
    const saved = localStorage.getItem('buildtrack_purchases');
    return saved ? JSON.parse(saved) : initialPurchases;
  });

  const [transactions, setTransactions] = useState<Transaction[]>(() => {
    const saved = localStorage.getItem('buildtrack_transactions');
    return saved ? JSON.parse(saved) : initialTransactions;
  });

  const [suppliers] = useState<Supplier[]>(initialSuppliers);
  const [clients] = useState<Client[]>(initialClients);

  // Filters
  const [selectedPeriod, setSelectedPeriod] = useState<PeriodFilter>('thisMonth');
  const [selectedSiteId, setSelectedSiteId] = useState<string | null>(null);

  // Sync to local storage
  useEffect(() => {
    localStorage.setItem('buildtrack_projects', JSON.stringify(projects));
  }, [projects]);

  useEffect(() => {
    localStorage.setItem('buildtrack_labour', JSON.stringify(labourList));
  }, [labourList]);

  useEffect(() => {
    localStorage.setItem('buildtrack_attendance', JSON.stringify(attendance));
  }, [attendance]);

  useEffect(() => {
    localStorage.setItem('buildtrack_purchases', JSON.stringify(purchases));
  }, [purchases]);

  useEffect(() => {
    localStorage.setItem('buildtrack_transactions', JSON.stringify(transactions));
  }, [transactions]);

  // CRUD Implementations
  const addProject = (p: Omit<Project, 'id'>) => {
    const newProj: Project = { ...p, id: 'proj-' + Date.now() };
    setProjects(prev => [newProj, ...prev]);
  };

  const updateProject = (id: string, p: Partial<Project>) => {
    setProjects(prev => prev.map(item => (item.id === id ? { ...item, ...p } : item)));
  };

  const addLabour = (l: Omit<Labour, 'id'>) => {
    const newLab: Labour = { ...l, id: 'lab-' + Date.now() };
    setLabourList(prev => [newLab, ...prev]);
  };

  const updateLabour = (id: string, l: Partial<Labour>) => {
    setLabourList(prev => prev.map(item => (item.id === id ? { ...item, ...l } : item)));
  };

  const recordAttendance = (record: Omit<AttendanceRecord, 'id' | 'wageAmount' | 'hoursWorked' | 'overtimeHours'>) => {
    const labour = labourList.find(l => l.id === record.labourId);
    const rate = record.rate || labour?.defaultRate || 1000;
    const calc = new WageCalculator({ rate });
    const wageResult = calc.calculateDay({
      status: record.status,
      inTime: record.inTime,
      outTime: record.outTime,
    });

    const newRecord: AttendanceRecord = {
      ...record,
      id: 'att-' + Date.now(),
      hoursWorked: wageResult.hoursWorked,
      overtimeHours: wageResult.overtimeHours,
      rate,
      wageAmount: wageResult.wageAmount,
    };

    setAttendance(prev => {
      // If record for this labour and date already exists, replace it
      const filtered = prev.filter(a => !(a.labourId === record.labourId && a.date === record.date));
      return [newRecord, ...filtered];
    });
  };

  const addPurchase = (p: Omit<Purchase, 'id' | 'amount'>) => {
    const amount = p.qty * p.rate;
    const newPurchase: Purchase = {
      ...p,
      id: 'pur-' + Date.now(),
      amount,
    };
    setPurchases(prev => [newPurchase, ...prev]);

    // Material purchase automatically logs an expense transaction
    const newTx: Transaction = {
      id: 'tx-' + Date.now(),
      projectId: p.projectId,
      date: p.date,
      type: 'expense',
      categoryId: 'cat-materials',
      categoryName: 'Materials',
      description: `Purchase: ${p.qty} ${p.unit} ${p.item} (${p.supplierName || 'Supplier'})`,
      amount,
      source: 'purchase',
      sourceId: newPurchase.id,
    };
    setTransactions(prev => [newTx, ...prev]);
  };

  const addTransaction = (tx: Omit<Transaction, 'id'>) => {
    const newTx: Transaction = {
      ...tx,
      id: 'tx-' + Date.now(),
    };
    setTransactions(prev => [newTx, ...prev]);
  };

  // Filtered Summary Computations
  const summary = useMemo(() => {
    let filteredTx = transactions;
    if (selectedSiteId) {
      filteredTx = filteredTx.filter(t => t.projectId === selectedSiteId);
    }

    const totalIncome = filteredTx
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalExpense = filteredTx
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);

    const netProfit = totalIncome - totalExpense;

    const activeSitesCount = projects.filter(p => p.status === 'in_progress').length;
    const totalLabourCount = labourList.filter(l => l.active).length;

    const todayStr = new Date().toISOString().split('T')[0];
    const todayPresentCount = attendance.filter(
      a => a.date === todayStr && a.status === 'present' && (!selectedSiteId || a.projectId === selectedSiteId)
    ).length;

    return {
      totalIncome,
      totalExpense,
      netProfit,
      activeSitesCount,
      totalLabourCount,
      todayPresentCount,
    };
  }, [transactions, projects, labourList, attendance, selectedSiteId]);

  return (
    <AppContext.Provider
      value={{
        language,
        setLanguage,
        t,
        isRtl,
        themeMode,
        setThemeMode,
        isDark,
        currentUser,
        userRole,
        signIn,
        signUp,
        signOut,
        switchUserRole,
        changePassword,
        selectedPeriod,
        setSelectedPeriod,
        selectedSiteId,
        setSelectedSiteId,
        projects,
        labourList,
        attendance,
        transactions,
        purchases,
        suppliers,
        clients,
        addProject,
        updateProject,
        addLabour,
        updateLabour,
        recordAttendance,
        addPurchase,
        addTransaction,
        summary,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
