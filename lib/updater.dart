import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as hash;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'log.dart';

/// Compare "1.2.3" style versions. A leading "v" and a "+build" suffix are ignored; a "-rc1" style suffix makes a version
/// sort just below the same number without it (1.0.0-rc1 < 1.0.0). Parts too large for an int still compare correctly.
int compareVersions(String a, String b) {
  (List<BigInt>, bool) parse(String v) {
    final noBuild = v.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;
    final dash = noBuild.indexOf('-');
    final core = dash < 0 ? noBuild : noBuild.substring(0, dash);
    final parts = core.split('.').map((p) => BigInt.tryParse(p) ?? BigInt.zero).toList();
    while (parts.length < 3) {
      parts.add(BigInt.zero);
    }
    return (parts, dash >= 0);
  }

  final (x, xPre) = parse(a);
  final (y, yPre) = parse(b);
  final n = x.length > y.length ? x.length : y.length;
  for (var i = 0; i < n; i++) {
    final xi = i < x.length ? x[i] : BigInt.zero, yi = i < y.length ? y[i] : BigInt.zero;
    if (xi != yi) return xi.compareTo(yi);
  }
  if (xPre != yPre) return xPre ? -1 : 1;
  return 0;
}

class ReleaseNote {
  final String version, title, body;
  final DateTime? date;
  const ReleaseNote(this.version, this.title, this.body, this.date);
}

class UpdateInfo {
  final String current, latest;
  final List<ReleaseNote> notes; // every release newer than the installed one, newest first
  final String? assetName, assetUrl, sha256;
  final int? assetBytes;
  const UpdateInfo({required this.current, required this.latest, required this.notes, this.assetName, this.assetUrl, this.sha256, this.assetBytes});

  bool get available => compareVersions(latest, current) > 0;
  int get releasesBehind => notes.length;
  bool get canInstall => assetUrl != null;
}

class UpdateException implements Exception {
  final String message;
  UpdateException(this.message);
  @override
  String toString() => message;
}

/// Checks the project's GitHub Releases (the only network call this feature makes) and installs
/// the matching APK. Same signing key as the installed app, so Android upgrades in place and keeps your data.
class Updater {
  static const repo = 'AxialForge/Pagemark';
  static http.Client client = http.Client();

  /// Which APK in a release is for this phone: arm64 first, then 32-bit ARM, then x86_64.
  static Map<String, Object?>? pickAsset(List<dynamic> assets, List<String> abis) {
    final apks = [for (final a in assets) if (a is Map<String, Object?> && '${a['name']}'.endsWith('.apk')) a];
    bool has(Map a, String k) => '${a['name']}'.toLowerCase().contains(k);
    final wants = <String>[
      for (final abi in abis)
        if (abi.startsWith('arm64')) 'arm64' else if (abi.startsWith('armeabi')) 'armv7' else if (abi.startsWith('x86_64')) 'x86_64',
    ];
    for (final w in wants) {
      final hit = apks.where((a) => has(a, w)).firstOrNull;
      if (hit != null) return hit;
    }
    return apks.length == 1 ? apks.first : null;
  }

  static Future<List<String>> _abis() async {
    try {
      return (await DeviceInfoPlugin().androidInfo).supportedAbis;
    } catch (_) {
      return const ['arm64-v8a'];
    }
  }

