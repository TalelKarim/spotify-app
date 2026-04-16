# Documentation

Ce dossier centralise les diagrammes d'architecture et les diagrammes de séquence du projet.

## Structure

- `architecture/` : vues globales et vues de structure du système
- `sequences/` : flux métier détaillés en diagrammes de séquence

## Fichiers disponibles

### Architecture

- [architecture/global-architecture.drawio](architecture/global-architecture.drawio) : vue d'ensemble de la plateforme, de la SPA jusqu'aux composants serverless AWS et aux flux de données principaux

### Séquences

- [sequences/track-play-flow.puml](sequences/track-play-flow.puml) : lecture d'un titre et propagation du `TrackPlayed`
- [sequences/track-upload-validation-flow.puml](sequences/track-upload-validation-flow.puml) : création, upload, validation et indexation d'un titre
- [sequences/search-flow.puml](sequences/search-flow.puml) : recherche de titres via API Gateway et OpenSearch
- [sequences/listening-history-flow.puml](sequences/listening-history-flow.puml) : récupération de l'historique d'écoute enrichi
- [sequences/analytics-orchestration-flow.puml](sequences/analytics-orchestration-flow.puml) : orchestration des agrégats piste, utilisateur et globaux

## Outils recommandés

- `global-architecture.drawio` : ouvrir avec diagrams.net ou l'extension Draw.io pour VS Code
- fichiers `.puml` : ouvrir avec une extension PlantUML ou générer en PNG/SVG via votre toolchain PlantUML

## Convention

Les diagrammes documentent l'état actuel du dépôt et distinguent les composants réellement implémentés des placeholders encore présents dans le code.