export type TokenSource = 'id' | 'access';

export interface Tokens {
  accessToken: string;
  idToken: string;
  refreshToken?: string;
  expiresAt: number;
}

export interface UserProfile {
  sub?: string;
  email?: string;
  name?: string;
  groups: string[];
}

export interface SearchResult {
  trackId: string;
  title: string;
  artist: string;
  duration?: number;
  plays?: number;
  status?: string;
  objectKey?: string | null;
  coverKey?: string | null;
  audioUrl?: string | null;
  coverUrl?: string | null;
  highlights?: {
    title?: string[];
    artist?: string[];
  };
}

export interface SearchResponse {
  q: string;
  total: number;
  offset: number;
  limit: number;
  sort: string;
  results: SearchResult[];
}

export interface TrackDetails {
  trackId: string;
  title: string;
  artist: string;
  duration?: number;
  plays?: number;
  audioUrl?: string | null;
  coverUrl?: string | null;
  objectKey?: string | null;
  coverKey?: string | null;
}

export interface TracksListResponse {
  items: SearchResult[];
  nextCursor?: string | null;
}

export interface HistoryItem {
  trackId: string;
  playedAt: string;
  title?: string | null;
  artist?: string | null;
  coverUrl?: string | null;
  metadata?: Record<string, unknown>;
}

export interface HistoryResponse {
  userId: string;
  items: HistoryItem[];
}

export interface RecentlyPlayedItem {
  trackId: string;
  title: string;
  artist: string;
  coverUrl?: string | null;
  playedAt: string;
  plays?: number;
  duration?: number;
}

export interface RecentlyPlayedResponse {
  userId: string;
  items: RecentlyPlayedItem[];
}

export interface AnalyticsResponse {
  date: string;
  dailyPlays: number;
}

export interface MeResponse {
  userId?: string;
  sub?: string;
  email?: string;
  username?: string;
  [key: string]: unknown;
}
export interface CreateTrackPayload {
  title: string;
  artist: string;
  coverContentType: string;
  audioHash: string;
}

export interface CreateTrackResponse {
  trackId: string;
  audioUploadUrl: string;
  coverUploadUrl: string;
  audioKey: string;
  coverKey: string;
}
