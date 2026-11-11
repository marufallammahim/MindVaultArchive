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
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.delete_outline_rounded, size: 34),
            title: const Text('Move note to trash?'),
            content: Text(
              '"${note.title.trim().isEmpty ? 'Untitled note' : note.title}" '
              'will be moved to Trash. You can restore it later or delete it permanently.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Move to trash'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await db.setDeleted(note.id, true);
        }
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
                            const SizedBox(width: 8),
                            _roundAction(
                              context,
                              Icons.delete_outline_rounded,
                              'Trash',
                              () => context.push('/trash'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF171719).withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _dockItem(context, Icons.home_rounded, 'Home', true, () {}),
              _dockItem(context, Icons.checklist_rounded, 'Tasks', false,
                  () => context.push('/tasks')),
              _dockItem(context, Icons.insights_rounded, 'Insights', false,
                  () => context.push('/insights')),
              _dockItem(context, Icons.settings_rounded, 'Settings', false,
                  () => context.push('/settings')),
            ],
          ),
        ),
      ),
  }

  Widget _dockItem(
    BuildContext context,
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final foreground = selected
        ? const Color(0xFF171719)
        : Colors.white.withValues(alpha: 0.68);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFD65A) : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 21),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
    final foreground = color.computeLuminance() > 0.48
        ? const Color(0xFF171717)
        : Colors.white;
    final words = RegExp(r'\S+').allMatches(note.documentContent).length;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 17, 74, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          MaterialLocalizations.of(context)
                              .formatShortDate(note.updatedAt),
                          style: TextStyle(
                            color: foreground.withValues(alpha: 0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (note.sortOrder == 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(Icons.push_pin_rounded,
                              color: foreground, size: 17),
                        ),
                      if (note.isFavorite)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(Icons.star_rounded,
                              color: foreground, size: 18),
                        ),
                      IconButton(
                        tooltip: 'Edit note',
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              foreground.withValues(alpha: 0.10),
                          foregroundColor: foreground,
                        ),
                        onPressed: onTap,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'More note actions',
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_horiz, color: foreground),
                        onSelected: onAction,
                        itemBuilder: (_) => actions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  Text(
                    note.title.trim().isEmpty ? 'Untitled note' : note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 21,
                      height: 1.16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.45,
                    ),
                  ),
                  if (note.documentContent.trim().isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      note.documentContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.82),
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      _metaPill(foreground, '1 note'),
                      _metaPill(foreground, '$words words'),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 13,
              bottom: 13,
              child: Material(
                color: const Color(0xFFFFD65A),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: const SizedBox(
                    width: 54,
                    height: 54,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: Color(0xFF171717),
                      size: 27,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaPill(Color foreground, String label) => DecoratedBox(
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
