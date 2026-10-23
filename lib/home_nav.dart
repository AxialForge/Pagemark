import 'package:flutter/material.dart';

/// Lets a tab's own app bar open the side menu. Absent on wide screens (the rail is used) and on pushed screens.
class HomeNav extends InheritedWidget {
  final VoidCallback open;
  const HomeNav({super.key, required this.open, required super.child});
  @override
  bool updateShouldNotify(HomeNav old) => false;
}

/// The menu button for a tab's app bar, or null when there is no side menu (so Back shows instead).
Widget? navButton(BuildContext context) {
  final nav = context.dependOnInheritedWidgetOfExactType<HomeNav>();
  return nav == null ? null : IconButton(icon: const Icon(Icons.menu), tooltip: 'Open menu', onPressed: nav.open);
}
