import { env } from '../lib/env';
import { refreshTokensIfNeeded } from '../auth/cognito';
import { getTokens } from '../auth/storage';

export async function apiFetch<T>(path: string, init: RequestInit = {}): Promise<T> {
  await refreshTokensIfNeeded();
  const tokens = getTokens();
  const authToken = env.apiTokenSource === 'access' ? tokens?.accessToken : tokens?.idToken;

  const headers = new Headers(init.headers || {});
  if (!headers.has('Content-Type') && init.body && !(init.body instanceof FormData) && typeof init.body !== 'string') {
    headers.set('Content-Type', 'application/json');
  }
  if (authToken) headers.set('Authorization', `Bearer ${authToken}`);

  const res = await fetch(`${env.apiUrl}${path}`, {
    ...init,
    headers,
  });

  const text = await res.text();
  const data = text ? JSON.parse(text) : null;

  if (!res.ok) {
    const message = data?.error || data?.message || 'API request failed';
    throw new Error(message);
  }

  return data as T;
}
