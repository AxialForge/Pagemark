/// Guesses a series name and volume number from a book title ("One Piece, Vol. 12" is volume 12 of One Piece).
///
/// It only ever suggests: the caller asks the owner before anything is renamed. A title with no volume marker gives null, so
/// "Fahrenheit 451" and "Catch-22" are never mistaken for volumes.
class VolumeGuess {
  final String series;
  final double number;

  /// An edition note taken out of the title, such as "Deluxe Edition" or "3-in-1 Edition"; empty when there was none.
  final String edition;

  /// False when the title is probably a collection (an omnibus or a range like "1-3"), so the guess needs a closer look.
  final bool sure;
  const VolumeGuess(this.series, this.number, {this.edition = '', this.sure = true});

  @override
  String toString() => 'VolumeGuess($series, $number, edition: $edition, sure: $sure)';
}

const kinds = {'': 'Book', 'manga': 'Manga', 'comic': 'Comic', 'lightnovel': 'Light novel'};

final _edition = RegExp(r'\(([^()]*\b(?:edition|omnibus|in-1|in 1|collector)[^()]*)\)', caseSensitive: false);
final _looseEdition = RegExp(r'\b((?:deluxe|collector\x27?s?|hardcover|special|complete|ultimate|premium)\s+edition)\b', caseSensitive: false);
final _roman = RegExp(r'^(?=[ivxlc]+$)(?:x{0,3})(?:ix|iv|v?i{0,3})$', caseSensitive: false);
// "Vol. 12", "Volume 02", "Book 3", "No. 4", "#7", "Omnibus 3": a marker word (or #), then the number or a range
final _marker = RegExp(
  r'[\s,:–—-]*\b(vol(?:ume)?s?\.?|book|no\.?|omnibus|#)\s*([0-9]+(?:\.[0-9]+)?|[ivxlc]+)(?:\s*[-–]\s*([0-9]+))?\s*$|[\s,:–—-]*#\s*([0-9]+(?:\.[0-9]+)?)\s*$',
  caseSensitive: false,
);

int _fromRoman(String s) {
  const v = {'i': 1, 'v': 5, 'x': 10, 'l': 50, 'c': 100};
  var total = 0;
  final t = s.toLowerCase();
  for (var i = 0; i < t.length; i++) {
    final cur = v[t[i]]!, next = i + 1 < t.length ? v[t[i + 1]]! : 0;
    total += cur < next ? -cur : cur;
  }
  return total;
}

VolumeGuess? parseVolume(String title) {
  var t = title.trim();
  if (t.isEmpty || t.length > 300) return null;
  var edition = '';
  final paren = _edition.firstMatch(t);
  if (paren != null) {
    edition = paren.group(1)!.trim();
    t = t.replaceFirst(paren.group(0)!, ' ');
  }
  final loose = _looseEdition.firstMatch(t);
  if (loose != null) {
    edition = edition.isEmpty ? loose.group(1)! : edition;
    t = t.replaceFirst(loose.group(0)!, ' ');
  }
  t = t.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  final m = _marker.firstMatch(t);
  if (m == null) return null;
  final word = (m.group(1) ?? '#').toLowerCase();
  final raw = m.group(2) ?? m.group(4)!;
  double number;
  if (RegExp(r'^[0-9]').hasMatch(raw)) {
    number = double.parse(raw);
  } else {
    // a roman numeral only counts after a real volume word, never after "#" or "no."
    if (!word.startsWith('vol') && word != 'book') return null;
    if (!_roman.hasMatch(raw)) return null;
    number = _fromRoman(raw).toDouble();
  }
  if (!number.isFinite || number <= 0 || number >= 10000) return null;
  var series = t.substring(0, m.start).trim();
  series = series.replaceAll(RegExp(r'[\s,:–—-]+$'), '').trim();
  if (series.isEmpty) return null;
  final isRange = m.group(3) != null;
  final omnibus = word == 'omnibus' || edition.toLowerCase().contains('omnibus') || edition.toLowerCase().contains('in-1') || edition.toLowerCase().contains('in 1');
  return VolumeGuess(series, number, edition: edition, sure: !isRange && word != 'omnibus' && !omnibus);
}
