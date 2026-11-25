/// Plain-text formatting for dates, times, distances and pace.
library;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "Nov 25", or "Nov 25, 2025" when not this year.
String formatDate(DateTime d, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final base = '${_months[d.month - 1]} ${d.day}';
  return d.year == n.year ? base : '$base, ${d.year}';
}

/// "14:05".
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "November 2026".
String monthHeading(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

/// 125 -> "2:05", 3725 -> "1:02:05".
String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

/// 5230 meters -> "5.23".
String formatKm(double meters) => (meters / 1000).toStringAsFixed(2);

/// Minutes and seconds per kilometer, or "--" when there is too little data.
String formatPace(double meters, int seconds) {
  if (meters < 50 || seconds <= 0) return '--';
  final perKm = seconds / (meters / 1000);
  var m = perKm ~/ 60;
  var s = (perKm % 60).round();
  if (s == 60) {
    m += 1;
    s = 0;
  }
  return '$m:${s.toString().padLeft(2, '0')} /km';
}
