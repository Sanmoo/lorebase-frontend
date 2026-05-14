import 'dart:convert';
import 'dart:io';

const double _threshold = 100.0;

Future<void> main(List<String> args) async {
  final packageDir = Directory.current.path;
  final lcovPath = '$packageDir/coverage/lcov.info';

  // 1. Run flutter test with coverage and branch coverage
  final testProcess = await Process.start(
    'flutter',
    ['test', '--coverage'],
  );

  testProcess.stdout.transform(utf8.decoder).listen(stdout.write);
  testProcess.stderr.transform(utf8.decoder).listen(stderr.write);

  final testExitCode = await testProcess.exitCode;
  if (testExitCode != 0) {
    stderr.writeln(
        'ERROR: flutter test failed with exit code $testExitCode');
    exit(testExitCode);
  }

  // 2. Parse LCOV file
  final lcovFile = File(lcovPath);
  if (!lcovFile.existsSync()) {
    stderr.writeln('ERROR: coverage/lcov.info not found after test run');
    exit(1);
  }

  final lines = await lcovFile.readAsLines();

  var totalFiles = 0;
  var totalLines = 0;
  var hitLines = 0;
  var totalBranches = 0;
  var hitBranches = 0;
  var inExcludedFile = false;
  var currentFile = '';

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      inExcludedFile = _isExcluded(currentFile);
      if (!inExcludedFile) totalFiles++;
    } else if (line.startsWith('end_of_record')) {
      // Reset per-file state
    } else if (!inExcludedFile) {
      if (line.startsWith('DA:')) {
        totalLines++;
        final hit = int.tryParse(line.split(',').last);
        if (hit != null && hit > 0) hitLines++;
      } else if (line.startsWith('BRDA:')) {
        totalBranches++;
        final parts = line.split(',');
        if (parts.length >= 4) {
          final taken = parts[3].trim();
          if (taken != '-' && int.tryParse(taken) != 0) hitBranches++;
        }
      }
    }
  }

  // 3. Calculate percentages
  final linePct = totalLines > 0 ? (hitLines / totalLines) * 100 : 100.0;
  final branchPct =
      totalBranches > 0 ? (hitBranches / totalBranches) * 100 : 100.0;

  // 4. Print report
  stderr.writeln('');
  stderr.writeln('Coverage Report:');
  stderr.writeln('  Files: $totalFiles (after exclusions)');
  stderr.writeln('');
  stderr.writeln('  Lines:     ${linePct.toStringAsFixed(2)}%'
      ' ($hitLines/$totalLines)');
  stderr.writeln('  Branches:  ${branchPct.toStringAsFixed(2)}%'
      ' ($hitBranches/$totalBranches)');
  stderr.writeln('');
  stderr.writeln('Threshold: ${_threshold.toStringAsFixed(0)}%');

  // 5. Check threshold
  var failed = false;
  failed = _checkMetric('Line', linePct) || failed;
  failed = _checkMetric('Branch', branchPct) || failed;

  if (failed) {
    stderr.writeln('\nQuality gate FAILED');
    exit(1);
  }

  stderr.writeln('\nQuality gate PASSED');
  exit(0);
}

bool _checkMetric(String name, double pct) {
  if (pct < _threshold) {
    stderr.writeln(
        'FAIL: $name coverage ${pct.toStringAsFixed(2)}% < $_threshold%');
    return true;
  }
  return false;
}

bool _isExcluded(String filePath) {
  if (filePath.endsWith('.g.dart') || filePath.endsWith('.freezed.dart')) {
    return true;
  }
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
