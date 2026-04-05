class CatalogBookingOption {
  const CatalogBookingOption({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.primaryPriceLabel,
    this.originalPriceLabel = '',
    required this.secondaryPriceLabel,
    required this.statusLabel,
    required this.offerIndex,
    required this.isEnabled,
    this.details = const [],
  });

  final String key;
  final String label;
  final String subtitle;
  final String primaryPriceLabel;
  final String originalPriceLabel;
  final String secondaryPriceLabel;
  final String statusLabel;
  final int offerIndex;
  final bool isEnabled;
  final List<String> details;

  bool get hasDetails => details.isNotEmpty;
}
