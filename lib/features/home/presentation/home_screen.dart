import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _view = 'all';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _editProfile() async {
    final profile = ref.read(userProfileProvider);
    final name = TextEditingController(text: profile.name);
    var avatar = profile.avatarBase64;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: const Text('Your profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage:
                    avatar == null ? null : MemoryImage(base64Decode(avatar!)),
                child: avatar == null
                    ? const Icon(Icons.person_outline, size: 38)
                    : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  final bytes = result?.files.single.bytes;
                  if (bytes == null) return;
                  if (bytes.length > 1500 * 1024) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Choose an image smaller than 1.5 MB.'),
                      ),
                    );
                    return;
                  }
                  refresh(() => avatar = base64Encode(bytes));
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Choose photo'),
              ),
              if (avatar != null)
                TextButton(
                  onPressed: () => refresh(() => avatar = null),
                  child: const Text('Remove photo'),
                ),
              TextField(
                controller: name,
                autofocus: true,
                maxLength: 40,
                decoration: const InputDecoration(labelText: 'Your name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await ref.read(userProfileProvider.notifier).save(
            name: name.text,
            avatarBase64: avatar,
          );
    }
    name.dispose();
  }

  List<PopupMenuEntry<String>> _noteActions(Note note) => [
        PopupMenuItem(
          value: 'pin',
          child: Text(note.sortOrder == 1 ? 'Unpin note' : 'Pin note'),
        ),
        PopupMenuItem(
          value: 'favorite',
          child: Text(note.isFavorite ? 'Remove favorite' : 'Add to favorites'),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Text(note.isArchived ? 'Unarchive' : 'Archive'),
        ),
        const PopupMenuItem(value: 'trash', child: Text('Move to trash')),
      ];

  Future<void> _handleNoteAction(
    AppDatabase db,
    Note note,
    String action,
  ) async {
    switch (action) {
      case 'pin':
        await db.setPinned(note.id, note.sortOrder != 1);
        break;
      case 'favorite':
        await db.setFavorite(note.id, !note.isFavorite);
        break;
      case 'archive':
        await db.setArchived(note.id, !note.isArchived);
        break;
      case 'trash':
        await db.setDeleted(note.id, true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final profile = ref.watch(userProfileProvider);
    final accent = Theme.of(context).colorScheme.primary;
    final notesQuery = db.select(db.notes)
      ..where((note) {
        switch (_view) {
          case 'favorites':
            return note.isDeleted.equals(false) & note.isFavorite.equals(true);
          case 'archive':
            return note.isDeleted.equals(false) & note.isArchived.equals(true);
          case 'category':
            return note.isDeleted.equals(false) &
                note.isArchived.equals(false) &
                note.categoryId.equals(_selectedCategoryId!);
          default:
            return note.isDeleted.equals(false) & note.isArchived.equals(false);
        }
      })
      ..orderBy([
        (note) => OrderingTerm.desc(note.sortOrder),
        (note) => OrderingTerm.desc(note.updatedAt),
      ]);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Note>>(
          stream: notesQuery.watch(),
          builder: (context, snapshot) {
            final allNotes = snapshot.data ?? [];
            final term = _query.toLowerCase();
            final notes = term.isEmpty
                ? allNotes
                : allNotes
                    .where((note) =>
                        note.title.toLowerCase().contains(term) ||
                        note.documentContent.toLowerCase().contains(term))
                    .toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _editProfile,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage: profile.avatar,
                                    child: profile.avatar == null
                                        ? const Icon(Icons.person_outline)
                                        : null,
                                  ),
                                  const SizedBox(width: 11),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello, ${profile.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      Text(
                                        'Your personal archive',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            _roundAction(
                              context,
                              Icons.search_rounded,
                              'Search',
                              () => context.push('/search'),
                            ),
                            const SizedBox(width: 8),
                            _roundAction(
                              context,
                              Icons.settings_outlined,
                              'Settings',
                              () => context.push('/settings'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'my notes',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.1,
                              ),
                        ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChip(context, '#all', 'all'),
                              _filterChip(context, '#favorites', 'favorites'),
                              _filterChip(context, '#archive', 'archive'),
                              StreamBuilder<List<Category>>(
                                stream: (db.select(db.categories)
                                      ..orderBy([
                                        (c) => OrderingTerm.asc(c.name),
                                      ]))
                                    .watch(),
                                builder: (context, categories) => Row(
                                  children: [
                                    for (final category
                                        in categories.data ?? [])
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          label: Text('#${category.name}'),
                                          selected: _view == 'category' &&
                                              _selectedCategoryId ==
                                                  category.id,
                                          onSelected: (_) => setState(() {
                                            _view = 'category';
                                            _selectedCategoryId = category.id;
                                          }),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _query = value.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search your notes...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Recent notes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${notes.length} items',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Could not load notes: ${snapshot.error}'),
                    ),
                  )
                else if (!snapshot.hasData)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (notes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.note_add_outlined,
                                size: 62, color: accent),
                            const SizedBox(height: 14),
                            Text(
                              term.isEmpty
                                  ? 'Your archive is waiting'
                                  : 'No matches found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Capture a thought and keep it safe.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                    sliver: SliverList.separated(
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        final colors = [
                          const Color(0xFFE97855),
                          const Color(0xFFA8D76D),
                          const Color(0xFF4D91F0),
                          const Color(0xFFE5C45B),
                          const Color(0xFFB28ADD),
                        ];
                        final color = note.color == null
                            ? colors[index % colors.length]
                            : Color(note.color!);
                        return _NoteCard(
                          note: note,
                          color: color,
                          onTap: () => context.push('/editor/${note.id}'),
                          actions: _noteActions(note),
                          onAction: (action) =>
                              _handleNoteAction(db, note, action),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/editor/${const Uuid().v4()}'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            selectedIcon: Icon(Icons.note_alt_rounded),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              context.push('/tasks');
              break;
            case 2:
              context.push('/insights');
              break;
            case 3:
              context.push('/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, String view) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _view == view,
        onSelected: (_) => setState(() {
          _view = view;
          _selectedCategoryId = null;
        }),
      ),
    );
  }

  Widget _roundAction(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.color,
    required this.onTap,
    required this.actions,
    required this.onAction,
  });

  final Note note;
  final Color color;
  final VoidCallback onTap;
  final List<PopupMenuEntry<String>> actions;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = color.computeLuminance() > 0.48
        ? const Color(0xFF171717)
        : Colors.white;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    MaterialLocalizations.of(context)
                        .formatShortDate(note.updatedAt),
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.78),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (note.sortOrder == 1)
                    Icon(Icons.push_pin_rounded, color: foreground, size: 17),
                  if (note.isFavorite)
                    Icon(Icons.star_rounded, color: foreground, size: 18),
                  PopupMenuButton<String>(
                    tooltip: 'Note actions',
                    icon: Icon(Icons.more_horiz, color: foreground),
                    onSelected: onAction,
                    itemBuilder: (_) => actions,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                note.title.trim().isEmpty ? 'Untitled note' : note.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 19,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              if (note.documentContent.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.documentContent,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.82),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _metaPill(foreground, note.isFavorite ? 'Favorite' : 'Note'),
                  const SizedBox(width: 7),
                  _metaPill(foreground, note.isArchived ? 'Archived' : 'Saved'),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded,
                      color: foreground, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaPill(Color foreground, String label) => DecoratedBox(
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
