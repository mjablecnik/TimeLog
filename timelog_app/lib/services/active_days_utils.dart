/// Encodes a set of weekdays (Dart `DateTime.weekday` convention: 1=Monday,
/// 7=Sunday) into a 7-bit bitmask (bit 0 = Monday, bit 6 = Sunday).
/// All days = 0b1111111 = 127; e.g. Mon+Wed+Fri = 0b0010101 = 21.
int encodeDays(Set<int> weekdays) {
  int mask = 0;
  for (final day in weekdays) {
    mask |= (1 << (day - 1));
  }
  return mask;
}

/// Decodes a 7-bit bitmask into a set of weekdays (1=Monday, 7=Sunday).
Set<int> decodeDays(int mask) {
  final days = <int>{};
  for (int i = 0; i < 7; i++) {
    if (mask & (1 << i) != 0) {
      days.add(i + 1);
    }
  }
  return days;
}

/// Whether [weekday] (1=Monday, 7=Sunday) is set in [mask].
bool isDayActive(int mask, int weekday) => (mask & (1 << (weekday - 1))) != 0;
