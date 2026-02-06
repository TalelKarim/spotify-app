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

4. Use cases fonctionnels

UC-01 — Consulter les métadonnées d’un track

L’utilisateur récupère les informations d’un morceau (titre, artiste, durée, etc.).


UC-02 — Démarrer l’écoute d’un track

L’utilisateur clique sur “Play”.
Le backend vérifie les droits et retourne une URL CloudFront signée.
Le streaming est effectué directement depuis le CDN.

UC-03 — Enregistrer une écoute

Chaque écoute génère un événement métier TrackPlayed, traité de manière asynchrone.

UC-04 — Mettre à jour les statistiques

Les statistiques d’écoute (track, utilisateur) sont mises à jour sans impacter l’utilisateur.

UC-05 — Notifications (future extension)

Possibilité de notifier l’utilisateur ou des systèmes tiers.

UC-06 — Recherche de contenu

Recherche textuelle sur les tracks via un moteur d’indexation.

UC-07 — Opérations techniques

Ingestion de données audio, re-indexation, maintenance.