import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/updater.dart';

Map<String, Object?> rel(String tag, {String body = 'notes', bool draft = false, bool pre = false, List<Map<String, Object?>>? assets}) => {
      'tag_name': tag, 'name': 'Pagemark ${tag.substring(1)}', 'body': body, 'draft': draft, 'prerelease': pre,
      'published_at': '2026-10-12T10:00:00Z', 'assets': assets ?? [],
    };

Map<String, Object?> apk(String name, {int size = 10, String? digest}) =>
    {'name': name, 'size': size, 'browser_download_url': 'https://github.com/x/$name', 'digest': ?digest};

http.Response json(Object o, [int code = 200]) => http.Response.bytes(utf8.encode(jsonEncode(o)), code);

void main() {
  test('version comparison', () {
    expect(compareVersions('0.4.0', '0.3.0'), greaterThan(0));
    expect(compareVersions('v0.10.0', '0.9.9'), greaterThan(0), reason: 'numeric, not alphabetical');
    expect(compareVersions('1.0.0', '1.0.0+7'), 0);
    expect(compareVersions('1.0', '1.0.0'), 0);
    expect(compareVersions('0.4.0', 'v0.4.1'), lessThan(0));
  });

  group('asset choice', () {
    final assets = [apk('Pagemark-0.5.0-arm64.apk'), apk('Pagemark-0.5.0-armv7.apk'), {'name': 'notes.txt'}];
    test('prefers the phone architecture', () {
      expect(Updater.pickAsset(assets, ['arm64-v8a', 'armeabi-v7a'])!['name'], 'Pagemark-0.5.0-arm64.apk');
      expect(Updater.pickAsset(assets, ['armeabi-v7a', 'armeabi'])!['name'], 'Pagemark-0.5.0-armv7.apk');
      expect(Updater.pickAsset(assets, ['x86_64']), isNull);
    });
    test('a single universal APK is used when architectures are not named', () {
      expect(Updater.pickAsset([apk('Pagemark.apk')], ['x86_64'])!['name'], 'Pagemark.apk');
    });
  });

  group('check', () {
    Future<UpdateInfo> run(List<Object> body, {String current = '0.3.0', int code = 200}) {
      Updater.client = MockClient((_) async => json(body, code));
      return Updater.check(currentVersion: current, abis: ['arm64-v8a']);
    }

    test('lists every newer release (newest first) and picks the newest APK with its checksum', () async {
      final sha = sha256.convert([1, 2, 3]).toString();
      final i = await run([
        rel('v0.3.0'), rel('v0.5.0', body: 'five', assets: [apk('Pagemark-0.5.0-arm64.apk', size: 3, digest: 'sha256:$sha')]),
        rel('v0.4.0', body: 'four'), rel('v0.6.0', draft: true), rel('v0.7.0-beta', pre: true),
      ]);
      expect(i.available, isTrue);
      expect(i.latest, '0.5.0');
      expect(i.notes.map((n) => n.version), ['0.5.0', '0.4.0']);
      expect(i.releasesBehind, 2);
      expect(i.assetName, 'Pagemark-0.5.0-arm64.apk');
      expect(i.sha256, sha);
    });

    test('up to date, and an empty release list, are not updates', () async {
      expect((await run([rel('v0.3.0')])).available, isFalse);
      expect((await run([], current: '0.3.0')).available, isFalse);
    });

    test('readable errors for private repo, rate limit and offline', () async {
      await expectLater(run([], code: 404), throwsA(isA<UpdateException>().having((e) => e.message, 'm', contains('private'))));
      await expectLater(run([], code: 403), throwsA(isA<UpdateException>().having((e) => e.message, 'm', contains('rate'))));
      Updater.client = MockClient((_) async => throw const SocketException('offline'));
      await expectLater(Updater.check(currentVersion: '0.3.0', abis: ['arm64-v8a']), throwsA(isA<UpdateException>().having((e) => e.message, 'm', contains('connection'))));
    });
  });

  group('download', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('pgmupd'));
    tearDown(() => dir.deleteSync(recursive: true));
    final bytes = List<int>.generate(2000, (i) => i % 256);

    UpdateInfo info({int? size, String? sha}) => UpdateInfo(
        current: '0.3.0', latest: '0.5.0', notes: const [], assetName: 'a.apk', assetUrl: 'https://x/a.apk', assetBytes: size ?? bytes.length, sha256: sha);

    test('good file passes; progress reaches 1', () async {
      Updater.client = MockClient((_) async => http.Response.bytes(bytes, 200));
      var last = 0.0;
      final f = await Updater.download(info(sha: sha256.convert(bytes).toString()), (p) => last = p, to: File('${dir.path}/u.apk'));
      expect(await f.length(), bytes.length);
      expect(last, 1.0);
    });

    test('wrong checksum or wrong size is rejected and the file deleted', () async {
      Updater.client = MockClient((_) async => http.Response.bytes(bytes, 200));
      final f1 = File('${dir.path}/a.apk');
      await expectLater(Updater.download(info(sha: 'deadbeef'), (_) {}, to: f1), throwsA(isA<UpdateException>().having((e) => e.message, 'm', contains('integrity'))));
      expect(await f1.exists(), isFalse);
      final f2 = File('${dir.path}/b.apk');
      await expectLater(Updater.download(info(size: 5000), (_) {}, to: f2), throwsA(isA<UpdateException>().having((e) => e.message, 'm', contains('cut short'))));
      expect(await f2.exists(), isFalse);
    });

    test('HTTP errors surface', () async {
      Updater.client = MockClient((_) async => http.Response('no', 404));
      await expectLater(Updater.download(info(), (_) {}, to: File('${dir.path}/c.apk')), throwsA(isA<UpdateException>()));
    });
  });
}
