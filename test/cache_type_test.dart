import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_response_cache/cached_web_request.dart';
import 'package:web_response_cache/web_cache_type/time_cache_type.dart';
import 'package:web_response_cache/web_cache_type/util_web_cache_type.dart';

void main() {

  setUp(() => CachedWebRequest.clearCache());

  group('Test timed cache', () {
    test('Test time cache', () async {
      const testUrl = 'http://worldtimeapi.org/api/timezone/Europe/Berlin';
      final request = CachedWebRequest(url: testUrl, webCacheType: TimeWebCacheType(cacheDuration: const Duration(days: 1)));
      expect(await request.hasCachedDocument(), false);

      var response = await request.startRequest();
      final firstContent = response.body;
      expect(request.isValidResponse(response), true);

      await Future.delayed(const Duration(milliseconds: 100));
      response = await request.startRequest();
      expect(response.body, firstContent,
          reason: 'As the cache duration is longer than the time waited, the cache document should be used');
    });

    test('Test duration timeout', () async {
      const testUrl = 'http://worldtimeapi.org/api/timezone/Europe/Berlin';
      final request = CachedWebRequest(url: testUrl, webCacheType: TimeWebCacheType(cacheDuration: const Duration(milliseconds: 50)));
      expect(await request.hasCachedDocument(), false);

      var response = await request.startRequest();
      final firstContent = response.body;
      expect(request.isValidResponse(response), true,
          reason: 'As the cache duration is longer than the time waited, the cache document should be used');

      await Future.delayed(const Duration(milliseconds: 100));
      response = await request.startRequest();
      expect(response.body != firstContent, true,
          reason: 'As the cache duration is shorter than the time waited, the cache document should not be used');
    });
  });

  group('Test util cache types', () {
    test('Test always use cache', () async {
      const testUrl = 'http://worldtimeapi.org/api/timezone/Europe/Berlin';
      final request = CachedWebRequest(url: testUrl, webCacheType: AlwaysUseCacheType());
      expect(await request.hasCachedDocument(), false);

      var response = await request.startRequest();
      final firstContent = response.body;
      expect(request.isValidResponse(response), true);

      await Future.delayed(const Duration(milliseconds: 50));
      response = await request.startRequest();
      expect(response.body, firstContent,
          reason: 'As the cache is always used, results should be the very same');

      await request.deleteCacheDocument();
      expect(await request.hasCachedDocument(), false);
      response = await request.startRequest();
      expect(response.body != firstContent, true,
          reason: 'After the cache has been cleared, the document is no longer available');
    });

    test('Test never use cache types', () async {
      const testUrl = 'http://worldtimeapi.org/api/timezone/Europe/Berlin';
      final request = CachedWebRequest(url: testUrl, webCacheType: NeverUseCacheType());
      expect(await request.hasCachedDocument(), false);

      var response = await request.startRequest();
      final firstContent = response.body;
      expect(request.isValidResponse(response), true);

      await Future.delayed(const Duration(milliseconds: 50));
      response = await request.startRequest();
      expect(response.body != firstContent, true,
          reason: 'As the cache is never used when getting a valid response, the response values should differ');
    });
  });
}
