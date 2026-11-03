import React from 'react';
import clsx from 'clsx';

export type StatusVariant =
  | 'in_progress'
  | 'planning'
  | 'on_hold'
  | 'completed'
  | 'present'
  | 'absent'
  | 'leave'
  | 'active'
  | 'inactive';

interface StatusChipProps {
  status: string;
  label?: string;
  className?: string;
}

export const StatusChip: React.FC<StatusChipProps> = ({ status, label, className }) => {
  const normalized = status.toLowerCase();

  const getStyle = (): string => {
    switch (normalized) {
      case 'in_progress':
      case 'present':
      case 'active':
        return 'bg-[#E7F7EE] text-[#0B7A3B] border-[#12A150]/30 dark:bg-[#0F2A20] dark:text-[#3DD68C] dark:border-[#3DD68C]/30';
      case 'planning':
      case 'leave':
        return 'bg-[#FFF4DC] text-[#8A5A00] border-[#D98A06]/30 dark:bg-[#2B2310] dark:text-[#FFC456] dark:border-[#FFC456]/30';
      case 'absent':
      case 'inactive':
        return 'bg-[#FDECEC] text-[#B4232C] border-[#E5484D]/30 dark:bg-[#2E1519] dark:text-[#FF6B70] dark:border-[#FF6B70]/30';
      case 'completed':
        return 'bg-[#F1EEFC] text-[#5B43B5] border-[#6E56CF]/30 dark:bg-[#1E1A3A] dark:text-[#9A8CFF] dark:border-[#9A8CFF]/30';
      case 'on_hold':
      default:
        return 'bg-[#E7E3DD]/50 text-[#5F6470] border-[#8A8D96]/30 dark:bg-[#24272E] dark:text-[#B7B3AB] dark:border-[#2F333C]';
    }
  };

  const displayText = label || status.replace(/_/g, ' ');

  return (
    <span
      className={clsx(
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize border',
        getStyle(),
        className
      )}
    >
      {displayText}
    </span>
  );
};
