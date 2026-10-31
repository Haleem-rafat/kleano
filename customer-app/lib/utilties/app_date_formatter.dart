import 'package:intl/intl.dart';


class AppDateFormatter {
  static String dateToString(DateTime dateTime, [String? local]) {
    return DateFormat('EEEE, dd MMM yyyy', local).format(dateTime);
  }

  static String dateToStringToServer(DateTime dateTime, [String? locale]) {
    return DateFormat('yyyy-MM-dd', locale).format(dateTime);
  }

  // static String dateToStringToServerWithoutYear(DateTime dateTime,
  //     [String? locale]) {
  //   return DateFormat('MM/dd', locale).format(dateTime);
  // }

  static String dateToStringFormat(DateTime dateTime) {
    return DateFormat("EEEE, MMM d, yyyy", "en_SA").format(dateTime);
  }

  static String dateToStringWithDayName(DateTime dateTime, [String? locale]) {
    return DateFormat('EEEE, dd MMM yyyy', locale).format(dateTime);
  }

  static String dateToStringToServerYearAndMonth(DateTime dateTime,
      [String? locale]) {
    return DateFormat('yyyy/MMM', locale).format(dateTime);
  }

  static String dateToStringHHMMA(DateTime dateTime, [String? local]) {
    return DateFormat('hh:mm a', local).format(dateTime);
  }

  static int differenceBetweenTwoDate(DateTime date1, DateTime date2) {
    return date2.difference(date1).inDays;
  }

  static String dateToStringToServerWithoutYear(DateTime dateTime,
      [String? locale]) {
    return DateFormat('MMM/yyyy', locale).format(dateTime);
  }

  static String dayAndMonth(DateTime dateTime, [String? locale]) {
    return DateFormat('EEEE, dd MMM', locale).format(dateTime);
  }

  static String allDate(DateTime dateTime, [String? locale]) {
    return DateFormat('EEEE, d/M/y', locale).format(dateTime);
  }

  static String dataAllString(DateTime dateTime, [String? locale]) {
    return DateFormat('EEEE, dd/MM/yyyy', locale).format(dateTime);
  }

  static String hours(DateTime dateTime, [String? local]) {
    return DateFormat('hh', local).format(dateTime);
  }
}
