import 'dart:convert';

/// Short, deterministic fingerprint of the backend environment identified by
/// [baseUrl]. It is embedded in every physical cache key so that entries
/// written against one environment are never served for another.
///
/// The result is plain lowercase hex, so it is always safe inside a key
/// segment (no `:`), and it is stable across runs and platforms.
///
/// [String.hashCode] is deliberately not used: its seed is randomized per
/// process, which would produce a different key every launch. The arithmetic
/// below is a djb2 rolling hash kept within 2^53 so it stays exact on the web
/// (where `int` is a double), and it avoids `Object.hash` for the same reason.
String envFingerprintOf(String baseUrl) {
  var hash = 5381;
  for (final byte in utf8.encode(baseUrl)) {
    hash = (hash * 33 + byte) % 0x100000000;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
