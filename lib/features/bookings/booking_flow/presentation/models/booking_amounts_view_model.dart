class BookingAmountsViewModel {
  const BookingAmountsViewModel({
    required this.adultTotal,
    required this.childTotal,
    required this.subtotal,
    required this.originalAdultTotal,
    required this.originalChildTotal,
    required this.originalSubtotal,
    required this.discountTotal,
    required this.tax,
    required this.totalPayable,
  });

  final double adultTotal;
  final double childTotal;
  final double subtotal;
  final double originalAdultTotal;
  final double originalChildTotal;
  final double originalSubtotal;
  final double discountTotal;
  final double tax;
  final double totalPayable;

  static BookingAmountsViewModel calculate({
    required double adultPrice,
    required double childPrice,
    required double adultOriginalPrice,
    required int adultCount,
    required int childCount,
    double taxRate = 0.05,
  }) {
    final childOriginal =
        (adultPrice > 0 && adultOriginalPrice > 0 && childPrice > 0)
        ? childPrice * (adultOriginalPrice / adultPrice)
        : childPrice;
    final adultTotal = adultPrice * adultCount;
    final childTotal = childPrice * childCount;
    final subtotal = adultTotal + childTotal;
    final originalAdultTotal = adultOriginalPrice * adultCount;
    final originalChildTotal = childOriginal * childCount;
    final originalSubtotal = originalAdultTotal + originalChildTotal;
    final discountTotal = originalSubtotal > subtotal
        ? (originalSubtotal - subtotal)
        : 0.0;
    final tax = subtotal * taxRate;
    final totalPayable = subtotal + tax;
    return BookingAmountsViewModel(
      adultTotal: adultTotal,
      childTotal: childTotal,
      subtotal: subtotal,
      originalAdultTotal: originalAdultTotal,
      originalChildTotal: originalChildTotal,
      originalSubtotal: originalSubtotal,
      discountTotal: discountTotal,
      tax: tax,
      totalPayable: totalPayable,
    );
  }
}
