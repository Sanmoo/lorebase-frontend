import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coverage/coverage.dart';

const double _threshold = 100.0;

Future<void> main(List<String> args) async {
  final packageDir = Directory.current.path;

  // 1. Start flutter test with VM service
  final serviceUriCompleter = Completer<Uri>();

  final testProcess = await Process.start(
    'flutter',
    ['test', '--enable-vm-service=0'],
  );

  // Forward stdout/stderr to console
  testProcess.stdout.transform(utf8.decoder).listen(stdout.write);
  testProcess.stderr.transform(utf8.decoder).listen((line) {
    if (!serviceUriCompleter.isCompleted) {
      final uri = _extractVmServiceUri(line);
      if (uri != null) {
        serviceUriCompleter.complete(uri);
      }
    }
    stderr.write(line);
  });

  // 2. Wait for VM service URI (timeout if not found)
  final serviceUri = await serviceUriCompleter.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      testProcess.kill();
      stderr.writeln(
          'ERROR: Could not find VM service URI from flutter test output');
      exit(1);
    },
  );

  // 3. Collect coverage with function + branch data
  final coverageJson = await collect(
    serviceUri,
    true, // resume isolates after collection
    true, // wait for isolates to pause
    false, // don't include Dart SDK
    {packageDir}, // scope output to package directory
    functionCoverage: true,
    branchCoverage: true,
  );

  // 4. Wait for test process to complete
  final testExitCode = await testProcess.exitCode;
  if (testExitCode != 0) {
    stderr.writeln(
        'ERROR: flutter test failed with exit code $testExitCode');
    exit(testExitCode);
  }

  // 5. Create hitmap from collected JSON
  final hitmap = await createHitmap(
    [coverageJson],
    checkIgnoredLines: true,
    packagePath: packageDir,
  );

  // 6. Calculate percentages
  final totalFiles = <String>{};
  var totalLines = 0;
  var hitLines = 0;
  var totalFunctions = 0;
  var hitFunctions = 0;
  var totalBranches = 0;
  var hitBranches = 0;

  for (final entry in hitmap.entries) {
    if (_isExcluded(entry.key)) continue;
    totalFiles.add(entry.key);
    for (final lineEntry in entry.value.entries) {
      totalLines++;
      if (lineEntry.value > 0) hitLines++;
    }
  }

  // Extract function and branch data from raw JSON
  // (these are stored separately in the coverage JSON from collect())
  final rawFunctions = coverageJson['functionHits'] as Map<String, dynamic>?;
  if (rawFunctions != null) {
    for (final entry in rawFunctions.entries) {
      if (_isExcluded(entry.key)) continue;
      final data = entry.value as Map<String, dynamic>;
      totalFunctions += data['total'] as int? ?? 0;
      hitFunctions += data['hit'] as int? ?? 0;
    }
  }

  final rawBranches = coverageJson['branchHits'] as Map<String, dynamic>?;
  if (rawBranches != null) {
    for (final entry in rawBranches.entries) {
      if (_isExcluded(entry.key)) continue;
      final data = entry.value as Map<String, dynamic>;
      totalBranches += data['total'] as int? ?? 0;
      hitBranches += data['hit'] as int? ?? 0;
    }
  }

  // 7. Calculate percentages
  final linePct = totalLines > 0 ? (hitLines / totalLines) * 100 : 100.0;
  final funcPct =
      totalFunctions > 0 ? (hitFunctions / totalFunctions) * 100 : 100.0;
  final branchPct =
      totalBranches > 0 ? (hitBranches / totalBranches) * 100 : 100.0;

  // 8. Print report
  print('Coverage Report:');
  print('  Files: ${totalFiles.length}');
  print('');
  print('  Lines:     ${linePct.toStringAsFixed(2)}%'
      ' ($hitLines/$totalLines)');
  print('  Functions: ${funcPct.toStringAsFixed(2)}%'
      ' ($hitFunctions/$totalFunctions)');
  print('  Branches:  ${branchPct.toStringAsFixed(2)}%'
      ' ($hitBranches/$totalBranches)');
  print('');
  print('Threshold: ${_threshold.toStringAsFixed(0)}%');

  // 9. Check threshold
  var failed = false;
  failed = _checkMetric('Line', linePct) || failed;
  failed = _checkMetric('Function', funcPct) || failed;
  failed = _checkMetric('Branch', branchPct) || failed;

  if (failed) {
    stderr.writeln('\nQuality gate FAILED');
    exit(1);
  }

  print('\nQuality gate PASSED');
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

Uri? _extractVmServiceUri(String line) {
  final match =
      RegExp(r'http://127\.0\.0\.1:\d+/[A-Za-z0-9_/-]*').firstMatch(line);
  if (match != null) {
    final uri = Uri.tryParse(match.group(0)!);
    if (uri != null && uri.port > 0) return uri;
  }
  return null;
}

bool _isExcluded(String filePath) {
  if (filePath.endsWith('.g.dart') || filePath.endsWith('.freezed.dart')) {
    return true;
  }
  if (filePath.contains('/test/')) return true;
  return false;
}
