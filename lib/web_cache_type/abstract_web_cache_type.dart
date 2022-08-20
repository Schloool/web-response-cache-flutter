import 'package:web_response_cache/web_cache_document.dart';

/// Abstraction containing information of when a [CachedWebRequest] will use its cache.
abstract class AbstractWebCacheType {

  /// Function providing information of whether a given [cacheDocument] will be used or not.
  bool useCachedDocument(WebCacheDocument cacheDocument);
}