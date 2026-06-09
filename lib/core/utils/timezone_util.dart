import 'package:timezone/timezone.dart' as tz;

abstract final class TimezoneUtil {
  static tz.TZDateTime nextDailyEight() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
