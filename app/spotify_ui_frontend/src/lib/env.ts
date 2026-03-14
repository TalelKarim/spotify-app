import type { TokenSource } from '../types';

const required = (key: string, fallback = '') => {
  const value = import.meta.env[key] ?? fallback;
  return String(value);
};

export const env = {
  appName: required('VITE_APP_NAME', 'Symphony Premium'),
  apiUrl: required('VITE_API_URL'),
  mediaCdnDomain: required('VITE_MEDIA_CDN_DOMAIN'),
  awsRegion: required('VITE_AWS_REGION', 'eu-west-1'),
  cognitoDomain: required('VITE_COGNITO_DOMAIN'),
  cognitoClientId: required('VITE_COGNITO_CLIENT_ID'),
  cognitoRedirectUri: required('VITE_COGNITO_REDIRECT_URI', 'http://localhost:5173/auth/callback'),
  cognitoLogoutUri: required('VITE_COGNITO_LOGOUT_URI', 'http://localhost:5173'),
  apiTokenSource: required('VITE_API_TOKEN_SOURCE', 'id') as TokenSource,
};
