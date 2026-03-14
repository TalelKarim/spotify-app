import type { Tokens, UserProfile } from '../types';

const TOKENS_KEY = 'sym_tokens';
const USER_KEY = 'sym_user';
const PKCE_KEY = 'sym_pkce_verifier';

export function saveTokens(tokens: Tokens) {
  localStorage.setItem(TOKENS_KEY, JSON.stringify(tokens));
}

export function getTokens(): Tokens | null {
  const raw = localStorage.getItem(TOKENS_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as Tokens;
  } catch {
    return null;
  }
}

export function clearTokens() {
  localStorage.removeItem(TOKENS_KEY);
  localStorage.removeItem(USER_KEY);
  localStorage.removeItem(PKCE_KEY);
}

export function saveUser(user: UserProfile) {
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function getUser(): UserProfile | null {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as UserProfile;
  } catch {
    return null;
  }
}

export function savePkceVerifier(verifier: string) {
  localStorage.setItem(PKCE_KEY, verifier);
}

export function getPkceVerifier() {
  return localStorage.getItem(PKCE_KEY);
}

export function clearPkceVerifier() {
  localStorage.removeItem(PKCE_KEY);
}
