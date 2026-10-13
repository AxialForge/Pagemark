// PGM-201 evidence: exceptions from Drift/sqlite3 embed the SQL statement AND its bound parameters in toString().
// Log.e / Log.w interpolate `$e` (import_ui.dart:42,55; backup.dart:46,201; log.dart:75,79 global handlers), so a failing
// write can put book titles / thoughts / shelf names into the Diagnostics log, which the docs promise never holds them.
//   flutter test docs/release-audit/scripts/pgm201_log_param_leak_test.dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';

void main() {
  test('PGM-201: logged exception text contains user data', () async {
    final db = AppDb.memory();
    await db.into(db.shelves).insert(ShelvesCompanion.insert(name: 'MY-SECRET-SHELF-NAME'));
    Object? caught;
    try {
      await db.into(db.shelves).insert(ShelvesCompanion.insert(name: 'MY-SECRET-SHELF-NAME'));
    } catch (e) {
      caught = e;
    }
    final text = '$caught'; // exactly what Log.e('import', e) / Log.w('backup', '... $e') would write
    // ignore: avoid_print
    print(text);
    expect(text.contains('MY-SECRET-SHELF-NAME'), isTrue, reason: 'parameters are in the exception text => in pagemark.log');
    await db.close();
  });
}
