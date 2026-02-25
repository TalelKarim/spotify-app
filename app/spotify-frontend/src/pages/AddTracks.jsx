import { useState } from "react"
import { createTrack } from "../api/tracksApi"
import { useNavigate } from "react-router-dom"


export default function AddTrack() {
  const navigate = useNavigate()

  const [form, setForm] = useState({
    title: "",
    artist: "",
    description: "",
    duration: ""
  })

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value
    })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      await createTrack({
        ...form,
        duration: Number(form.duration)
      })

      navigate("/") // Retour au dashboard
    } catch (err) {
      console.error(err)
      setError("Failed to create track")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-xl">
      <h2 className="text-3xl font-bold mb-6">Add New Track</h2>

      <form
        onSubmit={handleSubmit}
        className="bg-neutral-800 p-6 rounded space-y-4"
      >
        <input
          name="title"
          placeholder="Title"
          value={form.title}
          onChange={handleChange}
          className="w-full p-3 bg-neutral-900 rounded"
          required
        />

        <input
          name="artist"
          placeholder="Artist"
          value={form.artist}
          onChange={handleChange}
          className="w-full p-3 bg-neutral-900 rounded"
          required
        />

        <textarea
          name="description"
          placeholder="Description"
          value={form.description}
          onChange={handleChange}
          className="w-full p-3 bg-neutral-900 rounded"
        />

        <input
          name="duration"
          placeholder="Duration (seconds)"
          value={form.duration}
          onChange={handleChange}
          className="w-full p-3 bg-neutral-900 rounded"
          type="number"
          required
        />

        {error && (
          <p className="text-red-500">{error}</p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="bg-green-600 px-6 py-2 rounded hover:bg-green-700 transition"
        >
          {loading ? "Creating..." : "Create Track"}
        </button>
      </form>
    </div>
  )
}