import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';

/// Full-screen, reference-inspired confirmation before moving a note to Trash.
class DeleteConfirmationScreen extends ConsumerWidget {
  const DeleteConfirmationScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final noteQuery = db.select(db.notes)
      ..where((note) => note.id.equals(noteId));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder(
          stream: noteQuery.watchSingleOrNull(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Could not load note: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final note = snapshot.data;
            if (note == null) {
              return _missing(context);
            }
            final title = note.title.trim().isEmpty
                ? 'Untitled note'
                : note.title.trim();
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      tooltip: 'Go back',
                      onPressed: () => context.pop(false),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF263F9B), Color(0xFF7B43CE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6546D7).withValues(alpha: .28),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD65A),
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Text(
                    'You sure\nabout this?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 39,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'If you move “$title” to Trash, you can still find it there and restore it later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .64),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 220,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF171719),
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.draw_rounded,
                          size: 100,
                          color: const Color(0xFFFFD65A).withValues(alpha: .18),
                        ),
                        const Icon(
                          Icons.delete_sweep_rounded,
                          size: 82,
                          color: Color(0xFFFFB21D),
                        ),
                        Positioned(
                          right: 32,
                          top: 25,
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white.withValues(alpha: .8),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF27F80),
                        foregroundColor: const Color(0xFF251416),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => context.pop(true),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text(
                        'Move to Trash',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text(
                      'No, keep it',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _missing(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.note_alt_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('This note is no longer available.'),
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Go back'),
            ),
          ],
        ),
      );
}
