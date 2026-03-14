# Symphony Premium Frontend

Frontend React + Vite + Tailwind pour ton projet Spotify-like AWS.

## Ce que cette version ajoute

- **Phase 1**
  - Home branchée sur `GET /me/recently-played`
  - fallback automatique vers `GET /me/listening/history` si le nouvel endpoint n'est pas encore déployé
  - page Profile avec un historique compact au lieu d'une grille de cartes dupliquées

- **Phase 2 (partie frontend)**
  - calcul du `audioHash` SHA-256 dans l'upload admin avant `POST /tracks`
  - envoi du hash au backend pour préparer l'unicité métier
  - message plus clair si le backend refuse un doublon audio

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

## Backend attendu pour exploiter toutes les nouveautés

### Phase 1
Le backend devrait exposer :

- `GET /me/recently-played`
- `GET /me/listening/history` enrichi avec `title`, `artist`, `coverUrl`

Le front reste compatible si `recently-played` n'est pas encore là, grâce au fallback.

### Phase 2
Le backend devrait accepter dans `POST /tracks` :

```json
{
  "title": "...",
  "artist": "...",
  "duration": 180,
  "coverContentType": "image/jpeg",
  "audioHash": "sha256hex"
}
```

## Notes importantes

- le player continue de charger automatiquement le détail d'un titre si le catalogue ne fournit pas encore l'URL audio
- l'authentification Hosted UI attend que l'URL de callback du front soit strictement déclarée dans Cognito
- les uploads audio/cover utilisent directement les presigned URLs S3 renvoyées par `POST /tracks`
