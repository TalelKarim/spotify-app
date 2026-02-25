export const oidcConfig = {
  authority: "https://cognito-idp.eu-west-1.amazonaws.com/eu-west-1_VmaIbNq40",
  client_id: "4nkq725188sudjg6n9ndr8m09e",
  redirect_uri: "http://localhost:5173",
  response_type: "code",
  scope: "openid email profile",
  post_logout_redirect_uri: "http://localhost:5173",
  automaticSilentRenew: true,
  loadUserInfo: true
}