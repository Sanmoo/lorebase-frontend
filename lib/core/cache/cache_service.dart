import 'package:hive/hive.dart';
import 'cache_entry.dart';

class CacheService {
  final Map<String, CacheEntry> _memory = {};
  final Box? _hiveBox;

  CacheService([this._hiveBox]);

  CacheEntry? getSync(String key) => _memory[key];

  CacheEntry? getFromDiskSync(String key) {
    final raw = _hiveBox?.get(key);
    if (raw == null) return null;
    final entry = CacheEntry.fromJson(
      Map<String, dynamic>.from(raw as Map),
    );
    _memory[key] = entry;
    return entry;
  }

  Future<void> set(String key, CacheEntry entry) async {
    _memory[key] = entry;
    await _hiveBox?.put(key, entry.toJson());
  }

  Future<void> remove(String key) async {
    _memory.remove(key);
    await _hiveBox?.delete(key);
  }

  Future<void> removeByPrefix(String prefix) async {
    if (_hiveBox == null) {
      _memory.removeWhere((k, _) => k.startsWith(prefix));
      return;
    }
    final keysToRemove = _hiveBox!.keys
        .where((k) => k.toString().startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _memory.remove(key);
      await _hiveBox!.delete(key);
    }
  }

  Future<void> clearAll() async {
    _memory.clear();
    await _hiveBox?.clear();
  }
}
