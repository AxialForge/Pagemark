import 'package:flutter/material.dart';
import 'db.dart';

/// Multi-select state shared with every Library style. Items ask the scope what a tap should do (open the book, or toggle
/// it while a selection is active) so each style only needs a few lines to take part.
class SelectionScope extends InheritedWidget {
  final Set<int> selected;
  final void Function(BookRow) onToggle; // long-press: start / extend a selection
  final void Function(BookRow)? onQuickFinish; // swipe right (classic + compact)
  final void Function(BookRow)? onQuickTrash; // swipe left
  const SelectionScope({super.key, required this.selected, required this.onToggle, this.onQuickFinish, this.onQuickTrash, required super.child});

  bool get active => selected.isNotEmpty;

  static SelectionScope? maybeOf(BuildContext c) => c.dependOnInheritedWidgetOfExactType<SelectionScope>();

  static bool isSelected(BuildContext c, int id) => maybeOf(c)?.selected.contains(id) ?? false;

  @override
  bool updateShouldNotify(SelectionScope old) => true; // the Set is mutated in place
}

/// Check badge drawn over a selected item.
class SelectedBadge extends StatelessWidget {
  const SelectedBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle, border: Border.all(color: cs.onPrimary, width: 1.5)),
      child: Icon(Icons.check, size: 14, color: cs.onPrimary),
    );
  }
}

/// Wraps a row in swipe gestures (classic and compact lists only): swipe right = finished today, left = Trash.
/// Both actions are undoable via the Library's snackbar, and the row removes/updates itself through the database stream,
/// so the Dismissible never actually leaves the tree.
class SwipeActions extends StatelessWidget {
  final BookRow row;
  final Widget child;
  const SwipeActions({super.key, required this.row, required this.child});

  @override
  Widget build(BuildContext context) {
    final scope = SelectionScope.maybeOf(context);
    if (scope == null || scope.active || scope.onQuickTrash == null) return child;
    final cs = Theme.of(context).colorScheme;
    Widget bg(IconData i, String t, Color c, Alignment a) => Container(
          color: c, alignment: a, padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: cs.onPrimary), const SizedBox(width: 8), Text(t, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600))]),
        );
    return Dismissible(
      key: ValueKey('swipe-${row.book.id}'),
      background: bg(Icons.done_all, 'Finished today', cs.primary, Alignment.centerLeft),
      secondaryBackground: bg(Icons.delete_outline, 'Move to Trash', cs.error, Alignment.centerRight),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          scope.onQuickFinish?.call(row);
        } else {
          scope.onQuickTrash?.call(row);
        }
        return false; // the stream rebuilds the list; never leave a dismissed widget behind
      },
      child: child,
    );
  }
}
