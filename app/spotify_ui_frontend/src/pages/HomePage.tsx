import { useEffect, useState } from 'react';
import { getGlobalAnalytics, getMyHistory, getRecentlyPlayed, getTrack, listTracks } from '../api/tracks';
import { Section } from '../components/Section';
import { TrackCard } from '../components/TrackCard';
import { Surface } from '../components/Surface';
import { Label } from '../components/Label';
import { Badge } from '../components/Badge';
import type { AnalyticsResponse, RecentlyPlayedItem, SearchResult, TrackDetails } from '../types';
import { useAuth } from '../context/AuthContext';
import { toMediaUrl } from '../lib/media';
import { TrendingUp, Music, Radio } from 'lucide-react';

async function hydrateHistoryFallback(items: { trackId: string; playedAt?: string }[]) {
  const detailed = await Promise.allSettled(items.slice(0, 8).map(async (item) => getTrack(item.trackId)));

  return detailed
    .filter((result): result is PromiseFulfilledResult<TrackDetails> => result.status === 'fulfilled')
    .map((result, index) => ({
      trackId: result.value.trackId,
      title: result.value.title,
      artist: result.value.artist,
      coverUrl: toMediaUrl(result.value.coverKey ?? undefined, result.value.coverUrl ?? undefined),
      playedAt: items[index]?.playedAt ?? '',
    }));
}

export default function HomePage() {
  const { isAuthenticated } = useAuth();
  const [tracks, setTracks] = useState<SearchResult[]>([]);
  const [recentlyPlayed, setRecentlyPlayed] = useState<RecentlyPlayedItem[]>([]);
  const [analytics, setAnalytics] = useState<AnalyticsResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function loadHome() {
      const [tracksRes, analyticsRes] = await Promise.allSettled([listTracks(), getGlobalAnalytics()]);

      if (!cancelled && tracksRes.status === 'fulfilled') setTracks(tracksRes.value.items ?? []);
      if (!cancelled && analyticsRes.status === 'fulfilled') setAnalytics(analyticsRes.value);

      if (isAuthenticated) {
        try {
          const recent = await getRecentlyPlayed(8);
          if (!cancelled) setRecentlyPlayed(recent.items ?? []);
        } catch {
          try {
            const history = await getMyHistory(12);
            const fallback = await hydrateHistoryFallback(history.items ?? []);
            if (!cancelled) setRecentlyPlayed(fallback);
          } catch {
            // ignore personalized block failure while the rest of the page still loads
          }
        }
      }

      if (!cancelled && tracksRes.status === 'rejected' && analyticsRes.status === 'rejected') {
        setError('Unable to load the home page right now.');
      }
    }

    void loadHome();

    return () => {
      cancelled = true;
    };
  }, [isAuthenticated]);

  const stats = [
    {
      icon: Music,
      label: 'Available Tracks',
      value: tracks.length,
      variant: 'default' as const,
    },
    {
      icon: TrendingUp,
      label: 'Plays Today',
      value: analytics?.dailyPlays ?? 0,
      variant: 'success' as const,
    },
    {
      icon: Radio,
      label: 'Recently Played',
      value: recentlyPlayed.length,
      variant: 'info' as const,
    },
  ];

  return (
    <div className="space-y-10">
      {/* Hero Section */}
      <Surface
        elevation="elevated"
        background="gradient"
        rounded="3xl"
        padding="xl"
        border={true}
        className="relative overflow-hidden"
      >
        {/* Background decorative elements */}
        <div className="absolute -right-32 top-0 h-72 w-72 rounded-full bg-spotify-green/15 blur-3xl" />
        <div className="absolute -left-40 -bottom-40 h-80 w-80 rounded-full bg-spotify-cyan/5 blur-3xl" />

        <div className="relative z-10">
          {/* Header */}
          <div className="max-w-3xl">
            <Badge variant="default" size="sm" className="inline-flex">
              ✨ Featured Today
            </Badge>

            <Label variant="heading" weight="bold" className="mt-4 block">
              Find Your Next Favorite Track
            </Label>

            <Label variant="body" color="secondary" className="mt-4 block max-w-2xl">
              Discover fresh releases, enjoy seamless playback, and experience a refined listening environment designed for true music enthusiasts.
            </Label>
          </div>

          {/* Stats Grid */}
          <div className="mt-8 grid gap-4 sm:grid-cols-3">
            {stats.map(({ icon: Icon, label, value, variant }) => (
              <Surface
                key={label}
                elevation="raised"
                background="dark"
                rounded="xl"
                padding="md"
                border={true}
                className="group transition-transform duration-300 hover:translate-y-[-2px]"
              >
                <div className="flex items-start justify-between">
                  <div>
                    <Label variant="caption" color="muted" weight="semibold" className="uppercase block">
                      {label}
                    </Label>
                    <Label variant="3xl" weight="bold" className="mt-2 block">
                      {value.toLocaleString()}
                    </Label>
                  </div>
                  <div
                    className={`rounded-lg p-3 ${
                      variant === 'default'
                        ? 'bg-spotify-green/10 text-spotify-green'
                        : variant === 'success'
                          ? 'bg-emerald-500/10 text-emerald-400'
                          : 'bg-blue-500/10 text-blue-400'
                    }`}
                  >
                    <Icon className="h-5 w-5" />
                  </div>
                </div>
              </Surface>
            ))}
          </div>
        </div>
      </Surface>

      {/* Error State */}
      {error && (
        <Surface elevation="raised" background="dark" rounded="xl" padding="md" border={true} className="border-red-500/30 bg-red-500/10">
          <Label color="danger">{error}</Label>
        </Surface>
      )}

      {/* Recently Played Section */}
      {isAuthenticated && recentlyPlayed.length > 0 && (
        <Section title="Recently Played" subtitle={`${recentlyPlayed.length} tracks from your history`}>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {recentlyPlayed.map((track) => <TrackCard key={track.trackId} track={track} />)}
          </div>
        </Section>
      )}

      {/* Fresh Tracks Section */}
      <Section
        title="Fresh on the Platform"
        subtitle={`${Math.min(8, tracks.length)} new tracks available`}
      >
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {tracks.slice(0, 8).map((track) => (
            <TrackCard key={track.trackId} track={track} />
          ))}
        </div>
      </Section>
    </div>
  );
}
