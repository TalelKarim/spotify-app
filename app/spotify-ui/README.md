# Symphony Premium Frontend

Frontend React + Vite + Tailwind pour ton projet Spotify-like AWS.



## Pré-requis

- Node.js 20+
- npm 10+

## Lancement local

1. Copier le fichier d'environnement :

```bash
cp .env.example .env
```

2. Installer les dépendances :

```bash
npm install
```

3. Lancer le projet :

```bash
npm run dev
```

4. Ouvrir :

```text
http://localhost:5173
```

## Build production

```bash
npm run build
npm run preview
```

## Variables d'environnement

- `VITE_APP_NAME` : nom de l'application
- `VITE_API_URL` : URL de base API Gateway
- `VITE_MEDIA_CDN_DOMAIN` : domaine CloudFront pour audio et covers
- `VITE_COGNITO_DOMAIN` : domaine Hosted UI Cognito
- `VITE_COGNITO_CLIENT_ID` : app client Cognito
- `VITE_COGNITO_REDIRECT_URI` : callback OAuth locale
- `VITE_COGNITO_LOGOUT_URI` : URL de logout
- `VITE_API_TOKEN_SOURCE` : `id` ou `access`

## Notes importantes

- le player déclenche maintenant le chargement du détail d'un titre si le catalogue ne fournit pas encore l'URL audio
- l'authentification Hosted UI attend que l'URL de callback du front soit strictement déclarée dans Cognito
- les uploads audio/cover utilisent directement les presigned URLs S3 renvoyées par `POST /tracks`
