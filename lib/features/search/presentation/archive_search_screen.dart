import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/features/search/data/archive_search_service.dart';

class ArchiveSearchScreen extends ConsumerStatefulWidget {
  const ArchiveSearchScreen({super.key});

  @override
  ConsumerState<ArchiveSearchScreen> createState() =>
      _ArchiveSearchScreenState();
}

class _ArchiveSearchScreenState extends ConsumerState<ArchiveSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<ArchiveSearchResult> _results = const [];
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      _requestId++;
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ArchiveSearchService(ref.read(databaseProvider));
      final results = await service.search(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = 'Search could not be completed: $error';
        _loading = false;
      });
    }
  }

  void _openResult(ArchiveSearchResult result) {
    if (result.kind == ArchiveSearchKind.note) {
      context.push('/editor/${result.id}');
    } else {
      context.push('/tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search your archive')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _debounce?.cancel();
                _runSearch(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search notes, tags, categories, tasks…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    _onChanged('');
                  },
                  icon: const Icon(Icons.close),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _controller.text.trim().isEmpty
                ? const _SearchHint()
                : _results.isEmpty && !_loading && _error == null
                    ? const _NoResults()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final isNote = item.kind == ArchiveSearchKind.note;
                          final labels = <String>[
                            if (item.category != null) item.category!,
                            ...item.tags,
                          ];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  isNote
                                      ? Icons.description_outlined
                                      : Icons.check_circle_outline,
                                ),
                              ),
                              title: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.preview.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.preview,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (labels.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          for (final label in labels.take(5))
                                            Chip(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              label: Text(label),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openResult(item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'Find what you remember',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Search note titles and content, category names, tags, and task details. Everything is searched locally on this device.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No results found. Try another keyword.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
