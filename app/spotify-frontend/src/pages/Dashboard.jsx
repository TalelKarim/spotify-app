import { useEffect, useState } from "react"
import { getTrack } from "../api/tracksApi"
import TrackCard from "../components/TrackCard"

export default function Dashboard() {
  const [tracks, setTracks] = useState([])

  useEffect(() => {
    const loadTracks = async () => {
      try {
        // ⚠️ Fake list pour test
        const ids = ["track-123", "track-456"]

        const results = await Promise.all(
          ids.map((id) => getTrack(id))
        )

        setTracks(results)
      } catch (err) {
        console.error("Error loading tracks:", err)
      }
    }

    loadTracks()
  }, [])

  return (
    <div>
      <h2 className="text-3xl font-bold mb-6">Trending Tracks</h2>

      <div className="grid grid-cols-4 gap-6">
        {tracks.map((track) => (
          <TrackCard key={track.trackId} track={track} />
        ))}
      </div>
    </div>
  )
}