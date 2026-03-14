import { env } from './env';

const base = `https://${env.mediaCdnDomain}`;

export function toMediaUrl(key?: string | null, explicitUrl?: string | null) {
  if (explicitUrl) return explicitUrl;
  if (!key) return null;
  return `${base}/${key}`;
}
