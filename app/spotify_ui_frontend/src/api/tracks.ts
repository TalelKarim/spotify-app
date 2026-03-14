import { apiFetch } from './client';
import type {
  AnalyticsResponse,
  CreateTrackPayload,
  CreateTrackResponse,
  HistoryResponse,
  MeResponse,
  RecentlyPlayedResponse,
  SearchResult,
  TrackDetails,
  TracksListResponse,
} from '../types';

export async function listTracks() {
  return apiFetch<TracksListResponse>('/tracks');
}

export async function getTrack(trackId: string) {
  return apiFetch<TrackDetails>(`/tracks/${trackId}`);
}

export async function getTrackStats(trackId: string) {
  return apiFetch<Record<string, unknown>>(`/tracks/${trackId}/stats`);
}

export async function registerPlay(trackId: string) {
  return apiFetch<Record<string, unknown>>(`/tracks/${trackId}/play`, {
    method: 'POST',
  });
}

export async function createTrack(payload: CreateTrackPayload) {
  return apiFetch<CreateTrackResponse>('/tracks', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}

export async function uploadToPresignedUrl(url: string, file: File) {
  const res = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': file.type,
    },
    body: file,
  });

  if (!res.ok) {
    throw new Error(`Upload failed (${res.status})`);
  }
}

export async function getMe() {
  return apiFetch<MeResponse>('/me');
}

export async function getMyHistory(limit = 24) {
  return apiFetch<HistoryResponse>(`/me/listening/history?limit=${limit}`);
}

export async function getRecentlyPlayed(limit = 8) {
  return apiFetch<RecentlyPlayedResponse>(`/me/recently-played?limit=${limit}`);
}

export async function getGlobalAnalytics() {
  return apiFetch<AnalyticsResponse>('/analytics/global');
}
