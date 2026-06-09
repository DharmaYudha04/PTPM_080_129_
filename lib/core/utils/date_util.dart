import 'package:intl/intl.dart';

abstract final class DateUtil {
  static String friendlyDate(DateTime value) =>
      DateFormat('d MMM yyyy').format(value);
  static String hourMinute(DateTime value) => DateFormat('HH:mm').format(value);
}
