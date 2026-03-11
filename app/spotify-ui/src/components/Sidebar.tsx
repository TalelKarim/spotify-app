import { Disc3, Home, Search, Upload, User } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { env } from '../lib/env';

const base = 'flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium transition';

export function Sidebar() {
  const { isAdmin } = useAuth();

  return (
    <aside className="flex h-full w-64 flex-col gap-4 rounded-3xl border border-spotify-border bg-gradient-to-b from-[#181818] to-[#101010] p-4 shadow-soft">
      <div className="flex items-center gap-3 px-2 py-3">
        <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-spotify-green/20 text-spotify-green">
          <Disc3 className="h-6 w-6" />
        </div>
        <div>
          <p className="text-xs uppercase tracking-[0.2em] text-zinc-500">Listening club</p>
          <h1 className="text-lg font-semibold">{env.appName}</h1>
        </div>
      </div>

      <nav className="flex flex-1 flex-col gap-2">
        <NavLink to="/" className={({ isActive }) => `${base} ${isActive ? 'bg-spotify-hover text-white' : 'text-zinc-300 hover:bg-spotify-hover hover:text-white'}`}>
          <Home className="h-5 w-5" /> Home
        </NavLink>
        <NavLink to="/search" className={({ isActive }) => `${base} ${isActive ? 'bg-spotify-hover text-white' : 'text-zinc-300 hover:bg-spotify-hover hover:text-white'}`}>
          <Search className="h-5 w-5" /> Search
        </NavLink>
        <NavLink to="/me" className={({ isActive }) => `${base} ${isActive ? 'bg-spotify-hover text-white' : 'text-zinc-300 hover:bg-spotify-hover hover:text-white'}`}>
          <User className="h-5 w-5" /> Profile
        </NavLink>
        {isAdmin && (
          <NavLink to="/upload" className={({ isActive }) => `${base} ${isActive ? 'bg-spotify-hover text-white' : 'text-zinc-300 hover:bg-spotify-hover hover:text-white'}`}>
            <Upload className="h-5 w-5" /> Studio
          </NavLink>
        )}
      </nav>

      <div className="rounded-2xl border border-spotify-border bg-black/30 p-4 text-sm text-zinc-400">
        <p className="mb-2 text-xs uppercase tracking-[0.2em] text-zinc-500">Good to know</p>
        <p>Discover new songs, jump back into your latest listens and keep everything within one polished player.</p>
      </div>
    </aside>
  );
}
