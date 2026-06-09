import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'shared/widgets/biometric_app_lock.dart';

class JogjaSplorasiApp extends ConsumerStatefulWidget {
  const JogjaSplorasiApp({required this.initialLoggedIn, super.key});

  final bool initialLoggedIn;

  @override
  ConsumerState<JogjaSplorasiApp> createState() => _JogjaSplorasiAppState();
}

class _JogjaSplorasiAppState extends ConsumerState<JogjaSplorasiApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // GoRouter owns Navigator widgets that use GlobalKeys. Keep the router
    // instance alive for the lifetime of the app so theme/provider rebuilds and
    // bottom-tab navigation do not create duplicate Navigator GlobalKeys.
    _router = AppRouter.createRouter(
      ref,
      initialLoggedIn: widget.initialLoggedIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    final platformBrightness = MediaQuery.of(context).platformBrightness;

    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JogjaSplorasi',
      theme: themeForMode(themeMode, platformBrightness),
      routerConfig: _router,
      builder: (context, child) {
        return BiometricAppLock(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
