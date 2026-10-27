import 'dart:convert';

/// Decodes an MDS JSON [body] into a map.
///
/// An empty body decodes to an empty map. Throws a [FormatException] when the
/// body is not a JSON object.
Map<String, dynamic> decodeJsonObject(String body) {
  if (body.trim().isEmpty) return <String, dynamic>{};
  final decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) return decoded;
  throw FormatException('Expected a JSON object but got ${decoded.runtimeType}.', body);
}
