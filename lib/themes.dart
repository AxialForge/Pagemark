import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

const _display = 'Newsreader'; // titles
const _ui = 'HankenGrotesk'; // everything else

/// CardKeep's look: warm neutral pages, white panels, hairlines, a charcoal band
/// (drawer header, snack bars), with the theme's own colour as the one accent.
class _Neutrals {
  final Color ground, surface, raised, selected, hairline, outline, ink, ink2, strong, onStrong;
  const _Neutrals(this.ground, this.surface, this.raised, this.selected, this.hairline, this.outline, this.ink, this.ink2, this.strong, this.onStrong);
  static const light = _Neutrals(Color(0xFFFAFAF9), Color(0xFFFFFFFF), Color(0xFFF7F5F1), Color(0xFFF1ECE5), Color(0xFFE6E3DE),
      Color(0xFFC9C4BC), Color(0xFF1C1B19), Color(0xFF5E5A54), Color(0xFF24231F), Color(0xFFFFFFFF));
  static const dark = _Neutrals(Color(0xFF000000), Color(0xFF151413), Color(0xFF1C1B19), Color(0xFF262421), Color(0xFF2B2926),
      Color(0xFF4A4640), Color(0xFFF1ECE3), Color(0xFFABA59B), Color(0xFF1D1C1A), Color(0xFFF7F4ED));
}

class PTheme {
  /// Stable id (saved in preferences, so never change it); [name] is what the user sees.
  final String id, name;
  final Color seed;
  final Brightness brightness;
  const PTheme(this.id, this.name, this.seed, this.brightness);
  String get mode => brightness == Brightness.dark ? 'Dark' : 'Light';

  ThemeData get data {
    final dark = brightness == Brightness.dark;
    final n = dark ? _Neutrals.dark : _Neutrals.light;
    final tones = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    // buttons and the FAB use the theme colour itself (a little brighter on dark pages)
    final action = dark ? Color.lerp(seed, Colors.white, 0.12)! : seed;
    final onAction = ThemeData.estimateBrightnessForColor(action) == Brightness.dark ? Colors.white : const Color(0xFF1C1B19);
    final cs = tones.copyWith(
      primary: action,
      onPrimary: onAction,
      surface: n.ground,
      onSurface: n.ink,
      onSurfaceVariant: n.ink2,
      surfaceContainerLowest: n.surface,
      surfaceContainerLow: n.surface,
      surfaceContainer: n.raised,
      surfaceContainerHigh: n.selected,
      surfaceContainerHighest: n.selected,
      surfaceTint: Colors.transparent,
      secondaryContainer: n.selected,
      onSecondaryContainer: n.ink,
      outline: n.outline,
      outlineVariant: n.hairline,
      inverseSurface: n.strong,
      onInverseSurface: n.onStrong,
      // stars, quote bars and bookmark ribbons: the theme colour, not a second generated hue
      tertiary: tones.primary,
      onTertiary: tones.onPrimary,
    );
    final accentText = tones.primary; // M3 tone 40/80: AA on the page in both modes

    final base = ThemeData(useMaterial3: true, colorScheme: cs, fontFamily: _ui);
    TextStyle? serif(TextStyle? s, double size) => s?.copyWith(fontFamily: _display, fontSize: size, fontWeight: FontWeight.w600, height: 1.15, color: n.ink);
    final tt = base.textTheme.apply(fontFamily: _ui, bodyColor: n.ink, displayColor: n.ink);
    final text = tt.copyWith(
      displayLarge: serif(tt.displayLarge, 48),
      displayMedium: serif(tt.displayMedium, 40),
      displaySmall: serif(tt.displaySmall, 34),
      headlineLarge: serif(tt.headlineLarge, 30),
      headlineMedium: serif(tt.headlineMedium, 28),
      headlineSmall: serif(tt.headlineSmall, 26),
      titleLarge: serif(tt.titleLarge, 21),
      titleMedium: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodySmall: tt.bodySmall?.copyWith(color: n.ink2),
      labelMedium: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: n.ink2),
    );
    final radiusSm = BorderRadius.circular(12);
    OutlineInputBorder edge(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: radiusSm, borderSide: BorderSide(color: c, width: w));
    const button = TextStyle(fontFamily: _ui, fontSize: 15, fontWeight: FontWeight.w600);

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      scaffoldBackgroundColor: n.ground,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: n.ground,
        foregroundColor: n.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      dividerTheme: DividerThemeData(color: n.hairline, thickness: 1, space: 1),
      drawerTheme: DrawerThemeData(backgroundColor: n.surface, width: 308),
      cardTheme: CardThemeData(
        color: n.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: n.hairline)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: onAction,
          minimumSize: const Size(48, 52),
          textStyle: button,
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: n.ink,
          minimumSize: const Size(48, 52),
          textStyle: button,
          side: BorderSide(color: n.ink),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: accentText, textStyle: button)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: action,
        foregroundColor: onAction,
        elevation: 2,
        extendedTextStyle: const TextStyle(fontFamily: _ui, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: n.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: edge(n.hairline),
        enabledBorder: edge(n.hairline),
        focusedBorder: edge(accentText, 1.5),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: n.surface,
        selectedColor: action,
        side: BorderSide(color: n.hairline),
        labelStyle: TextStyle(fontFamily: _ui, fontSize: 13, fontWeight: FontWeight.w600, color: n.ink2),
        secondaryLabelStyle: TextStyle(fontFamily: _ui, fontSize: 13, fontWeight: FontWeight.w600, color: onAction),
        checkmarkColor: onAction,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onAction : n.outline),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? action : n.selected),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? action : n.outline),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: action, linearTrackColor: n.selected),
      listTileTheme: ListTileThemeData(iconColor: n.ink, textColor: n.ink, minVerticalPadding: 10),
      popupMenuTheme: PopupMenuThemeData(color: n.surface, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(backgroundColor: n.surface, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: n.surface, surfaceTintColor: Colors.transparent, showDragHandle: true),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: n.strong,
        contentTextStyle: TextStyle(fontFamily: _ui, fontSize: 15, color: n.onStrong),
        // the bar is charcoal in both modes, so its link always uses the light tone of the accent
        actionTextColor: dark ? tones.primary : tones.inversePrimary,
        behavior: SnackBarBehavior.floating,
      ),
      navigationRailTheme: NavigationRailThemeData(backgroundColor: n.surface, indicatorColor: n.selected),
    );
  }
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
