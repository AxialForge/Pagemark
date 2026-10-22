import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/lock.dart';
import 'package:pagemark/widgets.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    iosTouchId = false;
  });

  test('Android keeps its words', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(biometricName, 'fingerprint');
    expect(biometricNameCap, 'Fingerprint');
    expect(phoneSettingsName, 'Android Settings');
    expect(cloudDriveName, 'Google Drive');
  });

  test('iPhone with Face ID', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(biometricName, 'Face ID');
    expect(phoneSettingsName, 'iPhone Settings');
    expect(cloudDriveName, 'iCloud Drive');
  });

  test('iPhone with Touch ID never says Face ID', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    iosTouchId = true;
    expect(biometricName, 'Touch ID');
    expect(biometricNameCap, 'Touch ID');
  });

  test('Touch ID detection is iOS-only', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(await LockService.hasTouchId(), isFalse);
  });
}
