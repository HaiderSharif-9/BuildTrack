import React, { useState } from 'react';
import { useApp } from './context/AppContext';
import { AppShell, TabId } from './components/layout/AppShell';
import { DashboardScreen } from './components/dashboard/DashboardScreen';
import { SitesScreen } from './components/sites/SitesScreen';
import { SiteDetailScreen } from './components/sites/SiteDetailScreen';
import { AttendanceScreen } from './components/attendance/AttendanceScreen';
import { MoneyScreen } from './components/money/MoneyScreen';
import { LabourScreen } from './components/labour/LabourScreen';
import { MoreScreen } from './components/more/MoreScreen';
import { LoginScreen } from './components/auth/LoginScreen';
import { SignUpScreen } from './components/auth/SignUpScreen';
import { ForgotPasswordScreen } from './components/auth/ForgotPasswordScreen';

type AuthView = 'login' | 'signup' | 'forgot-password' | null;

export const App: React.FC = () => {
  const { currentUser } = useApp();
  const [currentTab, setCurrentTab] = useState<TabId>('home');
  const [activeSiteId, setActiveSiteId] = useState<string | null>(null);
  const [viewingLabour, setViewingLabour] = useState(false);
  const [authView, setAuthView] = useState<AuthView>(() => {
    return currentUser ? null : 'login';
  });

  // If user explicitly signed out
  if (!currentUser || authView) {
    if (authView === 'signup') {
      return (
        <SignUpScreen
          onSuccess={() => setAuthView(null)}
          onBackToLogin={() => setAuthView('login')}
        />
      );
    }
    if (authView === 'forgot-password') {
      return (
        <ForgotPasswordScreen
          onBackToLogin={() => setAuthView('login')}
        />
      );
    }
    return (
      <LoginScreen
        onSuccess={() => setAuthView(null)}
        onNavigateToSignUp={() => setAuthView('signup')}
        onNavigateToForgotPass={() => setAuthView('forgot-password')}
      />
    );
  }

  // Handle Tab Navigation
  const handleSelectTab = (tab: TabId) => {
    setCurrentTab(tab);
    setViewingLabour(false);
    if (tab !== 'sites') {
      setActiveSiteId(null);
    }
  };

  const handleNavigateToSite = (siteId: string) => {
    setActiveSiteId(siteId);
    setCurrentTab('sites');
    setViewingLabour(false);
  };

  // Render active content
  let content: React.ReactNode;

  if (viewingLabour) {
    content = <LabourScreen />;
  } else if (currentTab === 'home') {
    content = (
      <DashboardScreen
        onNavigateToSite={handleNavigateToSite}
        onNavigateToTab={tab => handleSelectTab(tab)}
      />
    );
  } else if (currentTab === 'sites') {
    if (activeSiteId) {
      content = (
        <SiteDetailScreen
          siteId={activeSiteId}
          onBack={() => setActiveSiteId(null)}
        />
      );
    } else {
      content = <SitesScreen onSelectSite={handleNavigateToSite} />;
    }
  } else if (currentTab === 'attendance') {
    content = <AttendanceScreen />;
  } else if (currentTab === 'money') {
    content = <MoneyScreen />;
  } else if (currentTab === 'more') {
    content = (
      <MoreScreen
        onNavigateToLabour={() => setViewingLabour(true)}
        onOpenLogin={() => setAuthView('login')}
      />
    );
  }

  return (
    <AppShell currentTab={currentTab} onSelectTab={handleSelectTab}>
      {content}
    </AppShell>
  );
};
