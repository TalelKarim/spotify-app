import { apiFetch } from './client';
import type { SearchResponse } from '../types';

export async function searchTracks(query: string, options?: { limit?: number; offset?: number; sort?: string; }) {
  const params = new URLSearchParams({ q: query });
  if (options?.limit) params.set('limit', String(options.limit));
  if (options?.offset) params.set('offset', String(options.offset));
  if (options?.sort) params.set('sort', options.sort);

  return apiFetch<SearchResponse>(`/search?${params.toString()}`);
}
