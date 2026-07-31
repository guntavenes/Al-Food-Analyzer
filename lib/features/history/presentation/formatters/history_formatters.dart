import 'package:intl/intl.dart';

abstract final class HistoryFormatters {
  static String dateTime(DateTime value, String locale) {
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
  }
}
