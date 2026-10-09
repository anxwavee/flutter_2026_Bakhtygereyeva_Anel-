const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

String formatClock(int hour, int minute) =>
    '${twoDigits(hour)}:${twoDigits(minute)}';

String formatTime(DateTime date) => formatClock(date.hour, date.minute);

String formatDateTime(DateTime date) =>
    '${formatDate(date)}, ${formatTime(date)}';

String formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
  }
  if (duration.inHours > 0) {
    return '${duration.inHours}h ${twoDigits(duration.inMinutes.remainder(60))}m';
  }
  return '${duration.inMinutes}m';
}
