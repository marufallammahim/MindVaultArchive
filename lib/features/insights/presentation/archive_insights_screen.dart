import 'package:flutter/material.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';

class ArchiveInsightsScreen extends ConsumerWidget {
  const ArchiveInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Archive insights')),
      body: StreamBuilder<List<Note>>(
        stream: (db.select(db.notes)..where((n) => n.isDeleted.equals(false)))
            .watch(),
        builder: (context, notesSnapshot) {
          if (notesSnapshot.hasError) {
            return _Message('Could not analyse notes: ${notesSnapshot.error}');
          }
          if (!notesSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = notesSnapshot.data!;
          return StreamBuilder<List<VaultTask>>(
            stream: db.select(db.tasks).watch(),
            builder: (context, tasksSnapshot) {
              if (tasksSnapshot.hasError) {
                return _Message(
                    'Could not analyse tasks: ${tasksSnapshot.error}');
              }
              if (!tasksSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = tasksSnapshot.data!;
              final active = notes.where((n) => !n.isArchived).toList();
              final completed = tasks.where((t) => t.isCompleted).length;
              final pending = tasks.length - completed;
              final words = notes.fold<int>(
                  0,
                  (sum, note) =>
                      sum +
                      RegExp(r'\b[\w\u0980-\u09FF]+\b')
                          .allMatches(note.documentContent)
                          .length);
              final titles = <String, List<Note>>{};
              for (final note in notes) {
                final key = note.title.trim().toLowerCase();
                if (key.isNotEmpty) (titles[key] ??= []).add(note);
              }
              final duplicates =
                  titles.values.where((items) => items.length > 1).toList();
              final knownTitles = titles.keys.toSet();
              final brokenLinks = <String, Set<String>>{};
              final linkPattern = RegExp(r'\[\[([^\]]+)\]\]');
              for (final note in notes) {
                for (final match
                    in linkPattern.allMatches(note.documentContent)) {
                  final target = match.group(1)?.trim().toLowerCase() ?? '';
                  if (target.isNotEmpty && !knownTitles.contains(target)) {
                    (brokenLinks[target] ??= <String>{})
                        .add(note.title.isEmpty ? 'Untitled' : note.title);
                  }
                }
              }
              final now = DateTime.now();
              final weekStart = DateTime(now.year, now.month, now.day)
                  .subtract(const Duration(days: 6));
              final recent =
                  notes.where((n) => !n.createdAt.isBefore(weekStart)).length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                children: [
                  const FeatureHero(
                    icon: Icons.insights_rounded,
                    title: 'Archive insights',
                    subtitle: 'A clear view of the knowledge you are building.',
                  ),
                  const SizedBox(height: 18),
                  Text('Your knowledge at a glance',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7)),
                  const SizedBox(height: 6),
                  const Text(
                      'These insights are calculated on this device from your local archive.'),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: [
                      _Metric(
                          label: 'Active notes',
                          value: '${active.length}',
                          icon: Icons.notes_outlined),
                      _Metric(
                          label: 'Archived',
                          value: '${notes.length - active.length}',
                          icon: Icons.archive_outlined),
                      _Metric(
                          label: 'Words stored',
                          value: '$words',
                          icon: Icons.menu_book_outlined),
                      _Metric(
                          label: 'New this week',
                          value: '$recent',
                          icon: Icons.trending_up),
                      _Metric(
                          label: 'Tasks pending',
                          value: '$pending',
                          icon: Icons.pending_actions_outlined),
                      _Metric(
                          label: 'Tasks completed',
                          value: '$completed',
                          icon: Icons.task_alt_outlined),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Archive health',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _HealthRow(
                      icon: Icons.copy_all_outlined,
                      title: 'Possible duplicate titles',
                      detail: duplicates.isEmpty
                          ? 'No duplicate titles detected.'
                          : '${duplicates.length} title groups need review.',
                      count: duplicates.length),
                  _HealthRow(
                      icon: Icons.link_off_outlined,
                      title: 'Broken note links',
                      detail: brokenLinks.isEmpty
                          ? 'No missing [[wikilink]] targets detected.'
                          : '${brokenLinks.length} missing targets referenced by your notes.',
                      count: brokenLinks.length),
                  if (duplicates.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Duplicate title groups',
                        style: Theme.of(context).textTheme.titleMedium),
                    for (final group in duplicates)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.copy_outlined),
                        title: Text(group.first.title),
                        subtitle:
                            Text('${group.length} notes share this title'),
                      ),
                  ],
                  if (brokenLinks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Missing link targets',
                        style: Theme.of(context).textTheme.titleMedium),
                    for (final entry in brokenLinks.entries)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.link_off_outlined),
                        title: Text(entry.key),
                        subtitle:
                            Text('Referenced by ${entry.value.length} note(s)'),
                      ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                      'Health checks are advisory. Review results before changing or deleting any note.'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium),
              ]),
        ),
      );
}

class _HealthRow extends StatelessWidget {
  const _HealthRow(
      {required this.icon,
      required this.title,
      required this.detail,
      required this.count});
  final IconData icon;
  final String title;
  final String detail;
  final int count;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(detail),
          trailing: count == 0
              ? const Icon(Icons.check_circle_outline)
              : CircleAvatar(radius: 14, child: Text('$count')),
        ),
      );
}

class _Message extends StatelessWidget {
  const _Message(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center)));
}
