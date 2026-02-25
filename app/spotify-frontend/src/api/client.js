import axios from "axios"
import { config } from "../config/config"


import { UserManager } from "oidc-client-ts"
import { oidcConfig } from "../auth/oidcConfig"

const userManager = new UserManager(oidcConfig)


const api = axios.create({
  baseURL: config.apiBaseUrl,
})

api.interceptors.request.use(async (request) => {
  const user = await userManager.getUser()
  if (user?.access_token) {
    request.headers.Authorization = `Bearer ${user.access_token}`
  }
  return request
})

export default api