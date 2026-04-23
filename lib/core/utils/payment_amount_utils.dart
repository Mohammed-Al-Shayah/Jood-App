const String _omaniRialCode = 'OMR';
const String _omaniRialLegacyCode = 'OMN';
const String _omaniRialDisplayLabel = '\u0631.\u0639';
const String _genericRialLigature = '\uFDFC';

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
  return '\$${value.toStringAsFixed(1)}';
}

bool isOmaniRialCurrency(String currency) {
  final trimmed = currency.trim();
  if (trimmed.isEmpty) return false;

  final uppercase = trimmed.toUpperCase();
  if (uppercase == _omaniRialCode || uppercase == _omaniRialLegacyCode) {
    return true;
  }

  final collapsed = trimmed.replaceAll(' ', '').replaceAll('.', '');
  return collapsed == '\u0631\u0639' || collapsed == _genericRialLigature;
}

String displayCurrencyLabel(String currency) {
  final trimmed = currency.trim();
  if (trimmed.isEmpty) return '';
  if (isOmaniRialCurrency(trimmed)) {
    return _omaniRialDisplayLabel;
  }
  return trimmed;
}

String formatCurrencyAmount(num value) {
  return value.toDouble().toStringAsFixed(1);
}

String? currencyFromFormattedLabel(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;

  if (text.startsWith(_omaniRialDisplayLabel) ||
      text.startsWith(_genericRialLigature)) {
    return _omaniRialCode;
  }

  final collapsed = text.replaceAll(' ', '').replaceAll('.', '');
  if (collapsed.startsWith('\u0631\u0639')) {
    return _omaniRialCode;
  }

  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final character = String.fromCharCode(rune);
    final isLetter =
        (rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122);
    if (isLetter) {
      buffer.write(character);
      continue;
    }
    if (buffer.isNotEmpty) {
      break;
    }
  }

  final result = buffer.toString().trim();
  return result.isEmpty ? null : result.toUpperCase();
}

String formatCurrency(String currency, num value) {
  final amount = formatCurrencyAmount(value);
  final label = displayCurrencyLabel(currency);
  if (label.isEmpty) {
    return '\$$amount';
  }
  if (label == _omaniRialDisplayLabel) {
    return '$label $amount';
  }

  final isSymbol = label.length == 1 ||
      RegExp(
        r'^[\$\u00A2\u00A3\u00A5\u20AA\u20AC\u20B9\u20BD\u20BA\u20AB\u20A9\u20BF]+$',
      ).hasMatch(label);
  return isSymbol ? '$label$amount' : '$label $amount';
}
