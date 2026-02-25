import React from "react"
import { createRoot } from "react-dom/client"
import { AuthProvider } from "react-oidc-context"
import { oidcConfig } from "./auth/oidcConfig"
import App from "./App"
import "./index.css"

createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <AuthProvider {...oidcConfig}>
      <App />
    </AuthProvider>
  </React.StrictMode>
)