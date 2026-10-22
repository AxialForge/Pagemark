import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lock.dart';
import 'widgets.dart';

void _snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

String _fmt(Duration d) => d.inMinutes >= 1 ? '${d.inMinutes} min ${d.inSeconds % 60} s' : '${d.inSeconds} s';

Future<String?> _pinDialog(BuildContext c, String title, {String hint = 'PIN'}) {
  final ctl = TextEditingController();
  return showDialog<String>(
    context: c,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctl, autofocus: true, obscureText: true, keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(labelText: hint),
        onSubmitted: (v) => Navigator.pop(c, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, ctl.text), child: const Text('OK')),
      ],
    ),
  );
}

/// Make the user prove they own the lock before changing it (current PIN, or device auth).
/// Makes the fingerprint or device lock the only way in: warns when the phone has no strong biometric, then asks the phone to confirm.
/// Returns whether the lock is now device-only.
Future<bool> chooseDeviceLock(BuildContext context) async {
  if (!await LockService.strongBiometricAvailable()) {
    if (!context.mounted) return false;
    final go = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('No fingerprint or Face ID on this phone'),
        content: const Text('Without a strong biometric, "device lock" means your screen-lock PIN or pattern, or a weaker face unlock. '
            'A Pagemark PIN is stronger. Use the device lock anyway?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Use a PIN instead')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Use device lock')),
        ],
      ),
    );
    if (go != true || !context.mounted) return false;
  }
  if (!await LockService.deviceAuth('Confirm to use your device lock')) return false;
  await LockService.setDeviceOnly();
  return true;
}

Future<bool> confirmCurrent(BuildContext c, {String title = 'Enter your current PIN'}) async {
  final mode = await LockService.mode();
  if (mode == null) return true;
  if (mode == 'device' || mode == 'lost' || mode == 'unavailable') return LockService.deviceAuth('Confirm it is you');
  if (!c.mounted) return false;
  final pin = await _pinDialog(c, title);
  if (pin == null || !c.mounted) return false;
  final result = await LockService.checkPin(pin);
  if (!c.mounted) return false;
  switch (result) {
    case PinResult.ok:
      return true;
    case PinResult.wrong:
      _snack(c, 'Wrong PIN');
    case PinResult.lockedOut:
      final left = await LockService.lockoutRemaining();
      if (!c.mounted) return false;
      _snack(c, 'Too many attempts — try again in ${_fmt(left)}');
  }
  return false;
}

/// New PIN entered twice, then a one-time recovery code the user must acknowledge.
Future<bool> setupPin(BuildContext c) async {
  final a = await _pinDialog(c, 'New PIN (4–12 digits)');
  if (a == null || !c.mounted) return false;
  if (a.length < 4 || a.length > 12) {
    _snack(c, 'PIN must be 4–12 digits');
    return false;
  }
  final b = await _pinDialog(c, 'Re-enter the PIN', hint: 'Confirm PIN');
  if (b == null || !c.mounted) return false;
  if (a != b) {
    _snack(c, 'PINs did not match — nothing changed');
    return false;
  }
  final code = await LockService.setPin(a);
  if (!c.mounted) return true;
  await showDialog<void>(
    context: c,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Save your recovery code'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('If you forget your PIN, this code is the only way back into the locked library. It is shown once.'),
        const SizedBox(height: 12),
        SelectableText(code, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ]),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            Timer(const Duration(seconds: 60), () async { // do not leave the recovery code on the clipboard
              final now = await Clipboard.getData(Clipboard.kTextPlain);
              if (now?.text == code) await Clipboard.setData(const ClipboardData(text: ''));
            });
          },
          child: const Text('Copy (clears in 1 min)'),
        ),
        FilledButton(onPressed: () => Navigator.pop(c), child: const Text('I saved it')),
      ],
    ),
  );
  return true;
}

