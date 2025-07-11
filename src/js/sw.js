self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open('v1').then(function (cache) {
      return cache.addAll([
        '/',
        '/index.html',
        '/src/index.js',
        '/src/urls.cfg',
        '/src/index.css',
        '/src/js/chart.umd.js',
        '/src/js/dataProcessing.js',
        '/src/js/domManipulation.js',
        '/src/js/fetchurlsconfig.js',
        '/src/js/genReports.js',
        '/src/js/getclieninfo.js',
        '/src/js/getyear.js',
        '/src/js/lastupdated.js',
        '/src/js/reloadreports.js',
        '/src/js/reslogs.js',
        '/src/js/scroll.js',
        '/src/js/timelapsechart.js',
        '/src/js/tooltip.js',
        '/src/js/utils.js',
        '/src/js/scrollreveal.min.js',
        '/src/js/startanimation.js',
        '/src/images/favicon.ico',
        '/src/images/logo.svg',
        '/src/images/logo.png',
        '/src/images/partial.svg',
        '/src/images/failure.svg',
        '/src/images/nodata.svg',
        '/src/images/success.svg',

        // 本地日志
        '/logs/Web_report.log',
        '/logs/Dev_report.log',
        '/logs/Google_report.log'

        // 网络资源

      ]);
    })
  );
});

const putInCache = async (request, response) => {
  const cache = await caches.open("v1");
  await cache.put(request, response);
};

const cacheFirst = async ({ request, fallbackUrl }) => {
  // 首先尝试从缓存中获取资源。
  const responseFromCache = await caches.match(request);
  if (responseFromCache) {
    return responseFromCache;
  }
};

self.addEventListener("fetch", (event) => {
  event.respondWith(
    cacheFirst({
      request: event.request,
      fallbackUrl: "/index.html",
    }),
  );
});
