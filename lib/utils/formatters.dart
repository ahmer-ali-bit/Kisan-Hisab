import 'package:intl/intl.dart';

class AppFormatters {
  // Example: Rs. 10,000
  static String currency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    return formatter.format(amount);
  }

  // Example: 10 Aug 2026
  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Example: 09:30 AM
  static String time(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
