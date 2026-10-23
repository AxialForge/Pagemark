import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/theme_families.dart';
import 'package:pagemark/themes.dart';

void main() {
  test('every existing theme is in exactly one family, unchanged', () {
    for (final t in themes) {
      final f = ThemeFamily.ofPaletteId(t.id);
      final inFamily = t.brightness == Brightness.dark ? f.dark : f.light;
      expect(inFamily.id, t.id);
      expect(inFamily.seed, t.seed, reason: '${t.id} keeps its colour');
      expect(inFamily.name, t.name);
    }
  });

  test('old saved ids keep their meaning', () {
    expect(ThemeChoice.parse('light_him').family, ThemeFamily.harbor);
    expect(ThemeChoice.parse('light_him').mode, ThemeMode.light);
    expect(ThemeChoice.parse('dark_her').family, ThemeFamily.rosewater);
    expect(ThemeChoice.parse('dark_her').mode, ThemeMode.dark);
    expect(ThemeChoice.parse('dark_amber').family, ThemeFamily.lamplight);
    expect(ThemeChoice.parse('dark_amber').mode, ThemeMode.dark);
    expect(ThemeChoice.parse(null).id, 'light_him');
    expect(ThemeChoice.parse('nope').id, 'light_him');
  });

  test('ids round-trip for every family and mode', () {
    for (final f in ThemeFamily.all) {
      for (final m in ThemeMode.values) {
        final back = ThemeChoice.parse(ThemeChoice(f, m).id);
        expect(back.family, f);
        expect(back.mode, m);
      }
    }
  });

  test('family and palette ids are unique', () {
    final ids = [for (final f in ThemeFamily.all) ...[f.light.id, f.dark.id]];
    expect(ids.toSet().length, ids.length);
    expect({for (final f in ThemeFamily.all) f.id}.length, ThemeFamily.all.length);
  });

  test('switching family keeps the mode', () {
    expect(ThemeChoice.parse('dark_him').withFamily(ThemeFamily.rosewater).id, 'dark_her');
    expect(ThemeChoice.parse('system').withFamily(ThemeFamily.rosewater).id, 'system:her');
  });

  test('text stays readable in every palette, including the two new ones', () {
    double lum(Color c) => c.computeLuminance();
    double ratio(Color a, Color b) {
      final (x, y) = (lum(a), lum(b));
      return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
    }

    for (final f in ThemeFamily.all) {
      for (final t in [f.light, f.dark]) {
        final s = ColorScheme.fromSeed(seedColor: t.seed, brightness: t.brightness);
        expect(ratio(s.onSurface, s.surface), greaterThanOrEqualTo(4.5), reason: t.id);
        expect(ratio(s.onPrimary, s.primary), greaterThanOrEqualTo(4.5), reason: '${t.id} button');
      }
    }
  });
}
