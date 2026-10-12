import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// "Discard your changes?" - used by the editors when you leave with unsaved edits.
Future<bool> confirmDiscard(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Discard changes?'),
      content: const Text('You have unsaved edits. If you leave now they will be lost.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep editing')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Discard')),
      ],
    ),
  );
  return r == true;
}

/// Long text collapsed to [maxLines] with a "Read more" toggle (only when it actually overflows).
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  const ExpandableText(this.text, {super.key, this.maxLines = 4});
  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool open = false;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final style = DefaultTextStyle.of(context).style;
        final tp = TextPainter(text: TextSpan(text: widget.text, style: style), maxLines: widget.maxLines, textDirection: TextDirection.ltr, textScaler: MediaQuery.textScalerOf(context))
          ..layout(maxWidth: box.maxWidth);
        final overflows = tp.didExceedMaxLines;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: Text(widget.text, maxLines: open ? null : widget.maxLines, overflow: open ? TextOverflow.visible : TextOverflow.ellipsis),
          ),
          if (overflows) TextButton(onPressed: () => setState(() => open = !open), child: Text(open ? 'Show less' : 'Read more')),
        ]);
      });
}

/// Open this app's page in Android settings (permissions, battery, ...). No-op elsewhere.
Future<void> openAppSettings() async {
  if (defaultTargetPlatform != TargetPlatform.android) return;
  await const AndroidIntent(action: 'android.settings.APPLICATION_DETAILS_SETTINGS', data: 'package:com.axialforge.pagemark').launch();
}

/// Open Android's security settings (to set a screen lock again).
Future<void> openSecuritySettings() async {
  if (defaultTargetPlatform != TargetPlatform.android) return;
  await const AndroidIntent(action: 'android.settings.SECURITY_SETTINGS').launch();
}

/// Open Android's battery-optimisation list so Pagemark can be allowed to run scheduled backups.
Future<void> openBatterySettings() async {
  if (defaultTargetPlatform != TargetPlatform.android) return;
  await const AndroidIntent(action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS').launch();
}
