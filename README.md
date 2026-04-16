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

POST /tracks/{trackId}/play ✅ (USER/ADMIN).        x 

POST /events/listening ✅ (USER/ADMIN) (si on garde cette route)



Admin-only

POST /tracks ✅ ADMIN.        x 

PUT /tracks/{id} ✅ ADMIN.    

DELETE /tracks/{id} ✅ ADMIN


Public/Anonymous (à décider)

GET /tracks  x

GET /tracks/{id} x 

GET /tracks/{id}/stats x 



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




    # Spotify Serverless App - Documentation Copilot

## Vue d'ensemble du projet

Ce projet implémente une **plateforme de streaming audio de type Spotify** conçue autour d'une architecture serverless, event-driven et scalable sur AWS. L'objectif est de créer un système distribué moderne capable de servir des millions d'écoutes, d'absorber des pics de charge et de séparer strictement le temps réel utilisateur des traitements lourds.

### Principes architecturaux fondamentaux

1. **Séparation stricte des plans** :
   - **Plan de contrôle** : API Gateway + Lambdas API pour la logique métier
   - **Plan de données** : CloudFront + S3 pour le streaming audio direct
   - **Plan événementiel** : EventBridge + SQS pour les traitements asynchrones

2. **Architecture serverless** : Pas de serveurs à gérer, scaling automatique

3. **Event-driven** : Tous les événements métier sont publiés et traités de manière asynchrone

4. **Sécurité first** : Chiffrement KMS, authentification Cognito, IAM least privilege

## Architecture C4

### 1. Contexte système (System Context)

```mermaid
graph TB
    User[👤 Utilisateur final<br/>Écoute musique, recherche, interactions] --> System[🎵 Système Spotify<br/>Plateforme de streaming serverless]

    System --> Cognito[🔐 Amazon Cognito<br/>Authentification]
    System --> AWS[☁️ Infrastructure AWS<br/>Services managés]

    Cognito -.-> User
    AWS -.-> System
```

**Explication** : Le système interagit avec l'utilisateur final pour le streaming audio et utilise Cognito pour l'authentification. Toute l'infrastructure repose sur les services AWS managés.

### 2. Conteneurs (Containers)

```mermaid
graph TB
    User[👤 Utilisateur] --> Frontend[🌐 Application Web<br/>React SPA<br/>S3 + CloudFront]

    Frontend --> API[🚪 API Gateway<br/>Exposition REST]

    API --> Auth[🔐 Cognito<br/>Validation JWT]

    API --> API_Lambdas[⚡ Lambdas API<br/>Logique métier temps réel]

    API_Lambdas --> Data[(🗄️ DynamoDB<br/>Données primaires)]

    API_Lambdas --> Search[(🔍 OpenSearch<br/>Index de recherche)]

    API_Lambdas --> Events[📡 EventBridge<br/>Bus d'événements]

    Events --> Queues[📨 SQS<br/>Files d'attente]

    Queues --> Orchestrator[🔄 Step Functions<br/>Orchestration]

    Orchestrator --> Orchestration_Lambdas[⚡ Lambdas Orchestration<br/>Traitements lourds]

    Events --> Event_Lambdas[⚡ Lambdas Événements<br/>Traitement asynchrone]

    API_Lambdas --> Media[🎵 CloudFront + S3<br/>Streaming audio]

    Media --> User
```

**Explication** :
- **Frontend** : Interface utilisateur en React, hébergée statiquement
- **API Gateway** : Point d'entrée REST avec authentification
- **Lambdas API** : Traitement synchrone des requêtes utilisateur
- **EventBridge/SQS** : Découplage pour les traitements asynchrones
- **Step Functions** : Orchestration des workflows complexes
- **DynamoDB/OpenSearch** : Stockage et recherche des métadonnées
- **S3/CloudFront Media** : Streaming direct des fichiers audio

### 3. Composants (Components) - Couche API

```mermaid
graph TB
    subgraph "API Gateway"
        Auth[Authentification<br/>Cognito JWT]
        Routing[Routing<br/>vers Lambdas]
    end

    subgraph "Lambdas API"
        GetMe[GET /me<br/>Profil utilisateur]
        GetTracks[GET /tracks<br/>Liste pistes]
        GetTrack[GET /track/{id}<br/>Détails piste]
        Search[POST /search<br/>Recherche]
        CreateTrack[POST /tracks<br/>Créer piste]
        PostListening[POST /listening<br/>Événement écoute]
        GetAnalytics[GET /analytics<br/>Statistiques]
    end

    Auth --> Routing
    Routing --> GetMe
    Routing --> GetTracks
    Routing --> GetTrack
    Routing --> Search
    Routing --> CreateTrack
    Routing --> PostListening
    Routing --> GetAnalytics

    GetMe --> DynamoDB[(DynamoDB)]
    GetTracks --> DynamoDB
    GetTrack --> DynamoDB
    Search --> OpenSearch[(OpenSearch)]
    CreateTrack --> DynamoDB
    PostListening --> EventBridge[📡 EventBridge]
    GetAnalytics --> DynamoDB
```

