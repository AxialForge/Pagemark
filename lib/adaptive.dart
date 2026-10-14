import 'package:flutter/material.dart';

/// Layout for bigger screens: tablets, foldables and phones turned sideways.
/// 600 dp and wider: the bottom bar becomes a side rail. 840 dp and wider: the Library and the open book sit side by side.
const railWidth = 600.0, twoPaneWidth = 840.0, pageMaxWidth = 720.0;

/// The book shown in the right-hand pane (two-pane layout only).
final selectedBook = ValueNotifier<int?>(null);

bool useRail(BuildContext c) => MediaQuery.sizeOf(c).width >= railWidth;
bool useTwoPane(BuildContext c) => MediaQuery.sizeOf(c).width >= twoPaneWidth;

/// Marks the main Library as sitting beside a detail pane, so tapping a book fills the pane instead of opening a new page.
class DetailPane extends InheritedWidget {
  const DetailPane({super.key, required super.child});
  static bool active(BuildContext c) => c.getInheritedWidgetOfExactType<DetailPane>() != null;
  @override
  bool updateShouldNotify(DetailPane old) => false;
}

/// Opens a book: in the pane beside the list on wide screens, as a full page otherwise.
void openBookIn(BuildContext c, int id, Widget Function() page) {
  if (DetailPane.active(c)) {
    selectedBook.value = id;
  } else {
    Navigator.push(c, MaterialPageRoute(builder: (_) => page()));
  }
}

/// Leaves a book page: empties the pane, or goes back from a full page.
void closeBook(BuildContext c) {
  if (DetailPane.active(c)) {
    selectedBook.value = null;
  } else {
    Navigator.pop(c);
  }
}

/// Keeps forms and lists a comfortable reading width on big screens (centred), and full width on phones.
class NarrowColumn extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const NarrowColumn({super.key, required this.child, this.maxWidth = pageMaxWidth});
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}
