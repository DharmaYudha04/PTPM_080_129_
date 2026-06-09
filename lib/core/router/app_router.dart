import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_local_datasource.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/converter/presentation/converter_screen.dart';
import '../../features/destination_detail/presentation/destination_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/global_search/presentation/global_search_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mini_game/presentation/mini_game_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/sensor_hub/presentation/sensor_hub_screen.dart';
import '../../features/tpm_about/presentation/tpm_about_screen.dart';
import '../../shared/widgets/floating_tab_bar.dart';
import '../../shared/widgets/global_sensor_layer.dart';
import '../di/injection.dart';
import 'route_names.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
  static final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeBranchNavigator');
  static final GlobalKey<NavigatorState> _exploreNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'exploreBranchNavigator');
  static final GlobalKey<NavigatorState> _guideNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'guideBranchNavigator');
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileBranchNavigator');

  static GoRouter createRouter(WidgetRef ref, {required bool initialLoggedIn}) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.splash,
      redirect: (context, state) async {
        final isLoggedIn = await getIt<AuthLocalDataSource>().checkSession();
        final onAuth = state.uri.path == RouteNames.auth;
        final onSplash = state.uri.path == RouteNames.splash;

        if (onSplash) return null;
        if (!isLoggedIn && !onAuth) return RouteNames.auth;
        if (isLoggedIn && onAuth) return RouteNames.home;
        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (context, state) => SplashScreen(initialLoggedIn: initialLoggedIn),
        ),
        GoRoute(
          path: RouteNames.auth,
          builder: (context, state) => const AuthScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return _MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              routes: [
                GoRoute(
                  path: RouteNames.home,
                  pageBuilder: (context, state) => _softPage(const HomeScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _exploreNavigatorKey,
              routes: [
                GoRoute(
                  path: RouteNames.explore,
                  pageBuilder: (context, state) => _softPage(const ExploreScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _guideNavigatorKey,
              routes: [
                GoRoute(
                  path: RouteNames.guide,
                  pageBuilder: (context, state) => _softPage(
                    GuideScreen(
                      initialPrompt: state.uri.queryParameters['prompt'],
                      destinationContext: state.uri.queryParameters['destination'],
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _profileNavigatorKey,
              routes: [
                GoRoute(
                  path: RouteNames.profile,
                  pageBuilder: (context, state) => _softPage(const ProfileScreen()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.globalSearch,
          pageBuilder: (context, state) =>
              _softPage(const GlobalSearchScreen()),
        ),

        GoRoute(
          path: RouteNames.editProfile,
          pageBuilder: (context, state) =>
              _softPage(const EditProfileScreen()),
        ),
        GoRoute(
          path: RouteNames.feedback,
          pageBuilder: (context, state) =>
              _softPage(const FeedbackScreen()),
        ),
        GoRoute(
          path: RouteNames.tpmAbout,
          pageBuilder: (context, state) =>
              _softPage(const TpmAboutScreen()),
        ),
        GoRoute(
          path: RouteNames.sensor,
          pageBuilder: (context, state) =>
              _softPage(const SensorHubScreen()),
        ),
        GoRoute(
          path: '${RouteNames.destination}/:id',
          pageBuilder: (context, state) => _softPage(
            DestinationDetailScreen(
              destinationId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: RouteNames.converter,
          pageBuilder: (context, state) => _softPage(
            ConverterScreen(
              initialMode: state.uri.queryParameters['tab'] == 'time'
                  ? 'time'
                  : 'currency',
            ),
          ),
        ),
        GoRoute(
          path: RouteNames.game,
          pageBuilder: (context, state) =>
              _softPage(const MiniGameScreen()),
        ),
        GoRoute(
          path: RouteNames.favorites,
          pageBuilder: (context, state) =>
              _softPage(const FavoritesScreen()),
        ),
      ],
    );
  }
}


CustomTransitionPage<void> _softPage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GlobalSensorLayer(
        child: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          FloatingTabBar(
            currentIndex: _shellIndexToNavIndex(navigationShell.currentIndex),
            onTap: (index) {
              final branchIndex = _navIndexToShellIndex(index);
              if (branchIndex == null) {
                if (index == 4) context.push(RouteNames.feedback);
                return;
              }

              navigationShell.goBranch(
                branchIndex,
                initialLocation: branchIndex == navigationShell.currentIndex,
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  int _shellIndexToNavIndex(int shellIndex) {
    switch (shellIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return 0;
    }
  }

  int? _navIndexToShellIndex(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return null;
    }
  }
}