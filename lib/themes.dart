import 'package:flutter/material.dart';

class PTheme {
  final String id, name;
  final Color seed;
  final Brightness brightness;
  const PTheme(this.id, this.name, this.seed, this.brightness);
  ThemeData get data => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      );
}

const themes = [
  PTheme('light_him', 'Light · Him (slate blue)', Color(0xFF2F5D8A), Brightness.light),
  PTheme('dark_him', 'Dark · Him (midnight)', Color(0xFF3B6EA5), Brightness.dark),
  PTheme('light_her', 'Light · Her (rose)', Color(0xFFC2557A), Brightness.light),
  PTheme('dark_her', 'Dark · Her (plum)', Color(0xFFB0558C), Brightness.dark),
];
PTheme themeById(String? id) => themes.firstWhere((t) => t.id == id, orElse: () => themes[0]);
