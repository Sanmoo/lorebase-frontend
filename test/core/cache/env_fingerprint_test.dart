import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/env_fingerprint.dart';

void main() {
  group('envFingerprintOf', () {
    test('is deterministic for the same baseUrl', () {
      expect(
        envFingerprintOf('https://api.example.com'),
        envFingerprintOf('https://api.example.com'),
      );
    });

    test('differs for different baseUrls', () {
      expect(
        envFingerprintOf('https://api.example.com'),
        isNot(envFingerprintOf('https://dev.example.com')),
      );
    });

    test('is stable across calls and matches the documented algorithm', () {
      // Locks the djb2 hash so a future refactor (e.g. to hashCode, whose
      // seed is randomized per process) is caught.
      expect(envFingerprintOf('https://api.example.com'), '314dca91');
      expect(envFingerprintOf(''), '00001505');
    });

    test('is a plain lowercase hex segment', () {
      final fingerprint = envFingerprintOf('https://qa.api.example.com/v1');
      expect(fingerprint, matches(RegExp(r'^[0-9a-f]{8}$')));
      expect(fingerprint.contains(':'), false);
    });
  });
}
