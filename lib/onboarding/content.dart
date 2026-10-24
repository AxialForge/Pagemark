/// The tour's words, as plain data. No Flutter imports: the tour, the Help hub and the tests all read the same lists, so
/// what the tour teaches cannot drift from what Help says. Every claim is checked against the app as it ships; update
/// the text whenever a feature changes.
library;

/// Which version of the tour this build carries. Bump it when the tour changes enough that people who finished it
/// should hear about it (they get the short "What's new" sheet, never the whole tour).
const tourVersion = '1.3.0';

/// Which small animation goes with a page (drawn in `tour_art.dart`).
enum Art { welcome, privacy, keeps, tour, camera, bell, setup, addBook, logRead, library, manga, quotes, locked, stats, backup, start }

/// One numbered point of a page, lesson or article.
class TourStep {
  final String title;
  final String body;
  const TourStep(this.title, this.body);
}

/// One welcome page.
class WelcomeInfo {
  final String id;
  final Art art;
  final String title;
  final String lead;
  final List<TourStep> points;
  const WelcomeInfo(this.id, this.art, this.title, this.lead, this.points);
}

/// What Pagemark can actually ask Android for.
enum PermKind { camera, notifications }

/// A permission explained before Android's own question.
class PermissionInfo {
  final String id;
  final Art art;
  final String title;
  final PermKind kind;
  final String why;
  final String never;
  final String ifNo;
  final String later;
  const PermissionInfo({required this.id, required this.art, required this.title, required this.kind, required this.why, required this.never, required this.ifNo, required this.later});
}

/// Where a lesson's "Try it" button goes.
enum TryTarget { addBook, library, manga, book, locked, stats, backup }

/// A lesson in the tour, also listed in Help & tips.
class Lesson {
  final String id;
  final String title;
  final String summary;
  final Art art;
  final List<TourStep> steps;
  final String? tip;
  final String tryLabel;
  final TryTarget target;

  /// The coach-mark tip shown on the real screen after Try it.
  final String coachId;
  const Lesson({required this.id, required this.title, required this.summary, required this.art, required this.steps, this.tip, required this.tryLabel, required this.target, required this.coachId});

  String get haystack => [title, summary, ...steps.expand((s) => [s.title, s.body]), ?tip].join(' ').toLowerCase();
}

/// One tooltip of a screen's coach marks: which marked widget to light up and what to say.
class CoachStep {
  final String targetId;
  final String title;
  final String body;
  const CoachStep(this.targetId, this.title, this.body);
}

const welcomePages = <WelcomeInfo>[
  WelcomeInfo('meet', Art.welcome, 'Meet Pagemark', 'A private reading log. Every book you read or listen to, in one place on your phone.', [
    TourStep('Log what you read', 'Print, e-books and audiobooks: how far you are, when you started and finished, your stars and your thoughts.'),
    TourStep('Keep your lists', 'What you want to read next, shelves of your own, and manga or comics by the volume.'),
    TourStep('See your year', 'Stats, a reading goal and a year-in-books card you can share if you want to.'),
  ]),
  WelcomeInfo('privacy', Art.privacy, 'Your privacy, precisely', 'No account. No ads. No tracking. No AI. Here is exactly what that means.', [
    TourStep('Your books stay here', 'Your library, reads, thoughts and quotes are kept on this phone. There is no Pagemark server to send them to.'),
    TourStep('The only internet use', 'Book searches go to Open Library and, unless you turn it off, Google Books: they see what you typed or scanned. The GitHub version also checks GitHub for updates. Nothing about you or your library is sent.'),
    TourStep('The barcode reader', 'It uses Google\'s ML Kit on the phone. Pagemark never saves or sends the camera picture, but Google\'s library may report anonymous technical information to Google.'),
  ]),
  WelcomeInfo('keeps', Art.keeps, 'What Pagemark keeps, and who can see it', 'Only what you put in, in the app\'s private storage.', [
    TourStep('What is stored', 'Your books and their details, every read with its dates, stars and thoughts, quotes, shelves, and cover pictures saved for offline use.'),
    TourStep('Who can see it', 'Only you, inside Pagemark. Other apps cannot open its storage, and Android\'s own cloud backup is switched off for Pagemark. A book leaves only when you share, export or back it up yourself.'),
    TourStep('Private books', 'Books you move to Locked are hidden behind a PIN or your fingerprint, and left out of Stats and spreadsheets. Whole backups do include them, so give backups a password.'),
  ]),
  WelcomeInfo('how', Art.tour, 'How this tour works', 'About four minutes, and you stay in control.', [
    TourStep('Permissions, explained first', 'Before Android asks about the camera or notifications, you read why. Not now is always fine.'),
    TourStep('A few set-up choices', 'Colours, how new reads start, and backup reminders, with sensible defaults.'),
    TourStep('Eight short lessons', 'Each has a small animation and a Try it button that opens the real screen with a tip. Skip any of them.'),
    TourStep('Leave any time', 'Skip and Back are always there. Replay the tour later from Help & tips in the menu.'),
  ]),
];

