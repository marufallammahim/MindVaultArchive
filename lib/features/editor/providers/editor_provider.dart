import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/main.dart';
import 'package:mindvault_archive/core/database/database.dart';

class EditorState {
  final String noteId;
  final String title;
  final String content;
  final bool isSaving;
  final bool isLoaded;
  final DateTime? lastSaved;

  EditorState({
    required this.noteId,
    this.title = '',
    this.content = '',
    this.isSaving = false,
    this.isLoaded = false,
    this.lastSaved,
  });

  EditorState copyWith({
    String? title,
    String? content,
    bool? isSaving,
    bool? isLoaded,
    DateTime? lastSaved,
  }) {
    return EditorState(
      noteId: noteId,
      title: title ?? this.title,
      content: content ?? this.content,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  final AppDatabase _db;
  Timer? _debounce;

  EditorNotifier(this._db, String noteId)
      : super(EditorState(noteId: noteId)) {
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final note = await (_db.select(_db.notes)
            ..where((t) => t.id.equals(state.noteId)))
          .getSingleOrNull();
      if (!mounted) return;
      if (note != null) {
        state = state.copyWith(
          title: note.title,
          content: note.documentContent,
          isLoaded: true,
        );
      } else {
        state = state.copyWith(isLoaded: true);
      }
    } catch (_) {
      if (mounted) state = state.copyWith(isLoaded: true);
    }
  }

  void updateContent(String title, String content) {
    state = state.copyWith(title: title, content: content, isSaving: true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _saveToDb);
  }

  Future<void> _saveToDb() async {
    if (!mounted || !state.isLoaded) return;
    final snapshot = state;
    await _db.saveNoteContent(snapshot.noteId, snapshot.title, snapshot.content);
    if (mounted &&
        state.title == snapshot.title &&
        state.content == snapshot.content) {
      state = state.copyWith(isSaving: false, lastSaved: DateTime.now());
    }
  }

  Future<void> forceSave() async {
    _debounce?.cancel();
    await _saveToDb();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final editorProvider =
    StateNotifierProvider.family<EditorNotifier, EditorState, String>(
  (ref, noteId) => EditorNotifier(ref.watch(databaseProvider), noteId),
);
