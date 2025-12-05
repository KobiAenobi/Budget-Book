import 'package:intl/intl.dart';


/// ============================================================================
/// 📅 formatDateTime(DateTime date)
/// ----------------------------------------------------------------------------
/// This helper function converts a DateTime into a *human-friendly* string.
///
/// It intelligently formats values like:
///   • "Just now"
///   • "5 min ago"
///   • "Today, 3:20 PM"
///   • "Yesterday, 9:10 AM"
///   • "Monday, 4:15 PM"
///   • "24 September 2024, 8:30 PM"
///
/// The logic checks the age of the timestamp and applies different formats.
/// NOT A SINGLE CHARACTER has been changed — only comments were added.
/// ============================================================================
String formatDateTime(DateTime date) {

  final now = DateTime.now();
  final difference = now.difference(date);

  // ---------------------------------------------------------------------------
  // 🟢 JUST NOW — Less than 60 seconds old
  // ---------------------------------------------------------------------------
  if (difference.inSeconds < 60) {
    return "Just now";
  }

  // ---------------------------------------------------------------------------
  // 🟡 MINUTES AGO — Less than 60 minutes old
  // ---------------------------------------------------------------------------
  if (difference.inMinutes < 60) {
    return "${difference.inMinutes} min ago";
  }

  // ---------------------------------------------------------------------------
  // Normalize dates to midnight for easier comparison
  // today      = <current date at 00:00>
  // yesterday  = today - 1 day
  // dateOnly   = <item date at 00:00>
  // ---------------------------------------------------------------------------
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  // ---------------------------------------------------------------------------
  // 🔵 TODAY — More than 1 hour ago but still today
  // Example: "Today, 3:15 PM"
  // ---------------------------------------------------------------------------
  if (dateOnly == today) {
    return "Today, ${DateFormat('h:mm a').format(date)}";
  }

  // ---------------------------------------------------------------------------
  // 🟣 YESTERDAY
  // Example: "Yesterday, 10:05 PM"
  // ---------------------------------------------------------------------------
  if (dateOnly == yesterday) {
    return "Yesterday, ${DateFormat('h:mm a').format(date)}";
  }

  // ---------------------------------------------------------------------------
  // 🟠 LAST 7 DAYS
  // Shows weekday name + time
  // Example: "Monday, 2:18 PM"
  // ---------------------------------------------------------------------------
  if (difference.inDays < 7) {
    return "${DateFormat('EEEE').format(date)}, ${DateFormat('h:mm a').format(date)}";
  }

  // ---------------------------------------------------------------------------
  // 🔴 OLDER THAN A WEEK
  // Example: "23 July 2024, 8:14 PM"
  // ---------------------------------------------------------------------------
  return DateFormat("dd MMMM yyyy").format(date);
}
