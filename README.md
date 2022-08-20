# Introduction
This package is used for caching responses obtained from web requests.
There are no limitations in which representations (such as JSON, HTML, XML, ...) are cached. All major HTTP verbs such as GET, POST, PUT and DELETE are supported.

It is currently planned to extend the package with more cache types as well as more cache-related fields in the future.
Feel free to send ideas and feedback using the [GitHub Issue Board](https://github.com/Schloool/web-response-cache-flutter/issues).

## Example
Using a simple time cache for a JSON response:
````
const testUrl = 'http://worldtimeapi.org/api/timezone/Europe/Berlin';
final cachedRequest = CachedWebRequest(url: testUrl, webCacheType: TimeWebCacheType(cacheDuration: const Duration(days: 1)));
var response = await cachedRequest.startRequest();
...

// response body will have the same body content for the duration of one day
response = await cachedRequest.startRequest();
````

## Dependencies
 - [http](https://pub.dev/packages/http) (used for sending HTTP requests)
 - [path_provider](https://pub.dev/packages/path_provider) (used for getting the temporary cache directory)

## Contributing
Contributions to the [GitHub Repository](https://github.com/Schloool/web-response-cache-flutter) are very welcomed.
I also appreciate feature requests as well as bug reports using the [GitHub Issue Board](https://github.com/Schloool/web-response-cache-flutter/issues).