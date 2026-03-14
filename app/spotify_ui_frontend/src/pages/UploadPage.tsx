import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { createTrack, getTrack, uploadToPresignedUrl } from '../api/tracks';

async function computeSha256(file: File) {
  const buffer = await file.arrayBuffer();
  const digest = await crypto.subtle.digest('SHA-256', buffer);
  const bytes = Array.from(new Uint8Array(digest));
  return bytes.map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

export default function UploadPage() {
  const navigate = useNavigate();

  const [title, setTitle] = useState('');
  const [artist, setArtist] = useState('');
  const [duration, setDuration] = useState(180);
  const [audioFile, setAudioFile] = useState<File | null>(null);
  const [coverFile, setCoverFile] = useState<File | null>(null);
  const [status, setStatus] = useState<string>('');
  const [submitting, setSubmitting] = useState(false);
  const [trackId, setTrackId] = useState<string | null>(null);

  const canSubmit = useMemo(
    () => !!title && !!artist && !!audioFile && !!coverFile && !submitting,
    [title, artist, audioFile, coverFile, submitting]
  );

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    if (!audioFile || !coverFile) return;

    try {
      setSubmitting(true);
      setStatus('Checking your audio fingerprint...');

      const audioHash = await computeSha256(audioFile);

      setStatus('Creating your release...');

      const created = await createTrack({
        title,
        artist,
        duration,
        coverContentType: coverFile.type,
        audioHash,
      });

      setTrackId(created.trackId);

      setStatus('Uploading audio...');
      await uploadToPresignedUrl(created.audioUploadUrl, audioFile);

      setStatus('Uploading artwork...');
      await uploadToPresignedUrl(created.coverUploadUrl, coverFile);

      setStatus('Finishing your release...');

      const maxTries = 12;

      for (let i = 0; i < maxTries; i += 1) {
        await new Promise((resolve) => setTimeout(resolve, 5000));

        try {
          await getTrack(created.trackId);
          setStatus('Your track is live and ready to share.');
          setSubmitting(false);
          setTimeout(() => navigate('/'), 1000);
          return;
        } catch {
          setStatus(`Final touches in progress... (${i + 1}/${maxTries})`);
        }
      }

      setStatus(
        'The files were uploaded successfully, but the release is still being prepared. Check back in a few moments.'
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Upload failed';
      if (message.toLowerCase().includes('already exists')) {
        setStatus('This audio file is already available on the platform. Try uploading a different track.');
      } else {
        setStatus(message);
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="mx-auto max-w-3xl space-y-8">
      <div>
        <h1 className="text-4xl font-black tracking-tight">Studio</h1>
        <p className="mt-2 text-zinc-400">
          Add a new release with audio, artwork and a polished listening page.
        </p>
      </div>

      <form
        onSubmit={handleSubmit}
        className="space-y-5 rounded-[2rem] border border-spotify-border bg-black/20 p-6"
      >
        <div className="grid gap-5 md:grid-cols-2">
          <label className="space-y-2">
            <span className="text-sm text-zinc-400">Title</span>
            <input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full rounded-2xl border border-spotify-border bg-[#191919] px-4 py-3 outline-none"
            />
          </label>

          <label className="space-y-2">
            <span className="text-sm text-zinc-400">Artist</span>
            <input
              value={artist}
              onChange={(e) => setArtist(e.target.value)}
              className="w-full rounded-2xl border border-spotify-border bg-[#191919] px-4 py-3 outline-none"
            />
          </label>
        </div>

        <label className="block space-y-2">
          <span className="text-sm text-zinc-400">Duration (seconds)</span>
          <input
            type="number"
            value={duration}
            onChange={(e) => setDuration(Number(e.target.value))}
            className="w-full rounded-2xl border border-spotify-border bg-[#191919] px-4 py-3 outline-none"
          />
        </label>

        <div className="grid gap-5 md:grid-cols-2">
          <label className="block space-y-2">
            <span className="text-sm text-zinc-400">Audio file (.mp3)</span>
            <input
              type="file"
              accept="audio/mpeg"
              onChange={(e) => setAudioFile(e.target.files?.[0] ?? null)}
              className="block w-full text-sm text-zinc-300 file:mr-4 file:rounded-full file:border-0 file:bg-white file:px-4 file:py-2 file:text-black"
            />
          </label>

          <label className="block space-y-2">
            <span className="text-sm text-zinc-400">Cover image</span>
            <input
              type="file"
              accept="image/png,image/jpeg,image/webp"
              onChange={(e) => setCoverFile(e.target.files?.[0] ?? null)}
              className="block w-full text-sm text-zinc-300 file:mr-4 file:rounded-full file:border-0 file:bg-white file:px-4 file:py-2 file:text-black"
            />
          </label>
        </div>

        <button
          disabled={!canSubmit}
          className="rounded-full bg-spotify-green px-6 py-3 font-semibold text-black disabled:cursor-not-allowed disabled:opacity-50"
        >
          {submitting ? 'Uploading...' : 'Publish release'}
        </button>
      </form>

      {status && (
        <div className="rounded-2xl border border-spotify-border bg-black/20 p-4 text-sm text-zinc-300">
          <p>{status}</p>
          {trackId && <p className="mt-2 text-zinc-500">Release ID: {trackId}</p>}
        </div>
      )}
    </div>
  );
}
