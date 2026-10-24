import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_lock.dart';
import 'backup_reminder.dart';
import 'covers.dart';
import 'export.dart';
import 'log.dart';
import 'notifier.dart';
import 'privacy.dart';
import 'db.dart';
import 'theme_families.dart';
import 'ui.dart';
import 'onboarding/tips.dart';

final db = AppDb();
late SharedPreferences prefs;
final themeId = ValueNotifier<String>('light_him');
/// Stealth: hide the Locked tab (the vault is then opened by long-pressing the Library title).
final hideLockedTab = ValueNotifier<bool>(false);
/// Opt-in: stars for story, characters, writing, pace and feeling on each read (Settings > Your library).
final detailedRatings = ValueNotifier<bool>(false);
/// Opt-in private fields on each read: a heat level and content notes (Settings, Privacy).
final adultFields = ValueNotifier<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.installGlobalHandlers();
  LicenseRegistry.addLicense(() async* {
    for (final f in ['Newsreader', 'HankenGrotesk']) {
      yield LicenseEntryWithLineBreaks([f], await rootBundle.loadString('assets/fonts/OFL-$f.txt'));
    }
  });
  if (Secure.docBuild) Log.w('build', 'documentation build: screenshot blocking is OFF (never ship this build)');
  prefs = await SharedPreferences.getInstance();
  Guidance.init(prefs);
  await CoverStore.init();
  themeId.value = prefs.getString('theme') ?? 'light_him';
  themeId.addListener(() => prefs.setString('theme', themeId.value));
  hideLockedTab.value = prefs.getBool('hide_locked') ?? false;
  hideLockedTab.addListener(() => prefs.setBool('hide_locked', hideLockedTab.value));
  initAppLockSettings();
  for (final k in prefs.getKeys().where((k) => k.startsWith('bk_')).toList()) {
    await prefs.remove(k); // leftovers of the Google Drive backup, removed in 0.8.2
  }
  if (prefs.getString('first_run') == null) await prefs.setString('first_run', DateTime.now().toIso8601String());
  Exporter.onSaved = BackupReminder.recordBackup;
  Notifier.clearLegacy();
  const FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: false)).delete(key: 'bk_pass').catchError((_) {});
  detailedRatings.value = prefs.getBool('detailed_ratings') ?? false;
  detailedRatings.addListener(() => prefs.setBool('detailed_ratings', detailedRatings.value));
  adultFields.value = prefs.getBool('adult_fields') ?? false;
  adultFields.addListener(() => prefs.setBool('adult_fields', adultFields.value));
  runApp(const PagemarkApp());
}

class PagemarkApp extends StatelessWidget {
  const PagemarkApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: themeId,
        builder: (_, id, _) {
          final c = ThemeChoice.parse(id);
          return MaterialApp(
            navigatorKey: navKey,
            title: 'Pagemark',
            debugShowCheckedModeBanner: false,
            theme: c.family.light.data,
            darkTheme: c.family.dark.data,
            themeMode: c.mode,
            builder: (context, child) => AppLockOverlay(child: child ?? const SizedBox.shrink()),
            home: const Home(),
          );
        },
      );
}