  static Future<UpdateInfo> check({String? currentVersion, List<String>? abis}) async {
    final current = currentVersion ?? (await PackageInfo.fromPlatform()).version;
    final http.Response r;
    try {
      r = await client
          .get(Uri.https('api.github.com', '/repos/$repo/releases', {'per_page': '20'}),
              headers: {'Accept': 'application/vnd.github+json', 'User-Agent': 'Pagemark-updater'})
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      Log.w('update', 'check failed: $e');
      throw UpdateException('Could not reach GitHub — check your connection.');
    }
    if (r.statusCode == 404) {
      throw UpdateException('No public releases found. If the repository is private, updates can\'t be checked from the app.');
    }
    if (r.statusCode == 403 || r.statusCode == 429) throw UpdateException('GitHub is rate-limiting update checks. Try again later.');
    if (r.statusCode != 200) throw UpdateException('GitHub answered HTTP ${r.statusCode}.');

    final list = jsonDecode(utf8.decode(r.bodyBytes));
    final releases = [
      for (final x in (list is List ? list : const []))
        if (x is Map<String, Object?> && x['draft'] != true && x['prerelease'] != true && x['tag_name'] is String && (x['tag_name'] as String).isNotEmpty) x,
    ]..sort((a, b) => compareVersions('${b['tag_name']}', '${a['tag_name']}'));
    if (releases.isEmpty) return UpdateInfo(current: current, latest: current, notes: const []);

    final newer = releases.where((x) => compareVersions('${x['tag_name']}', current) > 0).toList();
    final top = releases.first;
    final asset = pickAsset(top['assets'] is List ? top['assets'] as List : const [], abis ?? await _abis());
    final digest = asset?['digest'];
    return UpdateInfo(
      current: current,
      latest: '${top['tag_name']}'.replaceFirst(RegExp(r'^[vV]'), ''),
      notes: [
        for (final x in newer)
          ReleaseNote('${x['tag_name']}'.replaceFirst(RegExp(r'^[vV]'), ''), '${x['name'] ?? x['tag_name']}', '${x['body'] ?? ''}'.trim(),
              DateTime.tryParse('${x['published_at']}')),
      ],
      assetName: asset?['name'] as String?,
      assetUrl: asset?['browser_download_url'] as String?,
      sha256: digest is String && digest.startsWith('sha256:') ? digest.substring(7).toLowerCase() : null,
      assetBytes: asset?['size'] is int ? asset!['size'] as int : null,
    );
  }

  /// Download with progress; verifies size and (when GitHub provides it) SHA-256 before returning the file.
  static Future<File> download(UpdateInfo info, void Function(double) onProgress, {File? to}) async {
    final uri = Uri.tryParse(info.assetUrl ?? '');
    const hosts = {'github.com', 'objects.githubusercontent.com', 'github-releases.githubusercontent.com'};
    if (uri == null || uri.scheme != 'https' || !hosts.contains(uri.host)) {
      throw UpdateException('The update is not hosted on GitHub, so Pagemark will not download it.');
    }
    if (info.sha256 == null && info.assetBytes == null) {
      throw UpdateException('GitHub did not say how large or which file this update should be, so it cannot be checked. Not downloaded.');
    }
    final file = to ?? File('${(await getTemporaryDirectory()).path}/pagemark-update.apk');
    if (await file.exists()) await file.delete();
    final req = http.Request('GET', uri)..headers['User-Agent'] = 'Pagemark-updater';
    final resp = await client.send(req).timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) throw UpdateException('Download failed (HTTP ${resp.statusCode}).');
    final total = resp.contentLength ?? info.assetBytes ?? 0;
    final sink = file.openWrite();
    var got = 0;
    try {
      await for (final chunk in resp.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress((got / total).clamp(0.0, 1.0));
      }
    } finally {
      await sink.close();
    }
    if (info.assetBytes != null && got != info.assetBytes) {
      await file.delete();
      throw UpdateException('The download was cut short ($got of ${info.assetBytes} bytes). Try again.');
    }
    if (info.sha256 != null) {
      final digest = (await hash.sha256.bind(file.openRead()).first).toString();
      if (digest != info.sha256) {
        await file.delete();
        throw UpdateException('The downloaded file failed its integrity check, so it was discarded.');
      }
    }
    return file;
  }

  /// Hand the APK to Android's installer. The first time, Android asks to allow installs from Pagemark.
  static Future<void> install(File apk) async {
    if (defaultTargetPlatform != TargetPlatform.android) throw UpdateException('Installing updates is Android-only.');
    final r = await OpenFilex.open(apk.path, type: 'application/vnd.android.package-archive');
    Log.i('update', 'installer result: ${r.type} ${r.message}');
    if (r.type == ResultType.permissionDenied) {
      throw UpdateException('Allow Pagemark to install apps (Android will have asked), then tap Install again.');
    }
    if (r.type != ResultType.done) throw UpdateException('Could not open the installer: ${r.message}');
  }
}
