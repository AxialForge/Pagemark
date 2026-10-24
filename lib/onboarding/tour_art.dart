import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'content.dart';

/// What each animation shows, for TalkBack.
String artDescription(Art a) => switch (a) {
      Art.welcome => 'Three books rise onto a shelf.',
      Art.privacy => 'A phone with a lock, and a crossed-out cloud: your books are not uploaded.',
      Art.keeps => 'Books kept inside the phone behind a lock.',
      Art.tour => 'A row of eight dots lighting up one by one towards a finish flag.',
      Art.camera => 'A camera icon with a pulsing ring.',
      Art.bell => 'A bell icon with a pulsing ring.',
      Art.setup => 'A slider icon with a pulsing ring.',
      Art.addBook => 'A barcode is scanned by a moving line, then a tick appears.',
      Art.logRead => 'A reading progress bar fills up page by page.',
      Art.library => 'Book covers line up on a shelf.',
      Art.manga => 'A grid of volume squares fills in: read, owned, wanted.',
      Art.quotes => 'A quotation mark, with lines of text appearing beside it.',
      Art.locked => 'A book slides behind a padlock, which closes.',
      Art.stats => 'Bars of a chart grow, month by month.',
      Art.backup => 'A backup file moves from the phone to a safe place.',
      Art.start => 'An open book with a pulsing ring.',
    };

/// A small looping illustration drawn in Flutter. With "remove animations" on, it shows the finished frame and
/// stands still.
class TourArt extends StatefulWidget {
  final Art art;
  final double height;
  const TourArt(this.art, {super.key, this.height = 150});

  @override
  State<TourArt> createState() => _TourArtState();
}

