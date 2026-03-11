import { Music4, Play } from 'lucide-react';
import { Link } from 'react-router-dom';
import type { SearchResult, TrackDetails } from '../types';
import { toMediaUrl } from '../lib/media';
import { usePlayer } from '../context/PlayerContext';

export function TrackCard({ track }: { track: SearchResult | TrackDetails }) {
  const { playTrack } = usePlayer();
  const coverUrl = toMediaUrl(track.coverKey ?? undefined, track.coverUrl ?? undefined);

  return (
    <article className="group overflow-hidden rounded-[1.75rem] border border-white/6 bg-[#181818] p-3 transition duration-300 hover:-translate-y-1 hover:border-white/12 hover:bg-[#202020] hover:shadow-2xl">
      <div className="relative mb-4 aspect-square overflow-hidden rounded-2xl bg-black/40">
        {coverUrl ? (
          <img src={coverUrl} alt={track.title} className="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-[#202020] text-zinc-500">
            <Music4 className="h-14 w-14" />
          </div>
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/10 to-transparent" />
        <button
          onClick={() => void playTrack(track)}
          className="absolute bottom-3 right-3 inline-flex h-12 w-12 translate-y-3 items-center justify-center rounded-full bg-spotify-green text-black opacity-0 shadow-lg transition group-hover:translate-y-0 group-hover:opacity-100"
          aria-label={`Play ${track.title}`}
        >
          <Play className="h-5 w-5 fill-current" />
        </button>
      </div>

      <Link to={`/tracks/${track.trackId}`} className="block">
        <h3 className="truncate text-base font-semibold text-white">{track.title}</h3>
        <p className="mt-1 truncate text-sm text-zinc-400">{track.artist}</p>
      </Link>

      <div className="mt-4 flex items-center justify-between text-xs text-zinc-500">
        <span>{track.plays ?? 0} plays</span>
        <span>{track.duration ? `${Math.floor(track.duration / 60)}:${String(track.duration % 60).padStart(2, '0')}` : '--:--'}</span>
      </div>
    </article>
  );
}
