import 'package:flutter/material.dart';
import 'db.dart';
import 'features.dart' show StarRating;
import 'main.dart';

/// Optional "rate it in more detail": stars for the story, characters, writing, pace and feeling of a read (plus the narrator for audiobooks).
/// Off by default (Settings > Your library). The overall stars always stay.
class RatingAspect {
  final String key, label;
  final bool audioOnly;
  const RatingAspect(this.key, this.label, {this.audioOnly = false});
}

const ratingAspects = [
  RatingAspect('story', 'Story'),
  RatingAspect('characters', 'Characters'),
  RatingAspect('writing', 'Writing'),
  RatingAspect('pace', 'Pace'),
  RatingAspect('feeling', 'How it made me feel'),
  RatingAspect('narrator', 'Narrator', audioOnly: true),
];

bool detailedRatingsOn() => detailedRatings.value;

double? aspectOf(Read r, String key) => switch (key) {
      'story' => r.ratingStory,
      'characters' => r.ratingCharacters,
      'writing' => r.ratingWriting,
      'pace' => r.ratingPace,
      'feeling' => r.ratingFeeling,
      'narrator' => r.ratingNarrator,
      _ => null,
    };

String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

/// "Story 4 · Characters 5 · Pace 3.5" for a read, or '' when none were given.
String detailText(Read r) =>
    [for (final a in ratingAspects) if (aspectOf(r, a.key) != null) '${a.label} ${_fmt(aspectOf(r, a.key)!)}'].join(' · ');

/// Average of each aspect over the reads that have it.
Map<String, double> aspectAverages(Iterable<Read> reads) {
  final out = <String, double>{};
  for (final a in ratingAspects) {
    final v = [for (final r in reads) if (aspectOf(r, a.key) != null) aspectOf(r, a.key)!];
    if (v.isNotEmpty) out[a.key] = v.reduce((x, y) => x + y) / v.length;
  }
  return out;
}

/// Average overall rating of a series: each book counts once (the mean of its rated reads), unrated books are left out.
({double? average, int rated}) seriesAverage(List<BookRow> books) {
  final per = <double>[];
  for (final b in books) {
    final r = [for (final x in b.reads) if (x.rating != null) x.rating!];
    if (r.isNotEmpty) per.add(r.reduce((x, y) => x + y) / r.length);
  }
  return (average: per.isEmpty ? null : per.reduce((x, y) => x + y) / per.length, rated: per.length);
}

/// The star rows shown in the read editor while detailed ratings are on.
class DetailedRatingsEditor extends StatelessWidget {
  final Map<String, double> values;
  final bool audio;
  final void Function(String key, double value) onChanged;
  const DetailedRatingsEditor({super.key, required this.values, required this.audio, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('In more detail (optional)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        for (final a in ratingAspects)
          if (!a.audioOnly || audio)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                SizedBox(width: 130, child: Text(a.label)),
                StarRating(value: values[a.key] ?? 0, size: 28, onChanged: (v) => onChanged(a.key, v)),
              ]),
            ),
      ]);
}

/// The Stats card: your average for each aspect.
Widget detailedRatingsCard(BuildContext context, Iterable<Read> reads) {
  final avg = aspectAverages(reads);
  if (avg.isEmpty) return const SizedBox.shrink();
  final cs = Theme.of(context).colorScheme;
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your detailed ratings', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final a in ratingAspects)
          if (avg[a.key] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                SizedBox(width: 130, child: Text(a.label)),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: avg[a.key]! / 5, minHeight: 10, color: cs.tertiary, backgroundColor: cs.surfaceContainerHighest))),
                const SizedBox(width: 8),
                Text(avg[a.key]!.toStringAsFixed(1)),
              ]),
            ),
      ]),
    ),
  );
}
