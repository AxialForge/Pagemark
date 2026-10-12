import 'package:flutter/material.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'privacy.dart';
import 'db.dart';
import 'themes.dart';
import 'ui.dart';

final db = AppDb();
final themeId = ValueNotifier<String>('light_him');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterCryptography.enable(); // native AES/PBKDF2 instead of slow pure-Dart
  final prefs = await SharedPreferences.getInstance();
  themeId.value = prefs.getString('theme') ?? 'light_him';
  themeId.addListener(() => prefs.setString('theme', themeId.value));
  runApp(const PagemarkApp());
}

class PagemarkApp extends StatelessWidget {
  const PagemarkApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: themeId,
        builder: (_, id, _) => MaterialApp(
          navigatorKey: navKey,
          title: 'Pagemark',
          debugShowCheckedModeBanner: false,
          theme: themeById(id).data,
          home: const Home(),
        ),
      );
}
