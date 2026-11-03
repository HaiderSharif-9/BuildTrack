import React from 'react';
import { formatMoney } from '../../utils/money';
import clsx from 'clsx';

interface AmountTextProps {
  amount: number | string;
  type?: 'income' | 'expense' | 'default';
  showSign?: boolean;
  className?: string;
  showDecimals?: boolean;
}

export const AmountText: React.FC<AmountTextProps> = ({
  amount,
  type = 'default',
  showSign = true,
  className,
  showDecimals = false,
}) => {
  const num = typeof amount === 'string' ? parseFloat(amount) : amount;
  const formatted = formatMoney(Math.abs(num), showDecimals);

  let prefix = '';
  if (showSign) {
    if (type === 'income' || num > 0) prefix = '+ ';
    else if (type === 'expense' || num < 0) prefix = '- ';
  }

  const colorClass = {
    income: 'text-[#12A150] dark:text-[#3DD68C]',
    expense: 'text-[#E5484D] dark:text-[#FF6B70]',
    default: 'text-[#1A1C21] dark:text-[#F3F1EE]',
  }[type];

  return (
    <span className={clsx('font-semibold tabular-nums', colorClass, className)}>
      {prefix}
      {formatted}
    </span>
  );
};
