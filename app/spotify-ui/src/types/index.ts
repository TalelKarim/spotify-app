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

export interface HistoryResponse {
  userId: string;
  items: SearchResult[];
}

export interface AnalyticsResponse {
  date: string;
  dailyPlays: number;
}

export interface MeResponse {
  sub?: string;
  email?: string;
  username?: string;
  [key: string]: unknown;
}

export interface CreateTrackResponse {
  trackId: string;
  audioUploadUrl: string;
  coverUploadUrl: string;
  audioKey: string;
  coverKey: string;
}
