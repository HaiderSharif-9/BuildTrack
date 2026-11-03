import React from 'react';
import clsx from 'clsx';

interface AppTextFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  hint?: string;
  error?: string;
  icon?: React.ReactNode;
  suffixIcon?: React.ReactNode;
  onSuffixIconTap?: () => void;
}

export const AppTextField: React.FC<AppTextFieldProps> = ({
  label,
  hint,
  error,
  icon,
  suffixIcon,
  onSuffixIconTap,
  className,
  id,
  ...props
}) => {
  const inputId = id || (label ? label.toLowerCase().replace(/\s+/g, '-') : undefined);

  return (
    <div className="w-full flex flex-col gap-1.5 text-left">
      {label && (
        <label
          htmlFor={inputId}
          className="text-xs font-semibold text-[#5F6470] dark:text-[#B7B3AB] uppercase tracking-wider"
        >
          {label}
        </label>
      )}
      <div className="relative flex items-center">
        {icon && (
          <div className="absolute left-3.5 text-[#5F6470] dark:text-[#8D8A83] pointer-events-none flex items-center">
            {icon}
          </div>
        )}
        <input
          id={inputId}
          placeholder={hint}
          className={clsx(
            'w-full h-12 bg-[#FFF6DD]/60 dark:bg-[#24272E] border border-[#E7E3DD] dark:border-[#2F333C] rounded-[14px] text-sm text-[#1A1C21] dark:text-[#F3F1EE] placeholder-[#8A8D96] dark:placeholder-[#8D8A83] transition-colors focus:outline-none focus:border-[#F2B632] focus:ring-2 focus:ring-[#F2B632]/20',
            icon ? 'pl-11 pr-4' : 'px-4',
            suffixIcon && 'pr-11',
            error && 'border-[#E5484D] dark:border-[#FF6B70] focus:border-[#E5484D]',
            className
          )}
          {...props}
        />
        {suffixIcon && (
          <button
            type="button"
            onClick={onSuffixIconTap}
            tabIndex={-1}
            className="absolute right-3.5 text-[#5F6470] dark:text-[#8D8A83] hover:text-[#1A1C21] dark:hover:text-[#F3F1EE] transition-colors p-1"
          >
            {suffixIcon}
          </button>
        )}
      </div>
      {error && <p className="text-xs text-[#E5484D] dark:text-[#FF6B70] mt-0.5">{error}</p>}
    </div>
  );
};
