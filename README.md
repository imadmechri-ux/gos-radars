# gos-radars

Application iPhone (Swift / SwiftUI) de navigation avec alertes radars, inspirée de Coyote.
Usage personnel et test, pas de publication prévue pour l'instant.

## Choix retenus

| Sujet | Décision |
|---|---|
| Plateforme | iOS uniquement, natif Swift + SwiftUI, iOS 17+ |
| Cartes | OpenStreetMap via MapLibre Native (gratuit, sans quota) |
| Routage | OSRM ou Valhalla (serveur public pour les tests, puis auto-hébergé) |
| Radars fixes | Données ouvertes (à confirmer la source exacte), importées localement |
| Radars mobiles et contrôles | Signalements communautaires en temps réel |
| Backend communauté | Supabase (Postgres + temps réel), petit groupe d'utilisateurs |
| Périmètre | France, usage personnel, pas de publication sur l'App Store |

Waze n'a pas d'API publique : il n'est pas utilisé comme source de données.

## Points à valider avant toute diffusion

- **Cadre légal (France)** : les avertisseurs de radars et la signalisation de radars mobiles sont encadrés par le Code de la route. Vérifier la règle exacte avant d'activer les alertes sur radars mobiles, même en usage personnel.
- **Politique App Store** : les apps de détection de radars sont souvent refusées. À garder en tête si publication un jour.
- **Environnement** : le développement se fait sur un Mac avec Xcode. Compte Apple Developer requis pour installer sur iPhone et activer le GPS en arrière-plan.

## Architecture prévue

```
GosRadars/
├── App/            Point d'entrée SwiftUI, navigation par onglets
├── Location/       CLLocationManager, GPS en arrière-plan, vitesse, cap
├── Map/            Carte MapLibre, affichage position et itinéraire
├── Routing/        Client OSRM / Valhalla, calcul d'itinéraire
├── Radars/         Modèle radar, import des radars fixes, recherche géographique
├── Alerts/         Détection par rayon autour de la position, alerte vocale et visuelle
├── Community/      Signalements temps réel (Supabase), antispam simple
└── Tests/          Tests unitaires (logique de détection, import, distances)
```

## Feuille de route

1. **Jalon 1 : base GPS et carte**. Carte OSM centrée sur la position, suivi du GPS, vitesse et cap affichés.
2. **Jalon 2 : radars fixes**. Import des radars depuis les données ouvertes, stockage local, recherche par rayon.
3. **Jalon 3 : alertes**. Alerte vocale (AVSpeechSynthesizer) et visuelle à l'approche d'un radar, avec distance et limite de vitesse.
4. **Jalon 4 : itinéraire**. Recherche d'adresse, calcul via OSRM, guidage tour par tour simple.
5. **Jalon 5 : communauté**. Signalement d'un radar mobile ou d'un contrôle en un geste, diffusé via Supabase.
6. **Jalon 6 : tests terrain** sur route, batterie, GPS en arrière-plan.

## Statut

Démarrage : structure et documentation uniquement. Le code Swift viendra avec le jalon 1, à compiler et tester sur Mac.

## Jalon 1 : mise en place sur Mac

1. `brew install xcodegen`
2. `xcodegen generate` à la racine du dépôt
3. Ouvrir `GosRadars.xcodeproj`, vérifier la version du paquet MapLibre dans `project.yml`
4. Lancer sur iPhone (compte Apple Developer requis pour l'appareil réel)
5. Autoriser la position « Pendant l'utilisation », puis « Toujours » pour le suivi en arrière-plan

Le jalon 1 n'affiche aucune alerte radar. Le code n'a pas été compilé dans l'environnement de développement (Linux) : premier build à faire sur Mac.