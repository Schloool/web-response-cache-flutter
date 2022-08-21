import 'package:flutter_test/flutter_test.dart';
import 'package:web_response_cache/web_cache_document.dart';

void main() {
  test('Test cache document serialization and deserialization', () {
    final testDocument = WebCacheDocument(creationDate: DateTime.now(), responseValue: 'Response');
    final documentJson = testDocument.toJson();
    final parsedDocument = WebCacheDocument.fromJson(documentJson);

    expect(testDocument.responseValue, parsedDocument.responseValue,
        reason: 'Response values should match when deserializing the object');
    expect(testDocument.creationDate.millisecondsSinceEpoch, parsedDocument.creationDate.millisecondsSinceEpoch,
        reason: 'Time values should match when deserializing the object');
  });
}
