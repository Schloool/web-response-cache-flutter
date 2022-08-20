import 'package:web_response_cache/web_cache_document.dart';

abstract class AbstractWebCacheType {

  bool useCachedDocument(WebCacheDocument cacheDocument);
}