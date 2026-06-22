// Contains pure helpers for Movesense URIs, JSON display, and list handling.
//
// Parts:
// - URI builders for request and subscription operations.
// - JSON and subscription-preview formatters.
// - Small iterable and string helpers used across the example.

import 'dart:convert';

import 'package:carp_movesense_flutter/carp_movesense_flutter.dart';

/// Builds a full MDS request URI from a [serial] and resource path.
///
/// When [resource] is already a full `suunto://` URI, it is returned unchanged.
String? buildRequestUri({required String serial, required String resource}) {
  final trimmedResource = resource.trim();
  if (trimmedResource.startsWith('suunto://')) return trimmedResource;

  final trimmedSerial = serial.trim();
  if (trimmedSerial.isEmpty || trimmedResource.isEmpty) return null;
  return Mds.createRequestUri(
    trimmedSerial,
    normalizeResource(trimmedResource),
  );
}

/// Builds an MDS subscription URI from a [serial] and resource path.
String? buildSubscriptionUri({
  required String serial,
  required String resource,
}) {
  final trimmedSerial = serial.trim();
  final trimmedResource = resource.trim();
  if (trimmedSerial.isEmpty || trimmedResource.isEmpty) return null;
  return Mds.createSubscriptionUri(
    trimmedSerial,
    normalizeResource(trimmedResource),
  );
}

/// Ensures an MDS resource starts with `/`.
String normalizeResource(String resource) {
  return resource.startsWith('/') ? resource : '/$resource';
}

/// Creates a stable key for tracking a subscription in controller state.
String subscriptionKey(String label, String serial) => '$label $serial';

/// Returns a compact single-line preview for a subscription body.
String formatSubscriptionPreview(String body) {
  if (body.isEmpty) return 'No notifications yet.';
  return shorten(body, maxLength: 120);
}

/// Pretty-prints JSON when [body] contains valid JSON; otherwise returns it.
String prettyJson(String body) {
  if (body.isEmpty) return '';
  try {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonDecode(body));
  } catch (_) {
    return body;
  }
}

/// Decodes [body] into a JSON map, returning an empty map for invalid input.
Map<String, dynamic> decodeJsonMap(String body) {
  if (body.isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}

/// Returns the first item in [values], or `null` when [values] is empty.
T? firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  return iterator.moveNext() ? iterator.current : null;
}

/// Flattens [value] and trims it to [maxLength] characters for log display.
String shorten(String value, {int maxLength = 180}) {
  final flattened = value.replaceAll('\n', ' ');
  if (flattened.length <= maxLength) return flattened;
  return '${flattened.substring(0, maxLength)}...';
}
