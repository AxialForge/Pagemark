import 'package:flutter/material.dart';

/// Pagemark's promises, in plain words. Every claim here is checked by `test/promise_test.dart` (no tracking or AI packages in the app,
/// and the internet hosts the code talks to are exactly the ones listed below), so a promise cannot quietly go out of date.
const promiseHosts = ['openlibrary.org', 'covers.openlibrary.org', 'api.github.com', 'github.com'];

class PromisePage extends StatelessWidget {
  const PromisePage({super.key});

  static const _promises = [
    (Icons.phone_android, 'Your books stay on your phone', 'Nothing is uploaded unless you choose to save a backup, and then it goes only where you put it.'),
    (Icons.visibility_off_outlined, 'We never collect your data', 'No account, no sign-up, no analytics, no tracking and no advertising ID. We cannot see what you read, and we have no server to send it to.'),
    (Icons.block, 'No ads, no selling, no sharing', 'There is nothing for us to sell. Pagemark has no ads and no in-app purchases.'),
    (Icons.psychology_alt_outlined, 'No AI inside the app', 'No AI assistant, no AI features, and nothing you write is sent to an AI service or used to train one.'),
    (Icons.lock_outline, 'Private means private', 'Locked books never show in lists, stats, the widget or saved lists. Your PIN stays on this phone and is never part of a backup.'),
    (Icons.favorite_border, 'Free, and open to inspect', 'No subscription. The code is public at github.com/AxialForge/Pagemark, so anyone can check what the app does.'),
    (Icons.shield_outlined, 'It asks for very little', 'The camera only reads barcodes (pictures are not saved or sent). Notifications only for the reminders you choose.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Our promise to you')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.verified_user_outlined, size: 40, color: cs.onPrimaryContainer),
            const SizedBox(height: 8),
            Text('Your reading is your business.', style: t.headlineSmall?.copyWith(color: cs.onPrimaryContainer)),
            const SizedBox(height: 6),
            Text('Pagemark is a private reading log. This is what we promise, and what the app really does. The small print at the bottom covers the two things worth knowing.', style: TextStyle(color: cs.onPrimaryContainer)),
          ]),
        ),
        const SizedBox(height: 12),
        for (final p in _promises)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            leading: CircleAvatar(backgroundColor: cs.secondaryContainer, child: Icon(p.$1, color: cs.onSecondaryContainer)),
            title: Text(p.$2, style: t.titleMedium),
            subtitle: Text(p.$3),
          ),
        const Divider(height: 24),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('The small print', style: t.titleMedium),
            subtitle: const Text('Where the app uses the internet, and one thing about the barcode reader'),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('The only times Pagemark uses the internet', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              _Bullet('When you search for a book, what you type (a title, an author or a barcode number) is sent to Open Library, a free library catalogue. Cover pictures come from there too.'),
              _Bullet('The GitHub version checks for a new version of itself now and then (you can turn this off in Settings, Updates).'),
              _Bullet('If you choose a backup folder inside a cloud app such as Google Drive, that app uploads the file under its own rules. Pagemark never signs in to anything.'),
              SizedBox(height: 12),
              Text('About the barcode reader', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text(
                'To read a barcode, Pagemark uses a small on-device vision tool from Google (ML Kit). It finds the barcode in the camera picture on your phone; '
                'the picture is never saved or sent by Pagemark. It is not an AI assistant and learns nothing about you. Because it comes from Google, it may report '
                'anonymous technical information (such as how fast it ran) to Google, which Pagemark cannot control. If that matters to you, type the number under '
                'the barcode instead and never open the scanner.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Questions? Look at the code, or open a question at github.com/AxialForge/Pagemark.', style: t.bodySmall),
      ]),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•  '), Expanded(child: Text(text))]),
      );
}
