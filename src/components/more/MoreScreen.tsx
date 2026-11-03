import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { StatusChip } from '../common/StatusChip';
import { WageCalculator } from '../../utils/wageCalculator';
import { formatMoney } from '../../utils/money';
import {
  User,
  Globe,
  Moon,
  Sun,
  ShieldCheck,
  Lock,
  Info,
  LogOut,
  ChevronRight,
  Calculator,
  CheckCircle2,
  X,
} from 'lucide-react';
import clsx from 'clsx';

interface MoreScreenProps {
  onNavigateToLabour: () => void;
  onOpenLogin: () => void;
}

export const MoreScreen: React.FC<MoreScreenProps> = ({
  onNavigateToLabour,
  onOpenLogin,
}) => {
  const {
    t,
    language,
    setLanguage,
    themeMode,
    setThemeMode,
    currentUser,
    userRole,
    signOut,
    changePassword,
  } = useApp();

  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
  const [showAboutModal, setShowAboutModal] = useState(false);
  const [showChangePassModal, setShowChangePassModal] = useState(false);
  const [showWageTester, setShowWageTester] = useState(false);

  // Change pass form
  const [currentPass, setCurrentPass] = useState('');
  const [newPass, setNewPass] = useState('');
  const [passSuccess, setPassSuccess] = useState(false);

  // Wage Calculator Golden Cases Interactive Runner
  const goldenCases = [
    { rate: 1200, status: 'present' as const, inTime: '08:00', outTime: '18:00', label: '1200 rate, 08:00-18:00 (10h full day)', expected: 1200 },
    { rate: 1200, status: 'present' as const, inTime: '08:00', outTime: '13:00', label: '1200 rate, 08:00-13:00 (5h half day)', expected: 600 },
    { rate: 1200, status: 'present' as const, inTime: '08:00', outTime: '12:00', label: '1200 rate, 08:00-12:00 (4h)', expected: 480 },
    { rate: 1200, status: 'present' as const, inTime: '08:00', outTime: '20:00', label: '1200 rate, 08:00-20:00 (12h with 2h OT)', expected: 1560 },
    { rate: 1200, status: 'present' as const, inTime: null, outTime: null, label: '1200 rate, present no times (full day swipe)', expected: 1200 },
    { rate: 1200, status: 'present' as const, inTime: null, outTime: null, manualOT: 2, label: '1200 rate, present no times, manual 2h OT', expected: 1560 },
    { rate: 1000, status: 'present' as const, inTime: '08:00', outTime: '15:30', label: '1000 rate, 08:00-15:30 (7.5h)', expected: 750 },
    { rate: 1000, status: 'present' as const, inTime: '08:10', outTime: '17:55', label: '1000 rate, 08:10-17:55 (9.75h)', expected: 975 },
    { rate: 1200, status: 'absent' as const, inTime: null, outTime: null, label: 'Any rate, absent status', expected: 0 },
    { rate: 1200, status: 'leave' as const, inTime: null, outTime: null, label: 'Any rate, leave status', expected: 0 },
  ];

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newPass) return;
    await changePassword(currentPass, newPass);
    setPassSuccess(true);
    setTimeout(() => {
      setPassSuccess(false);
      setShowChangePassModal(false);
      setCurrentPass('');
      setNewPass('');
    }, 1500);
  };

  const getInitials = (name?: string) => {
    if (!name) return 'U';
    const parts = name.trim().split(' ');
    if (parts.length === 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  };

  return (
    <div className="space-y-4 animate-fadeIn">
      {/* Profile Card */}
      <AppCard className="p-5 text-center flex flex-col items-center">
        <div className="w-18 h-18 rounded-full bg-[#F2B632] flex items-center justify-center font-heading font-extrabold text-2xl text-[#15171C] shadow-md mb-3">
          {getInitials(currentUser?.fullName)}
        </div>
        <h2 className="font-heading font-extrabold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
          {currentUser?.fullName || 'User'}
        </h2>
        <span className="text-xs font-semibold text-[#5F6470] dark:text-[#8D8A83] mt-0.5">
          {currentUser?.loginId}
        </span>
        <div className="mt-2.5">
          <span className="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-[#FFF6DD] dark:bg-[#24272E] text-[#8A5A00] dark:text-[#F2B632] border border-[#F2B632]/40">
            {userRole}
          </span>
        </div>
      </AppCard>

      {/* Preferences Section */}
      <div className="space-y-2">
        <h3 className="text-xs font-bold text-[#8A8D96] uppercase tracking-wider px-1">
          {t.settings}
        </h3>

        {/* Language selector */}
        <AppCard className="p-3.5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Globe className="w-5 h-5 text-[#F2B632]" />
            <div>
              <p className="text-sm font-semibold">{t.language}</p>
              <p className="text-xs text-[#8A8D96]">
                {language === 'ur' ? 'اردو (RTL فعال)' : 'English (LTR)'}
              </p>
            </div>
          </div>
          <select
            value={language}
            onChange={e => setLanguage(e.target.value as any)}
            className="bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-xl px-3 py-1.5 text-xs font-bold text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none cursor-pointer"
          >
            <option value="en">English</option>
            <option value="ur">اردو (Urdu)</option>
          </select>
        </AppCard>

        {/* Theme mode selector */}
        <AppCard className="p-3.5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {themeMode === 'dark' ? (
              <Moon className="w-5 h-5 text-[#F2B632]" />
            ) : (
              <Sun className="w-5 h-5 text-[#F2B632]" />
            )}
            <div>
              <p className="text-sm font-semibold">{t.displayMode}</p>
              <p className="text-xs text-[#8A8D96]">
                {themeMode === 'dark' ? t.dark : themeMode === 'light' ? t.light : t.system}
              </p>
            </div>
          </div>
          <select
            value={themeMode}
            onChange={e => setThemeMode(e.target.value as any)}
            className="bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-xl px-3 py-1.5 text-xs font-bold text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none cursor-pointer"
          >
            <option value="light">{t.light}</option>
            <option value="dark">{t.dark}</option>
            <option value="system">{t.system}</option>
          </select>
        </AppCard>
      </div>

      {/* Operations & Utilities */}
      <div className="space-y-2">
        <h3 className="text-xs font-bold text-[#8A8D96] uppercase tracking-wider px-1">
          {t.actions}
        </h3>

        {/* Labour directory quick link */}
        <AppCard
          onClick={onNavigateToLabour}
          className="p-3.5 flex items-center justify-between hover:border-[#F2B632] group"
        >
          <div className="flex items-center gap-3">
            <User className="w-5 h-5 text-[#F2B632]" />
            <div>
              <p className="text-sm font-semibold">{t.labour} Directory</p>
              <p className="text-xs text-[#8A8D96]">
                Workers list, wage rates, CNIC records
              </p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
        </AppCard>

        {/* Wage Calculator Golden Cases Verification */}
        <AppCard
          onClick={() => setShowWageTester(true)}
          className="p-3.5 flex items-center justify-between hover:border-[#F2B632] group"
        >
          <div className="flex items-center gap-3">
            <Calculator className="w-5 h-5 text-[#12A150] dark:text-[#3DD68C]" />
            <div>
              <p className="text-sm font-semibold">Wage Calculator Verification</p>
              <p className="text-xs text-[#8A8D96]">
                Verify all 8 golden cases & 1.5x overtime logic
              </p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
        </AppCard>

        {/* Change password */}
        <AppCard
          onClick={() => setShowChangePassModal(true)}
          className="p-3.5 flex items-center justify-between hover:border-[#F2B632] group"
        >
          <div className="flex items-center gap-3">
            <Lock className="w-5 h-5 text-[#F2B632]" />
            <div>
              <p className="text-sm font-semibold">{t.changePassword}</p>
              <p className="text-xs text-[#8A8D96]">Update your account security</p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
        </AppCard>

        {/* About App */}
        <AppCard
          onClick={() => setShowAboutModal(true)}
          className="p-3.5 flex items-center justify-between hover:border-[#F2B632] group"
        >
          <div className="flex items-center gap-3">
            <Info className="w-5 h-5 text-[#F2B632]" />
            <div>
              <p className="text-sm font-semibold">{t.about}</p>
              <p className="text-xs text-[#8A8D96]">Care Constructiona Pvt Ltd</p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
        </AppCard>

        {/* Logout button */}
        <AppCard
          onClick={() => setShowLogoutConfirm(true)}
          className="p-3.5 flex items-center justify-between hover:border-[#E5484D] group text-[#E5484D]"
        >
          <div className="flex items-center gap-3">
            <LogOut className="w-5 h-5 text-[#E5484D]" />
            <div>
              <p className="text-sm font-semibold">{t.logout}</p>
              <p className="text-xs text-[#8A8D96]">Sign out of BuildTrack</p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
        </AppCard>
      </div>

      {/* Wage Golden Cases Modal */}
      {showWageTester && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-lg w-full p-6 shadow-2xl animate-scaleUp max-h-[85vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-3 border-b border-[#E7E3DD] dark:border-[#2F333C]">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-5 h-5 text-[#12A150] dark:text-[#3DD68C]" />
                <h2 className="font-heading font-bold text-base text-[#1A1C21] dark:text-[#F3F1EE]">
                  Wage Golden Cases Verification
                </h2>
              </div>
              <button
                onClick={() => setShowWageTester(false)}
                className="text-[#8A8D96] hover:text-[#1A1C21] dark:hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83] my-3">
              Automated in-engine calculation check of all 8 golden cases specified in the BuildTrack specifications:
            </p>

            <div className="space-y-2">
              {goldenCases.map((gc, i) => {
                const calc = new WageCalculator({ rate: gc.rate });
                const res = calc.calculateDay({
                  status: gc.status,
                  inTime: gc.inTime || undefined,
                  outTime: gc.outTime || undefined,
                  manualOvertimeHours: gc.manualOT || 0,
                });
                const passed = res.wageAmount === gc.expected;

                return (
                  <div
                    key={i}
                    className="p-3 bg-[#FFF6DD]/40 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-xl flex items-center justify-between text-xs"
                  >
                    <div>
                      <p className="font-semibold text-[#1A1C21] dark:text-[#F3F1EE]">{gc.label}</p>
                      <p className="text-[11px] text-[#8A8D96] mt-0.5">
                        Expected: {formatMoney(gc.expected)} • Calculated: {formatMoney(res.wageAmount)}
                        {res.overtimeHours ? ` (${res.overtimeHours}h OT)` : ''}
                      </p>
                    </div>
                    <span
                      className={clsx(
                        'px-2 py-0.5 rounded font-bold text-[10px]',
                        passed
                          ? 'bg-[#E7F7EE] text-[#12A150] dark:bg-[#0F2A20] dark:text-[#3DD68C]'
                          : 'bg-[#FDECEC] text-[#E5484D]'
                      )}
                    >
                      {passed ? 'PASS ✅' : 'FAIL ❌'}
                    </span>
                  </div>
                );
              })}
            </div>

            <div className="mt-4 pt-3 border-t border-[#E7E3DD] dark:border-[#2F333C]">
              <AppButton onClick={() => setShowWageTester(false)} variant="primary">
                Done
              </AppButton>
            </div>
          </div>
        </div>
      )}

      {/* About Modal */}
      {showAboutModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-sm w-full p-6 shadow-2xl text-center space-y-4 animate-scaleUp">
            <div className="w-16 h-16 rounded-2xl bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C] text-3xl mx-auto shadow-md">
              ◆
            </div>
            <div>
              <h2 className="font-heading font-extrabold text-xl">BuildTrack</h2>
              <p className="text-xs text-[#8A5A00] dark:text-[#F2B632] font-semibold mt-0.5">
                Building Today | For A Better Tomorrow
              </p>
              <p className="text-xs text-[#5F6470] dark:text-[#8D8A83] mt-2">
                Care Constructiona Pvt Ltd<br />
                Multan, Pakistan
              </p>
              <p className="text-[11px] text-[#8A8D96] mt-1">
                Version 1.0.0 • Full React Suite
              </p>
            </div>
            <AppButton onClick={() => setShowAboutModal(false)} variant="primary">
              Close
            </AppButton>
          </div>
        </div>
      )}

      {/* Change Password Modal */}
      {showChangePassModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-sm w-full p-6 shadow-2xl animate-scaleUp">
            <h2 className="font-heading font-bold text-base mb-3">
              {t.changePassword}
            </h2>
            <form onSubmit={handlePasswordSubmit} className="space-y-3">
              <AppTextField
                label={t.currentPassword}
                type="password"
                value={currentPass}
                onChange={e => setCurrentPass(e.target.value)}
                required
              />
              <AppTextField
                label={t.newPassword}
                type="password"
                hint="Minimum 8 characters"
                value={newPass}
                onChange={e => setNewPass(e.target.value)}
                required
              />

              {passSuccess && (
                <p className="text-xs text-[#12A150] dark:text-[#3DD68C] font-semibold">
                  {t.passwordChangedSuccessfully}
                </p>
              )}

              <div className="flex items-center gap-2 pt-2">
                <AppButton
                  type="button"
                  variant="outline"
                  onClick={() => setShowChangePassModal(false)}
                >
                  {t.cancel}
                </AppButton>
                <AppButton type="submit" variant="primary">
                  {t.save}
                </AppButton>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Logout Confirmation Dialog */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-sm w-full p-6 shadow-2xl space-y-4 animate-scaleUp">
            <h2 className="font-heading font-bold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
              {t.logout}
            </h2>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
              {t.confirmLogout}
            </p>
            <div className="flex items-center gap-3 pt-2">
              <AppButton
                variant="outline"
                onClick={() => setShowLogoutConfirm(false)}
              >
                {t.cancel}
              </AppButton>
              <AppButton
                variant="danger"
                onClick={() => {
                  setShowLogoutConfirm(false);
                  signOut();
                  onOpenLogin();
                }}
              >
                {t.logout}
              </AppButton>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
