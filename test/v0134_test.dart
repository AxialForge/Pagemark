import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/importer.dart';
import 'package:pagemark/privacy.dart';

void main() {
  group('PGM-203: leftover exports in the cache are really deleted', () {
    test('the share sheet and file picker folders, export files and the restore copy go; other files stay', () async {
      final dir = Directory.systemTemp.createTempSync('pgm203');
      addTearDown(() => dir.deleteSync(recursive: true));
      File('${dir.path}/share_plus/one/locked.csv').createSync(recursive: true);
      File('${dir.path}/file_picker/backup.pgbak').createSync(recursive: true);
      File('${dir.path}/pagemark-export-1.csv').createSync();
      File('${dir.path}/restore.sqlite').createSync();
      File('${dir.path}/keep.txt').createSync();
      Directory('${dir.path}/other_plugin').createSync();
      await cleanTempExports(dir: dir);
      final left = dir.listSync().map((e) => e.path.split(Platform.pathSeparator).last).toList()..sort();
      expect(left, ['keep.txt', 'other_plugin']);
    });
  });

  group('PGM-113: imported dates', () {
    test('a date that does not exist is refused in every written form', () {
      for (final bad in ['2023-02-29', '02/29/2023', '2/30/2024', '2023/02/30', '2023.02.31', '2023-04-31T10:00:00Z', '2023-13-01']) {
        expect(Importer.parseDate(bad), isNull, reason: bad);
      }
    });

    test('real dates still parse, and a timestamp keeps the day written in it', () {
      expect(Importer.parseDate('2024-02-29'), DateTime(2024, 2, 29));
      expect(Importer.parseDate('2/29/2024'), DateTime(2024, 2, 29));
      expect(Importer.parseDate('2023/05/14'), DateTime(2023, 5, 14));
      expect(Importer.parseDate('2023-05-14T23:30:00-08:00'), DateTime(2023, 5, 14), reason: 'UTC conversion must not move it to the 15th');
      expect(Importer.parseDate('2023-05-14T00:30:00+09:00'), DateTime(2023, 5, 14), reason: 'nor to the 13th');
      expect(Importer.parseDate('2023-05-14 10:00:00'), DateTime(2023, 5, 14));
    });
  });
}
