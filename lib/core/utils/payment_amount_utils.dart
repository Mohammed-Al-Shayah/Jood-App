double parsePrice(String price) {
  final cleaned = price.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (cleaned.isEmpty) return 0.0;

  // If both separators exist, assume ',' is thousands and '.' is decimal.
  String normalized = cleaned;
  if (cleaned.contains(',') && cleaned.contains('.')) {
    normalized = cleaned.replaceAll(',', '');
  } else if (cleaned.contains(',') && !cleaned.contains('.')) {
    normalized = cleaned.replaceAll(',', '.');
  }

  return double.tryParse(normalized) ?? 0.0;
}

String formatMoney(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String formatCurrency(String currency, num value) {
  final amount = value.toDouble().toStringAsFixed(2);
  final trimmed = currency.trim();
  if (trimmed.isEmpty) {
    return '\$${amount}';
  }
  final isSymbol = trimmed.length == 1 || RegExp(r'[$â‚¬Â£Â¥]').hasMatch(trimmed);
  return isSymbol ? '$trimmed$amount' : '$trimmed $amount';
}