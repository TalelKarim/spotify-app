import { createContext, useContext, useMemo, useRef, useState } from 'react';
import { getTrack, registerPlay } from '../api/tracks';
import type { SearchResult, TrackDetails } from '../types';
import { toMediaUrl } from '../lib/media';

export interface NowPlaying {
  trackId: string;
  title: string;
  artist: string;
  audioUrl: string;
  coverUrl?: string | null;
}

interface PlayerContextValue {
  current: NowPlaying | null;
  isPlaying: boolean;
  progress: number;
  duration: number;
  playTrack: (track: SearchResult | TrackDetails) => Promise<void>;
  togglePlay: () => void;
  dismissPlayer: () => void;
  seekTo: (seconds: number) => void;
  setVolume: (volume: number) => void;
  volume: number;
  audioRef: React.RefObject<HTMLAudioElement>;
}

const PlayerContext = createContext<PlayerContextValue | undefined>(undefined);

export function PlayerProvider({ children }: { children: React.ReactNode }) {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [current, setCurrent] = useState<NowPlaying | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolumeState] = useState(0.8);

  const bindAudioEvents = () => {
    const audio = audioRef.current;
    if (!audio) return;
    audio.onended = () => setIsPlaying(false);
    audio.ontimeupdate = () => setProgress(audio.currentTime);
    audio.onloadedmetadata = () => setDuration(audio.duration || 0);
  };

  const playTrack = async (track: SearchResult | TrackDetails) => {
    let sourceTrack: SearchResult | TrackDetails = track;
    let audioUrl = toMediaUrl(track.objectKey ?? undefined, track.audioUrl ?? undefined);

    if (!audioUrl && track.trackId) {
      const detailedTrack = await getTrack(track.trackId);
      sourceTrack = detailedTrack;
      audioUrl = toMediaUrl(detailedTrack.objectKey ?? undefined, detailedTrack.audioUrl ?? undefined);
    }

    if (!audioUrl) return;

    const next: NowPlaying = {
      trackId: sourceTrack.trackId,
      title: sourceTrack.title,
      artist: sourceTrack.artist,
      audioUrl,
      coverUrl: toMediaUrl(sourceTrack.coverKey ?? undefined, sourceTrack.coverUrl ?? undefined),
    };

    setCurrent(next);

    requestAnimationFrame(() => {
      const audio = audioRef.current;
      if (!audio) return;
      if (audio.src !== audioUrl) {
        audio.src = audioUrl;
        setProgress(0);
      }
      audio.volume = volume;
      bindAudioEvents();
      audio
        .play()
        .then(() => {
          setIsPlaying(true);
          registerPlay(next.trackId).catch(() => undefined);
        })
        .catch(() => setIsPlaying(false));
    });
  };

  const togglePlay = () => {
    const audio = audioRef.current;
    if (!audio || !current) return;
    if (audio.paused) {
      audio.play();
      setIsPlaying(true);
    } else {
      audio.pause();
      setIsPlaying(false);
    }
  };

  const dismissPlayer = () => {
    const audio = audioRef.current;
    if (audio) {
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
    }
    setIsPlaying(false);
    setProgress(0);
    setDuration(0);
    setCurrent(null);
  };

  const seekTo = (seconds: number) => {
    const audio = audioRef.current;
    if (!audio) return;
    audio.currentTime = seconds;
    setProgress(seconds);
  };

  const setVolume = (next: number) => {
    const audio = audioRef.current;
    setVolumeState(next);
    if (audio) audio.volume = next;
  };

  const value = useMemo(
    () => ({
      current,
      isPlaying,
      progress,
      duration,
      playTrack,
      togglePlay,
      dismissPlayer,
      seekTo,
      setVolume,
      volume,
      audioRef,
    }),
    [current, isPlaying, progress, duration, volume]
  );

  return <PlayerContext.Provider value={value}>{children}</PlayerContext.Provider>;
}

export function usePlayer() {
  const value = useContext(PlayerContext);
  if (!value) throw new Error('usePlayer must be used within PlayerProvider');
  return value;
}