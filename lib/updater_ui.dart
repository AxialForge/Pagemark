import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'branding.dart';
import 'log.dart';
import 'main.dart';
import 'updater.dart';

/// The Google Play build (`--flavor play`) never updates itself: Play does that, and Play forbids installing APKs from outside the store.
/// iOS never does either: it can't install APKs and the App Store forbids self-updating apps.
final bool selfUpdates = defaultTargetPlatform == TargetPlatform.android && appFlavor != 'play';

/// Set when a check found a newer release; drives the badge on Settings.
final updateAvailable = ValueNotifier<UpdateInfo?>(null);

/// Quiet check at most once a day, only if the user hasn't turned it off. Never throws.
Future<void> autoCheckUpdates() async {
  if (!selfUpdates || prefs.getBool('upd_auto') == false) return;
  final last = DateTime.tryParse(prefs.getString('upd_last') ?? '');
  if (last != null && DateTime.now().difference(last) < const Duration(hours: 24)) return;
  try {
    final info = await Updater.check();
    await prefs.setString('upd_last', DateTime.now().toIso8601String());
    updateAvailable.value = info.available ? info : null;
  } catch (e) {
    Log.w('update', 'auto-check skipped: $e');
  }
}

/// After an upgrade, point at what changed (offline: the changelog ships inside the app).
Future<void> announceNewVersion(BuildContext context) async {
  final v = (await PackageInfo.fromPlatform()).version;
  final seen = prefs.getString('seen_version');
  await prefs.setString('seen_version', v);
  if (seen == null || seen == v || !context.mounted) return; // fresh install, or nothing new
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Updated to Pagemark $v'),
    duration: const Duration(seconds: 8),
    action: SnackBarAction(label: "What's new", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogPage()))),
  ));
}

