import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { ArrowLeft, User, Mail, Phone, Lock, CheckCircle2 } from 'lucide-react';

interface SignUpScreenProps {
  onSuccess: () => void;
  onBackToLogin: () => void;
}

export const SignUpScreen: React.FC<SignUpScreenProps> = ({
  onSuccess,
  onBackToLogin,
}) => {
  const { t, signUp } = useApp();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!fullName.trim() || !email.trim()) {
      setError(t.pleaseEnterFullName);
      return;
    }
    if (password.length < 8) {
      setError(t.passwordMustBeAtLeast8Characters);
      return;
    }
    if (password !== confirmPassword) {
      setError(t.passwordsDoNotMatch);
      return;
    }

    setIsLoading(true);
    setError(null);
    try {
      await signUp(fullName.trim(), email.trim(), phone.trim());
      onSuccess();
    } catch {
      setError('Registration failed');
    } finally {
      setIsLoading(false);
    }
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
              {t.createFirstAdminAccount}
            </h2>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
              {t.devModeMessage}
            </p>
          </div>

          {error && (
            <div className="p-3 rounded-xl bg-[#FDECEC] dark:bg-[#2E1519] border border-[#E5484D] text-[#E5484D] dark:text-[#FF6B70] text-xs font-medium">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-3.5">
            <AppTextField
              label={t.fullName}
              hint={t.enterFullName}
              value={fullName}
              onChange={e => setFullName(e.target.value)}
              icon={<User className="w-4 h-4" />}
              required
            />

            <AppTextField
              label={t.email}
              type="email"
              hint={t.enterEmail}
              value={email}
              onChange={e => setEmail(e.target.value)}
              icon={<Mail className="w-4 h-4" />}
              required
            />

            <AppTextField
              label={t.phoneOrEmail}
              hint="e.g. 03001234567"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              icon={<Phone className="w-4 h-4" />}
            />

            <AppTextField
              label={t.password}
              type="password"
              hint={t.passwordMustBeAtLeast8Characters}
              value={password}
              onChange={e => setPassword(e.target.value)}
              icon={<Lock className="w-4 h-4" />}
              required
            />

            <AppTextField
              label={t.confirmPassword}
              type="password"
              hint="Re-enter password"
              value={confirmPassword}
              onChange={e => setConfirmPassword(e.target.value)}
              icon={<Lock className="w-4 h-4" />}
              required
            />

            <AppButton
              type="submit"
              variant="primary"
              isLoading={isLoading}
              className="mt-2 text-sm font-bold"
            >
              {t.createAccount}
            </AppButton>
          </form>
        </AppCard>
      </div>
    </div>
  );
};
