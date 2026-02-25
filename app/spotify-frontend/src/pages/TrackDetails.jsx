import { useParams } from "react-router-dom"
import { useEffect, useState } from "react"
import { getTrack } from "../api/tracksApi"

export default function TrackDetails() {
  const { id } = useParams()
  const [track, setTrack] = useState(null)

  useEffect(() => {
    const loadTrack = async () => {
      try {
        const data = await getTrack(id)
        setTrack(data)
      } catch (err) {
        console.error("Track load error:", err)
      }
    }

    loadTrack()
  }, [id])

  if (!track) {
    return <p className="text-gray-400">Loading...</p>
  }

  return (
    <div>
      <h2 className="text-3xl font-bold mb-6">{track.title}</h2>
      <p className="text-gray-400">{track.artist}</p>
      <p className="mt-4">{track.description}</p>
    </div>
  )
}