import { jwtDecode } from 'jwt-decode';
import { env } from '../lib/env';
import { createPkcePair } from '../lib/pkce';
import { clearPkceVerifier, getPkceVerifier, savePkceVerifier, saveTokens, saveUser, getTokens } from './storage';
import type { Tokens, UserProfile } from '../types';

interface JwtPayload {
  sub?: string;
  email?: string;
  name?: string;
  'cognito:groups'?: string[] | string;
  exp?: number;
}

export function parseUserFromIdToken(idToken: string): UserProfile {
  const decoded = jwtDecode<JwtPayload>(idToken);
  const rawGroups = decoded['cognito:groups'];
  const groups = Array.isArray(rawGroups)
    ? rawGroups
    : rawGroups
      ? String(rawGroups).split(',').map((g) => g.trim()).filter(Boolean)
      : [];

  return {
    sub: decoded.sub,
    email: decoded.email,
    name: decoded.name,
    groups,
  };
}

export async function startLogin() {
  const { verifier, challenge } = await createPkcePair();
  savePkceVerifier(verifier);

  const params = new URLSearchParams({
    response_type: 'code',
    client_id: env.cognitoClientId,
    redirect_uri: env.cognitoRedirectUri,
    scope: 'openid email profile',
    code_challenge_method: 'S256',
    code_challenge: challenge,
  });

  window.location.assign(`${env.cognitoDomain}/oauth2/authorize?${params.toString()}`);
}

export async function exchangeCodeForTokens(code: string): Promise<Tokens> {
  const verifier = getPkceVerifier();
  if (!verifier) throw new Error('Missing PKCE verifier in local storage. Please login again.');

  const body = new URLSearchParams({
    grant_type: 'authorization_code',
    client_id: env.cognitoClientId,
    code,
    redirect_uri: env.cognitoRedirectUri,
    code_verifier: verifier,
  });

  const res = await fetch(`${env.cognitoDomain}/oauth2/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body.toString(),
  });

  if (!res.ok) {
    throw new Error('Unable to exchange OAuth code for tokens.');
  }

  const json = await res.json();

  const tokens: Tokens = {
    accessToken: json.access_token,
    idToken: json.id_token,
    refreshToken: json.refresh_token,
    expiresAt: Date.now() + (json.expires_in ?? 3600) * 1000,
  };

  saveTokens(tokens);
  saveUser(parseUserFromIdToken(tokens.idToken));
  clearPkceVerifier();
  return tokens;
}

export function isTokenExpired(tokens: Tokens | null) {
  if (!tokens) return true;
  return Date.now() >= tokens.expiresAt - 30_000;
}

export async function refreshTokensIfNeeded() {
  const tokens = getTokens();
  if (!tokens || !tokens.refreshToken || !isTokenExpired(tokens)) return tokens;

  const body = new URLSearchParams({
    grant_type: 'refresh_token',
    client_id: env.cognitoClientId,
    refresh_token: tokens.refreshToken,
  });

  const res = await fetch(`${env.cognitoDomain}/oauth2/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body.toString(),
  });

  if (!res.ok) {
    return null;
  }

  const json = await res.json();
  const next: Tokens = {
    accessToken: json.access_token ?? tokens.accessToken,
    idToken: json.id_token ?? tokens.idToken,
    refreshToken: tokens.refreshToken,
    expiresAt: Date.now() + (json.expires_in ?? 3600) * 1000,
  };

  saveTokens(next);
  saveUser(parseUserFromIdToken(next.idToken));
  return next;
}

export function logout() {
  const params = new URLSearchParams({
    client_id: env.cognitoClientId,
    logout_uri: env.cognitoLogoutUri,
  });

  window.location.assign(`${env.cognitoDomain}/logout?${params.toString()}`);
}
