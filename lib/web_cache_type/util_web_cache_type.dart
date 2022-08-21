import 'package:web_response_cache/web_cache_document.dart';
import 'package:web_response_cache/web_cache_type/abstract_web_cache_type.dart';

/// A cache type only used when no valid response is available.
class NeverUseCacheType extends AbstractWebCacheType {

  @override
  bool useCachedDocument(WebCacheDocument cacheDocument) => false;
}

/// A cache type used whenever possible.
///
/// Once a successful response has been saved, it will be used until the cache gets manually reset.
class AlwaysUseCacheType extends AbstractWebCacheType {

  @override
  bool useCachedDocument(WebCacheDocument cacheDocument) => true;
}