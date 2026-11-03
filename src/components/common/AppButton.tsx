import React from 'react';
import clsx from 'clsx';
import { Loader2 } from 'lucide-react';

interface AppButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children?: React.ReactNode;
  label?: string;
  variant?: 'primary' | 'secondary' | 'outline' | 'danger';
  isLoading?: boolean;
  fullWidth?: boolean;
}

export const AppButton: React.FC<AppButtonProps> = ({
  children,
  label,
  variant = 'primary',
  isLoading = false,
  fullWidth = true,
  disabled,
  className,
  ...props
}) => {
  const content = label || children;

  const variantStyles = {
    primary:
      'bg-[#F2B632] hover:bg-[#F7C85A] text-[#15171C] font-semibold shadow-sm active:translate-y-[1px]',
    secondary:
      'bg-[#FFF6DD] dark:bg-[#24272E] text-[#8A5A00] dark:text-[#F2B632] hover:bg-[#FCEBBB] font-medium',
    outline:
      'bg-transparent border border-[#E7E3DD] dark:border-[#2F333C] text-[#1A1C21] dark:text-[#F3F1EE] hover:bg-black/5 dark:hover:bg-white/5 font-medium',
    danger:
      'bg-[#E5484D] hover:bg-[#B4232C] text-white font-medium shadow-sm',
  };

  return (
    <button
      disabled={disabled || isLoading}
      className={clsx(
        'h-12 px-6 rounded-[14px] flex items-center justify-center gap-2 text-sm transition-all duration-150 select-none cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed',
        variantStyles[variant],
        fullWidth && 'w-full',
        className
      )}
      {...props}
    >
      {isLoading ? (
        <>
          <Loader2 className="w-4 h-4 animate-spin text-current" />
          <span>Processing...</span>
        </>
      ) : (
        content
      )}
    </button>
  );
};
