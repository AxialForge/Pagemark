import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'export.dart';
import 'importer.dart';
import 'log.dart';
import 'main.dart';
import 'ui.dart';

/// Settings -> Import: pick a Pagemark / Goodreads / StoryGraph export, see what it holds, choose how to treat
/// books you already have, import in one all-or-nothing step, with a safety copy and an Undo.
class ImportPage extends StatefulWidget {
  const ImportPage({super.key});
  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  ImportParse? parsed;
  ImportPlan? plan;
  String? fileName, error;
  bool busy = false;
  DuplicatePolicy policy = DuplicatePolicy.skip;
  ImportResult? done;

  Future<void> _pick() async {
    final f = await FilePicker.pickFile();
    final path = f?.path;
    if (path == null) return;
    setState(() { busy = true; error = null; parsed = null; plan = null; done = null; });
    try {
      final text = utf8.decode(await File(path).readAsBytes(), allowMalformed: true);
      final p = Importer.parse(text);
      final pl = await ImportRunner.plan(db, p);
      _existing = {for (final s in await db.select(db.shelves).get()) s.name.toLowerCase()};
      setState(() { parsed = p; plan = pl; fileName = path.split(RegExp(r'[\\/]')).last; });
    } on ImportException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      Log.e('import', e);
      setState(() => error = 'That file could not be read. Is it a Goodreads, StoryGraph or Pagemark export?');
    }
    setState(() => busy = false);
  }

  Future<void> _import() async {
    setState(() => busy = true);
    try {
      await Exporter.safetyCopy(db, 'pre-import'); // restore point, newest 3 kept
      final r = await ImportRunner.run(db, plan!, policy);
      setState(() => done = r);
    } catch (e) {
      Log.e('import', e);
      setState(() => error = 'The import failed and nothing was changed. Details are in Settings, Help and about, Problem report.');
    }
    setState(() => busy = false);
  }

  Future<void> _undo() async {
    await ImportRunner.undo(db, done!); // new books go to Trash, so even this is recoverable for 30 days
    if (mounted) {
      snack(context, '${done!.newBookIds.length} imported books moved to Trash');
      setState(() { done = null; parsed = null; plan = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = parsed, pl = plan, cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (busy) const LinearProgressIndicator(),
        const Text('Bring in your reading history from another app, or from a Pagemark list you saved earlier. '
            'Imports go into your main library (never the locked one), and nothing is changed until you confirm.'),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Where do I get the file?'),
            subtitle: const Text('Goodreads: My Books → Import and export → Export Library.\n'
                'StoryGraph: Manage Account → Manage Your Data → Export.\n'
                'Pagemark: Settings → Import and export.'),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: busy ? null : _pick, icon: const Icon(Icons.upload_file), label: Text(p == null ? 'Choose a file' : 'Choose a different file')),
        if (error != null) Card(color: cs.errorContainer, margin: const EdgeInsets.only(top: 12), child: Padding(padding: const EdgeInsets.all(14), child: Text(error!, style: TextStyle(color: cs.onErrorContainer)))),
        if (p != null && pl != null && done == null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.source.label, style: Theme.of(context).textTheme.titleMedium),
                Text(fileName ?? '', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                _row('Books found', '${p.books.length}'),
                _row('Reads (read-throughs)', '${p.readCount}'),
                _row('New to your library', '${pl.fresh.length}'),
                _row('Already in your library', '${pl.duplicates.length}'),
                if (_shelvesToCreate(pl) > 0) _row('Shelves it will create', '${_shelvesToCreate(pl)}'),
                if (p.skipped.isNotEmpty) _row('Rows skipped', '${p.skipped.length}'),
              ]),
            ),
          ),
          if (p.skipped.isNotEmpty)
            ExpansionTile(title: const Text('Why were rows skipped?'), children: [for (final s in p.skipped.take(20)) ListTile(dense: true, title: Text(s))]),
          if (pl.duplicates.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('For the ${_n(pl.duplicates.length, 'book')} you already have:', style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<DuplicatePolicy>(
              groupValue: policy,
              onChanged: (v) => setState(() => policy = v ?? policy),
              child: Column(children: const [
                RadioListTile<DuplicatePolicy>(value: DuplicatePolicy.skip, title: Text('Skip them'), subtitle: Text('Keep what you have; import only new books')),
                RadioListTile<DuplicatePolicy>(value: DuplicatePolicy.addReads, title: Text('Add the file\'s reads to them'), subtitle: Text('Same book, extra read-throughs and shelves from the file')),
                RadioListTile<DuplicatePolicy>(value: DuplicatePolicy.addAnyway, title: Text('Import them as separate copies'), subtitle: Text('Creates a second entry for each')),
              ]),
            ),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: busy || (pl.fresh.isEmpty && (pl.duplicates.isEmpty || policy == DuplicatePolicy.skip)) ? null : _import,
            icon: const Icon(Icons.download_done),
            label: Text(_importLabel(pl)),
          ),
          const SizedBox(height: 4),
          const Text('A copy of your library is saved first, and you can undo the import afterwards.', style: TextStyle(fontSize: 12)),
        ],
        if (done != null) ...[
          const SizedBox(height: 12),
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Import finished', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onPrimaryContainer)),
                const SizedBox(height: 6),
                Text('${_n(done!.booksAdded, 'book')} added · ${_n(done!.readsAdded, 'read')} logged'
                    '${done!.shelvesCreated > 0 ? ' · ${_n(done!.shelvesCreated, 'shelf', 'shelves')} created' : ''}'
                    '${done!.duplicatesSkipped > 0 ? ' · ${_n(done!.duplicatesSkipped, 'already-owned book')} skipped' : ''}', style: TextStyle(color: cs.onPrimaryContainer)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: [
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('See my library')),
                  if (done!.newBookIds.isNotEmpty || done!.existingReadIds.isNotEmpty) OutlinedButton(onPressed: _undo, child: const Text('Undo import')),
                ]),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  static String _n(int n, String one, [String? many]) => '$n ${n == 1 ? one : (many ?? '${one}s')}';

  /// Shelves that do not exist yet and would be made for the books this policy actually imports.
  int _shelvesToCreate(ImportPlan pl) {
    final books = [...pl.fresh, if (policy != DuplicatePolicy.skip) for (final d in pl.duplicates) d.$1];
    return {for (final b in books) ...b.shelves.map((s) => s.toLowerCase())}.where((s) => !_existing.contains(s)).length;
  }

  Set<String> _existing = {};

  String _importLabel(ImportPlan pl) {
    final n = pl.fresh.length + (policy == DuplicatePolicy.skip ? 0 : pl.duplicates.length);
    return policy == DuplicatePolicy.addReads && pl.duplicates.isNotEmpty ? 'Import ${pl.fresh.length} new books + update ${pl.duplicates.length}' : 'Import ${NumberFormat.decimalPattern().format(n)} books';
  }

  Widget _row(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Expanded(child: Text(k)), Text(v, style: Theme.of(context).textTheme.titleMedium)]));
}
