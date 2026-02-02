class NumberUtils {
  const NumberUtils._();

  static double toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  static int toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return 0;
  }

  static double parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final text = value.toString();
    final match = RegExp(r'(\\d+(\\.\\d+)?)').firstMatch(text);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }
}
