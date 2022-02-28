extension DateTimeX on DateTime {
  static DateTime? customNow;
  static int? customFromMillisecondsSinceEpoch;
  static DateTime get current {
    if (customNow != null) {
      return customNow!;
    }
    return DateTime.now();
  }
}
