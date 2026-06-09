import '../core/di/injection.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/notifications/notification_service.dart';
import 'hive_init.dart';

abstract final class AppInit {
  /// Critical startup path: only initialize storage, dependencies, and session.
  static Future<bool> initializeCore() async {
    await HiveInit.initialize();
    await configureDependencies();
    return getIt<AuthLocalDataSource>().checkSession();
  }

  /// Non-critical startup work. Run after the first UI frame so old devices can
  /// show the app immediately instead of waiting for notification scheduling.
  static Future<void> initializeDeferred() async {
    final notificationService = getIt<NotificationService>();
    await notificationService.init();
    await notificationService.scheduleDefaultReminders();
  }

  /// Kept for compatibility with older call sites.
  static Future<bool> initialize() => initializeCore();
}
