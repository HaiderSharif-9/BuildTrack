import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { StatusChip } from '../common/StatusChip';
import { formatMoney } from '../../utils/money';
import { WageCalculator } from '../../utils/wageCalculator';
import {
  Calendar,
  Clock,
  Lock,
  Unlock,
  Check,
  X,
  Coffee,
  Sparkles,
  Zap,
} from 'lucide-react';
import clsx from 'clsx';

export const AttendanceScreen: React.FC = () => {
  const {
    t,
    projects,
    labourList,
    attendance,
    recordAttendance,
    selectedSiteId,
    setSelectedSiteId,
    userRole,
  } = useApp();

  const [date, setDate] = useState(() => new Date().toISOString().split('T')[0]);
  const activeSiteId = selectedSiteId || projects[0]?.id || '';

  // Get active workers
  const activeWorkers = labourList.filter(l => l.active);

  // Quick mark full day for all active workers
  const handleMarkAllFullDay = () => {
    activeWorkers.forEach(worker => {
      recordAttendance({
        projectId: activeSiteId,
        labourId: worker.id,
        date,
        status: 'present',
        inTime: '08:00',
        outTime: '18:00',
        locked: false,
        rate: worker.defaultRate,
      });
    });
  };

  // Compute daily totals
  const currentDayRecords = attendance.filter(
    a => a.date === date && (!activeSiteId || a.projectId === activeSiteId)
  );

  const totalWage = currentDayRecords
    .filter(a => a.status === 'present')
    .reduce((sum, a) => sum + (a.wageAmount || 0), 0);

  const presentCount = currentDayRecords.filter(a => a.status === 'present').length;
  const absentCount = currentDayRecords.filter(a => a.status === 'absent').length;
  const leaveCount = currentDayRecords.filter(a => a.status === 'leave').length;

  return (
    <div className="space-y-5 animate-fadeIn">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="font-heading font-extrabold text-xl text-[#1A1C21] dark:text-[#F3F1EE]">
            {t.attendance} & Wage Engine
          </h1>
          <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
            Daily 10h standard day with 1.5x automatic overtime calculation
          </p>
        </div>

        <button
          onClick={handleMarkAllFullDay}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#FFF6DD] dark:bg-[#24272E] text-[#8A5A00] dark:text-[#F2B632] border border-[#F2B632]/40 text-xs font-bold hover:bg-[#F2B632] hover:text-[#15171C] transition-colors cursor-pointer"
        >
          <Zap className="w-3.5 h-3.5" />
          <span>{t.quickSwipe} (All Present)</span>
        </button>
      </div>

      {/* Date & Site Filters Bar */}
      <AppCard className="p-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="text-[11px] font-bold text-[#8A8D96] uppercase tracking-wider block mb-1">
            Date
          </label>
          <div className="flex items-center gap-2">
            <input
              type="date"
              value={date}
              onChange={e => setDate(e.target.value)}
              className="w-full h-11 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[12px] px-3 text-xs font-semibold text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
            />
            <button
              onClick={() => setDate(new Date().toISOString().split('T')[0])}
              className="px-3 h-11 rounded-[12px] bg-[#E7E3DD] dark:bg-[#2F333C] text-xs font-bold hover:bg-[#F2B632] hover:text-[#15171C] transition-colors shrink-0"
            >
              Today
            </button>
          </div>
        </div>

        <div>
          <label className="text-[11px] font-bold text-[#8A8D96] uppercase tracking-wider block mb-1">
            Site
          </label>
          <select
            value={activeSiteId}
            onChange={e => setSelectedSiteId(e.target.value)}
            className="w-full h-11 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[12px] px-3 text-xs font-semibold text-[#1A1C21] dark:text-[#F3F1EE] focus:outline-none focus:border-[#F2B632]"
          >
            {projects.map(p => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </div>
      </AppCard>

      {/* Summary KPI Pills */}
      <div className="grid grid-cols-4 gap-2 text-center">
        <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] p-2.5 rounded-xl border border-[#E7E3DD] dark:border-[#2F333C]">
          <span className="text-[10px] text-[#8A8D96] block uppercase">Present</span>
          <span className="text-base font-bold text-[#12A150] dark:text-[#3DD68C]">{presentCount}</span>
        </div>
        <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] p-2.5 rounded-xl border border-[#E7E3DD] dark:border-[#2F333C]">
          <span className="text-[10px] text-[#8A8D96] block uppercase">Absent</span>
          <span className="text-base font-bold text-[#E5484D] dark:text-[#FF6B70]">{absentCount}</span>
        </div>
        <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] p-2.5 rounded-xl border border-[#E7E3DD] dark:border-[#2F333C]">
          <span className="text-[10px] text-[#8A8D96] block uppercase">Leave</span>
          <span className="text-base font-bold text-[#8A5A00] dark:text-[#F2B632]">{leaveCount}</span>
        </div>
        <div className="bg-[#FFFFFF] dark:bg-[#1A1C21] p-2.5 rounded-xl border border-[#E7E3DD] dark:border-[#2F333C]">
          <span className="text-[10px] text-[#8A8D96] block uppercase">Total Wages</span>
          <span className="text-sm font-extrabold text-[#15171C] dark:text-[#F2B632]">{formatMoney(totalWage)}</span>
        </div>
      </div>

      {/* Workers Roster List */}
      <div className="space-y-3">
        {activeWorkers.map(worker => {
          const rec = attendance.find(
            a => a.labourId === worker.id && a.date === date && (!activeSiteId || a.projectId === activeSiteId)
          );

          return (
            <WorkerAttendanceCard
              key={worker.id}
              worker={worker}
              record={rec}
              projectId={activeSiteId}
              date={date}
              onSave={recordAttendance}
            />
          );
        })}
      </div>
    </div>
  );
};

interface WorkerAttendanceCardProps {
  worker: any;
  record?: any;
  projectId: string;
  date: string;
  onSave: (record: any) => void;
}

const WorkerAttendanceCard: React.FC<WorkerAttendanceCardProps> = ({
  worker,
  record,
  projectId,
  date,
  onSave,
}) => {
  const [status, setStatus] = useState<'present' | 'absent' | 'leave'>(
    record?.status || 'present'
  );
  const [inTime, setInTime] = useState(record?.inTime || '08:00');
  const [outTime, setOutTime] = useState(record?.outTime || '18:00');
  const [isLocked, setIsLocked] = useState(record?.locked || false);

  const calc = new WageCalculator({ rate: worker.defaultRate });
  const liveWage = calc.calculateDay({
    status,
    inTime: status === 'present' ? inTime : undefined,
    outTime: status === 'present' ? outTime : undefined,
  });

  const handleStatusChange = (newStatus: 'present' | 'absent' | 'leave') => {
    setStatus(newStatus);
    onSave({
      projectId,
      labourId: worker.id,
      date,
      status: newStatus,
      inTime: newStatus === 'present' ? inTime : undefined,
      outTime: newStatus === 'present' ? outTime : undefined,
      locked: isLocked,
      rate: worker.defaultRate,
    });
  };

  const handleTimeBlur = () => {
    if (status === 'present') {
      onSave({
        projectId,
        labourId: worker.id,
        date,
        status,
        inTime,
        outTime,
        locked: isLocked,
        rate: worker.defaultRate,
      });
    }
  };

  return (
    <AppCard className="p-4 space-y-3">
      {/* Worker Header */}
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C] text-sm">
            {worker.name[0]}
          </div>
          <div>
            <h3 className="font-heading font-bold text-sm text-[#1A1C21] dark:text-[#F3F1EE]">
              {worker.name}
            </h3>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
              {worker.trade} • Base: {formatMoney(worker.defaultRate)}/10h
            </p>
          </div>
        </div>

        {/* Live Wage Output */}
        <div className="text-right">
          <span className="text-[10px] text-[#8A8D96] block uppercase tracking-wider">
            Computed Wage
          </span>
          <span className="font-heading font-extrabold text-base text-[#12A150] dark:text-[#3DD68C]">
            {formatMoney(liveWage.wageAmount)}
          </span>
          {liveWage.overtimeHours > 0 && (
            <span className="text-[10px] text-[#D98A06] dark:text-[#FFC456] block font-semibold">
              +{liveWage.overtimeHours}h OT ({formatMoney(liveWage.overtimePay)})
            </span>
          )}
        </div>
      </div>

      {/* Status Picker Buttons */}
      <div className="flex items-center gap-2 pt-1">
        <button
          onClick={() => handleStatusChange('present')}
          className={clsx(
            'flex-1 py-1.5 rounded-xl text-xs font-bold flex items-center justify-center gap-1 transition-all cursor-pointer border',
            status === 'present'
              ? 'bg-[#12A150] text-white border-[#12A150] shadow-xs'
              : 'bg-[#FFF6DD]/40 dark:bg-[#24272E] text-[#5F6470] dark:text-[#B7B3AB] border-[#E7E3DD] dark:border-[#2F333C]'
          )}
        >
          <Check className="w-3.5 h-3.5" />
          <span>Present</span>
        </button>

        <button
          onClick={() => handleStatusChange('absent')}
          className={clsx(
            'flex-1 py-1.5 rounded-xl text-xs font-bold flex items-center justify-center gap-1 transition-all cursor-pointer border',
            status === 'absent'
              ? 'bg-[#E5484D] text-white border-[#E5484D] shadow-xs'
              : 'bg-[#FFF6DD]/40 dark:bg-[#24272E] text-[#5F6470] dark:text-[#B7B3AB] border-[#E7E3DD] dark:border-[#2F333C]'
          )}
        >
          <X className="w-3.5 h-3.5" />
          <span>Absent</span>
        </button>

        <button
          onClick={() => handleStatusChange('leave')}
          className={clsx(
            'flex-1 py-1.5 rounded-xl text-xs font-bold flex items-center justify-center gap-1 transition-all cursor-pointer border',
            status === 'leave'
              ? 'bg-[#D98A06] text-white border-[#D98A06] shadow-xs'
              : 'bg-[#FFF6DD]/40 dark:bg-[#24272E] text-[#5F6470] dark:text-[#B7B3AB] border-[#E7E3DD] dark:border-[#2F333C]'
          )}
        >
          <Coffee className="w-3.5 h-3.5" />
          <span>Leave</span>
        </button>
      </div>

      {/* Time entries if present */}
      {status === 'present' && (
        <div className="flex items-center gap-3 pt-1 text-xs">
          <div className="flex-1 flex items-center gap-1.5">
            <Clock className="w-3.5 h-3.5 text-[#8A8D96]" />
            <span className="text-[#8A8D96]">In:</span>
            <input
              type="time"
              value={inTime}
              onChange={e => setInTime(e.target.value)}
              onBlur={handleTimeBlur}
              className="bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-lg px-2 py-1 text-xs font-semibold focus:outline-none focus:border-[#F2B632]"
            />
          </div>

          <div className="flex-1 flex items-center gap-1.5">
            <Clock className="w-3.5 h-3.5 text-[#8A8D96]" />
            <span className="text-[#8A8D96]">Out:</span>
            <input
              type="time"
              value={outTime}
              onChange={e => setOutTime(e.target.value)}
              onBlur={handleTimeBlur}
              className="bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-lg px-2 py-1 text-xs font-semibold focus:outline-none focus:border-[#F2B632]"
            />
          </div>

          <div className="text-[#8A8D96] font-medium shrink-0">
            {liveWage.hoursWorked ? `${liveWage.hoursWorked} hrs` : '10 hrs'}
          </div>
        </div>
      )}
    </AppCard>
  );
};
