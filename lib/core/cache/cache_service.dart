import 'package:hive/hive.dart';
import 'cache_entry.dart';

/// Persistent cache backed by Hive, scoped to one backend environment.
///
/// Call sites keep passing the logical keys they always did; the service
/// translates each one to the physical key `env:<fingerprint>:<logical>`.
/// A box shared between environments therefore never serves an entry written
/// against another one.
class CacheService {
  static const String _scopeRoot = 'env';

  /// Short fingerprint of the environment (see `envFingerprintOf`).
  final String envFingerprint;
  final Map<String, CacheEntry> _memory = {};
  final Box? _hiveBox;

  CacheService({required this.envFingerprint, Box? hiveBox})
    : _hiveBox = hiveBox;

  String get _namespace => '$_scopeRoot:$envFingerprint:';

  String _physicalKey(String logicalKey) => '$_namespace$logicalKey';

  CacheEntry? getSync(String key) => _memory[_physicalKey(key)];

  CacheEntry? getFromDiskSync(String key) {
    final physicalKey = _physicalKey(key);
    final raw = _hiveBox?.get(physicalKey);
    if (raw == null) return null;
    try {
      final entry = CacheEntry.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
      _memory[physicalKey] = entry;
      return entry;
    } catch (_) {
      _hiveBox?.delete(physicalKey);
      return null;
    }
  }

  Future<void> set(String key, CacheEntry entry) async {
    final physicalKey = _physicalKey(key);
    _memory[physicalKey] = entry;
    await _hiveBox?.put(physicalKey, entry.toJson());
  }

  Future<void> remove(String key) async {
    final physicalKey = _physicalKey(key);
    _memory.remove(physicalKey);
    await _hiveBox?.delete(physicalKey);
  }

  Future<void> removeByPrefix(String prefix) async {
    final scopedPrefix = _physicalKey(prefix);
    _memory.removeWhere((k, _) => k.startsWith(scopedPrefix));
    final box = _hiveBox;
    if (box == null) return;
    final keysToRemove = box.keys
        .where((k) => k.toString().startsWith(scopedPrefix))
        .toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }
  }

  /// Clears the whole box, including namespaces of other environments.
  ///
  /// Keeps the semantics used on logout and locale change: nothing cached
  /// survives.
  Future<void> clearAll() async {
    _memory.clear();
    await _hiveBox?.clear();
  }

  /// Drops every entry of other environments, including legacy keys written
  /// before cache scoping existed.
  ///
  /// Physical keys already keep environments apart, so this is disk hygiene:
  /// it reclaims the space of previous environments and removes legacy unscoped
  /// keys. Entries of the current environment survive. In-memory entries are
  /// always written under the current namespace, so only the box is purged.
  /// Run it once at boot, after the box is open and before the UI is built.
  Future<void> purgeForeignEnvironments() async {
    final box = _hiveBox;
    if (box == null) return;
    final foreignKeys = box.keys
        .where((k) => !k.toString().startsWith(_namespace))
        .toList();
    for (final key in foreignKeys) {
      await box.delete(key);
    }
  }
}
