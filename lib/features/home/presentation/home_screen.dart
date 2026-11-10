import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:mindvault_archive/app/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final notesQuery = db.select(db.notes)
      ..where((note) => note.isDeleted.equals(false) & note.isArchived.equals(false))
      ..orderBy([(note) => OrderingTerm.desc(note.updatedAt)]);

    return Scaffold(
      appBar: AppBar(
        title: _searchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes…',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              )
            : const Text('MindVault Archive'),
        actions: [
          IconButton(
            tooltip: _searchOpen ? 'Close search' : 'Search notes',
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searchOpen = !_searchOpen;
                _query = '';
                _searchController.clear();
              });
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF5A0719)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'MindVault Archive',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('All Notes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                context.push('/about');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: notesQuery.watch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load notes: ${snapshot.error}'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allNotes = snapshot.data ?? [];
          final query = _query.toLowerCase();
          final notes = query.isEmpty
              ? allNotes
              : allNotes
                  .where((note) =>
                      note.title.toLowerCase().contains(query) ||
                      note.documentContent.toLowerCase().contains(query))
                  .toList();

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      query.isEmpty
                          ? Icons.edit_note_rounded
                          : Icons.search_off,
                      size: 76,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      query.isEmpty
                          ? 'Your archive is waiting.'
                          : 'No matching notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      query.isEmpty
                          ? 'Create your first note and save an idea worth remembering.'
                          : 'Try another title or keyword.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 190,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/editor/${note.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title.isNotEmpty ? note.title : 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            note.documentContent,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          MaterialLocalizations.of(context)
                              .formatShortDate(note.updatedAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/editor/${const Uuid().v4()}'),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}
