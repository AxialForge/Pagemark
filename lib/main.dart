import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_lock.dart';
import 'covers.dart';
import 'log.dart';
import 'privacy.dart';
import 'db.dart';
import 'themes.dart';
import 'ui.dart';

final db = AppDb();
late SharedPreferences prefs;
final themeId = ValueNotifier<String>('light_him');
/// Stealth: hide the Locked tab (the vault is then opened by long-pressing the Library title).
final hideLockedTab = ValueNotifier<bool>(false);
/// Opt-in private fields on each read: a heat level and content notes (Settings, Privacy).
final adultFields = ValueNotifier<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.installGlobalHandlers();
  if (Secure.docBuild) Log.w('build', 'documentation build: screenshot blocking is OFF (never ship this build)');
  prefs = await SharedPreferences.getInstance();
  await CoverStore.init();
  themeId.value = prefs.getString('theme') ?? 'light_him';
  themeId.addListener(() => prefs.setString('theme', themeId.value));
  hideLockedTab.value = prefs.getBool('hide_locked') ?? false;
  hideLockedTab.addListener(() => prefs.setBool('hide_locked', hideLockedTab.value));
  initAppLockSettings();
  adultFields.value = prefs.getBool('adult_fields') ?? false;
  adultFields.addListener(() => prefs.setBool('adult_fields', adultFields.value));
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
          builder: (context, child) => AppLockOverlay(child: child ?? const SizedBox.shrink()),
          home: const Home(),
        ),
      );
}
