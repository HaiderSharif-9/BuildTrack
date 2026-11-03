import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { StatusChip } from '../common/StatusChip';
import { Labour } from '../../types';
import { formatMoney } from '../../utils/money';
import {
  Users,
  Search,
  Plus,
  X,
  Phone,
  CreditCard,
  Briefcase,
  ChevronRight,
  Shield,
  CheckCircle,
} from 'lucide-react';
import clsx from 'clsx';

export const LabourScreen: React.FC = () => {
  const { t, labourList, addLabour, updateLabour, userRole, projects } = useApp();
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);
  const [selectedLabour, setSelectedLabour] = useState<Labour | null>(null);

  // Form State
  const [name, setName] = useState('');
  const [trade, setTrade] = useState('Mason');
  const [rate, setRate] = useState('1200');
  const [phone, setPhone] = useState('03101111111');
  const [cnic, setCnic] = useState('12345-1234567-1');

  const filteredLabour = labourList.filter(
    l =>
      l.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      l.trade.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;

    addLabour({
      name: name.trim(),
      trade,
      active: true,
      defaultRate: parseFloat(rate) || 1000,
      phone,
      cnic,
    });

    setName('');
    setShowAddModal(false);
  };

  const maskCnic = (val?: string) => {
    if (!val) return '—';
    if (val.length < 4) return val;
    return '*****' + val.substring(val.length - 4);
  };

  return (
    <div className="space-y-4 animate-fadeIn">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-heading font-extrabold text-xl text-[#1A1C21] dark:text-[#F3F1EE]">
            {t.labour} ({labourList.length})
          </h1>
          <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
            Construction workforce directory and daily wage contracts
          </p>
        </div>

        {userRole !== 'manager' && (
          <AppButton
            variant="primary"
            onClick={() => setShowAddModal(true)}
            className="h-10 px-3.5 text-xs font-bold w-auto"
          >
            <Plus className="w-4 h-4 mr-1" />
            <span>Add Labour</span>
          </AppButton>
        )}
      </div>

      {/* Search Input */}
      <AppTextField
        value={searchQuery}
        onChange={e => setSearchQuery(e.target.value)}
        hint={t.search || 'Search name or trade (e.g. Mason, Carpenter)...'}
        icon={<Search className="w-4 h-4" />}
        className="h-11"
      />

      {/* Labour List */}
      <div className="space-y-2.5">
        {filteredLabour.length === 0 ? (
          <AppCard className="text-center py-10">
            <Users className="w-10 h-10 mx-auto text-[#8A8D96] mb-2" />
            <p className="text-sm font-semibold">{t.noData}</p>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83] mt-1">
              No workers match your search.
            </p>
          </AppCard>
        ) : (
          filteredLabour.map(labour => (
            <AppCard
              key={labour.id}
              onClick={() => setSelectedLabour(labour)}
              className="p-3.5 hover:border-[#F2B632] group"
            >
              <div className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-11 h-11 rounded-full bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C] text-base shrink-0 shadow-xs">
                    {labour.name[0]}
                  </div>
                  <div>
                    <h3 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE] group-hover:text-[#F2B632] transition-colors">
                      {labour.name}
                    </h3>
                    <p className="text-xs text-[#5F6470] dark:text-[#B7B3AB] flex items-center gap-1.5">
                      <Briefcase className="w-3 h-3 text-[#F2B632]" />
                      <span>{labour.trade}</span>
                      <span>•</span>
                      <span className="font-bold text-[#12A150] dark:text-[#3DD68C]">
                        {formatMoney(labour.defaultRate)}/day
                      </span>
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <StatusChip status={labour.active ? 'active' : 'inactive'} />
                  <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
                </div>
              </div>
            </AppCard>
          ))
        )}
      </div>

      {/* Labour Detail Modal */}
      {selectedLabour && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-md w-full p-6 shadow-2xl animate-scaleUp">
            <div className="flex items-start justify-between pb-3 border-b border-[#E7E3DD] dark:border-[#2F333C]">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C] text-lg">
                  {selectedLabour.name[0]}
                </div>
                <div>
                  <h2 className="font-heading font-bold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
                    {selectedLabour.name}
                  </h2>
                  <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
                    {selectedLabour.trade}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setSelectedLabour(null)}
                className="text-[#8A8D96] hover:text-[#1A1C21] dark:hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4 my-4 text-xs">
              <div className="grid grid-cols-2 gap-3 p-3 bg-[#FFF6DD]/50 dark:bg-[#24272E] rounded-xl border border-[#E7E3DD] dark:border-[#2F333C]">
                <div>
                  <span className="text-[#8A8D96] block uppercase tracking-wider text-[10px]">
                    Daily 10h Rate
                  </span>
                  <span className="text-base font-bold font-heading text-[#12A150] dark:text-[#3DD68C]">
                    {formatMoney(selectedLabour.defaultRate)}
                  </span>
                </div>
                <div>
                  <span className="text-[#8A8D96] block uppercase tracking-wider text-[10px]">
                    Hourly (with 1.5x OT)
                  </span>
                  <span className="text-base font-bold font-heading text-[#15171C] dark:text-[#F2B632]">
                    {formatMoney((selectedLabour.defaultRate / 10) * 1.5)}/hr
                  </span>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between py-1.5 border-b border-black/5 dark:border-white/5">
                  <span className="text-[#8A8D96] flex items-center gap-1.5">
                    <Phone className="w-3.5 h-3.5" /> Phone Number
                  </span>
                  <span className="font-semibold">{selectedLabour.phone || '03101111111'}</span>
                </div>
                <div className="flex items-center justify-between py-1.5 border-b border-black/5 dark:border-white/5">
                  <span className="text-[#8A8D96] flex items-center gap-1.5">
                    <CreditCard className="w-3.5 h-3.5" /> CNIC (National ID)
                  </span>
                  <span className="font-semibold font-mono">{maskCnic(selectedLabour.cnic)}</span>
                </div>
                <div className="flex items-center justify-between py-1.5 border-b border-black/5 dark:border-white/5">
                  <span className="text-[#8A8D96]">Employment Status</span>
                  <StatusChip status={selectedLabour.active ? 'active' : 'inactive'} />
                </div>
              </div>

              {userRole !== 'manager' && (
                <div className="pt-2">
                  <button
                    onClick={() => {
                      updateLabour(selectedLabour.id, { active: !selectedLabour.active });
                      setSelectedLabour(prev => prev ? { ...prev, active: !prev.active } : null);
                    }}
                    className={clsx(
                      'w-full py-2 rounded-xl font-bold text-xs border transition-colors cursor-pointer',
                      selectedLabour.active
                        ? 'border-[#E5484D] text-[#E5484D] hover:bg-[#E5484D]/10'
                        : 'border-[#12A150] text-[#12A150] hover:bg-[#12A150]/10'
                    )}
                  >
                    {selectedLabour.active ? 'Deactivate Worker' : 'Reactivate Worker'}
                  </button>
                </div>
              )}
            </div>

            <AppButton
              variant="outline"
              onClick={() => setSelectedLabour(null)}
              className="h-10 text-xs font-bold"
            >
              Close
            </AppButton>
          </div>
        </div>
      )}

      {/* Add Labour Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-md w-full p-6 shadow-2xl animate-scaleUp">
            <div className="flex items-center justify-between pb-3 border-b border-[#E7E3DD] dark:border-[#2F333C]">
              <h2 className="font-heading font-bold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
                Register New Worker
              </h2>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-[#8A8D96] hover:text-[#1A1C21] dark:hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreate} className="space-y-4 mt-4">
              <AppTextField
                label="Full Name"
                hint="e.g. Tariq Mehmood"
                value={name}
                onChange={e => setName(e.target.value)}
                required
              />

              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Trade / Skill
                </label>
                <select
                  value={trade}
                  onChange={e => setTrade(e.target.value)}
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  <option value="Mason">Mason (Raj)</option>
                  <option value="Carpenter">Carpenter (Barhai)</option>
                  <option value="Electrician">Electrician</option>
                  <option value="Plumber">Plumber</option>
                  <option value="Painter">Painter</option>
                  <option value="Welder">Welder</option>
                  <option value="Helper">Helper (Mazdoor)</option>
                  <option value="Foreman">Foreman</option>
                </select>
              </div>

              <AppTextField
                label="Default Daily Rate (PKR / 10 Hours)"
                type="number"
                hint="e.g. 1200 or 1000"
                value={rate}
                onChange={e => setRate(e.target.value)}
                required
              />

              <AppTextField
                label="Phone Number"
                hint="e.g. 03101111111"
                value={phone}
                onChange={e => setPhone(e.target.value)}
              />

              <AppTextField
                label="CNIC (National Identity Number)"
                hint="e.g. 12345-1234567-1"
                value={cnic}
                onChange={e => setCnic(e.target.value)}
              />

              <div className="flex items-center gap-3 pt-3">
                <AppButton
                  type="button"
                  variant="outline"
                  onClick={() => setShowAddModal(false)}
                >
                  {t.cancel}
                </AppButton>
                <AppButton type="submit" variant="primary">
                  {t.save} Worker
                </AppButton>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
