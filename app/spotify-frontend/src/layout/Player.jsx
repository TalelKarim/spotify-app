export default function Player() {
  return (
    <div className="h-20 bg-neutral-900 border-t border-neutral-800 flex items-center justify-between px-6">
      <div>
        <p className="text-sm text-gray-400">Now Playing</p>
        <p className="font-semibold">No track selected</p>
      </div>

      <div className="flex gap-6 text-xl">
        <button>⏮</button>
        <button>▶</button>
        <button>⏭</button>
      </div>

      <div>
        <input type="range" className="w-24" />
      </div>
    </div>
  )
}