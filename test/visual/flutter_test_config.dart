import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: const PlatformGoldensConfig(
        enabled: true,
      ),
      theme: ThemeData.light(),
      ciGoldensConfig: const CiGoldensConfig(
        enabled: true,
      ),
    ),
    run: testMain,
  );
}
