import { Pause, Play, Volume2, X, Music4 } from 'lucide-react';
import { usePlayer } from '../context/PlayerContext';
import { Surface } from './Surface';
import { Label } from './Label';
import { Button } from './Button';

function formatTime(value: number) {
  if (!Number.isFinite(value)) return '0:00';
  const minutes = Math.floor(value / 60);
  const seconds = Math.floor(value % 60);
  return `${minutes}:${String(seconds).padStart(2, '0')}`;
}

export function GlobalPlayer() {
  const { current, isPlaying, togglePlay, dismissPlayer, progress, duration, seekTo, setVolume, volume, audioRef } =
    usePlayer();

  return (
    <>
      <audio ref={audioRef} preload="metadata" />
      {current ? (
        <Surface
          elevation="floating"
          background="dark"
          rounded="3xl"
          padding="md"
          border={true}
          className="sticky bottom-0 z-30 mt-6 animate-slide-up"
        >
          <div className="grid gap-5 lg:grid-cols-[1.4fr_1fr_0.8fr] lg:items-center">
            {/* Track Info */}
            <div className="flex items-center gap-4">
              <div className="relative flex-shrink-0">
                {current.coverUrl ? (
                  <img
                    src={current.coverUrl}
                    alt={current.title}
                    className={`h-16 w-16 rounded-lg object-cover shadow-elevated ${isPlaying ? 'animate-pulse-soft' : ''}`}
                  />
                ) : (
                  <div className="h-16 w-16 rounded-lg bg-gradient-to-br from-spotify-green/20 to-black/40 flex items-center justify-center">
                    <Music4 className="h-8 w-8 text-spotify-green/50" />
                  </div>
                )}
                {isPlaying && (
                  <div className="absolute inset-0 rounded-lg ring-2 ring-spotify-green ring-offset-2 ring-offset-[#181818] animate-pulse" />
                )}
              </div>

              <div className="min-w-0 flex-1">
                <Label variant="body" weight="semibold" className="truncate block hover:text-spotify-green transition-colors">
                  {current.title}
                </Label>
                <Label variant="caption" color="secondary" className="truncate block mt-1">
                  {current.artist}
                </Label>

                {/* Progress Bar */}
                <div className="mt-3 space-y-2">
                  <input
                    type="range"
                    min={0}
                    max={Math.max(duration, 1)}
                    value={Math.min(progress, duration || 0)}
                    onChange={(e) => seekTo(Number(e.target.value))}
                    className="h-1.5 w-full cursor-pointer rounded-full bg-white/10 hover:bg-white/20 accent-spotify-green transition-all"
                  />
                  <div className="flex justify-between">
                    <Label variant="caption" color="muted" className="text-xs">
                      {formatTime(progress)}
                    </Label>
                    <Label variant="caption" color="muted" className="text-xs">
                      {formatTime(duration)}
                    </Label>
                  </div>
                </div>
              </div>
            </div>

            {/* Controls */}
            <div className="flex items-center justify-center gap-3">
              <Button variant="primary" size="md" onClick={togglePlay} className="w-fit">
                {isPlaying ? <Pause className="h-5 w-5 fill-current" /> : <Play className="h-5 w-5 fill-current" />}
              </Button>
              <Button variant="secondary" size="md" onClick={dismissPlayer} aria-label="Close player">
                <X className="h-5 w-5" />
              </Button>
            </div>

            {/* Volume Control */}
            <div className="flex items-center gap-3 justify-end">
              <Volume2 className="h-4 w-4 text-zinc-400 flex-shrink-0" />
              <div className="w-24 flex items-center gap-2">
                <input
                  type="range"
                  min={0}
                  max={1}
                  step={0.01}
                  value={volume}
                  onChange={(e) => setVolume(Number(e.target.value))}
                  className="h-1.5 flex-1 cursor-pointer rounded-full bg-white/10 hover:bg-white/20 accent-spotify-green transition-all"
                />
                <Label variant="caption" color="muted" className="w-6 text-right text-xs">
                  {Math.round(volume * 100)}%
                </Label>
              </div>
            </div>
          </div>
        </Surface>
      ) : null}
    </>
  );
}