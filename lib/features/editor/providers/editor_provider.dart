import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';

class EditorState {
  final String noteId;
  final String title;
  final String content;
  final bool isSaving;
  final bool isLoaded;
  final DateTime? lastSaved;
  final String? saveError;

  EditorState({
    required this.noteId,
    this.title = '',
    this.content = '',
    this.isSaving = false,
    this.isLoaded = false,
    this.lastSaved,
    this.saveError,
  });

  EditorState copyWith({
    String? title,
    String? content,
    bool? isSaving,
    bool? isLoaded,
    DateTime? lastSaved,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return EditorState(
      noteId: noteId,
      title: title ?? this.title,
      content: content ?? this.content,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      lastSaved: lastSaved ?? this.lastSaved,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  final AppDatabase _db;
  Timer? _debounce;
  Future<void> _saveQueue = Future<void>.value();

  EditorNotifier(this._db, String noteId) : super(EditorState(noteId: noteId)) {
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final note = await (_db.select(
        _db.notes,
      )..where((t) => t.id.equals(state.noteId))).getSingleOrNull();
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
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isLoaded: true,
          saveError: 'Could not load this note: $error',
        );
      }
    }
  }

  Future<void> reloadFromDatabase() => _loadNote();

  void updateContent(String title, String content) {
    if (!mounted) return;
    state = state.copyWith(
      title: title,
      content: content,
      isSaving: true,
      clearSaveError: true,
    );
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(_saveToDb());
    });
  }

  Future<bool> _saveToDb() async {
    if (!mounted || !state.isLoaded) return false;
    final snapshot = state;
    final operation = _saveQueue.then(
      (_) => _db.saveNoteContent(
        snapshot.noteId,
        snapshot.title,
        snapshot.content,
      ),
    );
    // Keep the queue usable after a failed write, while returning the original
    // error to this caller so the UI can report that the note was not saved.
    _saveQueue = operation.catchError((Object _) {});
    try {
      await operation;
      if (mounted &&
          state.title == snapshot.title &&
          state.content == snapshot.content) {
        state = state.copyWith(
          isSaving: false,
          lastSaved: DateTime.now(),
          clearSaveError: true,
        );
      }
      return true;
    } catch (error) {
      if (mounted &&
          state.title == snapshot.title &&
          state.content == snapshot.content) {
        state = state.copyWith(
          isSaving: false,
          saveError: 'Could not save note: $error',
        );
      }
      return false;
    }
  }

  Future<bool> forceSave() async {
    _debounce?.cancel();
    while (mounted) {
      final snapshot = state;
      final saved = await _saveToDb();
      if (!saved) return false;
      if (!mounted) return true;
      if (!state.isSaving &&
          state.title == snapshot.title &&
          state.content == snapshot.content) {
        return true;
      }
      // Text changed while a previous write was in flight. Cancel its
      // debounce and immediately persist the newest snapshot before leaving.
      _debounce?.cancel();
    }
    return false;
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