const permissionPages = <PermissionInfo>[
  PermissionInfo(
    id: 'camera',
    art: Art.camera,
    title: 'Camera',
    kind: PermKind.camera,
    why: 'To scan the barcode on the back of a book, one at a time or a whole shelf with Scan many books.',
    never: 'The camera runs only while the scanner is open. Pagemark never takes photos in the background, never records sound, and never saves or sends the picture.',
    ifNo: 'Scanning will not work. Searching by title or author, and adding a book by hand, still do.',
    later: 'Phone Settings, Apps, Pagemark, Permissions, Camera.',
  ),
  PermissionInfo(
    id: 'notifications',
    art: Art.bell,
    title: 'Notifications',
    kind: PermKind.notifications,
    why: 'For the reminders you choose: a daily nudge to read, and a reminder to save a backup now and then.',
    never: 'No adverts, no news, no "come back" messages. Only the reminders you switch on, and a warning if an automatic backup keeps failing.',
    ifNo: 'You will not get reminders. Everything else works, and a card in the Library still tells you when a backup is due.',
    later: 'Phone Settings, Apps, Pagemark, Notifications.',
  ),
];

const lessons = <Lesson>[
  Lesson(
    id: 'add',
    title: 'Add a book',
    summary: 'Three ways in, and Pagemark finds the cover and details.',
    art: Art.addBook,
    steps: [
      TourStep('Search', 'Tap Add book, type a title, an author or the barcode number, and tap the magnifier. Tap the right result.'),
      TourStep('Scan', 'Tap the barcode icon and point the camera at the back of the book. Scan many books does a whole shelf, one beep per book.'),
      TourStep('By hand', 'Not found? Add by hand takes just a title and an author.'),
    ],
    tip: 'Sharing a book from a shop or website to Pagemark opens Add book with it already filled in.',
    tryLabel: 'Open Add book',
    target: TryTarget.addBook,
    coachId: 'add',
  ),
  Lesson(
    id: 'log',
    title: 'Log your reading',
    summary: 'Each time you read a book is a "read", with its own dates, stars and thoughts.',
    art: Art.logRead,
    steps: [
      TourStep('Update progress', 'On a book you are reading, tap Update progress and type your page. Pagemark works out your pace.'),
      TourStep('Reading timer', 'Tap Start when you sit down to read and Stop when you finish. The time is added to the read.'),
      TourStep('Finish and rate', 'Tap Log a read (or edit the current one) to mark it finished, give it stars and write what you thought.'),
    ],
    tip: 'Reading a book a second time? Log another read; the first one is kept.',
    tryLabel: 'Open a book',
    target: TryTarget.book,
    coachId: 'book',
  ),
  Lesson(
    id: 'library',
    title: 'Find your way round the Library',
    summary: 'Search, filter, sort, and choose how your books look.',
    art: Art.library,
    steps: [
      TourStep('Search', 'The box at the top looks in titles, authors, notes, thoughts and quotes.'),
      TourStep('Filter and sort', 'The chips show Want to read, Reading, Finished or Did not finish. The sort button orders by date added, title, author or rating.'),
      TourStep('Styles', 'The style button switches between Classic, Cover wall, Bookshelf, Spines and Compact.'),
      TourStep('Shelves', 'On a book\'s page tap + Shelf to put it on a shelf of your own. Slide the chips sideways to show one shelf.'),
    ],
    tryLabel: 'Open the Library',
    target: TryTarget.library,
    coachId: 'library',
  ),
  Lesson(
    id: 'manga',
    title: 'Manga, comics and series',
    summary: 'Volumes have their own page, so books and volumes stay apart.',
    art: Art.manga,
    steps: [
      TourStep('Their own page', 'Open the menu and tap Manga & comics. Manga, comics and light novels show there, not in the Library.'),
      TourStep('One square per volume', 'Open a series to see every volume: read, owned, wanted or missing. Tap a grey square to add it.'),
      TourStep('Share what is missing', 'Share missing list sends a note like "Berserk: missing 3-5, 7" for the bookshop.'),
    ],
    tip: 'Add a book whose title ends in a volume number and Pagemark offers to put it in its series.',
    tryLabel: 'Open Manga & comics',
    target: TryTarget.manga,
    coachId: 'manga',
  ),
  Lesson(
    id: 'quotes',
    title: 'Quotes and thoughts',
    summary: 'Keep the lines you loved, with their page.',
    art: Art.quotes,
    steps: [
      TourStep('Add a quote', 'On a book\'s page tap Add quote, type the passage, add the page and give it stars if you like.'),
      TourStep('Find it again', 'Quotes show on the book\'s page and the Library search finds them.'),
      TourStep('Your thoughts', 'What you thought goes on the read itself, so a reread can have different thoughts.'),
    ],
    tryLabel: 'Open a book',
    target: TryTarget.book,
    coachId: 'book',
  ),
  Lesson(
    id: 'locked',
    title: 'Your Locked library',
    summary: 'Books only you can see, behind a PIN or your fingerprint.',
    art: Art.locked,
    steps: [
      TourStep('Set it up', 'Open the menu, tap Locked and choose a PIN (or the phone\'s own lock). Write down the recovery code it shows.'),
      TourStep('Move a book in', 'On a book\'s page, tap the three dots and choose Move to locked library.'),
      TourStep('It locks itself', 'Leaving Locked or the app locks it again. Settings, Privacy and lock sets how long it waits, and can hide Locked from the menu.'),
    ],
    tip: 'Locked books are left out of Stats and spreadsheets, but included in whole backups: give backups a password.',
    tryLabel: 'Open Locked',
    target: TryTarget.locked,
    coachId: 'locked',
  ),
  Lesson(
    id: 'stats',
    title: 'Stats and your year',
    summary: 'A goal, charts and a card for your year in books.',
    art: Art.stats,
    steps: [
      TourStep('Set a goal', 'On Stats tap Set goal and choose how many books you want to finish this year.'),
      TourStep('See the year', 'Books per month, your ratings, pages, top genres and authors, and the days you read.'),
      TourStep('Share it, or not', 'Share picture makes an image of your year card; Report makes a PDF. Nothing is shared unless you tap them.'),
    ],
    tryLabel: 'Open Stats',
    target: TryTarget.stats,
    coachId: 'stats',
  ),
  Lesson(
    id: 'backup',
    title: 'Keep your library safe',
    summary: 'Your books live only on this phone, so a backup is your safety net.',
    art: Art.backup,
    steps: [
      TourStep('Save a copy', 'Settings, Backup and restore, Save a copy as a file. Choose a password and keep the file somewhere safe: email, a drive or a computer.'),
      TourStep('Or let it happen', 'Save backups to a folder automatically: pick a folder once and Pagemark keeps it up to date.'),
      TourStep('Getting it back', 'Restore from a file replaces your library with the copy. Pagemark keeps an earlier copy before every restore.'),
    ],
    tip: 'Deleted books wait 30 days in Settings, Your library, Deleted books before they go for good.',
    tryLabel: 'Open Backup and restore',
    target: TryTarget.backup,
    coachId: 'backup',
  ),
];

