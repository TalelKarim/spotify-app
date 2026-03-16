import { useEffect, useState } from 'react';
import { Clock3, Headphones } from 'lucide-react';
import { getMe, getMyHistory, getTrack } from '../api/tracks';
import type { HistoryItem, MeResponse } from '../types';
import { toMediaUrl } from '../lib/media';

async function hydrateHistory(items: HistoryItem[]) {
  const missingTrackIds = Array.from(
    new Set(items.filter((item) => !item.title || !item.artist).map((item) => item.trackId))
  );

  if (missingTrackIds.length === 0) {
    return items;
  }

  const detailed = await Promise.allSettled(missingTrackIds.map(async (trackId) => getTrack(trackId)));

  const map = new Map(
    detailed
      .filter((result): result is PromiseFulfilledResult<Awaited<ReturnType<typeof getTrack>>> => result.status === 'fulfilled')
      .map((result) => [
        result.value.trackId,
        {
          title: result.value.title,
          artist: result.value.artist,
          coverUrl: toMediaUrl(result.value.coverKey ?? undefined, result.value.coverUrl ?? undefined),
        },
      ])
  );

  return items.map((item) => {
    const hydrated = map.get(item.trackId);
    if (!hydrated) return item;

    return {
      ...item,
      title: item.title ?? hydrated.title,
      artist: item.artist ?? hydrated.artist,
      coverUrl: item.coverUrl ?? hydrated.coverUrl,
    };
  });
}

function formatPlayedAt(value: string) {
  if (!value) return 'Recently played';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;

  return new Intl.DateTimeFormat('en-GB', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date);
}

export default function ProfilePage() {
  const [me, setMe] = useState<MeResponse | null>(null);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    Promise.allSettled([getMe(), getMyHistory(24)]).then(async ([meRes, historyRes]) => {
      if (cancelled) return;

      if (meRes.status === 'fulfilled') setMe(meRes.value);
      if (historyRes.status === 'fulfilled') {
        const hydrated = await hydrateHistory(historyRes.value.items ?? []);
        if (!cancelled) setHistory(hydrated);
      }
      if (meRes.status === 'rejected') setError(meRes.reason?.message ?? 'Unable to load profile');
    });

    return () => {
      cancelled = true;
    };
  }, []);

  const rawMemberId = me?.userId ?? me?.sub ?? me?.username ?? '';
  const memberId = rawMemberId ? rawMemberId.split('-')[0] : '—';

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-black tracking-tight">Profile</h1>
        <p className="mt-2 text-zinc-400">Your account and your full listening timeline, all in one place.</p>
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
            <p className="mt-2 text-base text-zinc-200">{memberId}</p>
          </div>
        </div>
      </section>

      <section className="space-y-5">
        <div>
          <h2 className="text-2xl font-bold">Listening history</h2>
          <p className="mt-1 text-sm text-zinc-400">A chronological record of every session, including repeats.</p>
        </div>

        {history.length === 0 ? (
          <div className="rounded-3xl border border-dashed border-spotify-border p-10 text-center text-zinc-400">
            Your listening timeline will appear here once you start playing tracks.
          </div>
        ) : (
          <div className="overflow-hidden rounded-[1.75rem] border border-white/8 bg-[#181818]">
            <ul className="divide-y divide-white/5">
              {history.map((item, index) => {
                const coverUrl = toMediaUrl(undefined, item.coverUrl ?? undefined);
                return (
                  <li key={`${item.trackId}-${item.playedAt}-${index}`} className="flex items-center gap-4 px-4 py-4 transition hover:bg-white/[0.03] sm:px-5">
                    {coverUrl ? (
                      <img src={coverUrl} alt={item.title ?? 'Track cover'} className="h-14 w-14 rounded-2xl object-cover" />
                    ) : (
                      <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-[#202020] text-zinc-500">
                        <Headphones className="h-5 w-5" />
                      </div>
                    )}

                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm font-semibold text-white">{item.title ?? 'Unavailable track'}</p>
                      <p className="truncate text-sm text-zinc-400">{item.artist ?? 'Unknown artist'}</p>
                    </div>

                    <div className="hidden items-center gap-2 text-xs text-zinc-500 sm:flex">
                      <Clock3 className="h-3.5 w-3.5" />
                      <span>{formatPlayedAt(item.playedAt)}</span>
                    </div>
                  </li>
                );
              })}
            </ul>
          </div>
        )}
      </section>
    </div>
  );
}