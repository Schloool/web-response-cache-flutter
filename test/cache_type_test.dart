import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_response_cache/cached_web_request.dart';
import 'package:web_response_cache/web_cache_type/time_cache_type.dart';

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
      expect(response.body, firstContent);
    });

    test('Test duration timeout', () async {
      const testUrl = 'http://worldtimeapi.org/api/timezone/Europe/Berlin';
      final request = CachedWebRequest(url: testUrl, webCacheType: TimeWebCacheType(cacheDuration: const Duration(milliseconds: 50)));
      expect(await request.hasCachedDocument(), false);

      var response = await request.startRequest();
      final firstContent = response.body;
      expect(request.isValidResponse(response), true);

      await Future.delayed(const Duration(milliseconds: 100));
      response = await request.startRequest();
      expect(response.body != firstContent, true);
    });
  });
}
