export const oidcConfig = {
  authority: "https://cognito-idp.eu-west-1.amazonaws.com/eu-west-1_t6Hqh46nS",
  client_id: "m1nsjbsdvjuhiab3eikcrbrj9",
  redirect_uri: "http://localhost:5173",
  response_type: "code",
  scope: "openid email profile",
  post_logout_redirect_uri: "http://localhost:5173",
  automaticSilentRenew: true,
  loadUserInfo: true
}