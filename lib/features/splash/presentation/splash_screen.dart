import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/data/auth_local_datasource.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.initialLoggedIn, super.key});

  final bool initialLoggedIn;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _goNext();
  }

  Future<void> _goNext() async {
    final sessionFuture = getIt<AuthLocalDataSource>().checkSession();
    await Future<void>.delayed(const Duration(seconds: 3));
    final isLoggedIn = widget.initialLoggedIn || await sessionFuture;

    if (!mounted) return;
    context.go(isLoggedIn ? RouteNames.home : RouteNames.auth);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bgBottom = isDark ? const Color(0xFF06070B) : AppColors.backgroundWarm;
    final bgMid = isDark ? const Color(0xFF0F0F16) : const Color(0xFFFFE8B8);
    final bgTop = isDark ? const Color(0xFF282836) : const Color(0xFFFFFBF2);
    final textColor = isDark ? AppColors.textPrimary : AppColors.textDark;
    final subTextColor = isDark ? AppColors.textSecondary : AppColors.textTertiary;

    return CupertinoPageScaffold(
      backgroundColor: bgBottom,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [bgTop, bgMid, bgBottom],
            stops: const [0, 0.54, 1],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: RepaintBoundary(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/branding/IkonJS.png',
                      width: 184,
                      height: 184,
                      fit: BoxFit.contain,
                      cacheWidth: 256,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'JogjaSplorasi',
                      style: AppTypography.displayBold34.copyWith(
                        color: textColor,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kanca jelajahmu di Yogyakarta',
                      style: AppTypography.textRegular13.copyWith(
                        color: subTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
