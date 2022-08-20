import 'package:flutter_test/flutter_test.dart';
import 'package:web_response_cache/cached_web_request.dart';
import 'package:web_response_cache/web_cache_type/time_cache_type.dart';

void main() {
  var cacheType = TimeWebCacheType(cacheDuration: const Duration(days: 1));

  setUp(() async => await CachedWebRequest.clearCache());

  group('Test cached request URL logic', () {
    test('Test invalid URL', () async {
      const invalidUrl = 'myInvalidUrl';
      final request = CachedWebRequest(url: invalidUrl, webCacheType: cacheType);
      final response = await request.startRequest();

      expect(request.isValidResponse(response), false);
      expect(response.statusCode, 500);
    });

    test('Test unavailable URL', () async {
      const unavailableUrl = 'http://unavailableUrl.abc';
      final request = CachedWebRequest(url: unavailableUrl, webCacheType: cacheType);
      final response = await request.startRequest();

      expect(request.isValidResponse(response), false);
      expect(response.statusCode, 500);
    });

    test('Test valid URL', () async {
      const unavailableUrl = 'http://google.com/';
      final request = CachedWebRequest(url: unavailableUrl, webCacheType: cacheType);
      final response = await request.startRequest();

      expect(request.isValidResponse(response), true);
      expect(response.statusCode, 200);
    });
  });

  test('Test response file save', () async {
    const url = 'https://google.com/';
    final request = CachedWebRequest(url: url, webCacheType: cacheType);
    expect(await request.hasCachedDocument(), false);
    expect(await (await request.getCacheFile()).exists(), false);

    final response = await request.startRequest();
    expect(request.isValidResponse(response), true);
    expect(await request.hasCachedDocument(), true);
    expect(await (await request.getCacheFile()).exists(), true);
  });
}