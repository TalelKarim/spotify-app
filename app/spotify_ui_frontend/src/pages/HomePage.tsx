import { useEffect, useState } from 'react';
import { getGlobalAnalytics, getMyHistory, getRecentlyPlayed, getTrack, listTracks } from '../api/tracks';
import { Section } from '../components/Section';
import { TrackCard } from '../components/TrackCard';
import type { AnalyticsResponse, RecentlyPlayedItem, SearchResult, TrackDetails } from '../types';
import { useAuth } from '../context/AuthContext';
import { toMediaUrl } from '../lib/media';

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

  return (
    <div className="space-y-10">
      <section className="relative overflow-hidden rounded-[2rem] border border-white/8 bg-[radial-gradient(circle_at_top_left,_rgba(29,185,84,0.35),_transparent_35%),linear-gradient(135deg,#181818_0%,#121212_55%,#0d0d0d_100%)] p-8 lg:p-10">
        <div className="absolute -right-20 top-0 h-56 w-56 rounded-full bg-spotify-green/20 blur-3xl" />
        <div className="relative max-w-3xl">
          <p className="text-sm font-medium uppercase tracking-[0.25em] text-zinc-300">Featured today</p>
          <h1 className="mt-4 text-4xl font-black leading-tight lg:text-6xl">
            Find your next favorite track in one place.
          </h1>
          <p className="mt-4 max-w-2xl text-base text-zinc-300 lg:text-lg">
            Fresh releases, effortless playback and a clean listening experience designed for real music lovers.
          </p>
        </div>
        <div className="relative mt-8 grid gap-4 sm:grid-cols-3">
          <div className="rounded-2xl border border-white/10 bg-black/25 p-4 backdrop-blur-sm">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Available tracks</p>
            <p className="mt-2 text-2xl font-bold">{tracks.length}</p>
          </div>
          <div className="rounded-2xl border border-white/10 bg-black/25 p-4 backdrop-blur-sm">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Plays today</p>
            <p className="mt-2 text-2xl font-bold">{analytics?.dailyPlays ?? 0}</p>
          </div>
          <div className="rounded-2xl border border-white/10 bg-black/25 p-4 backdrop-blur-sm">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Recently played</p>
            <p className="mt-2 text-2xl font-bold">{recentlyPlayed.length}</p>
          </div>
        </div>
      </section>

      {error && <div className="rounded-2xl border border-red-500/30 bg-red-500/10 p-4 text-sm text-red-300">{error}</div>}

      {isAuthenticated && recentlyPlayed.length > 0 && (
        <Section title="Recently played" subtitle="A cleaner snapshot of what you've had on repeat.">
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {recentlyPlayed.map((track) => <TrackCard key={track.trackId} track={track} />)}
          </div>
        </Section>
      )}

      <Section title="Fresh on the platform" subtitle="New music ready to play now.">
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {tracks.slice(0, 8).map((track) => <TrackCard key={track.trackId} track={track} />)}
        </div>
      </Section>
    </div>
  );
}
