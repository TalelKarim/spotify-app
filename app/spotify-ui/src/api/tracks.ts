import { apiFetch } from './client';
import type {
  CreateTrackResponse,
  SearchResult,
  TrackDetails,
  TracksListResponse,
  AnalyticsResponse,
  HistoryResponse,
  MeResponse,
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

export async function createTrack(payload: {
  title: string;
  artist: string;
  duration: number;
  coverContentType: string;
}) {
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

export async function getMyHistory() {
  return apiFetch<HistoryResponse>('/me/listening/history');
}

export async function getGlobalAnalytics() {
  return apiFetch<AnalyticsResponse>('/analytics/global');
}
