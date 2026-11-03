import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { AmountText } from '../common/AmountText';
import { KpiCard } from '../common/KpiCard';
import { formatMoney } from '../../utils/money';
import {
  Wallet,
  ShoppingBag,
  Plus,
  X,
  Filter,
  Layers,
  TrendingUp,
  TrendingDown,
  Building2,
} from 'lucide-react';
import clsx from 'clsx';

export const MoneyScreen: React.FC = () => {
  const {
    t,
    projects,
    transactions,
    purchases,
    suppliers,
    addTransaction,
    addPurchase,
    selectedSiteId,
    setSelectedSiteId,
    userRole,
  } = useApp();

  const [activeTab, setActiveTab] = useState<'transactions' | 'purchases'>('transactions');
  const [filterType, setFilterType] = useState<'all' | 'income' | 'expense'>('all');
  const [showAddTxModal, setShowAddTxModal] = useState(false);
  const [showAddPurchaseModal, setShowAddPurchaseModal] = useState(false);

  // New Transaction Form State
  const [txDesc, setTxDesc] = useState('');
  const [txAmount, setTxAmount] = useState('');
  const [txType, setTxType] = useState<'income' | 'expense'>('income');
  const [txCategory, setTxCategory] = useState('Client Payment');
  const [txProjectId, setTxProjectId] = useState<string>('');

  // New Purchase Form State
  const [purItem, setPurItem] = useState('');
  const [purQty, setPurQty] = useState('');
  const [purUnit, setPurUnit] = useState('Bag');
  const [purRate, setPurRate] = useState('');
  const [purSupplierId, setPurSupplierId] = useState('');
  const [purProjectId, setPurProjectId] = useState(projects[0]?.id || '');

  // Filtered lists
  const filteredTransactions = transactions
    .filter(t => !selectedSiteId || t.projectId === selectedSiteId)
    .filter(t => (filterType === 'all' ? true : t.type === filterType));

  const filteredPurchases = purchases.filter(
    p => !selectedSiteId || p.projectId === selectedSiteId
  );

  const totalIncome = transactions
    .filter(t => (!selectedSiteId || t.projectId === selectedSiteId) && t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpense = transactions
    .filter(t => (!selectedSiteId || t.projectId === selectedSiteId) && t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);

  const netBalance = totalIncome - totalExpense;

  const handleCreateTx = (e: React.FormEvent) => {
    e.preventDefault();
    if (!txDesc.trim() || !txAmount) return;

    addTransaction({
      description: txDesc.trim(),
      amount: parseFloat(txAmount) || 0,
      type: txType,
      categoryId: txCategory.toLowerCase().replace(/\s+/g, '-'),
      categoryName: txCategory,
      date: new Date().toISOString().split('T')[0],
      source: 'manual',
      projectId: txProjectId || null,
    });

    setTxDesc('');
    setTxAmount('');
    setShowAddTxModal(false);
  };

  const handleCreatePurchase = (e: React.FormEvent) => {
    e.preventDefault();
    if (!purItem.trim() || !purQty || !purRate || !purProjectId) return;

    const supplier = suppliers.find(s => s.id === purSupplierId);

    addPurchase({
      projectId: purProjectId,
      date: new Date().toISOString().split('T')[0],
      item: purItem.trim(),
      qty: parseFloat(purQty) || 1,
      unit: purUnit,
      rate: parseFloat(purRate) || 0,
      supplierId: purSupplierId || undefined,
      supplierName: supplier?.name,
    });

    setPurItem('');
    setPurQty('');
    setPurRate('');
    setShowAddPurchaseModal(false);
  };

  return (
    <div className="space-y-5 animate-fadeIn">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="font-heading font-extrabold text-xl text-[#1A1C21] dark:text-[#F3F1EE]">
            {t.money} & Company Ledger
          </h1>
          <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
            Track revenue, material purchases, and operational overheads
          </p>
        </div>

        {userRole !== 'manager' && (
          <div className="flex items-center gap-2">
            <AppButton
              variant="outline"
              onClick={() => setShowAddPurchaseModal(true)}
              className="h-10 px-3 text-xs font-bold w-auto"
            >
              <ShoppingBag className="w-4 h-4 mr-1" />
              <span>+ Purchase</span>
            </AppButton>
            <AppButton
              variant="primary"
              onClick={() => setShowAddTxModal(true)}
              className="h-10 px-3 text-xs font-bold w-auto"
            >
              <Plus className="w-4 h-4 mr-1" />
              <span>+ Transaction</span>
            </AppButton>
          </div>
        )}
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-3 gap-2 sm:gap-3">
        <KpiCard
          label={t.income}
          value={formatMoney(totalIncome)}
          type="income"
          icon={<TrendingUp className="w-4 h-4" />}
        />
        <KpiCard
          label={t.expense}
          value={formatMoney(totalExpense)}
          type="expense"
          icon={<TrendingDown className="w-4 h-4" />}
        />
        <KpiCard
          label="Net Balance"
          value={formatMoney(netBalance)}
          type="profit"
          icon={<Layers className="w-4 h-4" />}
        />
      </div>

      {/* Site Filter dropdown */}
      <div className="flex items-center gap-2">
        <span className="text-xs font-semibold text-[#8A8D96] shrink-0">Filter Site:</span>
        <select
          value={selectedSiteId || ''}
          onChange={e => setSelectedSiteId(e.target.value || null)}
          className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-xl px-3 py-1.5 text-xs font-semibold text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632] flex-1 max-w-xs cursor-pointer"
        >
          <option value="">{t.allSites} (Company-wide)</option>
          {projects.map(p => (
            <option key={p.id} value={p.id}>
              {p.name}
            </option>
          ))}
        </select>
      </div>

      {/* Sub Tabs: Transactions Ledger vs Material Purchases */}
      <div className="flex border-b border-[#E7E3DD] dark:border-[#2F333C]">
        <button
          onClick={() => setActiveTab('transactions')}
          className={clsx(
            'flex items-center gap-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all cursor-pointer',
            activeTab === 'transactions'
              ? 'border-[#F2B632] text-[#15171C] dark:text-[#F2B632]'
              : 'border-transparent text-[#5F6470] dark:text-[#8D8A83]'
          )}
        >
          <Wallet className="w-4 h-4" />
          <span>General Ledger ({filteredTransactions.length})</span>
        </button>

        <button
          onClick={() => setActiveTab('purchases')}
          className={clsx(
            'flex items-center gap-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all cursor-pointer',
            activeTab === 'purchases'
              ? 'border-[#F2B632] text-[#15171C] dark:text-[#F2B632]'
              : 'border-transparent text-[#5F6470] dark:text-[#8D8A83]'
          )}
        >
          <ShoppingBag className="w-4 h-4" />
          <span>Purchases & Materials ({filteredPurchases.length})</span>
        </button>
      </div>

      {/* General Ledger view */}
      {activeTab === 'transactions' && (
        <div className="space-y-3">
          {/* Income vs Expense Filter Filter Chips */}
          <div className="flex items-center gap-2">
            {(['all', 'income', 'expense'] as const).map(f => (
              <button
                key={f}
                onClick={() => setFilterType(f)}
                className={clsx(
                  'px-3 py-1 rounded-full text-xs font-semibold uppercase tracking-wider transition-all border cursor-pointer',
                  filterType === f
                    ? 'bg-[#F2B632] text-[#15171C] border-[#F2B632]'
                    : 'bg-[#FFFFFF] dark:bg-[#1A1C21] text-[#5F6470] border-[#E7E3DD] dark:border-[#2F333C]'
                )}
              >
                {f}
              </button>
            ))}
          </div>

          <AppCard className="p-0 overflow-hidden divide-y divide-[#E7E3DD] dark:divide-[#2F333C]">
            {filteredTransactions.length === 0 ? (
              <div className="p-8 text-center text-xs text-[#8A8D96]">
                No ledger transactions found.
              </div>
            ) : (
              filteredTransactions.map(tx => {
                const project = projects.find(p => p.id === tx.projectId);
                return (
                  <div
                    key={tx.id}
                    className="p-3.5 flex items-center justify-between gap-3 hover:bg-black/2 dark:hover:bg-white/2 transition-colors"
                  >
                    <div className="space-y-0.5">
                      <p className="text-xs font-bold text-[#1A1C21] dark:text-[#F3F1EE]">
                        {tx.description}
                      </p>
                      <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[11px] text-[#8A8D96]">
                        <span>{tx.date}</span>
                        <span>•</span>
                        <span className="font-semibold text-[#5F6470] dark:text-[#B7B3AB]">
                          {tx.categoryName || tx.categoryId}
                        </span>
                        {project ? (
                          <>
                            <span>•</span>
                            <span className="text-[#8A5A00] dark:text-[#F2B632]">
                              {project.name}
                            </span>
                          </>
                        ) : (
                          <>
                            <span>•</span>
                            <span className="text-[#5F6470]">Company Head Office</span>
                          </>
                        )}
                        {tx.source !== 'manual' && (
                          <span className="px-1.5 py-0.2 rounded bg-black/5 dark:bg-white/10 text-[9px] uppercase font-bold">
                            {tx.source}
                          </span>
                        )}
                      </div>
                    </div>
                    <AmountText
                      amount={tx.amount}
                      type={tx.type}
                      className="text-xs font-bold shrink-0"
                    />
                  </div>
                );
              })
            )}
          </AppCard>
        </div>
      )}

      {/* Purchases view */}
      {activeTab === 'purchases' && (
        <div className="space-y-3">
          {filteredPurchases.length === 0 ? (
            <AppCard className="p-8 text-center text-xs text-[#8A8D96]">
              No material purchases recorded.
            </AppCard>
          ) : (
            filteredPurchases.map(pur => {
              const project = projects.find(p => p.id === pur.projectId);
              return (
                <AppCard key={pur.id} className="p-4 flex items-center justify-between">
                  <div>
                    <h3 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE]">
                      {pur.item}
                    </h3>
                    <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
                      {pur.qty} {pur.unit} @ {formatMoney(pur.rate)}/{pur.unit} • {pur.date}
                    </p>
                    <div className="flex items-center gap-2 text-[11px] pt-1">
                      {project && (
                        <span className="text-[#8A5A00] dark:text-[#F2B632] font-semibold">
                          {project.name}
                        </span>
                      )}
                      {pur.supplierName && (
                        <span className="text-[#8A8D96]">({pur.supplierName})</span>
                      )}
                    </div>
                  </div>
                  <div className="text-right">
                    <span className="text-xs text-[#8A8D96] block">Total Cost</span>
                    <span className="font-heading font-extrabold text-sm text-[#E5484D] dark:text-[#FF6B70]">
                      {formatMoney(pur.amount)}
                    </span>
                  </div>
                </AppCard>
              );
            })
          )}
        </div>
      )}

      {/* Add Transaction Modal */}
      {showAddTxModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-md w-full p-6 shadow-2xl animate-scaleUp">
            <div className="flex items-center justify-between pb-3 border-b border-[#E7E3DD] dark:border-[#2F333C]">
              <h2 className="font-heading font-bold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
                Log Financial Transaction
              </h2>
              <button
                onClick={() => setShowAddTxModal(false)}
                className="text-[#8A8D96] hover:text-[#1A1C21] dark:hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateTx} className="space-y-4 mt-4">
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setTxType('income')}
                  className={clsx(
                    'flex-1 py-2 rounded-xl text-xs font-bold border transition-all cursor-pointer',
                    txType === 'income'
                      ? 'bg-[#12A150] text-white border-[#12A150]'
                      : 'bg-[#FFF6DD]/60 dark:bg-[#24272E] text-[#5F6470] border-[#E7E3DD] dark:border-[#2F333C]'
                  )}
                >
                  + Income (Received)
                </button>
                <button
                  type="button"
                  onClick={() => setTxType('expense')}
                  className={clsx(
                    'flex-1 py-2 rounded-xl text-xs font-bold border transition-all cursor-pointer',
                    txType === 'expense'
                      ? 'bg-[#E5484D] text-white border-[#E5484D]'
                      : 'bg-[#FFF6DD]/60 dark:bg-[#24272E] text-[#5F6470] border-[#E7E3DD] dark:border-[#2F333C]'
                  )}
                >
                  - Expense (Paid)
                </button>
              </div>

              <AppTextField
                label="Description"
                hint="e.g. Client Milestone Payment or Office Rent"
                value={txDesc}
                onChange={e => setTxDesc(e.target.value)}
                required
              />

              <AppTextField
                label="Amount (PKR)"
                type="number"
                hint="e.g. 500000"
                value={txAmount}
                onChange={e => setTxAmount(e.target.value)}
                required
              />

              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Category
                </label>
                <select
                  value={txCategory}
                  onChange={e => setTxCategory(e.target.value)}
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  {txType === 'income' ? (
                    <>
                      <option value="Client Payment">Client Payment</option>
                      <option value="Deposit">Deposit</option>
                      <option value="Other Income">Other Income</option>
                    </>
                  ) : (
                    <>
                      <option value="Office">Office & Rent</option>
                      <option value="Transport">Transport & Fleet</option>
                      <option value="Utilities">Utilities & Power</option>
                      <option value="Equipment">Equipment & Tools</option>
                      <option value="Miscellaneous">Miscellaneous</option>
                    </>
                  )}
                </select>
              </div>

              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Project Site (Optional)
                </label>
                <select
                  value={txProjectId}
                  onChange={e => setTxProjectId(e.target.value)}
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  <option value="">Company-level (Headquarters)</option>
                  {projects.map(p => (
                    <option key={p.id} value={p.id}>
                      {p.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="flex items-center gap-3 pt-3">
                <AppButton
                  type="button"
                  variant="outline"
                  onClick={() => setShowAddTxModal(false)}
                >
                  {t.cancel}
                </AppButton>
                <AppButton type="submit" variant="primary">
                  {t.save} Transaction
                </AppButton>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Purchase Modal */}
      {showAddPurchaseModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-md w-full p-6 shadow-2xl animate-scaleUp">
            <div className="flex items-center justify-between pb-3 border-b border-[#E7E3DD] dark:border-[#2F333C]">
              <h2 className="font-heading font-bold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
                Record Material Purchase
              </h2>
              <button
                onClick={() => setShowAddPurchaseModal(false)}
                className="text-[#8A8D96] hover:text-[#1A1C21] dark:hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreatePurchase} className="space-y-4 mt-4">
              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Project Site
                </label>
                <select
                  value={purProjectId}
                  onChange={e => setPurProjectId(e.target.value)}
                  required
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  {projects.map(p => (
                    <option key={p.id} value={p.id}>
                      {p.name}
                    </option>
                  ))}
                </select>
              </div>

              <AppTextField
                label="Item Name"
                hint="e.g. Cement, Steel Rods, Bricks, Sand"
                value={purItem}
                onChange={e => setPurItem(e.target.value)}
                required
              />

              <div className="grid grid-cols-2 gap-3">
                <AppTextField
                  label="Quantity"
                  type="number"
                  hint="e.g. 100"
                  value={purQty}
                  onChange={e => setPurQty(e.target.value)}
                  required
                />
                <div className="space-y-1">
                  <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                    Unit
                  </label>
                  <select
                    value={purUnit}
                    onChange={e => setPurUnit(e.target.value)}
                    className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                  >
                    <option value="Bag">Bag</option>
                    <option value="Kg">Kg</option>
                    <option value="Ton">Ton</option>
                    <option value="Pcs">Pcs</option>
                    <option value="Ft">Ft</option>
                    <option value="Trolley">Trolley</option>
                    <option value="Lot">Lot</option>
                  </select>
                </div>
              </div>

              <AppTextField
                label="Rate per Unit (PKR)"
                type="number"
                hint="e.g. 600"
                value={purRate}
                onChange={e => setPurRate(e.target.value)}
                required
              />

              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Supplier
                </label>
                <select
                  value={purSupplierId}
                  onChange={e => setPurSupplierId(e.target.value)}
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  <option value="">Select Supplier</option>
                  {suppliers.map(s => (
                    <option key={s.id} value={s.id}>
                      {s.name} ({s.address})
                    </option>
                  ))}
                </select>
              </div>

              <div className="flex items-center gap-3 pt-3">
                <AppButton
                  type="button"
                  variant="outline"
                  onClick={() => setShowAddPurchaseModal(false)}
                >
                  {t.cancel}
                </AppButton>
                <AppButton type="submit" variant="primary">
                  {t.save} Purchase
                </AppButton>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
