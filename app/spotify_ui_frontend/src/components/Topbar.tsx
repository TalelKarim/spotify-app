import { LogIn, LogOut, Search } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useState } from 'react';
import { Button } from './Button';
import { Surface } from './Surface';
import { Label } from './Label';

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
    <header className="sticky top-0 z-20">
      <Surface
        elevation="floating"
        background="transparent"
        rounded="2xl"
        padding="md"
        border={true}
        className="flex items-center justify-between gap-6"
      >
        {/* Search Bar */}
        <form onSubmit={submit} className="flex max-w-2xl flex-1 items-center gap-3 rounded-full border border-spotify-border bg-white/5 px-6 py-3 transition-all duration-200 hover:border-spotify-green/50 hover:bg-white/8 focus-within:border-spotify-green focus-within:ring-2 focus-within:ring-spotify-green/30">
          <Search className="h-5 w-5 text-zinc-500 flex-shrink-0" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search tracks, artists, vibes..."
            className="w-full bg-transparent text-base outline-none placeholder:text-zinc-600 focus:placeholder:text-zinc-500 transition-colors"
          />
        </form>

        {/* Auth Buttons */}
        <div className="flex items-center gap-3 flex-shrink-0">
          {isAuthenticated ? (
            <>
              <Link to="/me">
                <Button variant="secondary" size="md">
                  <Label variant="label" color="primary" className="m-0">
                    {user?.email ?? 'Account'}
                  </Label>
                </Button>
              </Link>
              <Button variant="outline" size="md" onClick={logout}>
                <LogOut className="h-4 w-4" />
              </Button>
            </>
          ) : (
            <Button variant="primary" size="md" onClick={login}>
              <LogIn className="h-4 w-4" />
              <span>Sign in</span>
            </Button>
          )}
        </div>
      </Surface>
    </header>
  );
}
