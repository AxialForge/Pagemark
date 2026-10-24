import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/reading_life.dart';

/// Stats, the year card and the PDF report show one average the same way (they used to disagree: 4.3 vs 4.25).
void main() {
  test('averages show up to two decimals without trailing zeros', () {
    expect(ratingText(4.25), '4.25');
    expect(ratingText(4.5), '4.5');
    expect(ratingText(4.0), '4');
    expect(ratingText(10.0), '10');
    expect(ratingText(3.333), '3.33');
  });
}
