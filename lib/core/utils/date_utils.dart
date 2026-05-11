import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _date = DateFormat('dd, MMMM, yyyy');
  static final DateFormat _dateTime = DateFormat('dd, MMMM, yyyy hh:mm a');

  static String formatDate(DateTime date) => _date.format(date.toLocal());

  static String formatDateTime(DateTime date) =>
      _dateTime.format(date.toLocal());
}
