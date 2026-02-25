import { useEffect, useState } from "react"
import { getAnalytics } from "../api/tracksApi"

export default function Analytics() {
  const [stats, setStats] = useState(null)

  useEffect(() => {
    const loadAnalytics = async () => {
      try {
        const data = await getAnalytics()
        setStats(data)
      } catch (err) {
        console.error("Error loading analytics:", err)
      }
    }

    loadAnalytics()
  }, [])

  return (
    <div>
      <h2 className="text-3xl font-bold mb-6">Analytics</h2>

      {!stats ? (
        <p className="text-gray-400">Loading analytics...</p>
      ) : (
        <div className="grid grid-cols-3 gap-6">
          <div className="bg-neutral-800 p-6 rounded">
            <p className="text-gray-400 text-sm">Total Plays</p>
            <p className="text-2xl font-bold">{stats.totalPlays}</p>
          </div>

          <div className="bg-neutral-800 p-6 rounded">
            <p className="text-gray-400 text-sm">Active Users</p>
            <p className="text-2xl font-bold">{stats.activeUsers}</p>
          </div>

          <div className="bg-neutral-800 p-6 rounded">
            <p className="text-gray-400 text-sm">Tracks</p>
            <p className="text-2xl font-bold">{stats.totalTracks}</p>
          </div>
        </div>
      )}
    </div>
  )
}