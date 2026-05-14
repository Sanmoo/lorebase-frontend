import 'dart:io';

bool isExcluded(String filePath) {
  if (filePath.endsWith('.g.dart') || filePath.endsWith('.freezed.dart')) return true;
  if (filePath.contains('/test/')) return true;
  if (filePath.endsWith('api_constants.dart')) return true;
  if (filePath.endsWith('core_providers.dart')) return true;
  if (filePath.endsWith('app_theme.dart')) return true;
  if (filePath.endsWith('dio_client.dart')) return true;
  if (filePath.endsWith('auth_repository.dart')) return true;
  if (filePath.endsWith('auth_interceptor.dart')) return true;
  if (filePath.endsWith('cache_entry.dart')) return true;
  if (filePath.endsWith('cache_providers.dart')) return true;
  if (filePath.endsWith('cache_service.dart')) return true;
  if (filePath.endsWith('locale_provider.dart')) return true;
  if (filePath.endsWith('error_interceptor.dart')) return true;
  if (filePath.endsWith('locale_interceptor.dart')) return true;
  if (filePath.endsWith('exceptions.dart')) return true;
  if (filePath.endsWith('failures.dart')) return true;
  return false;
}

void main() {
  final lines = File('coverage/lcov.info').readAsLinesSync();
  final fileData = <String, Map<String, dynamic>>{};

  String currentFile = '';
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      fileData[currentFile] = {
        'totalLines': 0, 'hitLines': 0,
        'totalBranches': 0, 'hitBranches': 0,
        'uncoveredLines': <int>[],
        'uncoveredBranches': <String>[],
      };
    } else if (line.startsWith('end_of_record')) {
      currentFile = '';
    } else if (currentFile.isNotEmpty) {
      final d = fileData[currentFile]!;
      if (line.startsWith('DA:')) {
        d['totalLines']++;
        final parts = line.substring(3).split(',');
        final hits = int.parse(parts[1]);
        if (hits > 0) {
          d['hitLines']++;
        } else {
          d['uncoveredLines'].add(int.parse(parts[0]));
        }
      } else if (line.startsWith('BRDA:')) {
        d['totalBranches']++;
        final parts = line.substring(5).split(',');
        if (parts.length >= 4) {
          final taken = parts[3].trim();
          if (taken != '-' && int.parse(taken) != 0) {
            d['hitBranches']++;
          } else {
            d['uncoveredBranches'].add('${parts[0]}:${parts[1]}:${parts[2]}');
          }
        }
      }
    }
  }

  int fileCount = 0;
  for (final entry in fileData.entries) {
    final path = entry.key;
    if (isExcluded(path)) continue;
    final d = entry.value;
    final linePct = d['totalLines'] > 0 ? (d['hitLines'] / d['totalLines']) * 100 : 100.0;
    final branchPct = d['totalBranches'] > 0 ? (d['hitBranches'] / d['totalBranches']) * 100 : 100.0;
    if (linePct < 100 || branchPct < 100) {
      print(path);
      print('  Lines: ${linePct.toStringAsFixed(1)}% (${d['hitLines']}/${d['totalLines']})');
      if (d['uncoveredLines'].length <= 30) {
        print('    Uncovered lines: ${d['uncoveredLines']}');
      }
      print('  Branches: ${branchPct.toStringAsFixed(1)}% (${d['hitBranches']}/${d['totalBranches']})');
      if (d['uncoveredBranches'].length <= 30) {
        print('    Uncovered branches: ${d['uncoveredBranches']}');
      }
      print('');
      fileCount++;
    }
  }

  if (fileCount == 0) {
    print('All non-excluded files at 100% coverage!');
  } else {
    print('$fileCount uncovered file(s) total');
  }
}
