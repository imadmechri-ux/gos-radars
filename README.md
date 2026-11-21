# Gos Radars

Application web installable (PWA), gratuite, pour la navigation avec alertes de radars fixes.
Même principe que l'app Rahim : une page statique hébergée sur GitHub Pages, installable sur l'écran d'accueil.

## Utilisation

1. Ouvrir l'adresse de l'app sur le téléphone (Safari sur iPhone, Chrome sur Android).
2. Installer : iPhone, Partager → « Sur l'écran d'accueil » ; Android, menu → « Installer l'application ».
3. Autoriser la localisation.
4. Taper une destination et appuyer sur **Chercher**. Choisir l'adresse dans la liste si plusieurs résultats.
5. Choisir un itinéraire parmi les propositions (durée, distance, heure d'arrivée, péages, autoroute).
6. Appuyer sur **Démarrer la navigation**. Le guidage vocal et visuel commence.

## Fonctionnalités

**Itinéraire**
- Calcul via Valhalla (OpenStreetMap), avec jusqu'à 3 propositions.
- Options mémorisées sur l'appareil : éviter les **péages**, les **autoroutes**, les **ferries**, les **pavés et chemins** (routes non goudronnées).
- Recalcul automatique si vous vous éloignez de l'itinéraire.
- Durée restante, distance restante et heure d'arrivée estimée.

**Guidage**
- Prochaine instruction en français, avec la distance.
- Annonces vocales à environ 400 m, puis au moment de la manœuvre.
- Carte qui tourne avec le sens de marche pendant la navigation.
- Bouton pour couper la voix.

**Vitesse et limites**
- Vitesse actuelle en km/h, en rouge si vous dépassez la limite de plus de 5 km/h.
- Limite de vitesse du tronçon en cours (source : données de routage, lorsqu'elles sont disponibles).

**Radars**
- 3 206 radars fixes de métropole, issus de la liste officielle du Ministère de l'Intérieur (data.gouv.fr, licence ouverte).
- Alerte vocale et bandeau à environ 700 m d'un radar fixe devant vous.

**Application**
- Mode hors ligne pour l'interface et les radars ; la carte, la recherche et le calcul d'itinéraire nécessitent le réseau.

**Communauté (Supabase)**
- Bouton **!** : signaler un radar mobile, un contrôle, un accident, un bouchon ou un danger, sur sa position.
- Les signalements apparaissent sur la carte en couleur et sont annoncés vocalement à moins de 500 m.
- Question « Toujours là ? » quand on passe près d'un signalement. Trois « Non » retirent le signalement.
- Un signalement expire après 45 minutes, prolongé de 20 minutes à chaque confirmation (90 minutes maximum).
- Limite anti-spam : 5 signalements maximum toutes les 10 minutes par utilisateur.
- Chaque visiteur est connecté de façon anonyme, sans compte à créer.

## Limites actuelles

- **Pas de trafic en temps réel** ni de travaux. Les bouchons et accidents dépendent des signalements des utilisateurs, pas d'un flux de trafic.
- **Radars mobiles et contrôles** : publiés par la communauté. L'utilisateur est responsable de l'usage de ces informations ; le point légal est à valider de son côté.
- **Arrière-plan** : une page web ne suit pas la position quand l'écran est éteint ou quand l'app est fermée. Garder l'app au premier plan et l'écran allumé.
- **Limite de vitesse** : dépend de la qualité des données OpenStreetMap. Elle peut être absente ou inexacte sur certains tronçons.
- **Option « pavés et chemins »** : appliquée au calcul, mais les routes pavées urbaines restent possibles. Son effet exact dépend des données OpenStreetMap.
- **DOM-TOM** : les 103 radars d'outre-mer ne sont pas inclus.
- **Service de routage public** : gratuit mais partagé. Il peut être lent ou indisponible aux heures de pointe. Une auto-hébergement est possible plus tard.

## Configurer la communauté (Supabase, gratuit)

1. Créer un compte sur supabase.com, puis un nouveau projet (région Europe, ex. Frankfurt ou Paris).
2. Dans le projet : **Authentication → Providers → Anonymous sign-ins** → activer.
3. Dans le projet : **SQL Editor → New query**, coller le contenu de `supabase/schema.sql`, puis **Run**.
4. Dans le projet : **Project Settings → API**, copier :
   - **Project URL** (ex. `https://abcdxyz.supabase.co`)
   - **anon public** key (clé publique, sans risque dans le code)
   - Ne jamais utiliser la clé **service_role** dans l'app.
5. Dans le dépôt GitHub, ouvrir `config.js`, renseigner `SUPABASE_URL` et `SUPABASE_ANON_KEY`, puis valider.
6. Attendre le redéploiement GitHub Pages, puis recharger l'app. Le bouton **!** doit être actif.

Sans cette configuration, l'app fonctionne normalement, sans la partie communautaire.

## Mise en ligne (GitHub Pages, gratuit)

1. Dans le dépôt : Settings → Pages.
2. Source : « Deploy from a branch », branche de travail, dossier `/ (root)`.
3. L'adresse sera de la forme `https://imadmechri-ux.github.io/gos-radars/`.

## Structure

```
index.html              Application (carte, GPS, itinéraire, guidage, radars, communauté), tout en un fichier
config.js               Identifiants publics Supabase (à renseigner)
supabase/schema.sql     Schéma de la base communautaire (tables, anti-spam, sécurité RLS)
sw.js                   Service worker (hors ligne)
manifest.webmanifest    Métadonnées PWA
icon-192.png, icon-512.png
data/radars.json        Radars fixes (généré depuis le CSV officiel)
.nojekyll               Désactive Jekyll sur GitHub Pages
```

## Services externes utilisés

- Carte : tuiles OpenFreeMap (style OpenStreetMap).
- Bibliothèque de carte : MapLibre GL JS (cdnjs).
- Itinéraire et limites : Valhalla, serveur public `valhalla1.openstreetmap.de`.
- Recherche d'adresse : Nominatim (OpenStreetMap), limité à une requête à la fois par usage normal.

## Mettre à jour les radars

Le CSV officiel est sur data.gouv.fr (« Liste des radars fixes en France », mis à jour le 30 décembre 2025). Pour le régénérer : conversion du CSV (séparateur `;`, encodage cp1252) vers `data/radars.json` avec les champs `id`, `type`, `vma`, `lat`, `lon`, en ne gardant que la métropole.

## Feuille de route

1. Carte et GPS (fait).
2. Radars fixes et alertes vocales (fait).
3. Itinéraire, options, guidage, vitesse et limites (fait, à tester sur route).
4. Communauté : signalements, confirmations, anti-spam (fait, à configurer dans Supabase).
5. Tests sur route : batterie, précision GPS, comportement en arrière-plan.
