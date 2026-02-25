import Sidebar from "./Sidebar"
import Topbar from "./Topbar"
import Player from "./Player"

export default function MainLayout({ children }) {
  return (
    <div className="flex h-screen bg-black text-white">
      <Sidebar />

      <div className="flex flex-col flex-1">
        <Topbar />

        <main className="flex-1 overflow-y-auto p-6">
          {children}
        </main>

        <Player />
      </div>
    </div>
  )
}