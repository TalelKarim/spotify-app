import { Pause, Play, Volume2, X } from 'lucide-react';
import { usePlayer } from '../context/PlayerContext';

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
        <div className="sticky bottom-0 z-30 mt-6 rounded-3xl border border-white/10 bg-black/75 p-4 backdrop-blur-xl shadow-2xl">
          <div className="grid gap-4 lg:grid-cols-[1.3fr_1fr] lg:items-center">
            <div className="flex items-center gap-4">
              {current.coverUrl ? (
                <img src={current.coverUrl} alt={current.title} className="h-16 w-16 rounded-2xl object-cover" />
              ) : (
                <div className="h-16 w-16 rounded-2xl bg-[#202020]" />
              )}
              <div className="min-w-0 flex-1">
                <p className="truncate text-base font-semibold">{current.title}</p>
                <p className="truncate text-sm text-zinc-400">{current.artist}</p>
                <div className="mt-3 flex items-center gap-3">
                  <button
                    onClick={togglePlay}
                    className="inline-flex h-11 w-11 items-center justify-center rounded-full bg-spotify-green text-black"
                  >
                    {isPlaying ? <Pause className="h-5 w-5 fill-current" /> : <Play className="h-5 w-5 fill-current" />}
                  </button>
                  <button
                    onClick={dismissPlayer}
                    aria-label="Close player"
                    className="inline-flex h-11 w-11 items-center justify-center rounded-full border border-white/10 bg-white/5 text-zinc-200 transition hover:bg-white/10"
                  >
                    <X className="h-5 w-5" />
                  </button>
                  <div className="w-full">
                    <input
                      type="range"
                      min={0}
                      max={Math.max(duration, 1)}
                      value={Math.min(progress, duration || 0)}
                      onChange={(e) => seekTo(Number(e.target.value))}
                      className="h-2 w-full cursor-pointer rounded-full bg-zinc-800"
                    />
                    <div className="mt-1 flex justify-between text-xs text-zinc-500">
                      <span>{formatTime(progress)}</span>
                      <span>{formatTime(duration)}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex items-center gap-3 lg:justify-end">
              <Volume2 className="h-4 w-4 text-zinc-400" />
              <input
                type="range"
                min={0}
                max={1}
                step={0.01}
                value={volume}
                onChange={(e) => setVolume(Number(e.target.value))}
                className="h-2 w-full max-w-40 cursor-pointer rounded-full bg-zinc-800"
              />
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}