/// The coach marks on each screen, by screen id. Targets that are not on screen are skipped.
const coachSteps = <String, List<CoachStep>>{
  'library': [
    CoachStep('lib.search', 'Search everything', 'Titles, authors, your notes, thoughts and quotes.'),
    CoachStep('lib.style', 'Choose a style', 'Classic, Cover wall, Bookshelf, Spines or Compact.'),
    CoachStep('lib.add', 'Add a book', 'Search, scan a barcode, or type it in by hand.'),
    CoachStep('nav.menu', 'The menu', 'Manga & comics, Locked, Stats, Settings and Help & tips are all in here.'),
  ],
  'manga': [
    CoachStep('lib.add', 'Add a volume', 'Volumes added here are saved as manga. Pagemark offers to put numbered titles in their series.'),
    CoachStep('lib.more', 'Your series', 'Series opens every series with its grid of volumes and the missing list.'),
  ],
  'add': [
    CoachStep('add.search', 'Search', 'Type a title, an author or the barcode number.'),
    CoachStep('add.scan', 'Scan a barcode', 'Point the camera at the back of the book.'),
    CoachStep('add.many', 'Scan many books', 'A whole shelf in one go, one beep per book.'),
    CoachStep('add.hand', 'Add by hand', 'For anything the search cannot find.'),
  ],
  'book': [
    CoachStep('book.progress', 'Update progress', 'Type the page you are on; Pagemark works out your pace.'),
    CoachStep('book.quote', 'Add a quote', 'Keep a line you loved, with its page.'),
    CoachStep('book.log', 'Log a read', 'Start a new read, or a reread, with its own dates, stars and thoughts.'),
  ],
  'stats': [
    CoachStep('stats.goal', 'Your goal', 'Choose how many books you want to finish this year.'),
    CoachStep('stats.share', 'Share your year', 'Makes a picture of the card. Nothing is shared unless you tap it.'),
  ],
  'locked': [
    CoachStep('locked.setup', 'Set up the lock', 'Choose a PIN or the phone\'s own lock. Keep the recovery code safe.'),
  ],
  'backup': [
    CoachStep('backup.save', 'Save a copy', 'The best backup: one file with everything, protected by your password.'),
    CoachStep('backup.folder', 'Automatic backups', 'Pick a folder once and Pagemark keeps a copy there.'),
  ],
};

