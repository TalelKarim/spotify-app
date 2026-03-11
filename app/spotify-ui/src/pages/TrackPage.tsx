import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getTrack, getTrackStats } from '../api/tracks';
import type { TrackDetails } from '../types';
import { usePlayer } from '../context/PlayerContext';
import { toMediaUrl } from '../lib/media';

export default function TrackPage() {
  const { trackId = '' } = useParams();
  const { playTrack } = usePlayer();
  const [track, setTrack] = useState<TrackDetails | null>(null);
  const [stats, setStats] = useState<Record<string, unknown> | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!trackId) return;
    Promise.allSettled([getTrack(trackId), getTrackStats(trackId)]).then(([trackRes, statsRes]) => {
      if (trackRes.status === 'fulfilled') setTrack(trackRes.value);
      if (statsRes.status === 'fulfilled') setStats(statsRes.value);
      if (trackRes.status === 'rejected') setError(trackRes.reason?.message ?? 'Unable to load track.');
    });
  }, [trackId]);

  if (error) {
    return <div className="rounded-2xl border border-red-500/30 bg-red-500/10 p-4 text-red-300">{error}</div>;
  }

  if (!track) {
    return <div className="text-zinc-400">Loading track...</div>;
  }

  const coverUrl = toMediaUrl(track.coverKey ?? undefined, track.coverUrl ?? undefined);
  const lastPlayedAt = typeof stats?.lastPlayedAt === 'string' ? stats.lastPlayedAt : null;

  return (
    <div className="space-y-8">
      <div className="grid gap-8 lg:grid-cols-[360px_1fr] lg:items-end">
        <div className="overflow-hidden rounded-[2rem] border border-spotify-border bg-[#1A1A1A] shadow-soft">
          {coverUrl ? (
            <img src={coverUrl} alt={track.title} className="aspect-square w-full object-cover" />
          ) : (
            <div className="aspect-square w-full bg-[#202020]" />
          )}
        </div>
        <div>
          <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Now playing</p>
          <h1 className="mt-3 text-5xl font-black tracking-tight">{track.title}</h1>
          <p className="mt-3 text-lg text-zinc-300">{track.artist}</p>
          <div className="mt-6 flex flex-wrap gap-3 text-sm text-zinc-400">
            <span className="rounded-full bg-white/5 px-4 py-2">{track.plays ?? 0} plays</span>
            <span className="rounded-full bg-white/5 px-4 py-2">{track.duration ?? 0} sec</span>
            {lastPlayedAt && <span className="rounded-full bg-white/5 px-4 py-2">Last play {lastPlayedAt}</span>}
          </div>
          <div className="mt-8 flex gap-3">
            <button
              onClick={() => void playTrack(track)}
              className="rounded-full bg-spotify-green px-6 py-3 font-semibold text-black"
            >
              Play track
            </button>
          </div>
        </div>
      </div>

      <section className="rounded-3xl border border-spotify-border bg-black/20 p-5">
        <h2 className="text-lg font-semibold">About this track</h2>
        <div className="mt-4 grid gap-4 sm:grid-cols-2">
          <div className="rounded-2xl bg-black/30 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Artist</p>
            <p className="mt-2 text-base text-zinc-200">{track.artist}</p>
          </div>
          <div className="rounded-2xl bg-black/30 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Duration</p>
            <p className="mt-2 text-base text-zinc-200">{track.duration ?? 0} seconds</p>
          </div>
        </div>
      </section>
    </div>
  );
}
