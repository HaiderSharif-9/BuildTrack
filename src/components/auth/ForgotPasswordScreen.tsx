import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { ArrowLeft, Mail, CheckCircle2 } from 'lucide-react';

interface ForgotPasswordScreenProps {
  onBackToLogin: () => void;
}

export const ForgotPasswordScreen: React.FC<ForgotPasswordScreenProps> = ({
  onBackToLogin,
}) => {
  const { t } = useApp();
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    setSent(true);
  };

  return (
    <div className="min-h-screen bg-linear-to-br from-[#15171C] to-[#343A46] text-white flex flex-col items-center justify-center p-4">
      <div className="max-w-md w-full space-y-5">
        <button
          onClick={onBackToLogin}
          className="flex items-center gap-1.5 text-xs font-semibold text-[#F2B632] hover:underline"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Sign In</span>
        </button>

        <AppCard className="p-6 space-y-5 bg-[#FFFFFF] dark:bg-[#1A1C21] text-[#1A1C21] dark:text-[#F3F1EE] shadow-2xl">
          <div className="space-y-1">
            <h2 className="font-heading font-bold text-xl">
              {t.resetPassword}
            </h2>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
              {t.enterEmailToResetPassword}
            </p>
          </div>

          {sent ? (
            <div className="p-4 rounded-xl bg-[#E7F7EE] dark:bg-[#0F2A20] text-[#0B7A3B] dark:text-[#3DD68C] text-xs font-medium space-y-2">
              <div className="flex items-center gap-2 font-bold">
                <CheckCircle2 className="w-4 h-4" />
                <span>{t.passwordResetEmailSent}</span>
              </div>
              <p>We've sent recovery instructions to {email}.</p>
              <AppButton
                onClick={onBackToLogin}
                variant="primary"
                className="mt-3 text-xs font-bold"
              >
                Return to Login
              </AppButton>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <AppTextField
                label={t.email}
                type="email"
                hint={t.enterEmail}
                value={email}
                onChange={e => setEmail(e.target.value)}
                icon={<Mail className="w-4 h-4" />}
                required
              />

              <AppButton type="submit" variant="primary" className="text-sm font-bold">
                {t.sendResetEmail}
              </AppButton>
            </form>
          )}
        </AppCard>
      </div>
    </div>
  );
};
