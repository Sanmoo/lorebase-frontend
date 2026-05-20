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
      items: rawItems
          .map((item) => fromJsonT(Map<String, dynamic>.from(item as Map)))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
