var VERSION = '19';

this.addEventListener('install', async function(e) {
  const cache = await caches.open(VERSION);

  await cache.addAll([
      '/',
      '/index.html',
      '/sw.js',
      '/stylesheets/default.css',
      '/javascripts/default.js'
    ]);
});

this.addEventListener('fetch', function(e) {
  async function tryInCachesFirst() {
    const cache = await caches.open(VERSION);
    const response = await cache.match(e.request);

    if (!response) {
      return handleNoCacheMatch(e);
    }
    // Update cache record in the background
    fetchFromNetworkAndCache(e);
    // Reply with stale data
    return response;
  }
  e.respondWith(tryInCachesFirst());
});

this.addEventListener('activate', async function(e) {
  const keys = await caches.keys();

  keys.forEach(async key => {
    if (key !== VERSION)
      await caches.delete(key);
  });
});

async function fetchFromNetworkAndCache(e) {
  try {
    const res = await fetch(e.request);
    // foreign requests may be res.type === 'opaque' and missing a url
    if (!res.url) return res;
    // regardless, we don't want to cache other origin's assets
    if (new URL(res.url).origin !== location.origin) return res;

    const cache = await caches.open(VERSION);
    // TODO: figure out if the content is new and therefore the page needs a reload.
    cache.put(e.request, res.clone());
    return res;
    
  } catch (err) { 
    console.error(e.request.url, err); 
  }

}

function handleNoCacheMatch(e) {
  return fetchFromNetworkAndCache(e);
}