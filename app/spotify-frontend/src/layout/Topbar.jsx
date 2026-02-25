import { useAuth } from "react-oidc-context"

export default function Topbar() {
  const auth = useAuth()

  const handleLogout = async () => {
    await auth.removeUser()

    const clientId = "4nkq725188sudjg6n9ndr8m09e"
    const logoutUri = "http://localhost:5173"
    const cognitoDomain = "https://spotify.auth.eu-west-1.amazoncognito.com"

    window.location.href = `${cognitoDomain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(logoutUri)}`
  }

  return (
    <div className="h-16 bg-neutral-900 flex items-center justify-between px-6 border-b border-neutral-800">
      <h2 className="text-xl font-semibold">Symphony</h2>

      {auth.isAuthenticated && (
        <button
          onClick={handleLogout}
          className="bg-red-500 px-4 py-2 rounded hover:bg-red-600 transition"
        >
          Logout
        </button>
      )}
    </div>
  )
}