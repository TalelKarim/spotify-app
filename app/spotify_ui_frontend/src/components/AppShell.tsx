import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { GlobalPlayer } from './GlobalPlayer';
import { Surface } from './Surface';

export function AppShell() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0F0F0F] via-[#1A1A1A] to-[#0D0D0D] text-white">
      {/* Background decorative elements */}
      <div className="fixed inset-0 -z-10 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-spotify-green/10 rounded-full blur-3xl opacity-20" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-spotify-cyan/5 rounded-full blur-3xl opacity-10" />
      </div>

      <div className="mx-auto flex min-h-screen max-w-[1800px] gap-4 px-3 py-4 lg:px-6">
        {/* Sidebar */}
        <div className="hidden lg:block">
          <Sidebar />
        </div>

        {/* Main Content */}
        <main className="flex min-h-[calc(100vh-2rem)] flex-1 flex-col gap-4 animate-fade-in">
          {/* Topbar */}
          <Topbar />

          {/* Content Area */}
          <Surface
            elevation="raised"
            background="gradient"
            rounded="3xl"
            padding="lg"
            border={true}
            className="flex-1 overflow-y-auto shadow-elevated"
          >
            <Outlet />
          </Surface>

          {/* Player */}
          <GlobalPlayer />
        </main>
      </div>
    </div>
  );
}