### 4. Composants (Components) - Couche Événements

```mermaid
graph TB
    EventBridge[📡 EventBridge] --> SQS_Track_Played[SQS: track-played]
    EventBridge --> SQS_Track_Upload[SQS: track-upload]
    EventBridge --> SQS_Notifications[SQS: notifications]

    SQS_Track_Played --> Store_Listening[⚡ store_listening_event<br/>Stocke événement]
    SQS_Track_Played --> Update_Track_Stats[⚡ update_track_stats<br/>Met à jour stats piste]

    SQS_Track_Upload --> Process_Track_Upload[⚡ process_track_upload<br/>Traite upload]

    SQS_Notifications --> Publish_Notifications[⚡ publish_notifications<br/>Envoie notifications]

    Store_Listening --> DynamoDB[(DynamoDB<br/>listening_events)]
    Update_Track_Stats --> DynamoDB

    Process_Track_Upload --> DynamoDB
    Process_Track_Upload --> S3_Media[(S3 Media)]

    subgraph "Step Functions"
        Compute_Analytics[🔄 compute_analytics<br/>Calcul statistiques]
        Update_User_Stats[🔄 update_user_stats<br/>Met à jour stats user]
    end

    SQS_Track_Played --> Compute_Analytics
    Compute_Analytics --> Update_User_Stats
    Update_User_Stats --> DynamoDB
```

## Flux fonctionnels détaillés

### 1. Authentification et autorisation
- Utilisateur se connecte via Cognito
- Reçoit un JWT token
- Toutes les requêtes API incluent le token dans l'Authorization header
- API Gateway valide le token avant de router vers les Lambdas

### 2. Streaming audio
- **Principe clé** : Aucun fichier audio ne transite par API Gateway ou Lambda
- Frontend demande l'URL signée via API
- API Lambda génère une URL pré-signée S3/CloudFront
- Frontend stream directement depuis CloudFront
- Avantages : Performance, coût, scalabilité

### 3. Gestion des métadonnées
- **DynamoDB single-table design** :
  - `PK` (Partition Key) : Identifiant principal
  - `SK` (Sort Key) : Identifiant secondaire
  - Tables : tracks, users, listening_events
- **OpenSearch** : Index full-text pour la recherche par titre, artiste, etc.

### 4. Événements et analytics
- Chaque action utilisateur génère un événement (play, pause, skip)
- Événements publiés sur EventBridge
- Routage vers SQS selon le type
- Traitement asynchrone :
  - Stockage immédiat des événements bruts
  - Mise à jour des statistiques en temps réel
  - Calculs analytiques différés via Step Functions

### 5. Upload de pistes
- Upload direct vers S3 via pré-signed URL
- Lambda traite les métadonnées (extraction ID3, génération waveform, etc.)
- Indexation dans OpenSearch
- Notification aux abonnés

## Infrastructure AWS détaillée

Voir le diagramme complet dans `infra_diagram.md`.

### Composants clés
- **Réseau** : VPC avec sous-réseaux public/privé, NAT Gateway
- **Sécurité** : Security Groups, IAM roles, KMS encryption
- **Monitoring** : CloudWatch logs, metrics, alarms, X-Ray tracing
- **CI/CD** : GitHub Actions pour déploiement automatisé

### Environnements
- **Dev** : Environnement de développement complet
- **Prod** : Environnement de production avec configurations optimisées

## Déploiement

### Prérequis
- AWS CLI configuré
- Terraform >= 1.4.0
- Node.js pour le frontend

### Déploiement infrastructure
```bash
cd infra/env/dev
terraform init
terraform plan
terraform apply
```

### Déploiement application
```bash
# Frontend
cd app/spotify_ui_frontend
npm install
npm run build
aws s3 sync dist/ s3://your-frontend-bucket

# Lambdas
cd app/lambdas
./build.sh
# Deploy via Terraform ou SAM
```

## Monitoring et observabilité

- **Logs** : CloudWatch Logs pour tous les Lambdas
- **Métriques** : Latence API, erreurs, utilisation ressources
- **Alertes** : Seuils configurés pour les erreurs critiques
- **Tracing** : X-Ray pour le suivi des requêtes distribuées

## Sécurité

- **Chiffrement** : Toutes les données sensibles chiffrées avec KMS
- **Authentification** : JWT via Cognito
- **Autorisation** : Vérification des permissions dans les Lambdas
- **Réseau** : Lambdas dans VPC privé, accès contrôlé via Security Groups

## Performance et scalabilité

- **Serverless scaling** : Lambdas scalent automatiquement
- **CDN** : CloudFront pour la distribution globale
- **Cache** : DynamoDB DAX, CloudFront caching
- **Optimisations** : Compression, minification, lazy loading

## Évolution et maintenance

- **Modularité** : Architecture en modules Terraform réutilisables
- **Tests** : Unit tests, integration tests, end-to-end tests
- **CI/CD** : Déploiements automatisés avec rollback
- **Documentation** : Mise à jour continue de cette doc

---

*Cette documentation est générée automatiquement par GitHub Copilot. Pour toute question ou modification, contactez l'équipe de développement.*