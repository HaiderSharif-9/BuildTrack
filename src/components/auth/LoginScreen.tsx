import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { AppCard } from '../common/AppCard';
import { AppButton } from '../common/AppButton';
import { AppTextField } from '../common/AppTextField';
import { Eye, EyeOff, User, Lock, ArrowRight } from 'lucide-react';

interface LoginScreenProps {
  onSuccess: () => void;
  onNavigateToSignUp: () => void;
  onNavigateToForgotPass: () => void;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({
  onSuccess,
  onNavigateToSignUp,
  onNavigateToForgotPass,
}) => {
  const { t, signIn } = useApp();
  const [loginId, setLoginId] = useState('admin@buildtrack.local');
  const [password, setPassword] = useState('password123');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!loginId.trim()) {
      setErrorMessage(t.pleaseEnterCredentials);
      return;
    }

    setIsLoading(true);
    setErrorMessage(null);

    try {
      await signIn(loginId, password);
      onSuccess();
    } catch {
      setErrorMessage('Login failed. Please check your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-linear-to-br from-[#15171C] to-[#343A46] text-white flex flex-col items-center justify-center p-4">
      <div className="max-w-md w-full space-y-6">
        {/* Branding Logo & Header */}
        <div className="text-center space-y-2">
          <div className="w-20 h-20 rounded-2xl bg-[#F2B632] flex items-center justify-center font-bold text-[#15171C] text-4xl mx-auto shadow-xl">
            ◆
          </div>
          <h1 className="font-heading font-extrabold text-3xl tracking-tight text-white pt-2">
            BuildTrack
          </h1>
          <p className="text-xs font-semibold text-[#F2B632]">
            {t.appSubtitle}
          </p>
        </div>

        {/* Login Form Card */}
        <AppCard className="p-6 sm:p-7 space-y-5 bg-[#FFFFFF] dark:bg-[#1A1C21] text-[#1A1C21] dark:text-[#F3F1EE] shadow-2xl">
          <div className="space-y-1">
            <h2 className="font-heading font-bold text-xl">
              {t.loginTitle}
            </h2>
            <p className="text-xs text-[#5F6470] dark:text-[#8D8A83]">
              Sign in with your email, phone, or administrative account
            </p>
          </div>

          {errorMessage && (
            <div className="p-3 rounded-xl bg-[#FDECEC] dark:bg-[#2E1519] border border-[#E5484D] text-[#E5484D] dark:text-[#FF6B70] text-xs font-medium">
              {errorMessage}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <AppTextField
              label={t.phoneOrEmail}
              hint={t.enterPhoneOrEmail}
              value={loginId}
              onChange={e => setLoginId(e.target.value)}
              icon={<User className="w-4 h-4" />}
              required
            />

            <AppTextField
              label={t.password}
              type={showPassword ? 'text' : 'password'}
              hint={t.enterPassword}
              value={password}
              onChange={e => setPassword(e.target.value)}
              icon={<Lock className="w-4 h-4" />}
              suffixIcon={
                showPassword ? (
                  <EyeOff className="w-4 h-4" />
                ) : (
                  <Eye className="w-4 h-4" />
                )
              }
              onSuffixIconTap={() => setShowPassword(p => !p)}
              required
            />

            <div className="flex justify-end">
              <button
                type="button"
                onClick={onNavigateToForgotPass}
                className="text-xs font-semibold text-[#8A5A00] dark:text-[#F2B632] hover:underline"
              >
                {t.forgotPassword}
              </button>
            </div>

            <AppButton
              type="submit"
              variant="primary"
              isLoading={isLoading}
              className="mt-2 text-sm font-bold"
            >
              <span>{t.loginButton}</span>
              <ArrowRight className="w-4 h-4" />
            </AppButton>
          </form>

          {/* Quick Demo Credentials helper */}
          <div className="pt-2 border-t border-[#E7E3DD] dark:border-[#2F333C] text-[11px] text-[#8A8D96] flex items-center justify-between">
            <span>Demo logins:</span>
            <div className="flex items-center gap-1.5 font-semibold text-[#8A5A00] dark:text-[#F2B632]">
              <button
                type="button"
                onClick={() => setLoginId('admin@buildtrack.local')}
                className="hover:underline"
              >
                Admin
              </button>
              <span>•</span>
              <button
                type="button"
                onClick={() => setLoginId('accountant@buildtrack.local')}
                className="hover:underline"
              >
                Accountant
              </button>
              <span>•</span>
              <button
                type="button"
                onClick={() => setLoginId('manager@buildtrack.local')}
                className="hover:underline"
              >
                Manager
              </button>
            </div>
          </div>
        </AppCard>

        {/* First admin signup */}
        <div className="text-center">
          <button
            type="button"
            onClick={onNavigateToSignUp}
            className="text-xs font-bold text-[#F2B632] hover:underline cursor-pointer"
          >
            {t.signUpAsFirstAdmin}
          </button>
        </div>
      </div>
    </div>
  );
};
