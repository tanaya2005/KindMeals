import 'package:intl/intl.dart';

/// Utility class to handle datetime operations consistently with IST timezone
class DateTimeHelper {
  /// The offset for Indian Standard Time (UTC+5:30)
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// Format a datetime object to a user-friendly string in IST
  static String formatDateTime(DateTime dateTime) {
    // Format using the local device timezone - no additional conversion needed
    // as Flutter's DateTime uses local timezone by default
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }

  /// Format date only in IST
  static String formatDate(DateTime dateTime) {
    // Format using the local device timezone
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Format time only in IST
  static String formatTime(DateTime dateTime) {
    // Format using the local device timezone
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Convert any DateTime to IST - only use for UTC times that need to be displayed in IST
  static DateTime toIST(DateTime dateTime) {
    // Only convert to IST if the time is in UTC
    if (dateTime.isUtc) {
      return dateTime.toLocal(); // Flutter will convert to device local time
    }
    // If already in local time, return as is
    return dateTime;
  }

  /// Convert a string datetime from API to local DateTime
  static DateTime parseToLocal(String dateTimeString) {
    // Parse the ISO string to DateTime (will be in UTC)
    final DateTime utcDateTime = DateTime.parse(dateTimeString);
    // Convert to local time
    return utcDateTime.toLocal();
  }

  /// Convert a local DateTime to a properly formatted string for API submission
  /// No timezone manipulation - just format as ISO string
  static String toISOString(DateTime localDateTime) {
    // Convert to UTC for API submission
    final DateTime utcDateTime = localDateTime.toUtc();
    // Return ISO string
    return utcDateTime.toIso8601String();
  }
}
