import { useAuth } from "react-oidc-context"

export default function ProtectedRoute({ children }) {
  const auth = useAuth()

  if (auth.isLoading) {
    return <div className="text-white p-10">Loading...</div>
  }

  if (auth.error) {
    return <div className="text-red-500 p-10">Auth error</div>
  }

  if (!auth.isAuthenticated) {
    auth.signinRedirect()
    return null
  }

  return children
}