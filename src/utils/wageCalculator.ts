import { WageCalculationResult } from '../types';

export interface WageCalculatorOptions {
  rate: number;
  fullDayHours?: number; // default 10.0
  overtimeMultiplier?: number; // default 1.5
}

export class WageCalculator {
  readonly rate: number;
  readonly fullDayHours: number;
  readonly overtimeMultiplier: number;

  constructor(options: WageCalculatorOptions) {
    this.rate = options.rate;
    this.fullDayHours = options.fullDayHours ?? 10.0;
    this.overtimeMultiplier = options.overtimeMultiplier ?? 1.5;
  }

  calculateDay(params: {
    status: 'present' | 'absent' | 'leave';
    inTime?: string | null;
    outTime?: string | null;
    manualOvertimeHours?: number;
  }): WageCalculationResult {
    const { status, inTime, outTime, manualOvertimeHours = 0 } = params;

    // Absent or leave: zero wage
    if (status === 'absent' || status === 'leave') {
      return {
        hoursWorked: null,
        overtimeHours: 0,
        basePay: 0,
        overtimePay: 0,
        wageAmount: 0,
      };
    }

    // Present
    if (status !== 'present') {
      return {
        hoursWorked: null,
        overtimeHours: 0,
        basePay: 0,
        overtimePay: 0,
        wageAmount: 0,
      };
    }

    // Both times provided: calculate exact hours worked and overtime
    if (inTime && outTime) {
      const hours = this.parseTimeAndCalculateHours(inTime, outTime);
      if (hours === null) {
        // Fallback to full day
        return this.calculateFullDay();
      }

      const effectiveHours = Math.min(hours, this.fullDayHours);
      const basePay = (this.rate * effectiveHours) / this.fullDayHours;
      const overtimeHours = hours > this.fullDayHours ? hours - this.fullDayHours : 0;
      const hourlyRate = this.rate / this.fullDayHours;
      const overtimePay = overtimeHours * hourlyRate * this.overtimeMultiplier;
      const wageAmount = Math.round(basePay + overtimePay);

      return {
        hoursWorked: hours,
        overtimeHours: overtimeHours > 0 ? Number(overtimeHours.toFixed(2)) : 0,
        basePay: Math.round(basePay * 100) / 100,
        overtimePay: Math.round(overtimePay * 100) / 100,
        wageAmount,
      };
    }

    // No times given, manual overtime provided
    if (manualOvertimeHours > 0) {
      const hourlyRate = this.rate / this.fullDayHours;
      const overtimePay = manualOvertimeHours * hourlyRate * this.overtimeMultiplier;
      const wageAmount = Math.round(this.rate + overtimePay);

      return {
        hoursWorked: null,
        overtimeHours: manualOvertimeHours,
        basePay: this.rate,
        overtimePay: Math.round(overtimePay * 100) / 100,
        wageAmount,
      };
    }

    // Full day present with no times
    return this.calculateFullDay();
  }

  private calculateFullDay(): WageCalculationResult {
    return {
      hoursWorked: null,
      overtimeHours: 0,
      basePay: this.rate,
      overtimePay: 0,
      wageAmount: this.rate,
    };
  }

  private parseTimeAndCalculateHours(inTime: string, outTime: string): number | null {
    try {
      const inParts = inTime.split(':');
      const outParts = outTime.split(':');

      if (inParts.length !== 2 || outParts.length !== 2) return null;

      const inHour = parseInt(inParts[0], 10);
      const inMin = parseInt(inParts[1], 10);
      const outHour = parseInt(outParts[0], 10);
      const outMin = parseInt(outParts[1], 10);

      if (
        isNaN(inHour) ||
        isNaN(inMin) ||
        isNaN(outHour) ||
        isNaN(outMin) ||
        inHour < 0 ||
        inHour > 23 ||
        inMin < 0 ||
        inMin > 59 ||
        outHour < 0 ||
        outHour > 23 ||
        outMin < 0 ||
        outMin > 59
      ) {
        return null;
      }

      const inTotalMin = inHour * 60 + inMin;
      const outTotalMin = outHour * 60 + outMin;

      if (outTotalMin <= inTotalMin) return null;

      const diffMin = outTotalMin - inTotalMin;
      const hours = diffMin / 60.0;

      if (hours > 24) return null;

      return Math.round(hours * 100) / 100;
    } catch {
      return null;
    }
  }
}
