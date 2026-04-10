import { Music4, Play, Heart } from 'lucide-react';
import { Link } from 'react-router-dom';
import type { SearchResult, TrackDetails } from '../types';
import { toMediaUrl } from '../lib/media';
import { usePlayer } from '../context/PlayerContext';
import { Surface } from './Surface';
import { Badge } from './Badge';
import { Label } from './Label';
import { useState } from 'react';

export function TrackCard({ track }: { track: SearchResult | TrackDetails }) {
  const { playTrack } = usePlayer();
  const coverUrl = toMediaUrl(track.coverKey ?? undefined, track.coverUrl ?? undefined);
  const [isFavorite, setIsFavorite] = useState(false);

  return (
    <article className="group h-full cursor-pointer">
      <Surface
        elevation="raised"
        background="dark"
        rounded="xl"
        padding="sm"
        className="h-full transform transition-all duration-300 ease-out hover:scale-[1.02] hover:shadow-elevated hover:bg-[#202020]"
      >
        {/* Image Container */}
        <div className="relative mb-4 aspect-square overflow-hidden rounded-lg bg-gradient-to-br from-spotify-green/10 to-black/50">
          {coverUrl ? (
            <img
              src={coverUrl}
              alt={track.title}
              className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110"
            />
          ) : (
            <div className="flex h-full w-full items-center justify-center bg-gradient-to-br from-[#202020] to-[#0F0F0F]">
              <Music4 className="h-12 w-12 text-zinc-600" />
            </div>
          )}

          {/* Gradient Overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent" />

          {/* Play & Favorite Buttons */}
          <div className="absolute inset-0 flex items-center justify-center gap-3 opacity-0 transition-opacity duration-300 group-hover:opacity-100">
            <button
              onClick={() => void playTrack(track)}
              className="flex h-14 w-14 items-center justify-center rounded-full bg-spotify-green text-black shadow-glow-green transition-all duration-200 hover:scale-110 active:scale-95"
              aria-label={`Play ${track.title}`}
            >
              <Play className="h-6 w-6 fill-current" />
            </button>

            <button
              onClick={() => setIsFavorite(!isFavorite)}
              className="flex h-12 w-12 items-center justify-center rounded-full bg-white/20 text-white transition-all duration-200 backdrop-blur-sm hover:bg-white/30 active:scale-95"
              aria-label={`Add ${track.title} to favorites`}
            >
              <Heart className={`h-5 w-5 ${isFavorite ? 'fill-current' : ''}`} />
            </button>
          </div>
        </div>

        {/* Content */}
        <Link to={`/tracks/${track.trackId}`} className="block">
          <Label variant="body" weight="semibold" className="line-clamp-2 hover:text-spotify-green transition-colors">
            {track.title}
          </Label>
          <Label variant="caption" color="secondary" className="mt-1 line-clamp-1 hover:text-white/80 transition-colors">
            {track.artist}
          </Label>
        </Link>

        {/* Stats */}
        <div className="mt-4 flex items-center justify-between gap-2">
          <Badge variant="default" size="sm">
            {track.plays ?? 0} plays
          </Badge>
          <Label variant="caption" color="muted">
            {track.duration ? `${Math.floor(track.duration / 60)}:${String(track.duration % 60).padStart(2, '0')}` : '--:--'}
          </Label>
        </div>
      </Surface>
    </article>
  );
}
