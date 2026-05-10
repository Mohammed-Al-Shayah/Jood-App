String normalizeSearchText(String value) {
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    if (rune >= 0x064B && rune <= 0x065F) continue;
    if (rune == 0x0670 || rune == 0x0640) continue;
    switch (rune) {
      case 0x0623:
      case 0x0625:
      case 0x0622:
      case 0x0671:
        buffer.write('ا');
      case 0x0649:
        buffer.write('ي');
      case 0x0629:
        buffer.write('ه');
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

bool matchesSearchQuery(String query, Iterable<String> fields) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return true;
  return fields.any(
    (field) => normalizeSearchText(field).contains(normalizedQuery),
  );
}
