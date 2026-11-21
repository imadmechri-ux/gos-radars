const CACHE = "gos-radars-v5";
const SHELL = ["./", "index.html", "manifest.webmanifest", "icon-192.png", "icon-512.png", "data/radars.json", "config.js"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // Bibliothèque de carte depuis le CDN : cache d'abord.
  if (url.hostname === "cdnjs.cloudflare.com") {
    e.respondWith(
      caches.open(CACHE).then((c) =>
        c.match(req).then((hit) => hit || fetch(req).then((res) => { c.put(req, res.clone()); return res; }))
      )
    );
    return;
  }

  // Coquille et données locales : réseau d'abord, repli sur le cache.
  if (url.origin === location.origin) {
    e.respondWith(
      fetch(req)
        .then((res) => { if (res.ok) caches.open(CACHE).then((c) => c.put(req, res.clone())); return res; })
        .catch(() => caches.match(req, { ignoreSearch: true }).then((hit) => hit || caches.match("index.html")))
    );
  }
  // Tuiles de carte et autres hôtes : pas de cache (volumineux, toujours à jour).
});
