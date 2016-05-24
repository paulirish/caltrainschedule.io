var VERSION = '10';

this.addEventListener('install', function(e) {
  e.waitUntil(caches.open(VERSION).then(cache => {
    return cache.addAll([
      '/',
      '/index.html',
      '/sw.js',
      '/stylesheets/default.css',
      '/javascripts/default.js'
    ]);
  }))
});

this.addEventListener('fetch', function(e) {
  e.respondWith(
    caches.match(e.request).then(response => {
      return response || handleNoCacheMatch(e);
    })
  );
});

this.addEventListener('activate', function(e) {
  e.waitUntil(caches.keys().then((keys) => {
    return Promise.all(keys.map(k => {
      if (k !== VERSION) {
        return caches.delete(k);
      }
    }));
  }));
});

function handleNoCacheMatch(e) {
  return fetch(e.request).then(res => {
    return caches.open(VERSION).then(cache => {
      cache.put(e.request, res.clone());
      return res;
    });
  });
}
