class CacheEntry {
  final String json;
  final DateTime cachedAt;
  final Duration ttl;

  const CacheEntry({
    required this.json,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isFresh => DateTime.now().isBefore(cachedAt.add(ttl));

  Map<String, dynamic> toJson() => {
        'json': json,
        'cachedAt': cachedAt.toIso8601String(),
        'ttl': ttl.inSeconds,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> map) => CacheEntry(
        json: map['json'] as String,
        cachedAt: DateTime.parse(map['cachedAt'] as String),
        ttl: Duration(seconds: map['ttl'] as int),
      );
}
