import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_names.dart';
import '../../shared/models/destination.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'jogjasplorasi_main';
  static const _channelName = 'JogjaSplorasi Main';
  static const _channelDescription =
      'Rekomendasi wisata, cuaca, kuis, dan update aplikasi.';

  static const _dailyRecommendationId = 1001;
  static const _quizReminderId = 1002;
  static const _favoritesReminderId = 1003;

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
      ),
      onDidReceiveNotificationResponse: (response) {
        handlePayload(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    await requestPermission();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true && payload != null) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        handlePayload(payload);
      });
    }
  }

  Future<bool> requestPermission() async {
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final macPlugin = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    final iosGranted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    final macGranted = await macPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    final androidGranted = await Permission.notification.request().isGranted;

    return iosGranted && macGranted && androidGranted;
  }

  Future<void> scheduleDefaultReminders() async {
    final destinations = Hive.box<DestinationModel>(
      AppConstants.destinationsBox,
    ).values.toList();

    final randomDestination = destinations.isEmpty
        ? null
        : destinations[Random().nextInt(destinations.length)];

    await scheduleDaily(
      _dailyRecommendationId,
      'Waktunya jelajah Jogja!',
      randomDestination == null
          ? 'Cek rekomendasi destinasi Jogja hari ini.'
          : 'Destinasi pilihan hari ini: ${randomDestination.name}.',
      const TimeOfDayCompat(hour: 8, minute: 0),
      payload: randomDestination == null
          ? NotificationPayload.home
          : NotificationPayload.destination(randomDestination.id),
    );

    await scheduleDaily(
      _quizReminderId,
      'Kuis budaya Jogja menunggu',
      'Uji pengetahuanmu tentang Jogja lewat mini game singkat.',
      const TimeOfDayCompat(hour: 19, minute: 30),
      payload: NotificationPayload.game,
    );

    final favorites = destinations.where((item) => item.isFavorite).toList();
    final favorite = favorites.isEmpty ? randomDestination : favorites.first;

    await scheduleDaily(
      _favoritesReminderId,
      'Rencana jalan-jalan berikutnya?',
      favorite == null
          ? 'Simpan destinasi favoritmu dan mulai eksplor Jogja.'
          : 'Kamu pernah menyimpan ${favorite.name}. Mau cek lagi?',
      const TimeOfDayCompat(hour: 16, minute: 0),
      payload: favorites.isEmpty
          ? NotificationPayload.explore
          : NotificationPayload.favorites,
    );
  }

  Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    TimeOfDayCompat time, {
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> showImmediate(
    String title,
    String body, {
    String? payload,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      _details(),
      payload: payload,
    );
  }

  Future<void> showDailyRecommendationNowForDemo() async {
    final destinations = Hive.box<DestinationModel>(
      AppConstants.destinationsBox,
    ).values.toList();

    final destination = destinations.isEmpty
        ? null
        : destinations[Random().nextInt(destinations.length)];

    await showImmediate(
      'Rekomendasi Jogja hari ini',
      destination == null
          ? 'Buka Jelajah dan temukan destinasi menarik.'
          : 'Coba kunjungi ${destination.name} hari ini.',
      payload: destination == null
          ? NotificationPayload.explore
          : NotificationPayload.destination(destination.id),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  void handlePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;

    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('Notification payload ignored. Context not ready: $payload');
      return;
    }

    final route = NotificationPayload.toRoute(payload);
    if (route == null) {
      debugPrint('Unknown notification payload: $payload');
      return;
    }

    context.go(route);
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  debugPrint('Background notification tapped: ${response.payload}');
}

class NotificationPayload {
  static const home = 'home';
  static const explore = 'explore';
  static const guide = 'guide';
  static const profile = 'profile';
  static const sensor = 'sensor';
  static const converter = 'converter';
  static const game = 'game';
  static const feedback = 'feedback';
  static const favorites = 'favorites';

  static String destination(String id) => 'destination:$id';

  static String? toRoute(String payload) {
    if (payload.startsWith('destination:')) {
      final id = payload.substring('destination:'.length);
      if (id.isEmpty) return null;
      return '${RouteNames.destination}/$id';
    }

    switch (payload) {
      case home:
        return RouteNames.home;
      case explore:
        return RouteNames.explore;
      case guide:
        return RouteNames.guide;
      case profile:
        return RouteNames.profile;
      case sensor:
        return RouteNames.sensor;
      case converter:
        return RouteNames.converter;
      case game:
        return RouteNames.game;
      case feedback:
        return RouteNames.feedback;
      case favorites:
        return RouteNames.favorites;
      default:
        return null;
    }
  }
}

class TimeOfDayCompat {
  const TimeOfDayCompat({
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;
}
