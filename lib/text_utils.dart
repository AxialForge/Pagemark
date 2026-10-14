/// Comma-separated tags -> tidy list: trimmed, de-duplicated ignoring case (first spelling wins), empties dropped.
String normalizeTags(String raw) {
  final seen = <String>{};
  final out = <String>[];
  for (final part in raw.split(RegExp(r'[,;\n]'))) {
    final t = part.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) continue;
    if (seen.add(t.toLowerCase())) out.add(t);
  }
  return out.join(', ');
}

/// "412 KB" / "1.3 MB" for a byte count.
String humanBytes(int n) {
  if (n < 1024) return '$n B';
  if (n < 1024 * 1024) return '${(n / 1024).round()} KB';
  return '${(n / 1048576).toStringAsFixed(1)} MB';
}
