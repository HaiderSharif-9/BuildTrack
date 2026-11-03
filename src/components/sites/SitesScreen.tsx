import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { StatusChip } from '../common/StatusChip';
import { Project, ProjectStatus } from '../../types';
import {
  Building2,
  MapPin,
  Plus,
  ChevronRight,
  User,
  X,
  Search,
} from 'lucide-react';

interface SitesScreenProps {
  onSelectSite: (siteId: string) => void;
}

export const SitesScreen: React.FC<SitesScreenProps> = ({ onSelectSite }) => {
  const { t, projects, clients, addProject, userRole } = useApp();
  const [showAddModal, setShowAddModal] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Form state
  const [name, setName] = useState('');
  const [location, setLocation] = useState('');
  const [clientId, setClientId] = useState('');
  const [budget, setBudget] = useState('2500000');
  const [status, setStatus] = useState<ProjectStatus>('in_progress');

  const filteredProjects = projects.filter(
    p =>
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !location.trim()) return;

    addProject({
      name: name.trim(),
      location: location.trim(),
      clientId: clientId || undefined,
      budget: parseFloat(budget) || 1000000,
      status,
      startDate: new Date().toISOString().split('T')[0],
    });

    setName('');
    setLocation('');
    setShowAddModal(false);
  };

  return (
    <div className="space-y-4 animate-fadeIn">
      {/* Header with Title and Add Button */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-heading font-extrabold text-xl text-[#1A1C21] dark:text-[#F3F1EE]">
            {t.sites}
          </h1>
          <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
            {projects.length} sites under Care Constructiona management
          </p>
        </div>
        {userRole !== 'manager' && (
          <AppButton
            variant="primary"
            onClick={() => setShowAddModal(true)}
            className="h-10 px-3.5 text-xs font-bold w-auto"
          >
            <Plus className="w-4 h-4 mr-1" />
            <span>Add Site</span>
          </AppButton>
        )}
      </div>

      {/* Search Input */}
      <div className="relative">
        <AppTextField
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          hint="Search site name or location..."
          icon={<Search className="w-4 h-4" />}
          className="h-11"
        />
      </div>

      {/* Site List */}
      <div className="space-y-3">
        {filteredProjects.length === 0 ? (
          <AppCard className="text-center py-12">
            <Building2 className="w-10 h-10 mx-auto text-[#8A8D96] mb-2" />
            <p className="text-sm font-semibold">{t.noData}</p>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83] mt-1">
              No construction sites match your filter.
            </p>
          </AppCard>
        ) : (
          filteredProjects.map(site => {
            const client = clients.find(c => c.id === site.clientId);
            return (
              <AppCard
                key={site.id}
                onClick={() => onSelectSite(site.id)}
                className="hover:border-[#F2B632] group"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="space-y-1.5 flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="font-heading font-bold text-base text-[#1A1C21] dark:text-[#F3F1EE] group-hover:text-[#F2B632] transition-colors">
                        {site.name}
                      </h3>
                    </div>

                    <div className="flex flex-wrap items-center gap-y-1 gap-x-3 text-xs text-[#5F6470] dark:text-[#B7B3AB]">
                      <span className="flex items-center gap-1">
                        <MapPin className="w-3.5 h-3.5 text-[#F2B632]" />
                        {site.location}
                      </span>
                      {client && (
                        <span className="flex items-center gap-1 text-[#8A8D96]">
                          <User className="w-3.5 h-3.5" />
                          {client.name}
                        </span>
                      )}
                    </div>

                    <div className="pt-1 text-xs">
                      <span className="text-[#8A8D96] dark:text-[#8D8A83]">
                        {t.budget}:
                      </span>{' '}
                      <span className="font-semibold text-[#1A1C21] dark:text-[#F3F1EE]">
                        Rs. {site.budget.toLocaleString()}
                      </span>
                    </div>
                  </div>

                  <div className="flex flex-col items-end gap-2 shrink-0">
                    <StatusChip status={site.status} />
                    <ChevronRight className="w-4 h-4 text-[#8A8D96] group-hover:translate-x-0.5 transition-transform" />
                  </div>
                </div>
              </AppCard>
            );
          })
        )}
      </div>

      {/* Add Site Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[24px] max-w-md w-full p-6 shadow-2xl animate-scaleUp">
            <div className="flex items-center justify-between pb-3 border-b border-[#E7E3DD] dark:border-[#2F333C]">
              <h2 className="font-heading font-bold text-lg text-[#1A1C21] dark:text-[#F3F1EE]">
                Add New Construction Site
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
                label="Site Name"
                hint="e.g. DHA Villa B-2 820"
                value={name}
                onChange={e => setName(e.target.value)}
                required
              />

              <AppTextField
                label="Location"
                hint="e.g. DHA Phase V or Gulberg"
                value={location}
                onChange={e => setLocation(e.target.value)}
                required
              />

              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Client
                </label>
                <select
                  value={clientId}
                  onChange={e => setClientId(e.target.value)}
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  <option value="">Select Client (Optional)</option>
                  {clients.map(c => (
                    <option key={c.id} value={c.id}>
                      {c.name} ({c.address})
                    </option>
                  ))}
                </select>
              </div>

              <AppTextField
                label="Budget (PKR)"
                type="number"
                value={budget}
                onChange={e => setBudget(e.target.value)}
                required
              />

              <div className="space-y-1">
                <label className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider block">
                  Status
                </label>
                <select
                  value={status}
                  onChange={e => setStatus(e.target.value as ProjectStatus)}
                  className="w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] px-4 text-sm text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
                >
                  <option value="planning">Planning</option>
                  <option value="in_progress">In Progress</option>
                  <option value="on_hold">On Hold</option>
                  <option value="completed">Completed</option>
                </select>
              </div>

              <div className="flex items-center gap-3 pt-3">
                <AppButton
                  type="button"
                  variant="outline"
                  onClick={() => setShowAddModal(false)}
                >
                  {t.cancel}
                </AppButton>
                <AppButton type="submit" variant="primary">
                  {t.save} Site
                </AppButton>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
