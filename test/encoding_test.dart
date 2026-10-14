import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// A script once re-encoded a Dart file and turned every dash into garbage (shipped in 0.7.1 to 0.8.0). This keeps that from happening again.
void main() {
  final roots = ['lib', 'test', 'assets', 'android/app/src', 'docs/release-package', 'README.md', 'CHANGELOG.md', 'CLAUDE.md'];
  const ext = {'.dart', '.md', '.xml', '.kt', '.yaml'};

  Iterable<File> files() sync* {
    for (final r in roots) {
      final t = FileSystemEntity.typeSync(r);
      if (t == FileSystemEntityType.file) {
        yield File(r);
      } else if (t == FileSystemEntityType.directory) {
        for (final f in Directory(r).listSync(recursive: true).whereType<File>()) {
          if (ext.any(f.path.endsWith) && !f.path.endsWith('.g.dart') && !f.path.contains('encoding_test.dart')) yield f;
        }
      }
    }
  }

  test('source files are plain UTF-8: no byte-order mark, no garbled dashes or quotes', () {
    final bad = <String>[];
    final garbled = RegExp('\u00e2\u20ac|\u00c3\u00a2\u00e2|\u00ef\u00bb\u00bf|\ufffd');
    for (final f in files()) {
      final bytes = f.readAsBytesSync();
      if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) bad.add('${f.path}: starts with a BOM');
      final text = String.fromCharCodes(f.readAsStringSync().runes);
      if (garbled.hasMatch(text)) bad.add('${f.path}: contains garbled characters');
    }
    expect(bad, isEmpty);
  });
}
