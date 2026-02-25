import { useNavigate } from "react-router-dom"

export default function TrackCard({ track }) {
  const navigate = useNavigate()

  return (
    <div
      className="bg-neutral-800 p-4 rounded-lg hover:bg-neutral-700 cursor-pointer transition"
      onClick={() => navigate(`/track/${track.trackId}`)}
    >
      <div className="h-40 bg-gray-600 rounded mb-4" />
      <h3 className="font-semibold">{track.title}</h3>
      <p className="text-sm text-gray-400">{track.artist}</p>
    </div>
  )
}