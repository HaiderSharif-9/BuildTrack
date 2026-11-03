import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { StatusChip } from '../common/StatusChip';
import { AmountText } from '../common/AmountText';
import { KpiCard } from '../common/KpiCard';
import { formatMoney } from '../../utils/money';
import {
  ArrowLeft,
  MapPin,
  Calendar,
  Users,
  ShoppingBag,
  FileText,
  Clock,
  CheckCircle,
  Building2,
} from 'lucide-react';
import clsx from 'clsx';

interface SiteDetailScreenProps {
  siteId: string;
  onBack: () => void;
}

export const SiteDetailScreen: React.FC<SiteDetailScreenProps> = ({
  siteId,
  onBack,
}) => {
  const {
    t,
    projects,
    labourList,
    purchases,
    transactions,
    attendance,
    clients,
  } = useApp();
  const [activeTab, setActiveTab] = useState<'overview' | 'labour' | 'purchases' | 'ledger'>('overview');

  const site = projects.find(p => p.id === siteId);

  if (!site) {
    return (
      <div className="text-center py-12 space-y-4">
        <p className="text-base font-bold text-[#E5484D]">Site not found</p>
        <AppButton onClick={onBack} variant="outline" className="w-auto mx-auto">
          Back to Sites
        </AppButton>
      </div>
    );
  }

  const client = clients.find(c => c.id === site.clientId);

  // Filter items specifically for this site
  const sitePurchases = purchases.filter(p => p.projectId === siteId);
  const siteTransactions = transactions.filter(t => t.projectId === siteId);
  const siteAttendance = attendance.filter(a => a.projectId === siteId);

  // Compute site financials
  const siteIncome = siteTransactions
    .filter(t => t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);

  const siteExpense = siteTransactions
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);

  const siteMaterialsTotal = sitePurchases.reduce((sum, p) => sum + p.amount, 0);

  // Labour active on this site
  const assignedLabour = labourList.filter(l =>
    siteAttendance.some(a => a.labourId === l.id) || (l.projectIds && l.projectIds.includes(siteId))
  );

  return (
    <div className="space-y-5 animate-fadeIn">
      {/* Back button and title */}
      <div className="flex items-center gap-3">
        <button
          onClick={onBack}
          className="p-2 rounded-xl bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] text-[#5F6470] dark:text-[#B7B3AB] hover:text-[#1A1C21] dark:hover:text-[#F3F1EE] cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="font-heading font-extrabold text-xl text-[#1A1C21] dark:text-[#F3F1EE]">
            {site.name}
          </h1>
          <div className="flex items-center gap-1.5 text-xs text-[#5F6470] dark:text-[#8D8A83]">
            <MapPin className="w-3.5 h-3.5 text-[#F2B632]" />
            <span>{site.location}</span>
          </div>
        </div>
      </div>

      {/* Site Header Card */}
      <AppCard className="p-5 space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <StatusChip status={site.status} />
            {site.startDate && (
              <span className="text-xs text-[#8A8D96] flex items-center gap-1">
                <Calendar className="w-3.5 h-3.5" />
                Started: {site.startDate}
              </span>
            )}
          </div>
          {client && (
            <span className="text-xs font-semibold px-2.5 py-1 rounded-md bg-[#FFF6DD] dark:bg-[#24272E] text-[#8A5A00] dark:text-[#F2B632]">
              Client: {client.name}
            </span>
          )}
        </div>

        {/* Budget Progress Bar */}
        <div className="space-y-1.5 pt-1">
          <div className="flex justify-between text-xs font-semibold">
            <span className="text-[#5F6470] dark:text-[#B7B3AB]">
              Budget Utilization (Total Expense: {formatMoney(siteExpense)})
            </span>
            <span className="font-bold text-[#1A1C21] dark:text-[#F3F1EE]">
              {site.budget > 0 ? Math.min(100, Math.round((siteExpense / site.budget) * 100)) : 0}%
            </span>
          </div>
          <div className="w-full h-3 bg-[#E7E3DD] dark:bg-[#24272E] rounded-full overflow-hidden">
            <div
              className="h-full bg-[#F2B632] rounded-full transition-all duration-500"
              style={{
                width: `${site.budget > 0 ? Math.min(100, Math.round((siteExpense / site.budget) * 100)) : 0}%`,
              }}
            />
          </div>
          <div className="flex justify-between text-[11px] text-[#8A8D96] dark:text-[#8D8A83]">
            <span>Spent: {formatMoney(siteExpense)}</span>
            <span>Allocated: {formatMoney(site.budget)}</span>
          </div>
        </div>

        {/* Site KPI mini cards */}
        <div className="grid grid-cols-3 gap-2 pt-2 border-t border-[#E7E3DD] dark:border-[#2F333C] text-center">
          <div>
            <span className="text-[11px] text-[#8A8D96] block">Client Received</span>
            <span className="text-xs sm:text-sm font-bold text-[#12A150] dark:text-[#3DD68C]">
              {formatMoney(siteIncome)}
            </span>
          </div>
          <div>
            <span className="text-[11px] text-[#8A8D96] block">Materials Cost</span>
            <span className="text-xs sm:text-sm font-bold text-[#E5484D] dark:text-[#FF6B70]">
              {formatMoney(siteMaterialsTotal)}
            </span>
          </div>
          <div>
            <span className="text-[11px] text-[#8A8D96] block">Labour Roster</span>
            <span className="text-xs sm:text-sm font-bold text-[#8A5A00] dark:text-[#F2B632]">
              {assignedLabour.length} workers
            </span>
          </div>
        </div>
      </AppCard>

      {/* Tabs Switcher: Overview, Labour, Purchases, Ledger */}
      <div className="flex border-b border-[#E7E3DD] dark:border-[#2F333C] overflow-x-auto no-scrollbar">
        {[
          { id: 'overview', label: 'Overview', icon: <Building2 className="w-4 h-4" /> },
          { id: 'labour', label: `Labour (${assignedLabour.length})`, icon: <Users className="w-4 h-4" /> },
          { id: 'purchases', label: `Purchases (${sitePurchases.length})`, icon: <ShoppingBag className="w-4 h-4" /> },
          { id: 'ledger', label: `Ledger (${siteTransactions.length})`, icon: <FileText className="w-4 h-4" /> },
        ].map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as any)}
            className={clsx(
              'flex items-center gap-2 px-4 py-2.5 text-xs font-bold border-b-2 whitespace-nowrap transition-all cursor-pointer',
              activeTab === tab.id
                ? 'border-[#F2B632] text-[#15171C] dark:text-[#F2B632]'
                : 'border-transparent text-[#5F6470] dark:text-[#8D8A83] hover:text-[#1A1C21]'
            )}
          >
            {tab.icon}
            <span>{tab.label}</span>
          </button>
        ))}
      </div>

      {/* Tab Contents */}
      {activeTab === 'overview' && (
        <div className="space-y-4">
          <AppCard className="p-4 space-y-3">
            <h3 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE]">
              Contract & Client Details
            </h3>
            <div className="grid grid-cols-2 gap-3 text-xs">
              <div>
                <span className="text-[#8A8D96] block">Client Name</span>
                <span className="font-semibold">{client?.name || 'Care Constructiona Internal'}</span>
              </div>
              <div>
                <span className="text-[#8A8D96] block">Contact Phone</span>
                <span className="font-semibold">{client?.phone || '03001234567'}</span>
              </div>
              <div>
                <span className="text-[#8A8D96] block">Project City</span>
                <span className="font-semibold">{site.location}</span>
              </div>
              <div>
                <span className="text-[#8A8D96] block">Status</span>
                <StatusChip status={site.status} />
              </div>
            </div>
          </AppCard>

          <AppCard className="p-4 space-y-2">
            <h3 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE]">
              Recent Attendance at this Site
            </h3>
            {siteAttendance.slice(0, 5).map(att => {
              const worker = labourList.find(l => l.id === att.labourId);
              return (
                <div key={att.id} className="flex items-center justify-between text-xs py-1.5 border-b border-black/5 dark:border-white/5 last:border-none">
                  <div>
                    <span className="font-semibold">{worker?.name || 'Worker'}</span>
                    <span className="text-[#8A8D96] block">{att.date} • {att.hoursWorked ? `${att.hoursWorked} hrs` : 'Full day'}</span>
                  </div>
                  <div className="text-right">
                    <StatusChip status={att.status} />
                    {att.wageAmount && att.status === 'present' && (
                      <span className="block font-bold text-[#12A150] dark:text-[#3DD68C] mt-0.5">
                        {formatMoney(att.wageAmount)}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </AppCard>
        </div>
      )}

      {activeTab === 'labour' && (
        <div className="space-y-3">
          {assignedLabour.length === 0 ? (
            <AppCard className="p-8 text-center text-xs text-[#8A8D96]">
              No labour workers recorded for this site yet.
            </AppCard>
          ) : (
            assignedLabour.map(lab => (
              <AppCard key={lab.id} className="p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C]">
                    {lab.name[0]}
                  </div>
                  <div>
                    <h4 className="font-heading font-bold text-sm">{lab.name}</h4>
                    <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">{lab.trade}</p>
                  </div>
                </div>
                <div className="text-right">
                  <span className="text-xs text-[#8A8D96] block">Default Rate</span>
                  <span className="text-sm font-bold">{formatMoney(lab.defaultRate)}/day</span>
                </div>
              </AppCard>
            ))
          )}
        </div>
      )}

      {activeTab === 'purchases' && (
        <div className="space-y-3">
          {sitePurchases.length === 0 ? (
            <AppCard className="p-8 text-center text-xs text-[#8A8D96]">
              No materials purchased for this site yet.
            </AppCard>
          ) : (
            sitePurchases.map(pur => (
              <AppCard key={pur.id} className="p-4 flex items-center justify-between">
                <div>
                  <h4 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE]">
                    {pur.item}
                  </h4>
                  <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
                    {pur.date} • {pur.qty} {pur.unit} @ {formatMoney(pur.rate)}/{pur.unit}
                  </p>
                  {pur.supplierName && (
                    <span className="text-[11px] text-[#8A5A00] dark:text-[#F2B632] block">
                      Supplier: {pur.supplierName}
                    </span>
                  )}
                </div>
                <div className="text-right">
                  <span className="text-sm font-bold text-[#E5484D] dark:text-[#FF6B70]">
                    {formatMoney(pur.amount)}
                  </span>
                </div>
              </AppCard>
            ))
          )}
        </div>
      )}

      {activeTab === 'ledger' && (
        <div className="space-y-3">
          {siteTransactions.length === 0 ? (
            <AppCard className="p-8 text-center text-xs text-[#8A8D96]">
              No financial transactions recorded for this site yet.
            </AppCard>
          ) : (
            siteTransactions.map(tx => (
              <AppCard key={tx.id} className="p-3.5 flex items-center justify-between">
                <div>
                  <h4 className="font-heading font-bold text-xs text-[#1A1C21] dark:text-[#F3F1EE]">
                    {tx.description}
                  </h4>
                  <p className="text-[11px] text-[#8A8D96]">
                    {tx.date} • {tx.categoryName || tx.source}
                  </p>
                </div>
                <AmountText amount={tx.amount} type={tx.type} className="text-xs font-bold" />
              </AppCard>
            ))
          )}
        </div>
      )}
    </div>
  );
};
