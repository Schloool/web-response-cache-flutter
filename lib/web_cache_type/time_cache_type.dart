import 'package:web_response_cache/web_cache_document.dart';
import 'package:web_response_cache/web_cache_type/abstract_web_cache_type.dart';

/// Cache type only accepting new requests when a given time has passed.
class TimeWebCacheType extends AbstractWebCacheType {

  /// Duration after which new requests get accepted.
  final Duration cacheDuration;

  TimeWebCacheType({required this.cacheDuration});

  @override
  bool useCachedDocument(WebCacheDocument cacheDocument) {
    return DateTime.now().difference(cacheDocument.creationDate).compareTo(cacheDuration) < 0;
  }
}