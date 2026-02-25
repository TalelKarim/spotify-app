import axios from "axios"
import { oidcConfig } from "../auth/oidcConfig"

const axiosClient = axios.create({
  baseURL: "https://i9m1tbyg57.execute-api.eu-west-1.amazonaws.com/dev", // ⚠️ remplace par ton API
})

// Interceptor pour injecter le token automatiquement
axiosClient.interceptors.request.use((config) => {
  const oidcStorageKey = `oidc.user:${oidcConfig.authority}:${oidcConfig.client_id}`
  const user = JSON.parse(localStorage.getItem(oidcStorageKey))

  if (user?.access_token) {
    config.headers.Authorization = `Bearer ${user.access_token}`
  }

  return config
})

export default axiosClient