class LockGate extends StatefulWidget {
  final VoidCallback onUnlock;
  final String title;
  const LockGate({super.key, required this.onUnlock, this.title = 'Locked library'});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  final pin = TextEditingController();
  String? mode;
  bool loaded = false, deviceOk = false;
  String? err;
  Duration wait = Duration.zero;
  Timer? tick;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await LockService.mode();
    final d = await LockService.deviceAvailable();
    final w = await LockService.lockoutRemaining();
    if (!mounted) return;
    setState(() { mode = m; deviceOk = d; wait = w; loaded = true; });
    _startTick();
    if (m == 'device') _device();
  }

  void _startTick() {
    tick?.cancel();
    if (wait <= Duration.zero) return;
    tick = Timer.periodic(const Duration(seconds: 1), (t) async {
      final w = await LockService.lockoutRemaining();
      if (!mounted) return;
      setState(() => wait = w);
      if (w <= Duration.zero) t.cancel();
    });
  }

  @override
  void dispose() {
    tick?.cancel();
    pin.dispose();
    super.dispose();
  }

  Future<void> _tryPin() async {
    final r = await LockService.checkPin(pin.text);
    pin.clear();
    if (!mounted) return;
    switch (r) {
      case PinResult.ok:
        widget.onUnlock();
      case PinResult.wrong:
        HapticFeedback.heavyImpact();
        setState(() => err = 'Wrong PIN');
      case PinResult.lockedOut:
        HapticFeedback.heavyImpact();
        wait = await LockService.lockoutRemaining();
        if (!mounted) return;
        setState(() => err = null);
        _startTick();
    }
  }

  Future<void> _device() async {
    if (await LockService.deviceAuth() && mounted) widget.onUnlock();
  }

  Future<void> _forgot() async {
    final code = TextEditingController(), np = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset with recovery code'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: code, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Recovery code')),
          TextField(controller: np, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'New PIN (4–12 digits)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (np.text.length < 4 || np.text.length > 12) {
      _snack(context, 'PIN must be 4–12 digits');
      return;
    }
    final fresh = await LockService.resetWithRecovery(code.text, np.text);
    if (!mounted) return;
    if (fresh == null) {
      _snack(context, 'Recovery code not accepted');
      _load();
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('New recovery code'),
        content: SelectableText('Your old code no longer works. Save this one:\n\n$fresh'),
        actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('I saved it'))],
      ),
    );
    if (mounted) widget.onUnlock();
  }

  @override
  Widget build(BuildContext context) {
    final locked = wait > Duration.zero;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: !loaded
          ? const SizedBox()
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(locked ? Icons.timer_outlined : Icons.lock, size: 64),
                  const SizedBox(height: 16),
                  if (mode == null) ...[
                    const Text('Choose how to protect this library.', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () async { if (await setupPin(context) && mounted) widget.onUnlock(); }, child: const Text('Set a PIN')),
                    TextButton.icon(
                      onPressed: !deviceOk
                          ? null
                          : () async {
                              if (await chooseDeviceLock(context) && mounted) widget.onUnlock();
                            },
                      icon: Icon(biometricIcon),
                      label: Text(deviceOk ? 'Use $biometricName / device lock only' : 'Device lock unavailable (set a screen lock first)'),
                    ),
                  ] else if (mode == 'lost' || mode == 'unavailable') ...[
                    Text(
                      mode == 'lost'
                          ? 'The phone cleared the saved lock for Pagemark (this can happen after a system restore or a change to the phone screen lock). '
                              'Your private library stays closed until you confirm it is you.'
                          : 'Pagemark could not read its saved lock just now, so the library stays closed. Try again in a moment.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (mode == 'lost')
                      FilledButton(
                        onPressed: () async {
                          // prove ownership with the phone's own lock first; with no phone lock at all there is nothing stronger to ask for
                          final ok = !deviceOk || await LockService.deviceAuth('Confirm it is you to set a new lock');
                          if (!ok || !mounted) return;
                          await LockService.clear();
                          if (!mounted) return;
                          if (await setupPin(this.context) && mounted) {
                            widget.onUnlock();
                          } else if (mounted) {
                            _load();
                          }
                        },
                        child: Text(deviceOk ? 'Confirm with phone lock, then set a new PIN' : 'Set a new PIN'),
                      ),
                    TextButton(onPressed: _load, child: const Text('Try again')),
                  ] else if (mode == 'device') ...[
                    if (!deviceOk) ...[
                      Text(
                        'This phone no longer has a screen lock or $biometricName set up, so the locked library cannot be opened. '
                        'Set a screen lock again in $phoneSettingsName, then come back.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: openSecuritySettings, child: const Text('Open security settings')),
                      TextButton(onPressed: _load, child: const Text('Try again')),
                    ] else
                      FilledButton.icon(onPressed: _device, icon: Icon(biometricIcon), label: const Text('Unlock')),
                  ] else ...[
                    if (locked) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('Too many attempts. Try again in ${_fmt(wait)}.', textAlign: TextAlign.center)),
                    TextField(
                      controller: pin, enabled: !locked, obscureText: true, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], onSubmitted: (_) => _tryPin(),
                      decoration: InputDecoration(labelText: 'PIN', errorText: err, border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: locked ? null : _tryPin, child: const Text('Unlock')),
                    if (deviceOk) TextButton.icon(onPressed: locked ? null : _device, icon: Icon(biometricIcon), label: Text('Use $biometricName / device lock')),
                    TextButton(onPressed: _forgot, child: const Text('Forgot PIN?')),
                  ],
                ]),
              ),
            ),
    );
  }
}

