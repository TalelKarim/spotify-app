import { useAuth } from "react-oidc-context"

export default function Profile() {
  const auth = useAuth()

  return (
    <div>
      <h2 className="text-3xl font-bold mb-6">Profile</h2>

      {auth.user && (
        <div className="bg-neutral-800 p-6 rounded w-96">
          <p><strong>Email:</strong> {auth.user.profile.email}</p>
          <p><strong>Sub:</strong> {auth.user.profile.sub}</p>
          <p><strong>Token Exp:</strong> {auth.user.profile.exp}</p>
        </div>
      )}
    </div>
  )
}