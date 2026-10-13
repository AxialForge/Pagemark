import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lock.dart';
import 'lock_ui.dart';
import 'main.dart';
import 'privacy.dart';

/// "Lock after leaving the app" choices, in seconds. 0 = as soon as you leave (the default, and the strictest).
const lockDelayChoices = <int, String>{0: 'Immediately', 60: 'After 1 minute', 300: 'After 5 minutes', 900: 'After 15 minutes'};

/// Should a lock engage when the app comes back after [away]? A delay of 0 means "locked the moment you left".
bool shouldRelock(Duration away, int delaySeconds) => delaySeconds <= 0 || away >= Duration(seconds: delaySeconds);

/// Settings (global): how long the app may stay in the background before the vault / app lock re-engage.
final lockDelay = ValueNotifier<int>(0);

/// Whole-app lock: when on, Pagemark asks for the PIN / fingerprint on launch and when you return after the delay.
final appLockEnabled = ValueNotifier<bool>(false);

/// True while the whole-app gate is showing.
final appLocked = ValueNotifier<bool>(false);

void initAppLockSettings() {
  lockDelay.value = prefs.getInt('lock_delay') ?? 0;
  lockDelay.addListener(() => prefs.setInt('lock_delay', lockDelay.value));
  appLockEnabled.value = prefs.getBool('app_lock') ?? false;
  appLockEnabled.addListener(() => prefs.setBool('app_lock', appLockEnabled.value));
  appLocked.value = appLockEnabled.value; // a cold start is always locked
}

/// Sits above the whole Navigator (so no screen can be pushed over it) and covers the app while [appLocked].
/// The app underneath keeps its state (open tab, scroll position), but nothing of it is visible or tappable.
class AppLockOverlay extends StatefulWidget {
  final Widget child;
  const AppLockOverlay({super.key, required this.child});
  @override
  State<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends State<AppLockOverlay> with WidgetsBindingObserver {
  DateTime? _leftAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (appLocked.value) Secure.set(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // back in front with nothing locked on screen: screen capture may be allowed again (the vault can leave it on while it closes)
    if (state == AppLifecycleState.resumed && !appLocked.value && !Secure.hold) Secure.set(false);
    if (!appLockEnabled.value) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _leftAt ??= DateTime.now();
      if (lockDelay.value == 0) _engage(); // lock before the recents card is captured
    } else if (state == AppLifecycleState.resumed) {
      final away = _leftAt == null ? Duration.zero : DateTime.now().difference(_leftAt!);
      _leftAt = null;
      if (!appLocked.value && _leftAt == null && away > Duration.zero && shouldRelock(away, lockDelay.value)) _engage();
    }
  }

  void _engage() {
    if (!appLocked.value) {
      appLocked.value = true;
      Secure.set(true);
    }
  }

  void _unlocked() {
    appLocked.value = false;
    Secure.set(false);
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        Positioned.fill(child: widget.child),
        ValueListenableBuilder<bool>(
          valueListenable: appLocked,
          builder: (context, locked, _) => locked
              ? Positioned.fill(
                  // its own Navigator gives the gate an Overlay (text fields need one) without joining the app's routes
                  child: HeroControllerScope.none( // the app's Navigator owns the Hero controller; the gate must not share it
                    child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => PopScope(
                        canPop: false,
                        onPopInvokedWithResult: (didPop, _) { if (!didPop) SystemNavigator.pop(); }, // Back leaves the app, never the lock
                        child: LockGate(title: 'Pagemark is locked', onUnlock: _unlocked),
                      ),
                    ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ]);
}

/// Turning the whole-app lock on needs a PIN or device lock to exist first.
Future<bool> enableAppLock(BuildContext context) async {
  if (await LockService.mode() == null) {
    if (!context.mounted) return false;
    final ok = await setupPin(context);
    if (!ok) return false;
  }
  return true;
}
