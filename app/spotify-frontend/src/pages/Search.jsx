import { useState } from "react"
import { searchTracks } from "../api/tracksApi"

export default function Search() {
  const [query, setQuery] = useState("")
  const [results, setResults] = useState([])

  const handleSearch = async () => {
    try {
      const data = await searchTracks(query)
      setResults(data)
    } catch (err) {
      console.error("Search error:", err)
    }
  }

  return (
    <div>
      <h2 className="text-3xl font-bold mb-6">Search</h2>

      <div className="flex gap-4 mb-6">
        <input
          className="bg-neutral-800 p-3 rounded flex-1"
          placeholder="Search tracks..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />

        <button
          onClick={handleSearch}
          className="bg-green-600 px-6 py-2 rounded hover:bg-green-700 transition"
        >
          Search
        </button>
      </div>

      <div className="space-y-4">
        {results.map((track) => (
          <div key={track.trackId} className="bg-neutral-800 p-4 rounded">
            {track.title}
          </div>
        ))}
      </div>
    </div>
  )
}