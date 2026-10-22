import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'finding.dart' show googleOn;
import 'isbn.dart';
import 'log.dart';
import 'lookup.dart';
import 'main.dart';
import 'ui.dart';
import 'volume.dart';
import 'volume_ui.dart';
import 'widgets.dart';

/// What happened to one scanned barcode.
enum ScanState { looking, added, already, notFound, failed }

class ScanItem {
  final String isbn;
  String title;
  ScanState state = ScanState.looking;
  String note = ''; // why a lookup failed, in plain words
  int? bookId;
  VolumeGuess? guess; // a suggestion only: it is applied when the owner taps it
  bool applied = false;
  ScanItem(this.isbn, this.title);
}

/// Scan a shelf in one go: the camera stays open, each new book barcode gives one click and a buzz, and the book is looked up and
/// added in the background. A barcode already scanned in this session, or a book already in the library, is not added twice.
class BulkScanPage extends StatefulWidget {
  final bool locked;
  const BulkScanPage({super.key, required this.locked});
  @override
  State<BulkScanPage> createState() => _BulkScanPageState();
}

class _BulkScanPageState extends State<BulkScanPage> {
  final controller = MobileScannerController();
  final items = <ScanItem>[];
  final seen = <String>{};

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handle(String code) async {
    final isbn = Isbn.to13(code);
    if (isbn == null || !seen.add(isbn)) return;
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click); // one beep per book
    final item = ScanItem(isbn, isbn);
    setState(() => items.insert(0, item));
    try {
      final dup = await db.findDuplicate(title: '', isbn: isbn, locked: widget.locked);
      if (dup != null) {
        item.title = dup.title;
        item.state = ScanState.already;
      } else {
        final m = await Lookup.byIsbnAll(isbn, google: googleOn());
        if (m == null) {
          item.state = ScanState.notFound;
        } else {
          item.title = m.title;
          final again = await db.findDuplicate(title: m.title, author: m.author, isbn: isbn, locked: widget.locked);
          if (again != null) {
            item.state = ScanState.already;
          } else {
            item.bookId = await insertMeta(m, locked: widget.locked);
            if (m.series.trim().isEmpty) item.guess = parseVolume(m.title);
            item.state = ScanState.added;
          }
        }
      }
    } catch (e) {
      Log.w('bulkscan', 'lookup failed: $e');
      item.state = ScanState.failed;
      item.note = e is LookupException ? e.message : 'The lookup did not work. Scan it again.';
      seen.remove(isbn); // scanning it again tries again
    }
    if (mounted) setState(() {});
  }

  String _label(ScanItem i) => switch (i.state) {
        ScanState.looking => 'Looking up…',
        ScanState.added => 'Added',
        ScanState.already => 'Already in this library',
        ScanState.notFound => 'Not found. Add it by hand later.',
        ScanState.failed => i.note.isEmpty ? 'The lookup did not work. Scan it again.' : '${i.note} Scan it again.',
      };

  @override
  Widget build(BuildContext context) {
    int n(ScanState s) => items.where((i) => i.state == s).length;
    final summary = items.isEmpty ? 'Point the camera at a barcode. Keep going: every book is added as you scan.' : '${n(ScanState.added)} added'
        '${n(ScanState.already) > 0 ? ', ${n(ScanState.already)} already here' : ''}'
        '${n(ScanState.notFound) > 0 ? ', ${n(ScanState.notFound)} not found' : ''}';
    return Scaffold(
      appBar: AppBar(title: const Text('Scan many books'), actions: [
        IconButton(icon: const Icon(Icons.flashlight_on_outlined), tooltip: 'Torch', onPressed: controller.toggleTorch),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ]),
      body: Column(children: [
        SizedBox(
          height: 220,
          child: MobileScanner(
            controller: controller,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Pagemark needs the camera to scan barcodes. Allow it in $phoneSettingsName.'
                      : 'The camera is not available right now.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            onDetect: (cap) {
              for (final b in cap.barcodes) {
                final v = b.rawValue;
                if (v != null && Isbn.looksLikeBookCode(v)) _handle(v);
              }
            },
          ),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Semantics(liveRegion: true, child: Text(summary, textAlign: TextAlign.center))),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final it = items[i];
              return ListTile(
                leading: switch (it.state) {
                  ScanState.looking => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ScanState.added => const Icon(Icons.check_circle_outline),
                  ScanState.already => const Icon(Icons.info_outline),
                  _ => const Icon(Icons.error_outline),
                },
                title: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(_label(it)),
                trailing: it.guess == null || it.bookId == null
                    ? null
                    : it.applied
                        ? const Icon(Icons.check)
                        : TextButton(
                            onPressed: () async {
                              await applyVolume(it.bookId!, it.guess!);
                              if (mounted) setState(() => it.applied = true);
                            },
                            child: Text(guessText(it.guess!)),
                          ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
