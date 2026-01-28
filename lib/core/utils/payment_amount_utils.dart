int parsePrice(String price) {
  final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? 0;
}

String formatMoney(int value) {
  return '\$${value.toString()}';
}
