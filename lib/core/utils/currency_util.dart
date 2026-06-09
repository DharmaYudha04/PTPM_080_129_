import 'package:intl/intl.dart';

abstract final class CurrencyUtil {
  static String toIdr(double value) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(value);
}
