'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "1b0d103dba6bab75314a5b84945eb7fc",
"index.html": "170560fddd84f7b97040fbf5ec15026c",
"/": "170560fddd84f7b97040fbf5ec15026c",
"main.dart.js": "a32a52e11b0d14c4e51eec5f08bd5f1d",
"favicon.png": "afcfe79f6e43a7d34e84dff207a6036f",
"icons/Icon-192.png": "9c413ec582fe598e71b7260bbd61dc09",
"icons/Icon-512.png": "02b646b3b8cbc40ea581acb529fa3a9d",
"manifest.json": "90badf870bad55ee8c7eab3f24c803a6",
"assets/AssetManifest.json": "4ec49fac0321505018502d4ff9f4ee85",
"assets/NOTICES": "4a031e843d45afe991945c20835f38f3",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/runevm_fl/assets/bridge.js": "16f011750fa2437cd79a68b4f53bce75",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/assets/images/rune_placeholder.png": "c7981722b582fa073e3f8a33531fd26b",
"assets/assets/images/icons/menu_down_background.png": "0615b41672e5497519daf3930bf18604",
"assets/assets/images/icons/icon_history.png": "13939e89b6b99b2e06ce0d8d987ce682",
"assets/assets/images/icons/search.png": "65c9293e5bd86461dcf808921c315465",
"assets/assets/images/icons/icon_model.png": "fbd8d111d9eec565d6878f2608884e34",
"assets/assets/images/icons/icon_chart.png": "445bb8f2177407e552720cfd072b81b2",
"assets/assets/images/icons/icon_user.png": "f095fa52e9286e8e4f306f500244a6a6",
"assets/assets/images/icons/filter.png": "4ec6fd70a2a48da69ce81878f099bc25",
"assets/assets/images/icons/icon_home.png": "157c3cabb9f218220e05dbea4b84db02",
"assets/assets/images/icons/qr.png": "582589ff17c3331bd25351aea03e9f11",
"assets/assets/images/icons/paste.png": "c66b9c8a16c18a9ce84bdc339d7b45ae",
"assets/assets/images/icons/notification.png": "d3031a26aa53f632e7ae82d03433d255",
"assets/assets/images/background_shapes/shape_4.png": "4488edfb41f64fe6555173b1be701d44",
"assets/assets/images/background_shapes/shape_2.png": "53a0f480dd53c0f63f075ca2cdf0ef78",
"assets/assets/images/background_shapes/shape_3.png": "891f239f344a1b99888513a2e277dc9a",
"assets/assets/images/background_shapes/shape_1.png": "14e44d88346b82adfb807cf900dc56cd"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
