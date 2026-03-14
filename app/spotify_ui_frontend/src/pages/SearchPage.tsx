import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { searchTracks } from '../api/search';
import type { SearchResult } from '../types';
import { TrackCard } from '../components/TrackCard';
import { Section } from '../components/Section';

export default function SearchPage() {
  const [params, setParams] = useSearchParams();
  const initialQ = params.get('q') ?? '';
  const [query, setQuery] = useState(initialQ);
  const [results, setResults] = useState<SearchResult[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setQuery(initialQ);
  }, [initialQ]);

  useEffect(() => {
    const term = query.trim();
    if (!term) {
      setResults([]);
      setTotal(0);
      return;
    }

    const timer = setTimeout(async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await searchTracks(term, { limit: 20, sort: 'relevance' });
        setResults(data.results);
        setTotal(data.total);
        setParams({ q: term }, { replace: true });
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Search failed');
      } finally {
        setLoading(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [query, setParams]);

  const summary = useMemo(() => {
    if (!query.trim()) return 'Search by song title or artist.';
    if (loading) return 'Looking for the best matches...';
    return `${total} result${total > 1 ? 's' : ''} for “${query.trim()}”.`;
  }, [loading, query, total]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-4xl font-black tracking-tight">Search</h1>
        <p className="mt-2 text-zinc-400">Jump straight to the tracks and artists you want to hear.</p>
      </div>

      <div className="rounded-3xl border border-spotify-border bg-black/20 p-4">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search by title or artist"
          className="w-full rounded-2xl border border-spotify-border bg-[#191919] px-4 py-4 text-lg outline-none placeholder:text-zinc-500"
        />
        <p className="mt-3 text-sm text-zinc-400">{summary}</p>
      </div>

      {error && <div className="rounded-2xl border border-red-500/30 bg-red-500/10 p-4 text-sm text-red-300">{error}</div>}

      <Section title="Results" subtitle="Tap play to start listening instantly.">
        {results.length === 0 && !loading ? (
          <div className="rounded-3xl border border-dashed border-spotify-border p-10 text-center text-zinc-400">
            {query.trim() ? 'No tracks match this search yet.' : 'Type a query to get started.'}
          </div>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {results.map((track) => <TrackCard key={track.trackId} track={track} />)}
          </div>
        )}
      </Section>
    </div>
  );
}
