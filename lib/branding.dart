import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The Pagemark logo (assets/branding/logo.png), with rounded corners and a soft fade-in.
class AppLogo extends StatelessWidget {
  final double size;
  final bool animate;
  const AppLogo({super.key, this.size = 56, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final img = Semantics(
      label: 'Pagemark logo',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset('assets/branding/logo.png', width: size, height: size, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
      ),
    );
    if (!animate) return img;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.scale(scale: 0.85 + 0.15 * v, child: child)),
      child: img,
    );
  }
}

/// Logo + message (+ optional button) for screens with nothing to show yet.
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => SingleChildScrollView( // scrolls instead of overflowing on short screens / large fonts
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight.isFinite ? box.maxHeight : 0),
            child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Opacity(opacity: 0.9, child: AppLogo(size: 88)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.add), label: Text(actionLabel!)),
            ],
          ]),
        ),
            ),
          ),
        ),
      );
}

/// Top of Settings: logo, name, version; tap for About (and the Open Library credit).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, snap) {
          final v = snap.data?.version ?? '';
          return ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            leading: const AppLogo(size: 52),
            title: Text('Pagemark', style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text(v.isEmpty ? 'Your private reading log' : 'Version $v · your private reading log'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Pagemark',
              applicationVersion: v,
              applicationIcon: const AppLogo(size: 48, animate: false),
              applicationLegalese: '© 2026 AxialForge. All your data stays on this device.',
              children: const [
                SizedBox(height: 12),
                Text('Book details and covers come from Open Library (openlibrary.org), a free, open project of the Internet Archive, and from Google Books.'),
              ],
            ),
          );
        },
      );
}
