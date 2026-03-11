import { useEffect, useState } from 'react';
import { getMe, getMyHistory, getTrack } from '../api/tracks';
import type { MeResponse, TrackDetails } from '../types';
import { TrackCard } from '../components/TrackCard';

async function hydrateHistory(trackIds: string[]) {
  const detailed = await Promise.allSettled(trackIds.map(async (trackId) => getTrack(trackId)));
  return detailed
    .filter((result): result is PromiseFulfilledResult<TrackDetails> => result.status === 'fulfilled')
    .map((result) => result.value);
}

export default function ProfilePage() {
  const [me, setMe] = useState<MeResponse | null>(null);
  const [history, setHistory] = useState<TrackDetails[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Promise.allSettled([getMe(), getMyHistory()]).then(async ([meRes, historyRes]) => {
      if (meRes.status === 'fulfilled') setMe(meRes.value);
      if (historyRes.status === 'fulfilled') {
        const hydrated = await hydrateHistory((historyRes.value.items ?? []).map((item) => item.trackId));
        setHistory(hydrated);
      }
      if (meRes.status === 'rejected') setError(meRes.reason?.message ?? 'Unable to load profile');
    });
  }, []);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-black tracking-tight">Profile</h1>
        <p className="mt-2 text-zinc-400">Your listening profile and recent sessions in one place.</p>
      </div>

      {error && <div className="rounded-2xl border border-red-500/30 bg-red-500/10 p-4 text-red-300">{error}</div>}

      <section className="rounded-3xl border border-spotify-border bg-black/20 p-5">
        <h2 className="text-lg font-semibold">Account</h2>
        <div className="mt-4 grid gap-4 sm:grid-cols-2">
          <div className="rounded-2xl bg-black/30 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Email</p>
            <p className="mt-2 text-base text-zinc-200">{String(me?.email ?? '—')}</p>
          </div>
          <div className="rounded-2xl bg-black/30 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Member ID</p>
            <p className="mt-2 truncate text-base text-zinc-200">{String(me?.sub ?? me?.username ?? '—')}</p>
          </div>
        </div>
      </section>

      <section className="space-y-5">
        <div>
          <h2 className="text-2xl font-bold">Listening history</h2>
          <p className="mt-1 text-sm text-zinc-400">Your latest sessions, ready to replay.</p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {history.map((track) => <TrackCard key={track.trackId} track={track} />)}
        </div>
      </section>
    </div>
  );
}
