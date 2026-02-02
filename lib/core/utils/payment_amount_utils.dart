int parsePrice(String price) {
  final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? 0;
}

String formatMoney(int value) {
  return '\$${value.toString()}';
}

String formatCurrency(String currency, num value) {
  final rounded = value.round();
  final trimmed = currency.trim();
  if (trimmed.isEmpty) {
    return '\$$rounded';
  }
  final isSymbol = trimmed.length == 1 || RegExp(r'[$â‚¬Â£Â¥]').hasMatch(trimmed);
  return isSymbol ? '$trimmed$rounded' : '$trimmed $rounded';
}
