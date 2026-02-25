import { useAuth } from "react-oidc-context"

export default function Layout({ children }) {
  const auth = useAuth()

  const handleLogout = async () => {
    const clientId = "4nkq725188sudjg6n9ndr8m09e"
    const logoutUri = "http://localhost:5173"
    const cognitoDomain = "https://spotify.auth.eu-west-1.amazoncognito.com"

    // 1️⃣ Clear local OIDC user (tokens in storage)
    await auth.removeUser()

    // 2️⃣ Redirect to Cognito Hosted UI logout endpoint
    window.location.href =
      `${cognitoDomain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(logoutUri)}`
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-black text-white px-6 py-4 flex justify-between">
        <span className="font-bold text-xl">Spotify Serverless</span>

        {auth.isAuthenticated && (
          <button
            onClick={handleLogout}
            className="bg-red-500 px-4 py-2 rounded"
          >
            Logout
          </button>
        )}
      </nav>

      <div className="p-8">
        {children}
      </div>
    </div>
  )
}