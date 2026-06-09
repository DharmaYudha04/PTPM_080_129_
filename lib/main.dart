import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap/app_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureImageCache();
  final isLoggedIn = await AppInit.initializeCore();

  runApp(ProviderScope(child: JogjaSplorasiApp(initialLoggedIn: isLoggedIn)));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future<void>.microtask(() async {
      try {
        await AppInit.initializeDeferred();
      } catch (_) {
        // Notification setup is non-critical; do not block or crash startup.
      }
    });
  });
}

void _configureImageCache() {
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 96;
  imageCache.maximumSizeBytes = 48 * 1024 * 1024;
}
