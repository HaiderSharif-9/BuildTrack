import React from 'react';
import { useApp, PeriodFilter } from '../../context/AppContext';
import { KpiCard } from '../common/KpiCard';
import { AppCard } from '../common/AppCard';
import { StatusChip } from '../common/StatusChip';
import { AmountText } from '../common/AmountText';
import { formatCompactMoney } from '../../utils/money';
import {
  TrendingUp,
  TrendingDown,
  Building2,
  Calendar,
  MapPin,
  ChevronRight,
  Activity,
  Layers,
} from 'lucide-react';
import clsx from 'clsx';

interface DashboardScreenProps {
  onNavigateToSite: (siteId: string) => void;
  onNavigateToTab: (tab: 'sites' | 'attendance' | 'money' | 'more') => void;
}

export const DashboardScreen: React.FC<DashboardScreenProps> = ({
  onNavigateToSite,
  onNavigateToTab,
}) => {
  const {
    t,
    projects,
    transactions,
    selectedPeriod,
    setSelectedPeriod,
    selectedSiteId,
    setSelectedSiteId,
    summary,
  } = useApp();

  const periods: { id: PeriodFilter; label: string }[] = [
    { id: 'today', label: t.today },
    { id: 'thisWeek', label: t.thisWeek },
    { id: 'thisMonth', label: t.thisMonth },
    { id: 'thisYear', label: t.thisYear },
    { id: 'custom', label: t.custom },
  ];

  // Filtered transactions for recent activity
  const recentTransactions = transactions
    .filter(t => !selectedSiteId || t.projectId === selectedSiteId)
    .slice(0, 5);

  const displayProjects = selectedSiteId
    ? projects.filter(p => p.id === selectedSiteId)
    : projects;

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Period Selector Pills */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
        {periods.map(p => {
          const isSelected = selectedPeriod === p.id;
          return (
            <button
              key={p.id}
              onClick={() => setSelectedPeriod(p.id)}
              className={clsx(
                'px-4 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all border',
                isSelected
                  ? 'bg-[#F2B632] text-[#15171C] border-[#F2B632] shadow-xs'
                  : 'bg-[#FFFFFF] dark:bg-[#1A1C21] text-[#5F6470] dark:text-[#B7B3AB] border-[#E7E3DD] dark:border-[#2F333C] hover:border-[#F2B632]/50'
              )}
            >
              {p.label}
            </button>
          );
        })}
      </div>

      {/* Site Filter Dropdown */}
      <AppCard className="p-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#FFF6DD] dark:bg-[#24272E] flex items-center justify-center text-[#8A5A00] dark:text-[#F2B632]">
            <MapPin className="w-4 h-4" />
          </div>
          <div className="flex-1">
            <label className="text-[10px] font-bold text-[#8A8D96] uppercase tracking-wider block">
              {t.sites}
            </label>
            <select
              value={selectedSiteId || ''}
              onChange={e => setSelectedSiteId(e.target.value || null)}
              className="w-full bg-transparent text-sm font-semibold text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none cursor-pointer"
            >
              <option value="" className="bg-[#FFFFFF] dark:bg-[#1A1C21]">
                {t.allSites} ({projects.length})
              </option>
              {projects.map(site => (
                <option
                  key={site.id}
                  value={site.id}
                  className="bg-[#FFFFFF] dark:bg-[#1A1C21]"
                >
                  {site.name} • {site.location}
                </option>
              ))}
            </select>
          </div>
        </div>
      </AppCard>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-2 gap-3 sm:gap-4">
        <KpiCard
          label={t.income}
          value={formatCompactMoney(summary.totalIncome)}
          type="income"
          icon={<TrendingUp className="w-5 h-5 text-[#12A150] dark:text-[#3DD68C]" />}
          subtitle="Client payments"
        />
        <KpiCard
          label={t.expense}
          value={formatCompactMoney(summary.totalExpense)}
          type="expense"
          icon={<TrendingDown className="w-5 h-5 text-[#E5484D] dark:text-[#FF6B70]" />}
          subtitle="Materials & wages"
        />
        <KpiCard
          label={t.profit}
          value={formatCompactMoney(summary.netProfit)}
          type="profit"
          icon={<Layers className="w-5 h-5 text-[#6E56CF] dark:text-[#9A8CFF]" />}
          subtitle={summary.netProfit >= 0 ? 'Net surplus' : 'Deficit'}
        />
        <KpiCard
          label={t.sites}
          value={displayProjects.length.toString()}
          type="info"
          icon={<Building2 className="w-5 h-5 text-[#8A5A00] dark:text-[#F2B632]" />}
          subtitle={`${summary.activeSitesCount} in progress`}
        />
      </div>

      {/* Income vs Expense Financial Analytics */}
      <AppCard className="p-5">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-sm font-bold uppercase tracking-wider text-[#5F6470] dark:text-[#B7B3AB]">
              {t.dashboard}
            </h2>
            <p className="text-lg font-extrabold font-heading text-[#1A1C21] dark:text-[#F3F1EE]">
              Financial Breakdown
            </p>
          </div>
          <span className="text-xs font-semibold px-2.5 py-1 rounded-md bg-[#FFF6DD] dark:bg-[#24272E] text-[#8A5A00] dark:text-[#F2B632]">
            {selectedPeriod}
          </span>
        </div>

        {/* Visual progress bar comparison */}
        <div className="space-y-3">
          <div>
            <div className="flex justify-between text-xs font-semibold mb-1">
              <span className="text-[#12A150] dark:text-[#3DD68C]">Income: Rs. {summary.totalIncome.toLocaleString()}</span>
              <span className="text-[#5F6470] dark:text-[#B7B3AB]">
                {summary.totalIncome > 0
                  ? Math.round(
                      (summary.totalIncome / (summary.totalIncome + summary.totalExpense || 1)) * 100
                    )
                  : 0}
                %
              </span>
            </div>
            <div className="w-full h-3 bg-[#E7E3DD] dark:bg-[#24272E] rounded-full overflow-hidden">
              <div
                className="h-full bg-[#12A150] dark:bg-[#3DD68C] transition-all duration-500 rounded-full"
                style={{
                  width: `${
                    summary.totalIncome > 0
                      ? Math.min(
                          100,
                          Math.round(
                            (summary.totalIncome /
                              (summary.totalIncome + summary.totalExpense || 1)) *
                              100
                          )
                        )
                      : 0
                  }%`,
                }}
              />
            </div>
          </div>

          <div>
            <div className="flex justify-between text-xs font-semibold mb-1">
              <span className="text-[#E5484D] dark:text-[#FF6B70]">Expense: Rs. {summary.totalExpense.toLocaleString()}</span>
              <span className="text-[#5F6470] dark:text-[#B7B3AB]">
                {summary.totalExpense > 0
                  ? Math.round(
                      (summary.totalExpense / (summary.totalIncome + summary.totalExpense || 1)) * 100
                    )
                  : 0}
                %
              </span>
            </div>
            <div className="w-full h-3 bg-[#E7E3DD] dark:bg-[#24272E] rounded-full overflow-hidden">
              <div
                className="h-full bg-[#E5484D] dark:bg-[#FF6B70] transition-all duration-500 rounded-full"
                style={{
                  width: `${
                    summary.totalExpense > 0
                      ? Math.min(
                          100,
                          Math.round(
                            (summary.totalExpense /
                              (summary.totalIncome + summary.totalExpense || 1)) *
                              100
                          )
                        )
                      : 0
                  }%`,
                }}
              />
            </div>
          </div>
        </div>

        {/* Quick summary notes */}
        <div className="mt-4 pt-4 border-t border-[#E7E3DD] dark:border-[#2F333C] grid grid-cols-2 gap-4 text-center">
          <div>
            <span className="text-[11px] text-[#8A8D96] dark:text-[#8D8A83] block">Cash Reserve</span>
            <span className="text-sm font-bold font-heading text-[#1A1C21] dark:text-[#F3F1EE]">
              Rs. {summary.netProfit.toLocaleString()}
            </span>
          </div>
          <div>
            <span className="text-[11px] text-[#8A8D96] dark:text-[#8D8A83] block">Sites Active</span>
            <span className="text-sm font-bold font-heading text-[#8A5A00] dark:text-[#F2B632]">
              {summary.activeSitesCount} of {projects.length}
            </span>
          </div>
        </div>
      </AppCard>

      {/* Sites Overview Section */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[#5F6470] dark:text-[#B7B3AB]">
            {t.sites} ({displayProjects.length})
          </h2>
          <button
            onClick={() => onNavigateToTab('sites')}
            className="text-xs font-semibold text-[#8A5A00] dark:text-[#F2B632] hover:underline flex items-center gap-0.5"
          >
            <span>View All</span>
            <ChevronRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="space-y-2.5">
          {displayProjects.map(site => (
            <AppCard
              key={site.id}
              onClick={() => onNavigateToSite(site.id)}
              className="p-4 hover:border-[#F2B632]"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE]">
                      {site.name}
                    </h3>
                  </div>
                  <div className="flex items-center gap-1.5 text-xs text-[#5F6470] dark:text-[#B7B3AB]">
                    <MapPin className="w-3.5 h-3.5 text-[#F2B632]" />
                    <span>{site.location}</span>
                  </div>
                  <div className="text-xs text-[#8A8D96] dark:text-[#8D8A83] pt-1">
                    {t.budget}: <span className="font-semibold text-[#1A1C21] dark:text-[#F3F1EE]">Rs. {site.budget.toLocaleString()}</span>
                  </div>
                </div>
                <div className="flex flex-col items-end gap-2">
                  <StatusChip status={site.status} />
                  <ChevronRight className="w-4 h-4 text-[#8A8D96] dark:text-[#8D8A83]" />
                </div>
              </div>
            </AppCard>
          ))}
        </div>
      </div>

      {/* Recent Activity Section */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[#5F6470] dark:text-[#B7B3AB]">
            {t.recentActivity}
          </h2>
          <button
            onClick={() => onNavigateToTab('money')}
            className="text-xs font-semibold text-[#8A5A00] dark:text-[#F2B632] hover:underline flex items-center gap-0.5"
          >
            <span>Ledger</span>
            <ChevronRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <AppCard className="divide-y divide-[#E7E3DD] dark:divide-[#2F333C] p-0 overflow-hidden">
          {recentTransactions.map(tx => (
            <div
              key={tx.id}
              className="p-3.5 flex items-center justify-between gap-3 hover:bg-black/2 dark:hover:bg-white/2 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div
                  className={clsx(
                    'w-8 h-8 rounded-full flex items-center justify-center shrink-0',
                    tx.type === 'income'
                      ? 'bg-[#E7F7EE] text-[#12A150] dark:bg-[#0F2A20] dark:text-[#3DD68C]'
                      : 'bg-[#FDECEC] text-[#E5484D] dark:bg-[#2E1519] dark:text-[#FF6B70]'
                  )}
                >
                  <Activity className="w-4 h-4" />
                </div>
                <div>
                  <p className="text-xs font-bold text-[#1A1C21] dark:text-[#F3F1EE] line-clamp-1">
                    {tx.description}
                  </p>
                  <p className="text-[11px] text-[#8A8D96] dark:text-[#8D8A83]">
                    {tx.date} • {tx.categoryName || tx.source}
                  </p>
                </div>
              </div>
              <AmountText
                amount={tx.amount}
                type={tx.type}
                className="text-xs shrink-0"
              />
            </div>
          ))}
        </AppCard>
      </div>
    </div>
  );
};
