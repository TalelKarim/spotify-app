import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { GlobalPlayer } from './GlobalPlayer';

export function AppShell() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0F0F0F] via-[#141414] to-[#0D0D0D] text-white">
      <div className="mx-auto flex min-h-screen max-w-[1700px] gap-4 px-4 py-4 lg:px-6">
        <div className="hidden lg:block">
          <Sidebar />
        </div>
        <main className="flex min-h-[calc(100vh-2rem)] flex-1 flex-col gap-4">
          <Topbar />
          <div className="flex-1 rounded-3xl border border-spotify-border bg-gradient-to-b from-[#171717] via-[#131313] to-[#0F0F0F] p-5 shadow-soft lg:p-8">
            <Outlet />
          </div>
          <GlobalPlayer />
        </main>
      </div>
    </div>
  );
}
