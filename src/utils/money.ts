/**
 * Formats a currency amount into Pakistani Rupees: "Rs. 1,234,567"
 */
export function formatMoney(amount: number | string | null | undefined, showDecimals = false): string {
  if (amount === null || amount === undefined || isNaN(Number(amount))) {
    return 'Rs. 0';
  }
  const num = typeof amount === 'string' ? parseFloat(amount) : amount;
  const formatted = new Intl.NumberFormat('en-US', {
    minimumFractionDigits: showDecimals ? 2 : 0,
    maximumFractionDigits: showDecimals ? 2 : 0,
  }).format(num);

  return `Rs. ${formatted}`;
}

/**
 * Formats a compact currency amount for KPIs: "2.4M", "600K", "1,200"
 */
export function formatCompactMoney(amount: number): string {
  if (Math.abs(amount) >= 1_000_000) {
    const val = amount / 1_000_000;
    return `${val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)}M`;
  }
  if (Math.abs(amount) >= 1_000) {
    const val = amount / 1_000;
    return `${val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)}K`;
  }
  return amount.toLocaleString('en-US');
}

/**
 * Money helper class mirroring Flutter's Money
 */
export class Money {
  private val: number;

  constructor(amount: number) {
    this.val = Math.round((amount + Number.EPSILON) * 100) / 100;
  }

  static fromInt(rupees: number): Money {
    return new Money(rupees);
  }

  static fromDouble(amount: number): Money {
    return new Money(amount);
  }

  static fromString(amountStr: string): Money {
    return new Money(parseFloat(amountStr || '0'));
  }

  static get zero(): Money {
    return new Money(0);
  }

  get isZero(): boolean {
    return this.val === 0;
  }

  roundToRupee(): Money {
    return new Money(Math.round(this.val));
  }

  plus(other: Money | number): Money {
    const o = typeof other === 'number' ? other : other.val;
    return new Money(this.val + o);
  }

  minus(other: Money | number): Money {
    const o = typeof other === 'number' ? other : other.val;
    return new Money(this.val - o);
  }

  times(scalar: number): Money {
    return new Money(this.val * scalar);
  }

  div(scalar: number): Money {
    return new Money(this.val / scalar);
  }

  toDouble(): number {
    return this.val;
  }

  toDisplayString(): string {
    return formatMoney(this.val);
  }

  toString(): string {
    return `Money(${this.val})`;
  }
}
