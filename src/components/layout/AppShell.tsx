import React from 'react';
import { useApp } from '../../context/AppContext';
import {
  Home,
  Building2,
  CheckCircle2,
  Wallet,
  MoreHorizontal,
  Shield,
  Briefcase,
  UserCheck,
} from 'lucide-react';
import clsx from 'clsx';

export type TabId = 'home' | 'sites' | 'attendance' | 'money' | 'more';

interface AppShellProps {
  currentTab: TabId;
  onSelectTab: (tab: TabId) => void;
  children: React.ReactNode;
}

export const AppShell: React.FC<AppShellProps> = ({
  currentTab,
  onSelectTab,
  children,
}) => {
  const { t, userRole, switchUserRole } = useApp();

  const tabs: { id: TabId; label: string; icon: React.ReactNode }[] = [
    { id: 'home', label: t.home, icon: <Home className="w-5 h-5" /> },
    { id: 'sites', label: t.sites, icon: <Building2 className="w-5 h-5" /> },
    { id: 'attendance', label: t.attendance, icon: <CheckCircle2 className="w-5 h-5" /> },
    { id: 'money', label: t.money, icon: <Wallet className="w-5 h-5" /> },
    { id: 'more', label: t.more, icon: <MoreHorizontal className="w-5 h-5" /> },
  ];

  return (
    <div className="min-h-screen bg-[#F7F5F2] dark:bg-[#101114] text-[#1A1C21] dark:text-[#F3F1EE] flex flex-col antialiased">
      {/* Top Header */}
      <header className="sticky top-0 z-40 bg-[#FFFFFF]/90 dark:bg-[#1A1C21]/90 backdrop-blur-md border-b border-[#E7E3DD] dark:border-[#2F333C] px-4 py-3">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C] text-lg shadow-sm">
              ◆
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="font-heading font-extrabold text-base tracking-tight text-[#15171C] dark:text-[#F3F1EE]">
                  BuildTrack
                </h1>
                <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-[#FFF6DD] dark:bg-[#24272E] text-[#8A5A00] dark:text-[#F2B632] border border-[#F2B632]/30">
                  {userRole?.toUpperCase()}
                </span>
              </div>
              <p className="text-[11px] text-[#5F6470] dark:text-[#8D8A83] hidden sm:block">
                Care Constructiona Pvt Ltd
              </p>
            </div>
          </div>

          {/* Quick Role Switcher for convenience and QA testing */}
          <div className="flex items-center gap-1 bg-[#FFF6DD]/60 dark:bg-[#24272E] p-1 rounded-full border border-[#E7E3DD] dark:border-[#2F333C]">
            <button
              onClick={() => switchUserRole('admin')}
              title="Admin role"
              className={clsx(
                'px-2.5 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all',
                userRole === 'admin'
                  ? 'bg-[#F2B632] text-[#15171C] shadow-xs'
                  : 'text-[#5F6470] dark:text-[#B7B3AB] hover:text-[#1A1C21]'
              )}
            >
              <Shield className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Admin</span>
            </button>
            <button
              onClick={() => switchUserRole('accountant')}
              title="Accountant role"
              className={clsx(
                'px-2.5 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all',
                userRole === 'accountant'
                  ? 'bg-[#F2B632] text-[#15171C] shadow-xs'
                  : 'text-[#5F6470] dark:text-[#B7B3AB] hover:text-[#1A1C21]'
              )}
            >
              <Briefcase className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Acct</span>
            </button>
            <button
              onClick={() => switchUserRole('manager')}
              title="Manager role"
              className={clsx(
                'px-2.5 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all',
                userRole === 'manager'
                  ? 'bg-[#F2B632] text-[#15171C] shadow-xs'
                  : 'text-[#5F6470] dark:text-[#B7B3AB] hover:text-[#1A1C21]'
              )}
            >
              <UserCheck className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Mgr</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Screen Content */}
      <main className="flex-1 max-w-4xl w-full mx-auto p-4 pb-24 sm:pb-28">
        {children}
      </main>

      {/* Bottom Navigation Bar */}
      <nav className="fixed bottom-0 left-0 right-0 z-40 bg-[#FFFFFF] dark:bg-[#1A1C21] border-t border-[#E7E3DD] dark:border-[#2F333C] py-1 shadow-lg">
        <div className="max-w-4xl mx-auto flex items-center justify-around h-16">
          {tabs.map(tab => {
            const isActive = currentTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => onSelectTab(tab.id)}
                className={clsx(
                  'flex flex-col items-center justify-center flex-1 h-full gap-1 transition-all select-none relative',
                  isActive
                    ? 'text-[#15171C] dark:text-[#F2B632]'
                    : 'text-[#5F6470] dark:text-[#8D8A83] hover:text-[#1A1C21] dark:hover:text-[#F3F1EE]'
                )}
              >
                <div
                  className={clsx(
                    'p-1.5 rounded-full transition-transform duration-150',
                    isActive && 'bg-[#F2B632]/20 scale-110'
                  )}
                >
                  {tab.icon}
                </div>
                <span
                  className={clsx(
                    'text-[11px] font-medium leading-none',
                    isActive && 'font-bold'
                  )}
                >
                  {tab.label}
                </span>
                {isActive && (
                  <span className="absolute top-1 w-1.5 h-1.5 rounded-full bg-[#F2B632]" />
                )}
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
};
