# Gos Radars

Application web installable (PWA), gratuite, pour la navigation avec alertes de radars fixes.
Même principe que l'app Rahim : une page statique hébergée sur GitHub Pages, installable sur l'écran d'accueil.

## Utilisation

1. Ouvrir l'adresse de l'app sur le téléphone (Safari sur iPhone, Chrome sur Android).
2. Installer : iPhone, Partager → « Sur l'écran d'accueil » ; Android, menu → « Installer l'application ».
3. Ouvrir l'app, appuyer sur **Démarrer**, autoriser la position.
4. Garder l'app ouverte et l'écran allumé. Les alertes vocales et visuelles se déclenchent à environ 700 m d'un radar fixe.

## Fonctionnalités

- Carte OpenStreetMap (OpenFreeMap), position, vitesse et cap en temps réel.
- 3 206 radars fixes de métropole, issus de la liste officielle du Ministère de l'Intérieur (data.gouv.fr, licence ouverte).
- Alerte vocale en français et bandeau à l'approche d'un radar, avec sa limite de vitesse.
- Bandeau rouge si vous dépassez la limite affichée de plus de 5 km/h.
- Mode hors ligne pour l'interface et les radars ; la carte nécessite le réseau.

## Limites actuelles

- **Radars mobiles et contrôles** : non couverts. Leur signalement est encadré par la loi en France ; ce point est à valider avant toute fonction de ce type.
- **Arrière-plan** : une page web ne suit pas la position quand l'écran est éteint ou quand l'app est fermée. Garder l'app au premier plan.
- **DOM-TOM** : les 103 radars d'outre-mer ne sont pas inclus pour l'instant.
- **Itinéraire** : pas encore disponible (prévu, voir feuille de route).
- Les données de radars peuvent être incomplètes ou obsolètes. Restez attentif à la route.

## Mise en ligne (GitHub Pages, gratuit)

1. Dans le dépôt : Settings → Pages.
2. Source : « Deploy from a branch », branche `main` (ou la branche de travail), dossier `/ (root)`.
3. L'adresse sera de la forme `https://imadmechri-ux.github.io/gos-radars/`.

## Structure

```
index.html              Application (carte, GPS, alertes), tout en un fichier
sw.js                   Service worker (hors ligne)
manifest.webmanifest    Métadonnées PWA
icon-192.png, icon-512.png
data/radars.json        Radars fixes (généré depuis le CSV officiel)
.nojekyll               Désactive Jekyll sur GitHub Pages
```

## Mettre à jour les radars

Le CSV officiel est sur data.gouv.fr (« Liste des radars fixes en France »). Le fichier actuel date du 30 décembre 2025. Pour le régénérer, conversion du CSV (séparateur `;`, encodage cp1252) vers `data/radars.json` avec les champs `id`, `type`, `vma`, `lat`, `lon`.

## Feuille de route

1. Carte et GPS (fait).
2. Radars fixes et alertes vocales (fait).
3. Itinéraire : recherche d'adresse, calcul via OSRM, guidage simple.
4. Signalement communautaire : radars mobiles et contrôles, via un backend gratuit (à choisir), après validation légale.
5. Tests sur route : batterie, précision, comportement en arrière-plan.
