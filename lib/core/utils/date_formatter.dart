import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dayFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _invoiceFormat = DateFormat('yyyyMM', 'id_ID');

  static String full(DateTime date) => _fullFormat.format(date);
  static String short(DateTime date) => _shortFormat.format(date);
  static String day(DateTime date) => _dayFormat.format(date);
  static String monthYear(DateTime date) => _monthYearFormat.format(date);
  static String time(DateTime date) => _timeFormat.format(date);
  static String invoiceMonth(DateTime date) => _invoiceFormat.format(date);
  static String dateTime(DateTime date) => '${_fullFormat.format(date)} ${_timeFormat.format(date)}';
}
