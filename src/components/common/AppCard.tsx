import React from 'react';
import clsx from 'clsx';

interface AppCardProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  bordered?: boolean;
}

export const AppCard: React.FC<AppCardProps> = ({
  children,
  className,
  onClick,
  bordered = true,
  ...props
}) => {
  return (
    <div
      onClick={onClick}
      className={clsx(
        'bg-[#FFFFFF] dark:bg-[#1A1C21] rounded-[20px] p-4 transition-all duration-200',
        bordered && 'border border-[#E7E3DD] dark:border-[#2F333C]',
        onClick && 'cursor-pointer hover:shadow-md hover:border-[#F2B632]/50 active:scale-[0.99]',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};
