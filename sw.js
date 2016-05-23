var VERSION = '0.0.1';

this.addEventListener('install', function(e) {
  e.waitUntil(caches.open(VERSION).then(cache => {
    return cache.addAll([
      '/',
      '/index.html',
      '/sw.js',
      '/stylesheets/default.css',
      '/javascripts/default.js',
      '/javascripts/jquery-2.1.0.min.js',
      '/images/switcher.png',
      '/data/routes.json',
      '/data/stops.json',
      '/data/calendar_dates.json',
      '/data/calendar.json',
    ]);
}))});

this.addEventListener('fetch', function(e) {
  e.respondWith(caches.match(e.request).catch(_ => {
    return handleNoCacheMatch();
  }));
});

this.addEventListener('active', function(e) {
  e.waitUntil(caches.key().then((keys) => {
    return Promise.all(keys.map(k => {
      if (k !== VERSION) {
        return caches.delete(k);
      }
    }));
}))});

function handleNoCacheMatch(e) {
  return fetch(e.request).then(res => {
    caches.open(VERSION).then(cache => {
      cache.put(e.request, res.clone());
      return res;
    });
  });
}