/// What someone who already uses Pagemark hears about after updating to this tour version.
const whatsNewItems = <TourStep>[
  TourStep('A guided tour', 'Short lessons with a Try it button for each part of the app. Take it now or any time from Help & tips.'),
  TourStep('Tips as you go', 'The first time you open a screen, a tip can point out what is there. Turn them on or off in Help & tips.'),
  TourStep('Help & tips', 'A new page in the menu: search every lesson and guide topic, replay the tour, or report a problem.'),
];

/// What to show when Pagemark opens.
enum OnboardingStart { tour, whatsNew, none }

/// The routing rule, kept pure so it is easy to test.
/// [doneVersion]: the tour version finished or skipped (null = never). [newsSeen]: the version whose sheet was shown.
/// [existingUser]: books are already there, or the old welcome screens were seen.
OnboardingStart decideOnboarding({required String? doneVersion, required String? newsSeen, required bool existingUser}) {
  if (doneVersion == tourVersion) return OnboardingStart.none;
  if (doneVersion == null && !existingUser) return OnboardingStart.tour;
  return newsSeen == tourVersion ? OnboardingStart.none : OnboardingStart.whatsNew;
}

/// The show-once rule for coach marks.
bool shouldShowTip(String id, {required bool tipsEnabled, required Set<String> seen, String? forced}) => forced == id || (tipsEnabled && !seen.contains(id));

/// Lessons whose text contains every word of [query] (empty query = all).
List<Lesson> searchLessons(String query) {
  final words = query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  return [for (final l in lessons) if (words.every(l.haystack.contains)) l];
}
