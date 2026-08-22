import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_scope.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/shared_preferences_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LocalStorageService storage = SharedPreferencesStorageService();
  await storage.init();

  runApp(
    AppScope(
      storage: storage,
      child: const SuperKidAdventureApp(),
    ),
  );
}
