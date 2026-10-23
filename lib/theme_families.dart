import 'package:flutter/material.dart';

import 'themes.dart';

/// A named look with a light and a dark version. Every colour Pagemark already
/// has is kept exactly as it is in themes.dart; a family only pairs them for the
/// theme picker.
///
/// Sage had no dark version and Lamplight had no light one, so those two get a
/// counterpart built from the same seed colour (marked NEW below). Delete either
/// counterpart and point the family at the original theme twice if you would
/// rather not have it.
class ThemeFamily {
  const ThemeFamily(this.id, this.label, this.light, this.dark);

  final String id;
  final String label;
  final PTheme light;
  final PTheme dark;

  static const _harborLight = PTheme('light_him', 'Harbor', Color(0xFF2F5D8A), Brightness.light);
  static const _harborDark = PTheme('dark_him', 'Midnight Ink', Color(0xFF3B6EA5), Brightness.dark);
  static const _roseLight = PTheme('light_her', 'Rosewater', Color(0xFFC2557A), Brightness.light);
  static const _roseDark = PTheme('dark_her', 'Plum Velvet', Color(0xFFB0558C), Brightness.dark);
  static const _sageLight = PTheme('light_sage', 'Sage', Color(0xFF4F7A5A), Brightness.light);
  static const _sageDark = PTheme('dark_sage', 'Sage Night', Color(0xFF4F7A5A), Brightness.dark); // NEW
  static const _lampDark = PTheme('dark_amber', 'Lamplight', Color(0xFFC4902F), Brightness.dark);
  static const _lampLight = PTheme('light_amber', 'Lamplight Day', Color(0xFFC4902F), Brightness.light); // NEW

  static const harbor = ThemeFamily('him', 'Harbor', _harborLight, _harborDark);
  static const rosewater = ThemeFamily('her', 'Rosewater', _roseLight, _roseDark);
  static const sage = ThemeFamily('sage', 'Sage', _sageLight, _sageDark);
  static const lamplight = ThemeFamily('amber', 'Lamplight', _lampLight, _lampDark);

  static const all = [harbor, rosewater, sage, lamplight];

  static ThemeFamily byId(String? id) => all.where((f) => f.id == id).firstOrNull ?? harbor;

  /// Family that holds a saved palette id such as 'dark_her'. Unknown ids give Harbor.
  static ThemeFamily ofPaletteId(String? id) =>
      all.where((f) => f.light.id == id || f.dark.id == id).firstOrNull ?? harbor;

  PTheme forBrightness(Brightness b) => b == Brightness.dark ? dark : light;

  /// Bubbles for the picker: background, accent, secondary.
  List<Color> bubbles(PTheme t) {
    final s = ColorScheme.fromSeed(seedColor: t.seed, brightness: t.brightness);
    return [s.surface, s.primary, s.secondary];
  }

  /// The accent used for a selection border or ring on this version.
  Color accent(PTheme t) => ColorScheme.fromSeed(seedColor: t.seed, brightness: t.brightness).primary;
}

/// What the user picked: a family plus a mode. Saved in the existing 'theme'
/// preference as one string, so every choice saved by older versions still works:
///   'light_him' 'dark_her' ...   a fixed palette (all the old ids)
///   'system'                     follow the phone, Harbor family
///   `'system:<familyId>'`          follow the phone, another family, e.g. 'system:her'
class ThemeChoice {
  const ThemeChoice(this.family, this.mode);

  final ThemeFamily family;
  final ThemeMode mode; // system, light or dark

  static const systemId = 'system';

  static ThemeChoice parse(String? raw) {
    final v = raw ?? 'light_him';
    if (v == systemId) return const ThemeChoice(ThemeFamily.harbor, ThemeMode.system);
    if (v.startsWith('$systemId:')) {
      return ThemeChoice(ThemeFamily.byId(v.substring(systemId.length + 1)), ThemeMode.system);
    }
    final f = ThemeFamily.ofPaletteId(v);
    return ThemeChoice(f, f.dark.id == v ? ThemeMode.dark : ThemeMode.light);
  }

  /// The string to save in the 'theme' preference.
  String get id => switch (mode) {
    ThemeMode.system => family == ThemeFamily.harbor ? systemId : '$systemId:${family.id}',
    ThemeMode.light => family.light.id,
    ThemeMode.dark => family.dark.id,
  };

  ThemeChoice withFamily(ThemeFamily f) => ThemeChoice(f, mode);
  ThemeChoice withMode(ThemeMode m) => ThemeChoice(family, m);
}
