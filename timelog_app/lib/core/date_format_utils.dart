String formatDeadline(String isoDate) {
  final date = DateTime.parse(isoDate);
  return '${date.day}. ${date.month}. ${date.year}';
}
