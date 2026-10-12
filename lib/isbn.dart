/// ISBN helpers: validation (checksums), normalisation to ISBN-13, and scan filtering.
class Isbn {
  static String clean(String s) => s.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

  static bool isValid10(String raw) {
    final s = clean(raw);
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(s)) return false;
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      final v = s[i] == 'X' ? 10 : int.parse(s[i]);
      sum += v * (10 - i);
    }
    return sum % 11 == 0;
  }

  static bool isValid13(String raw) {
    final s = clean(raw);
    if (!RegExp(r'^\d{13}$').hasMatch(s)) return false;
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(s[i]) * (i.isEven ? 1 : 3);
    }
    return (10 - sum % 10) % 10 == int.parse(s[12]);
  }

  static bool isValid(String raw) => isValid13(raw) || isValid10(raw);

  /// Returns the ISBN-13 for a valid ISBN-10/13, otherwise null.
  static String? to13(String raw) {
    final s = clean(raw);
    if (isValid13(s)) return s;
    if (!isValid10(s)) return null;
    final body = '978${s.substring(0, 9)}';
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(body[i]) * (i.isEven ? 1 : 3);
    }
    return '$body${(10 - sum % 10) % 10}';
  }

  /// A scanned/pasted code worth looking up: a valid ISBN (books use 978/979 EAN-13 barcodes).
  static bool looksLikeBookCode(String raw) {
    final s = clean(raw);
    if (isValid13(s)) return s.startsWith('978') || s.startsWith('979');
    return isValid10(s);
  }
}
