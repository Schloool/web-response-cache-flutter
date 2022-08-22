library web_response_cache;

/// A persistence structure used to save a response which has been sent successfully.
class WebCacheDocument {

  /// The [DateTime] at which the document was created.
  final DateTime creationDate;

  final Map<String, String> headers;

  /// The value of the response body that has been saved.
  final String responseValue;

  WebCacheDocument({required this.creationDate, required this.headers, required this.responseValue});

  factory WebCacheDocument.fromJson(Map<String, dynamic> json) {
    return WebCacheDocument(
      creationDate: DateTime.fromMillisecondsSinceEpoch(json['creationDate']),
      headers: (json['headers'] as Map).cast<String, String>(),
      responseValue: json['responseValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationDate': creationDate.millisecondsSinceEpoch,
      'headers': headers,
      'responseValue': responseValue,
    };
  }
}
