import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { getTokens, getUser, clearTokens } from '../auth/storage';
import { logout as cognitoLogout, startLogin } from '../auth/cognito';
import type { UserProfile } from '../types';

interface AuthContextValue {
  isAuthenticated: boolean;
  user: UserProfile | null;
  isAdmin: boolean;
  login: () => Promise<void>;
  logout: () => void;
  setUserState: (user: UserProfile | null) => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserProfile | null>(null);

  useEffect(() => {
    if (getTokens()) {
      setUser(getUser());
    }
  }, []);

  const value = useMemo<AuthContextValue>(() => ({
    isAuthenticated: !!getTokens(),
    user,
    isAdmin: !!user?.groups.includes('admin'),
    login: startLogin,
    logout: () => {
      clearTokens();
      cognitoLogout();
    },
    setUserState: setUser,
  }), [user]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used within AuthProvider');
  return value;
}
