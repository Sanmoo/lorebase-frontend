import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'amplifyconfiguration.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb && const bool.fromEnvironment('E2E')) {
    SemanticsBinding.instance.ensureSemantics();
  }
  usePathUrlStrategy();
  try {
    await dotenv.load(
      fileName: const String.fromEnvironment('ENV_FILE', defaultValue: '.env'),
    );
  } catch (e) {
    debugPrint('Warning: .env file not found, using defaults');
  }
  await _configureHive();
  await _configureAmplify();
  runApp(const ProviderScope(child: LorebaseApp()));
}

Future<void> _configureHive() async {
  try {
    await Hive.initFlutter();
    await Hive.openBox('cache');
  } catch (e) {
    debugPrint('Could not configure Hive cache: $e');
  }
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    debugPrint('Could not configure Amplify: $e');
  }
}
