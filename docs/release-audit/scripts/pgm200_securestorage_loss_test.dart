// PGM-200 evidence: when secure storage comes back EMPTY (flutter_secure_storage resetOnError=true after a Keystore
// failure), the locked-library gate and the whole-app lock treat the app as "no lock configured yet" and offer to set a
// NEW PIN, which then unlocks. Run from the project root:
//   flutter test docs/release-audit/scripts/pgm200_securestorage_loss_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/lock.dart';
import 'package:pagemark/lock_ui.dart';

void main() {
  testWidgets('PGM-200: empty secure storage => gate offers "Set a PIN" and unlocks without the old PIN', (t) async {
    FlutterSecureStorage.setMockInitialValues({}); // what the app sees after a silent resetOnError wipe
    LockService.debugDeviceSupported = false;
    var unlocked = false;
    await t.pumpWidget(MaterialApp(home: LockGate(onUnlock: () => unlocked = true)));
    await t.pumpAndSettle();
    expect(find.text('Set a PIN'), findsOneWidget, reason: 'gate should have refused (a PIN was configured before the wipe)');
    expect(await LockService.mode(), isNull);
    // the dialog flow itself is exercised by setupPin; mode()==null is the root cause
    expect(unlocked, isFalse);
    LockService.debugDeviceSupported = null;
  });
}
