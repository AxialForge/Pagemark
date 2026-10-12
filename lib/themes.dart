import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

class PTheme {
  /// Stable id (saved in preferences, so never change it); [name] is what the user sees.
  final String id, name;
  final Color seed;
  final Brightness brightness;
  const PTheme(this.id, this.name, this.seed, this.brightness);
  String get mode => brightness == Brightness.dark ? 'Dark' : 'Light';
  ThemeData get data => ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      );
}

const themes = [
  PTheme('light_him', 'Harbor', Color(0xFF2F5D8A), Brightness.light), // calm slate blue
  PTheme('dark_him', 'Midnight Ink', Color(0xFF3B6EA5), Brightness.dark), // deep blue-black
  PTheme('light_her', 'Rosewater', Color(0xFFC2557A), Brightness.light), // soft rose
  PTheme('dark_her', 'Plum Velvet', Color(0xFFB0558C), Brightness.dark), // rich plum
  PTheme('light_sage', 'Sage', Color(0xFF4F7A5A), Brightness.light), // gentle library green
  PTheme('dark_amber', 'Lamplight', Color(0xFFC4902F), Brightness.dark), // warm reading-lamp amber on dark
];
PTheme themeById(String? id) => themes.firstWhere((t) => t.id == id, orElse: () => themes[0]);