class _TourArtState extends State<TourArt> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c
        ..stop()
        ..value = 1;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: artDescription(widget.art),
      child: ExcludeSemantics(
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(18)),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(painter: _ArtPainter(widget.art, _c.value, cs)),
          ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  final Art art;
  final double t; // 0..1, loops
  final ColorScheme cs;
  _ArtPainter(this.art, this.t, this.cs);

  /// 0..1 progress of a stage that runs from [a] to [b] of the loop.
  double _p(double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
  double _ease(double x) => Curves.easeOutCubic.transform(x);

  Paint get _fill => Paint()..color = cs.primary;
  Paint _stroke([double w = 3]) => Paint()
    ..color = cs.onSurface
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static const _spines = [Color(0xFF2F4858), Color(0xFF7A3B2E), Color(0xFF4A5A3A), Color(0xFF3B3F6B), Color(0xFF6B4A2E)];

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    switch (art) {
      case Art.welcome:
        _shelf(canvas, s, 3);
      case Art.library:
        _shelf(canvas, s, 5);
      case Art.privacy:
        _phone(canvas, c);
        _lock(canvas, c.translate(0, 4), 1, closed: true);
        final cloud = c.translate(s.width * 0.26, -16);
        canvas.drawCircle(cloud.translate(-10, 4), 12, _stroke(2.5));
        canvas.drawCircle(cloud.translate(8, 0), 15, _stroke(2.5));
        final x = _ease(_p(0.2, 0.5));
        canvas.drawLine(cloud.translate(-24, -18), Offset.lerp(cloud.translate(-24, -18), cloud.translate(24, 20), x)!, _stroke(3.5)..color = cs.error);
      case Art.keeps:
        _phone(canvas, c);
        for (var i = 0; i < 3; i++) {
          final r = Rect.fromCenter(center: c.translate(0, 22 - i * 13.0), width: 44, height: 10);
          canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), Paint()..color = _spines[i]);
        }
        _lock(canvas, c.translate(0, -26), 0.7, closed: _p(0.4, 0.5) > 0);
      case Art.tour:
        const n = 8;
        final w = math.min(s.width - 80, 320.0);
        for (var i = 0; i < n; i++) {
          final x = c.dx - w / 2 + w * i / (n - 1);
          final lit = t * (n + 1) > i + 1;
          canvas.drawCircle(Offset(x, c.dy), lit ? 9 : 6, lit ? _fill : (Paint()..color = cs.outline));
        }
        final fx = c.dx + w / 2 + 26;
        canvas.drawLine(Offset(fx, c.dy + 18), Offset(fx, c.dy - 22), _stroke());
        canvas.drawPath(Path()..moveTo(fx, c.dy - 22)..lineTo(fx + 20, c.dy - 15)..lineTo(fx, c.dy - 8)..close(), _fill);
      case Art.camera:
        _pulse(canvas, c, Icons.photo_camera_outlined);
      case Art.bell:
        _pulse(canvas, c, Icons.notifications_none);
      case Art.setup:
        _pulse(canvas, c, Icons.tune);
      case Art.start:
        _pulse(canvas, c, Icons.auto_stories_outlined);
      case Art.addBook:
        final r = Rect.fromCenter(center: c, width: 120, height: 70);
        for (var i = 0; i < 18; i++) {
          final x = r.left + i * r.width / 18;
          canvas.drawRect(Rect.fromLTWH(x, r.top, i.isEven ? 3 : 1.5, r.height), Paint()..color = cs.onSurface);
        }
        final scan = _p(0.1, 0.6);
        if (scan < 1) {
          final y = r.top + r.height * scan;
          canvas.drawLine(Offset(r.left - 12, y), Offset(r.right + 12, y), Paint()
            ..color = cs.error
            ..strokeWidth = 3);
        } else {
          final k = _ease(_p(0.6, 0.75));
          canvas.drawCircle(c, 30 * k, _fill);
          canvas.drawPath(Path()..moveTo(c.dx - 13, c.dy)..lineTo(c.dx - 3, c.dy + 10)..lineTo(c.dx + 14, c.dy - 10), _stroke(4)..color = cs.onPrimary);
        }
      case Art.logRead:
        final w = math.min(s.width - 80, 300.0);
        final bar = Rect.fromCenter(center: c.translate(0, 18), width: w, height: 12);
        canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(6)), Paint()..color = cs.outlineVariant);
        final f = _ease(_p(0.05, 0.85));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bar.left, bar.top, bar.width * f, bar.height), const Radius.circular(6)), _fill);
        _text(canvas, 'Page ${(280 * f).round()} of 280', c.translate(0, -16), 18);
      case Art.manga:
        const cols = 6, rows = 2;
        const cell = 30.0, gap = 8.0;
        final total = cols * cell + (cols - 1) * gap;
        for (var i = 0; i < cols * rows; i++) {
          final x = c.dx - total / 2 + (i % cols) * (cell + gap);
          final y = c.dy - cell - gap / 2 + (i ~/ cols) * (cell + gap);
          final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, cell, cell), const Radius.circular(6));
          final on = t * (cols * rows + 2) > i + 1;
          if (!on) {
            canvas.drawRRect(r, Paint()..color = cs.outlineVariant);
          } else if (i % 5 == 3) {
            _dashed(canvas, r);
          } else if (i % 3 == 2) {
            canvas.drawRRect(r, _stroke(2.5)..color = cs.primary);
          } else {
            canvas.drawRRect(r, _fill);
          }
        }
      case Art.quotes:
        _text(canvas, '“', c.translate(-70, -6), 70, color: cs.primary);
        for (var i = 0; i < 3; i++) {
          final len = 130.0 * (i == 2 ? 0.6 : 1) * _ease(_p(0.1 + i * 0.2, 0.3 + i * 0.2));
          final y = c.dy - 22 + i * 22.0;
          canvas.drawLine(Offset(c.dx - 30, y), Offset(c.dx - 30 + len, y), _stroke(5)..color = cs.onSurfaceVariant);
        }
      case Art.locked:
        final slide = _ease(_p(0.05, 0.45));
        final book = Rect.fromCenter(center: Offset(c.dx - 90 + 90 * slide, c.dy + 6), width: 34, height: 48);
        canvas.drawRRect(RRect.fromRectAndRadius(book, const Radius.circular(4)), Paint()..color = _spines[1]);
        _lock(canvas, c.translate(0, 6), 1.4 - 0.4 * slide, closed: _p(0.5, 0.6) > 0, filled: true);
      case Art.stats:
        const heights = [0.35, 0.6, 0.45, 0.8, 0.55, 0.95];
        const bw = 22.0, gap = 12.0;
        final total = heights.length * bw + (heights.length - 1) * gap;
        final base = c.dy + 40;
        for (var i = 0; i < heights.length; i++) {
          final g = _ease(_p(0.05 + i * 0.1, 0.35 + i * 0.1));
          final h = 80 * heights[i] * g;
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(c.dx - total / 2 + i * (bw + gap), base - h, bw, h), const Radius.circular(5)), _fill);
        }
        canvas.drawLine(Offset(c.dx - total / 2 - 8, base), Offset(c.dx + total / 2 + 8, base), _stroke(2));
      case Art.backup:
        final from = c.translate(-80, 0), to = c.translate(80, 0);
        _phoneAt(canvas, from, 0.7);
        _iconAt(canvas, Icons.cloud_done_outlined, to, 54, cs.onSurface);
        final m = _ease(_p(0.1, 0.7));
        final p = Offset.lerp(from, to, m)!.translate(0, -30 * math.sin(math.pi * m));
        _iconAt(canvas, Icons.description_outlined, p, 34, cs.primary);
    }
  }

  void _shelf(Canvas canvas, Size s, int n) {
    final c = Offset(s.width / 2, s.height / 2);
    final base = c.dy + 34;
    const w = 26.0, gap = 6.0;
    final total = n * w + (n - 1) * gap;
    for (var i = 0; i < n; i++) {
      final up = _ease(_p(0.05 + i * 0.1, 0.35 + i * 0.1));
      final h = 70.0 + (i * 13 % 20);
      final r = Rect.fromLTWH(c.dx - total / 2 + i * (w + gap), base - h * up, w, h * up);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), Paint()..color = _spines[i % _spines.length]);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(c.dx - total / 2 - 18, base, total + 36, 8), const Radius.circular(2)), Paint()..color = const Color(0xFFB88A5B));
  }

  void _phone(Canvas canvas, Offset c) => _phoneAt(canvas, c, 1);

  void _phoneAt(Canvas canvas, Offset c, double k) {
    final r = Rect.fromCenter(center: c, width: 70 * k, height: 120 * k);
    canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(12 * k)), _stroke(3));
  }

  void _lock(Canvas canvas, Offset c, double k, {required bool closed, bool filled = false}) {
    final body = Rect.fromCenter(center: c.translate(0, 8 * k), width: 34 * k, height: 26 * k);
    final lift = closed ? 0.0 : 8 * k;
    final shackle = Rect.fromCenter(center: c.translate(0, -6 * k - lift), width: 22 * k, height: 26 * k);
    canvas.drawArc(shackle, math.pi, math.pi, false, _stroke(3.5 * k)..color = cs.primary);
    canvas.drawLine(Offset(shackle.left, shackle.center.dy), Offset(shackle.left, body.top), _stroke(3.5 * k)..color = cs.primary);
    canvas.drawLine(Offset(shackle.right, shackle.center.dy), Offset(shackle.right, body.top + (closed ? 0 : -lift)), _stroke(3.5 * k)..color = cs.primary);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(5 * k)), filled ? _fill : (_fill));
  }

  void _pulse(Canvas canvas, Offset c, IconData icon) {
    for (var i = 0; i < 2; i++) {
      final k = (t + i * 0.5) % 1;
      canvas.drawCircle(c, 34 + 34 * k, Paint()
        ..color = cs.primary.withValues(alpha: (1 - k) * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    canvas.drawCircle(c, 34, _fill);
    _iconAt(canvas, icon, c, 36, cs.onPrimary);
  }

  void _dashed(Canvas canvas, RRect r) {
    final p = Paint()
      ..color = cs.primary
      ..strokeWidth = 2.5;
    for (var d = 0.0; d < r.width; d += 7) {
      canvas.drawLine(Offset(r.left + d, r.top), Offset(r.left + math.min(d + 3.5, r.width), r.top), p);
      canvas.drawLine(Offset(r.left + d, r.bottom), Offset(r.left + math.min(d + 3.5, r.width), r.bottom), p);
      canvas.drawLine(Offset(r.left, r.top + d), Offset(r.left, r.top + math.min(d + 3.5, r.height)), p);
      canvas.drawLine(Offset(r.right, r.top + d), Offset(r.right, r.top + math.min(d + 3.5, r.height)), p);
    }
  }

  void _iconAt(Canvas canvas, IconData icon, Offset c, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  void _text(Canvas canvas, String s, Offset c, double size, {Color? color}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontFamily: 'Newsreader', fontSize: size, fontWeight: FontWeight.w600, color: color ?? cs.onSurface)),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_ArtPainter old) => old.t != t || old.art != art || old.cs != cs;
}