class UpdateTile extends StatelessWidget {
  const UpdateTile({super.key});
  @override
  Widget build(BuildContext context) => !selfUpdates ? const SizedBox.shrink() : ValueListenableBuilder<UpdateInfo?>(
        valueListenable: updateAvailable,
        builder: (_, info, _) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: Badge(
            isLabelVisible: info != null,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.system_update_alt, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
          title: Text('Updates', style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(info != null ? 'Pagemark ${info.latest} is ready to install' : 'Check for a newer version'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatePage())),
        ),
      );
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});
  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  UpdateInfo? info;
  String? error, version;
  bool checking = true, working = false;
  double progress = 0;
  String phase = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((p) { if (mounted) setState(() => version = p.version); });
    _check();
  }

  Future<void> _check() async {
    setState(() { checking = true; error = null; });
    try {
      final i = await Updater.check();
      await prefs.setString('upd_last', DateTime.now().toIso8601String());
      updateAvailable.value = i.available ? i : null;
      if (mounted) setState(() => info = i);
    } on UpdateException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (e) {
      Log.e('update', e);
      if (mounted) setState(() => error = 'Something went wrong while checking.');
    }
    if (mounted) setState(() => checking = false);
  }

  Future<void> _install() async {
    final i = info!;
    setState(() { working = true; progress = 0; phase = 'Downloading…'; error = null; });
    try {
      final apk = await Updater.download(i, (p) { if (mounted) setState(() => progress = p); });
      if (mounted) setState(() => phase = 'Opening the installer…');
      await Updater.install(apk);
    } on UpdateException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (e) {
      Log.e('update', e);
      if (mounted) setState(() => error = 'The update could not be installed.');
    }
    if (mounted) setState(() => working = false);
  }

  @override
  Widget build(BuildContext context) {
    final i = info;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Updates'), actions: [
        if (kDebugMode) // preview the "update available" state without publishing a release (debug builds only)
          PopupMenuButton<String>(
            tooltip: 'Debug',
            onSelected: (_) => setState(() {
              error = null;
              checking = false;
              info = UpdateInfo(
                current: version ?? '0.0.0',
                latest: '9.9.9',
                notes: [
                  ReleaseNote('9.9.9', 'Pagemark 9.9.9', 'Preview release: a faster library, import from Goodreads, and a few fixes.', DateTime.now()),
                  ReleaseNote('9.9.8', 'Pagemark 9.9.8', 'Preview release: small fixes.', DateTime.now().subtract(const Duration(days: 9))),
                ],
                assetName: 'Pagemark-9.9.9-arm64.apk',
                assetUrl: 'https://example.invalid/preview.apk',
                assetBytes: 30 * 1048576,
                sha256: 'preview',
              );
            }),
            itemBuilder: (_) => const [PopupMenuItem(value: 'x', child: Text('Preview "update available"'))],
          ),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: ListTile(
            leading: const AppLogo(size: 44),
            title: Text('Installed: Pagemark ${version ?? '…'}'),
            subtitle: Text(prefs.getString('upd_last') == null ? 'Not checked yet' : 'Last checked ${DateFormat.yMMMd().add_jm().format(DateTime.parse(prefs.getString('upd_last')!))}'),
          ),
        ),
        const SizedBox(height: 8),
        if (checking) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        if (!checking && error != null)
          Card(color: cs.errorContainer, child: Padding(padding: const EdgeInsets.all(14), child: Text(error!, style: TextStyle(color: cs.onErrorContainer)))),
        if (!checking && i != null && !i.available)
          const Card(child: ListTile(leading: Icon(Icons.check_circle_outline), title: Text("You're up to date"), subtitle: Text('This is the newest version.'))),
        if (!checking && i != null && i.available) ...[
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pagemark ${i.latest} is available', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(
                  '${i.releasesBehind == 1 ? 'One release' : '${i.releasesBehind} releases'} newer than yours'
                  '${i.assetBytes == null ? '' : ' · ${(i.assetBytes! / 1048576).toStringAsFixed(1)} MB'}'
                  '${i.sha256 == null ? '' : ' · integrity-checked'}',
                  style: TextStyle(color: cs.onPrimaryContainer),
                ),
                const SizedBox(height: 4),
                Text('Installs over the current app — your library, shelves and settings are kept.', style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12)),
                const SizedBox(height: 12),
                if (working) ...[
                  LinearProgressIndicator(value: phase.startsWith('Download') && progress > 0 ? progress : null),
                  const SizedBox(height: 6),
                  Text(phase.startsWith('Download') ? '$phase ${(progress * 100).round()}%' : phase, style: TextStyle(color: cs.onPrimaryContainer)),
                ] else if (i.canInstall)
                  FilledButton.icon(onPressed: _install, icon: const Icon(Icons.download), label: Text('Download & install ${i.latest}'))
                else
                  Text('This version has no download for your phone type.', style: TextStyle(color: cs.onPrimaryContainer)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text("What's new", style: Theme.of(context).textTheme.titleMedium),
          for (final n in i.notes)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${n.version}${n.date == null ? '' : ' · ${DateFormat.yMMMd().format(n.date!)}'}', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  SelectableText(n.body.isEmpty ? n.title : n.body),
                ]),
              ),
            ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: checking || working ? null : _check, icon: const Icon(Icons.refresh), label: const Text('Check again')),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Check automatically'),
          subtitle: const Text('Once a day when the app opens. Pagemark only asks the project website whether a new version exists.'),
          value: prefs.getBool('upd_auto') ?? true,
          onChanged: (v) async { await prefs.setBool('upd_auto', v); setState(() {}); },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history),
          title: const Text("What's new"),
          subtitle: const Text('Every change in every version (works without internet)'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogPage())),
        ),
      ]),
    );
  }
}

/// The changelog's inline formatting: **bold** and `code` (everything else is plain text, so nothing can inject markup).
TextSpan inlineMarkdown(String text) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
  var i = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
    if (m.group(1) != null) {
      spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.bold)));
    } else {
      spans.add(TextSpan(text: m.group(2), style: const TextStyle(fontFamily: 'monospace')));
    }
    i = m.end;
  }
  if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
  return TextSpan(children: spans);
}

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("What's new")),
        body: FutureBuilder<String>(
          future: rootBundle.loadString('CHANGELOG.md'),
          builder: (_, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(padding: const EdgeInsets.all(16), children: [
              for (final line in snap.data!.replaceAll(RegExp(r'\n {2,}(?=\S)'), ' ').split('\n').skipWhile((l) => !RegExp(r'^## \[\d').hasMatch(l)))
                if (line.startsWith('## ['))
                  Padding(padding: const EdgeInsets.only(top: 20, bottom: 4), child: Text(line.substring(3).replaceAll(RegExp(r'[\[\]]'), ''), style: Theme.of(context).textTheme.titleLarge))
                else if (line.startsWith('### '))
                  Padding(padding: const EdgeInsets.only(top: 8), child: Text(line.substring(4), style: Theme.of(context).textTheme.titleSmall))
                else if (line.startsWith('- '))
                  Padding(padding: const EdgeInsets.only(left: 8, top: 2), child: Text.rich(inlineMarkdown('•  ${line.substring(2)}')))
                else if (line.trim().isNotEmpty && !line.startsWith(' '))
                  Text.rich(inlineMarkdown(line)),
            ]);
          },
        ),
      );
}
