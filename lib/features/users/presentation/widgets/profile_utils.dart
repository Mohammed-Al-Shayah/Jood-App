String profileInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  final first = parts.first.substring(0, 1);
  final last = parts.last.substring(0, 1);
  return '${first.toUpperCase()}${last.toUpperCase()}';
}
