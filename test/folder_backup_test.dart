import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/folder_backup.dart';

void main() {
  group('when a folder backup is due', () {
    test('never run: due; recent: not due; old enough: due', () {
      final now = DateTime(2026, 10, 14, 9);
      expect(FolderBackup.isDue(now, null, 7), isTrue);
      expect(FolderBackup.isDue(now, DateTime(2026, 10, 10, 18), 7), isFalse);
      expect(FolderBackup.isDue(now, DateTime(2026, 10, 7, 23), 7), isTrue);
      expect(FolderBackup.isDue(now, DateTime(2026, 10, 13, 8), 1), isTrue);
      expect(FolderBackup.isDue(now, DateTime(2026, 10, 14, 1), 1), isFalse);
    });
  });

  group('keeping only the newest copies', () {
    test('deletes the oldest of our own files and never anything else', () {
      final names = [
        for (final d in ['20261001', '20261002', '20261003', '20261004', '20261005', '20261006', '20261007'])
          'Pagemark-backup-$d-0900.pgbak',
        'holiday-photos.zip',
        'Pagemark-notes.txt',
      ];
      final gone = FolderBackup.toDelete(names);
      expect(gone, ['Pagemark-backup-20261002-0900.pgbak', 'Pagemark-backup-20261001-0900.pgbak']);
      expect(FolderBackup.toDelete(names.take(3)), isEmpty);
    });
    test('file names carry the date and sort by age', () {
      expect(FolderBackup.fileName(DateTime(2026, 3, 5, 7, 4), 'pgbak'), 'Pagemark-backup-20260305-0704.pgbak');
    });
  });
}
