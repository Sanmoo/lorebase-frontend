class PaginatedSocialResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const PaginatedSocialResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  factory PaginatedSocialResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    return PaginatedSocialResponse<T>(
      items: rawItems.map((item) => fromJsonT(_stringKeyMap(item))).toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _stringKeyMap(Object? value) {
    return Map<String, dynamic>.from(
      (value as Map).map(
        (key, value) => MapEntry(key as String, _convertJsonValue(value)),
      ),
    );
  }

  static Object? _convertJsonValue(Object? value) {
    if (value is Map) {
      return _stringKeyMap(value);
    }
    if (value is List) {
      return value.map(_convertJsonValue).toList();
    }
    return value;
  }
}
