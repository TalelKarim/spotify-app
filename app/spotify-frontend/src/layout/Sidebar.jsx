import { Link, useLocation } from "react-router-dom"

export default function Sidebar() {
  const location = useLocation()

  const linkStyle = (path) =>
    `block px-4 py-2 rounded ${
      location.pathname === path
        ? "bg-green-600 text-white"
        : "hover:bg-neutral-800"
    }`

  return (
    <div className="w-64 bg-neutral-900 p-6 flex flex-col">
      <h1 className="text-2xl font-bold mb-10">Symphony</h1>

      <nav className="space-y-2">
        <Link to="/" className={linkStyle("/")}>Home</Link>
        <Link to="/search" className={linkStyle("/search")}>Search</Link>
        <Link to="/analytics" className={linkStyle("/analytics")}>Analytics</Link>
        <Link to="/profile" className={linkStyle("/profile")}>Profile</Link>
        <Link to="/add-track" className={linkStyle("/add-track")}>
  Add Track
</Link>
      </nav>
    </div>
  )
}