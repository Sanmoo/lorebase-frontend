/// Parses a [value] that may be either [int] or [String] into an [int].
///
/// Throws [FormatException] if [value] is neither [int] nor [String],
/// or if the String cannot be parsed as an integer.
int flexibleIntFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to int',
  );
}

/// Returns the [int] value unchanged for JSON serialization.
///
/// Exists so the `@JsonKey` annotation has a symmetric toJson companion
/// for the fromJson converter.
int flexibleIntToJson(int value) => value;

/// Parses a nullable [value] that may be either [int] or [String] into an [int].
int? flexibleNullableIntFromJson(dynamic value) {
  if (value == null) return null;
  return flexibleIntFromJson(value);
}

/// Returns the nullable [int] value unchanged for JSON serialization.
int? flexibleNullableIntToJson(int? value) => value;

/// Converts a [value] that may be [int] or [String] to a [String].
///
/// Used for fields where the API sends an integer but the model uses a [String].
String flexibleStringFromJson(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value == null) return '';
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to String',
  );
}

/// Returns the [String] value unchanged for JSON serialization.
String flexibleStringToJson(String value) => value;
