import { LogIn, LogOut, Search } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useState } from 'react';

export function Topbar() {
  const { isAuthenticated, login, logout, user } = useAuth();
  const [query, setQuery] = useState('');
  const navigate = useNavigate();

  const submit = (event: React.FormEvent) => {
    event.preventDefault();
    if (!query.trim()) return;
    navigate(`/search?q=${encodeURIComponent(query.trim())}`);
  };

  return (
    <header className="sticky top-0 z-20 flex items-center justify-between gap-4 rounded-3xl border border-spotify-border bg-black/30 px-5 py-4 backdrop-blur-xl">
      <form onSubmit={submit} className="flex max-w-2xl flex-1 items-center gap-3 rounded-2xl border border-spotify-border bg-[#1A1A1A] px-4 py-3">
        <Search className="h-5 w-5 text-zinc-500" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search tracks, artists, vibes..."
          className="w-full bg-transparent text-sm outline-none placeholder:text-zinc-500"
        />
      </form>

      <div className="flex items-center gap-3">
        {isAuthenticated ? (
          <>
            <Link to="/me" className="rounded-full bg-white/10 px-4 py-2 text-sm text-zinc-200 hover:bg-white/15">
              {user?.email ?? 'Account'}
            </Link>
            <button onClick={logout} className="inline-flex items-center gap-2 rounded-full bg-white px-4 py-2 text-sm font-medium text-black transition hover:opacity-90">
              <LogOut className="h-4 w-4" /> Logout
            </button>
          </>
        ) : (
          <button onClick={login} className="inline-flex items-center gap-2 rounded-full bg-spotify-green px-4 py-2 text-sm font-semibold text-black transition hover:scale-[1.02]">
            <LogIn className="h-4 w-4" /> Sign in
          </button>
        )}
      </div>
    </header>
  );
}
