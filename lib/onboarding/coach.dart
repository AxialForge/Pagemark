import 'dart:async';

import 'package:flutter/material.dart';

import 'content.dart';
import 'tips.dart';

final _targets = <String, GlobalKey>{};

/// Marks a widget a coach mark can point at. Name it in a [CoachStep] by [id].
class CoachTarget extends StatefulWidget {
  final String id;
  final Widget child;
  const CoachTarget({super.key, required this.id, required this.child});

  @override
  State<CoachTarget> createState() => _CoachTargetState();
}

class _CoachTargetState extends State<CoachTarget> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _targets[widget.id] = _key;
  }

  @override
  void didUpdateWidget(CoachTarget old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      if (_targets[old.id] == _key) _targets.remove(old.id);
      _targets[widget.id] = _key;
    }
  }

  @override
  void dispose() {
    if (_targets[widget.id] == _key) _targets.remove(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: _key, child: widget.child);
}

Rect? _rectOf(String id) {
  final box = _targets[id]?.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Shows [steps] one after another over the current screen. Completes with true if at least one step was shown
/// (targets that are not on screen are skipped).
Future<bool> runCoach(BuildContext context, List<CoachStep> steps) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final done = Completer<bool>();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CoachOverlay(
      steps: steps,
      onClose: (shown) {
        entry.remove();
        if (!done.isCompleted) done.complete(shown);
      },
    ),
  );
  overlay.insert(entry);
  return done.future;
}

/// Wraps a screen. The first time it opens (with tips on, or after "Try it"), it shows the screen's tips once.
class CoachScope extends StatefulWidget {
  final String tipId;
  final Widget child;

  /// Lets a screen hold its tip until it is ready (for example until the list has loaded).
  final bool enabled;
  const CoachScope({super.key, required this.tipId, required this.child, this.enabled = true});

  @override
  State<CoachScope> createState() => _CoachScopeState();
}

class _CoachScopeState extends State<CoachScope> {
  Timer? _timer;
  bool _tried = false;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(CoachScope old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !old.enabled) _arm();
  }

  void _arm() {
    if (!widget.enabled || Guidance.disabledForTests) return;
    _tried = false;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), _maybeShow);
  }

  Future<void> _maybeShow() async {
    if (!mounted || _tried || !widget.enabled) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      _timer = Timer(const Duration(milliseconds: 700), _maybeShow); // covered by another screen: try again shortly
      return;
    }
    final forced = Guidance.forced.value;
    if (!shouldShowTip(widget.tipId, tipsEnabled: Guidance.tipsEnabled && Guidance.doneVersion != null, seen: Guidance.seen, forced: forced)) return;
    _tried = true;
    if (forced == widget.tipId) Guidance.forced.value = null;
    final shown = await runCoach(context, coachSteps[widget.tipId] ?? const []);
    if (shown) await Guidance.markSeen(widget.tipId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _CoachOverlay extends StatefulWidget {
  final List<CoachStep> steps;
  final void Function(bool shown) onClose;
  const _CoachOverlay({required this.steps, required this.onClose});

  @override
  State<_CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<_CoachOverlay> {
  int _i = -1;
  bool _any = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _advance());
  }

  /// Moves to the next step whose target is on screen; closes when none is left.
  void _advance() {
    if (!mounted) return;
    var j = _i + 1;
    while (j < widget.steps.length && _rectOf(widget.steps[j].targetId) == null) {
      j++;
    }
    if (j >= widget.steps.length) {
      widget.onClose(_any);
      return;
    }
    setState(() {
      _i = j;
      _any = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_i < 0) return const SizedBox.shrink();
    final step = widget.steps[_i];
    final rect = _rectOf(step.targetId);
    if (rect == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _advance());
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final hole = RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(18));
    final below = rect.center.dy < size.height * 0.5;
    final last = widget.steps.indexWhere((s) => _rectOf(s.targetId) != null, _i + 1) < 0;
    // count only the tips whose target is on this screen
    final onScreen = [for (final s in widget.steps) if (_rectOf(s.targetId) != null) s];
    final pos = onScreen.indexOf(step) + 1;
    final reduce = MediaQuery.of(context).disableAnimations;
    return Material(
      type: MaterialType.transparency,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reduce ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 220),
        builder: (context, t, _) => Opacity(
          opacity: t,
          child: Stack(children: [
            // absorbs taps so the screen underneath is not used mid-tip
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: CustomPaint(painter: _SpotlightPainter(hole, cs.primary))),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: below ? hole.bottom + 12 : null,
              bottom: below ? null : size.height - hole.top + 12,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.height * 0.5),
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  label: 'Tip $pos of ${onScreen.length}: ${step.title}. ${step.body}',
                  child: Material(
                    color: cs.surfaceContainerLowest,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: cs.outlineVariant)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 12, 8),
                      child: SingleChildScrollView(
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          ExcludeSemantics(child: Text(step.title, style: tt.titleLarge)),
                          const SizedBox(height: 6),
                          ExcludeSemantics(child: Text(step.body, style: tt.bodyLarge)),
                          const SizedBox(height: 6),
                          Row(children: [
                            if (onScreen.length > 1) Text('$pos of ${onScreen.length}', style: tt.bodySmall),
                            const Spacer(),
                            if (!last) TextButton(onPressed: () => widget.onClose(true), child: const Text('Skip')),
                            FilledButton(onPressed: last ? () => widget.onClose(true) : _advance, child: Text(last ? 'Got it' : 'Next')),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final RRect hole;
  final Color ring;
  _SpotlightPainter(this.hole, this.ring);

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(hole));
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.72));
    canvas.drawRRect(hole, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = ring);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.hole != hole || old.ring != ring;
}
