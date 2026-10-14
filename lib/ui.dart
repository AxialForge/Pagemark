import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'adaptive.dart';
import 'app_lock.dart';
import 'bulk_scan.dart';
import 'finding.dart';
import 'reading_life_ui.dart';
import 'backup_reminder.dart';
import 'restore_ui.dart';
import 'book_extras.dart';
import 'covers.dart';
import 'branding.dart';
import 'updater.dart';
import 'updater_ui.dart';
import 'features.dart';
import 'import_ui.dart';
import 'lock_ui.dart';
import 'privacy.dart';
import 'selection.dart';
import 'skins.dart';
import 'notifier.dart';
import 'text_utils.dart';
import 'widgets.dart';
import 'db.dart';
import 'export.dart';
import 'lock.dart';
import 'isbn.dart';
import 'detailed_ratings.dart';
import 'firstrun.dart';
import 'folder_backup.dart';
import 'guide.dart';
import 'promise.dart';
import 'incoming.dart';
import 'log.dart';
import 'lookup.dart';
import 'reminders.dart';
import 'welcome.dart';
import 'widget_sync.dart';
import 'main.dart';
import 'themes.dart';

// This library is split over several files (one per group of screens) so each stays readable. They share privacy on purpose.
part 'ui/home.dart';
part 'ui/library.dart';
part 'ui/add_book.dart';
part 'ui/book_page.dart';
part 'ui/read_editor.dart';
part 'ui/settings.dart';
part 'ui/misc.dart';

const formats = {'print': 'Print', 'ebook': 'E-book', 'audio': 'Audiobook'};
const statuses = {'want': 'Want to read', 'reading': 'Reading', 'finished': 'Finished', 'dnf': 'Did not finish'};
DateFormat get _date => appDate(); // the style chosen in Settings > Your library

void snack(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..clearSnackBars() // a new message replaces the old one instead of queueing
  ..showSnackBar(SnackBar(content: Text(m)));
