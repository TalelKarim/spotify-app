1. Présentation du projet

Ce projet implémente une plateforme de streaming audio de type Spotify, conçue autour d’une architecture serverless, event-driven et scalable sur AWS.

L’objectif n’est pas de construire un simple CRUD, mais un système distribué moderne, capable de :

servir des millions d’écoutes

absorber des pics de charge

séparer strictement le temps réel utilisateur des traitements lourds

évoluer sans refonte majeure

2. Principes d’architecture
Séparation fondamentale

Control plane : API Gateway, Lambdas API

Data plane : CloudFront + S3 (streaming audio)

Event plane : EventBridge + SQS

Orchestration : Step Functions

👉 Aucun flux audio ne transite par API Gateway ni Lambda.

3. Acteurs du système

Utilisateur final

écoute de musique

recherche

interactions (play)

Backend applicatif

gestion des métadonnées

génération d’événements métier

Backend asynchrone

statistiques

analytics

traitements différés

Opérations techniques

ingestion

re-indexation




1) Use cases complets du projet Spotify


A. Auth & identité

    UC-A1 : Login / Logout (Cognito Hosted UI + PKCE)

    UC-A2 : Récupérer mon profil (GET /me)

    UC-A3 : RBAC simple : USER vs ADMIN



B. Catalogue tracks (métadonnées + media)

    UC-B1 (ADMIN) : Créer un track (métadonnées) + obtenir presigned upload URL

    UC-B2 (ADMIN) : Upload MP3 sur S3 via presigned URL

    UC-B3 (Système) : S3 Event → valider upload → passer track à READY

    UC-B4 (USER) : Lister tracks

    UC-B5 (USER) : Get track details (inclut audioUrl CloudFront)

    UC-B6 (USER) : Jouer un track (POST /tracks/{id}/play)


C. Listening events (événement métier)

    UC-C1 : Enregistrer un “TrackPlayed event” (source API)

    UC-C2 : Stocker l’événement brut dans listening-events (audit trail)

    UC-C3 : Orchestrer des traitements dérivés (stats track, stats user, analytics global)


D. Analytics & stats

    UC-D1 : Get analytics global (GET /analytics/global) — ex “daily plays”

    UC-D2 : Get stats user (GET /users/{userId} ou idéalement /users/me/stats)

    UC-D3 : Get stats track (GET /tracks/{id} renvoie déjà plays / lastPlayedAt)

    UC-D4 : (option) Analytics par jour / range (GET /analytics/daily?from=&to=)

E. Search / Indexation (tech)

    UC-E1 : Indexer un track à la création/READY dans OpenSearch

    UC-E2 : Indexer/mettre à jour stats (plays) côté index (optionnel)

    UC-E3 : Rechercher (GET /search?q=...) via OpenSearch

2) Contrats API finaux (côté API Gateway)
Auth (protégées par Cognito)

GET /me ✅ (USER/ADMIN).      x 

POST /tracks/{trackId}/play ✅ (USER/ADMIN).  

POST /events/listening ✅ (USER/ADMIN) (si on garde cette route)



Admin-only

POST /tracks ✅ ADMIN.        x 

PUT /tracks/{id} ✅ ADMIN.    

DELETE /tracks/{id} ✅ ADMIN


Public/Anonymous (à décider)

GET /tracks 

GET /tracks/{id}

GET /search

GET /analytics/global 




Event contract (le contrat le plus important)
EventBridge “TrackPlayed”

DetailType: TrackPlayed
Source: spotify.api
Detail:

  {
    "eventType": "TrackPlayed",
    "trackId": "track-123",
    "userId": "cognito-sub-or-userid",
    "timestamp": "2026-02-27T19:00:00Z",
    "source": "api",
    "metadata": {
      "device": "mobile",
      "country": "FR"
    }
  }




Lambdas


API Lambdas

- api_create_track (ADMIN)

    écrit DynamoDB track METADATA (status=UPLOADING, objectKey, TTL upload)

    génère presigned PUT URL S3 (KMS compatible)

- api_get_tracks

    scan/pagination

    renvoie audioUrl basé sur CloudFront + objectKey (si READY)

- api_get_track

    get_item

    bloque si status != READY (409)

    renvoie audioUrl

- api_start_stream (protégée)

    lit sub depuis JWT (authorizer claims)

    publie event EventBridge TrackPlayed

    renvoie 202


- api_get_me

    renvoie identity depuis claims

- api_search

  query OpenSearch




Orchestration Lambdas (utilisées par Step Functions)

- orch_update_track_stats

  increment plays + lastPlayedAt (ConditionExpression track exists)

- Orch_update_user_stats

 update “user aggregate” (totalPlays, lastPlayedTrack, etc.)

- orch_compute_analytics

  update “global daily analytics” (par date)



Tech / Indexing Lambdas

- process_track_upload (trigger S3)

    passe status=READY

    publie un event “TrackReady” pour indexation

- index_track (trigger TrackReady / EventBridge / SQS)

    upsert doc OpenSearch (title, artist, duration, trackId, maybe plays)

    Important : plays qui bougent souvent = pas obligé de les réindexer à chaque play (coût). On peut garder OpenSearch pour search “catalogue”, et Dynamo pour stats.