import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/utils/json_converters.dart';

void main() {
  group('flexibleIntFromJson', () {
    test('returns int when input is int', () {
      expect(flexibleIntFromJson(42), 42);
      expect(flexibleIntFromJson(0), 0);
      expect(flexibleIntFromJson(-1), -1);
    });

    test('parses int when input is String', () {
      expect(flexibleIntFromJson('42'), 42);
      expect(flexibleIntFromJson('0'), 0);
      expect(flexibleIntFromJson('123456'), 123456);
    });

    test('throws FormatException for unsupported types', () {
      expect(
        () => flexibleIntFromJson(true),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => flexibleIntFromJson(null),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => flexibleIntFromJson(3.14),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for non-numeric String', () {
      expect(
        () => flexibleIntFromJson('abc'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('flexibleIntToJson', () {
    test('returns the int unchanged', () {
      expect(flexibleIntToJson(42), 42);
      expect(flexibleIntToJson(0), 0);
    });
  });

  group('flexibleStringFromJson', () {
    test('returns String when input is String', () {
      expect(flexibleStringFromJson('hello'), 'hello');
      expect(flexibleStringFromJson(''), '');
    });

    test('converts int to String when input is int', () {
      expect(flexibleStringFromJson(42), '42');
      expect(flexibleStringFromJson(0), '0');
      expect(flexibleStringFromJson(-1), '-1');
    });

    test('returns empty string for null input', () {
      expect(flexibleStringFromJson(null), '');
    });

    test('throws FormatException for unsupported types', () {
      expect(
        () => flexibleStringFromJson(true),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => flexibleStringFromJson(3.14),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('flexibleStringToJson', () {
    test('returns the String unchanged', () {
      expect(flexibleStringToJson('hello'), 'hello');
      expect(flexibleStringToJson(''), '');
    });
  });
}
