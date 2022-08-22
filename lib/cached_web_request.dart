import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_response_cache/web_cache_document.dart';
import 'package:web_response_cache/web_cache_type/abstract_web_cache_type.dart';

/// Core class for creating a new web request using the package cache system.
class CachedWebRequest {

  /// The subfolder name used for the folder where cache files get stored.
  static const String subfolderName = 'web_response_cache';

  /// The URL which is used to send the request.
  final String url;

  /// HTTP headers which get sent with the request.
  final Map<String, String>? headers;

  /// The used cache type.
  final AbstractWebCacheType webCacheType;

  /// The function used to send the request.
  ///
  /// HTTP methods such as GET, POST or PUT or DELETE can be easily set if needed.
  /// However, as mostly only GET should be cached, GET is set as the application default.
  Future<Response> Function(Uri uri, {Map<String, String>? headers}) responseFunction;

  CachedWebRequest({required this.url, required this.webCacheType, this.headers, this.responseFunction = get});

  /// Get the [Directory] where cache files will be saved.
  static Future<Directory> getSaveFolder() async => Directory('${(await getTemporaryDirectory()).path}/$subfolderName');

  /// Clears the cache by deleting the entire cache directory.
  static Future<void> clearCache() async {
    final directory = await getSaveFolder();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  /// Performs the request.
  ///
  /// The resulting [Response] will either be obtained from a valid cache file or a web request.
  /// If a valid web [Response] has been sent, it will be saved in the cache.
  /// If setting [forceNewRequest] to true, not using the cache will be prioritized.
  Future<Response> startRequest({bool forceNewRequest = false}) async {
    final currentlyHasCachedDocument = await hasCachedDocument();
    if (currentlyHasCachedDocument) {
      final WebCacheDocument cacheDocument = await loadCachedDocument();
      if (webCacheType.useCachedDocument(cacheDocument) && !forceNewRequest) {
        return buildResponseFromDocument(cacheDocument);
      }
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return Response('Invalid URL format.', 500);
    }

    try {
      Response response = await responseFunction.call(Uri.parse(url), headers: headers);
      if (isValidResponse(response)) {
        await saveNewCacheResponse(response);
      } else if (currentlyHasCachedDocument) {
        // if the response was not valid and there are save-data, use them anyways
        response = buildResponseFromDocument(await loadCachedDocument());
      }

      return response;
    } catch (e) {
      return Response('An error occurred while performing the request.', 500);
    }
  }

  Response buildResponseFromDocument(WebCacheDocument document) {
    return Response(document.responseValue, 200, headers: document.headers);
  }

  /// Function used to validate whether a given response is valid for being saved in a [WebCacheDocument].
  ///
  /// Should return true if the [Response] is valid for being saved, otherwise false.
  bool isValidResponse(Response response) => response.statusCode >= 200 && response.statusCode < 300;

  /// Returns the [File] in which this [CachedWebRequest] will be saved.
  ///
  /// The returned [File] might not exist.
  Future<File> getCacheFile() async {
    final folder = await CachedWebRequest.getSaveFolder();
    return File('${folder.path}/${getFileName()}');
  }

  /// Saves the given [response] into the corresponding persistent [WebCacheDocument].
  Future<void> saveNewCacheResponse(Response response) async {
    final cacheDocument = WebCacheDocument(creationDate: DateTime.now(), headers: response.headers, responseValue: serializeResponseBody(response));
    final folder = await getSaveFolder();
    final file = await getCacheFile();

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    if (!await file.exists()) {
      await file.create();
    }

    final jsonContent = jsonEncode(cacheDocument.toJson());
    await file.writeAsString(jsonContent);
  }

  /// Function used to get the serialized form of a valid response.
  ///
  /// Can be overwritten to realize a custom serialization logic.
  String serializeResponseBody(Response response) => response.body;

  /// Whether this [CachedWebRequest] already has a cached [WebCacheDocument] or not.
  ///
  /// Returns true if a [WebCacheDocument] already exists, otherwise false.
  Future<bool> hasCachedDocument() async => (await getCacheFile()).exists();

  /// The name which will be used for generating a [WebCacheDocument] file.
  String getFileName() => '${url.replaceAll(RegExp(r'[/:.]'), '')}.json';

  /// Loads the corresponding [WebCacheDocument] for the given request [url].
  Future<WebCacheDocument> loadCachedDocument() async {
    final cacheFile = await getCacheFile();
    final jsonContent = await cacheFile.readAsString();
    final json = jsonDecode(jsonContent);

    return WebCacheDocument.fromJson(json);
  }

  /// Deletes the cache file for the request.
  Future<void> deleteCacheDocument() async {
    if (await hasCachedDocument()) {
      await (await getCacheFile()).delete();
    }
  }
}