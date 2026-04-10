import { Disc3, Home, Search, Upload, User } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { env } from '../lib/env';
import { Surface } from './Surface';
import { Label } from './Label';

const navItemBase = 'flex items-center gap-3 rounded-lg px-4 py-3 text-sm font-medium transition-all duration-200';

export function Sidebar() {
  const { isAdmin } = useAuth();

  return (
    <aside className="flex h-full w-64 flex-col gap-4 animate-fade-in">
      {/* Logo Section */}
      <Surface elevation="raised" background="dark" rounded="2xl" padding="md" border={true} className="h-fit">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-spotify text-black shadow-glow-green">
            <Disc3 className="h-6 w-6 font-bold" />
          </div>
          <div className="flex-1">
            <Label variant="caption" weight="semibold" color="secondary" className="block uppercase tracking-wider">
              {env.appName}
            </Label>
            <Label variant="label" weight="bold" className="block mt-0.5">
              Listening Club
            </Label>
          </div>
        </div>
      </Surface>

      {/* Navigation */}
      <Surface elevation="flat" background="transparent" rounded="xl" padding="sm" border={false} className="flex flex-1 flex-col gap-1">
        <nav className="space-y-1">
          <NavLink
            to="/"
            className={({ isActive }) =>
              `${navItemBase} ${
                isActive
                  ? 'bg-gradient-spotify text-black font-bold shadow-glow-green'
                  : 'text-zinc-300 hover:bg-white/10 hover:text-white'
              }`
            }
          >
            <Home className="h-5 w-5 flex-shrink-0" />
            <span>Home</span>
          </NavLink>

          <NavLink
            to="/search"
            className={({ isActive }) =>
              `${navItemBase} ${
                isActive
                  ? 'bg-gradient-spotify text-black font-bold shadow-glow-green'
                  : 'text-zinc-300 hover:bg-white/10 hover:text-white'
              }`
            }
          >
            <Search className="h-5 w-5 flex-shrink-0" />
            <span>Search</span>
          </NavLink>

          <NavLink
            to="/me"
            className={({ isActive }) =>
              `${navItemBase} ${
                isActive
                  ? 'bg-gradient-spotify text-black font-bold shadow-glow-green'
                  : 'text-zinc-300 hover:bg-white/10 hover:text-white'
              }`
            }
          >
            <User className="h-5 w-5 flex-shrink-0" />
            <span>Profile</span>
          </NavLink>

          {isAdmin && (
            <NavLink
              to="/upload"
              className={({ isActive }) =>
                `${navItemBase} ${
                  isActive
                    ? 'bg-gradient-spotify text-black font-bold shadow-glow-green'
                    : 'text-zinc-300 hover:bg-white/10 hover:text-white'
                }`
              }
            >
              <Upload className="h-5 w-5 flex-shrink-0" />
              <span>Studio</span>
            </NavLink>
          )}
        </nav>
      </Surface>

      {/* Info Card */}
      <Surface elevation="raised" background="gradient" rounded="xl" padding="md" border={true} className="h-fit">
        <Label variant="caption" weight="semibold" color="success" className="uppercase tracking-wider block mb-2">
          💡 Pro Tip
        </Label>
        <Label variant="caption" color="secondary">
          Explore new vibes, revisit your recent plays, and enjoy seamless streaming in one beautiful interface.
        </Label>
      </Surface>
    </aside>
  );
}
