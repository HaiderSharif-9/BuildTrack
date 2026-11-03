import React from 'react';
import { AppCard } from './AppCard';
import clsx from 'clsx';

export type KpiType = 'income' | 'expense' | 'profit' | 'info' | 'default';

interface KpiCardProps {
  label: string;
  value: string;
  subtitle?: string;
  type?: KpiType;
  icon?: React.ReactNode;
  className?: string;
}

export const KpiCard: React.FC<KpiCardProps> = ({
  label,
  value,
  subtitle,
  type = 'default',
  icon,
  className,
}) => {
  const textColorClass = {
    income: 'text-[#12A150] dark:text-[#3DD68C]',
    expense: 'text-[#E5484D] dark:text-[#FF6B70]',
    profit: 'text-[#6E56CF] dark:text-[#9A8CFF]',
    info: 'text-[#8A5A00] dark:text-[#F2B632]',
    default: 'text-[#F2B632]',
  }[type];

  return (
    <AppCard className={clsx('flex flex-col justify-between min-h-[105px] p-4', className)}>
      <div className="flex items-center justify-between gap-2">
        <span className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider">
          {label}
        </span>
        {icon && <div className={clsx('w-5 h-5 flex items-center justify-center', textColorClass)}>{icon}</div>}
      </div>
      <div className="mt-2">
        <div className={clsx('text-2xl font-extrabold tracking-tight font-heading tabular-nums', textColorClass)}>
          {value}
        </div>
        {subtitle && (
          <div className="text-xs text-[#8A8D96] dark:text-[#8D8A83] font-medium mt-0.5">
            {subtitle}
          </div>
        )}
      </div>
    </AppCard>
  );
};
