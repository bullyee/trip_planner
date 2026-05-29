import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/database_provider.dart';
import '../../poi/services/anitabi_api_service.dart';
import '../models/bangumi_subject.dart';
import '../services/bangumi_search_service.dart';

class BangumiSearchScreen extends ConsumerStatefulWidget {
  const BangumiSearchScreen({super.key});

  @override
  ConsumerState<BangumiSearchScreen> createState() =>
      _BangumiSearchScreenState();
}

class _BangumiSearchScreenState extends ConsumerState<BangumiSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;
  int _searchSeq = 0;

  List<BangumiSubject> _results = const [];
  bool _searching = false;
  bool _hasSearched = false;
  String? _importing; // bangumi subject id currently being imported

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = const [];
        _searching = false;
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(trimmed);
    });
  }

  Future<void> _runSearch(String keyword) async {
    final seq = ++_searchSeq;
    setState(() {
      _searching = true;
      _hasSearched = true;
    });
    final results = await BangumiSearchService.searchByName(keyword);
    if (!mounted || seq != _searchSeq) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  Future<void> _confirmAndImport(BangumiSubject subject) async {
    final messenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from Bangumi'),
        content: Text(
          'Pull POIs from Anitabi for "${subject.nameCn ?? subject.name}" '
          '(Bangumi id ${subject.id})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _importing = subject.id);

    final db = ref.read(databaseProvider);
    final result = await AnitabiApiService.importBangumiSubject(db, subject.id);

    if (!mounted) return;
    setState(() => _importing = null);

    if (result == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'No POIs found on Anitabi for "${subject.nameCn ?? subject.name}".',
          ),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Imported ${result.poisImported} POIs for "${result.animeName}" '
          '(${result.coversDownloaded} covers downloaded).',
        ),
      ),
    );
    goRouter.go('/anime/${result.animeId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Bangumi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _queryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search anime (e.g., K-On, Madoka)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_queryController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _queryController.clear();
                              _onQueryChanged('');
                            },
                          )),
                border: const OutlineInputBorder(),
              ),
              onChanged: _onQueryChanged,
              onSubmitted: (value) => _runSearch(value.trim()),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasSearched) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Type an anime name to search Bangumi.\n'
            'Pick a result to pull its POIs from Anitabi.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_searching && _results.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No matches.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) =>
          _SearchResultTile(
        subject: _results[index],
        isImporting: _importing == _results[index].id,
        anyImporting: _importing != null,
        onImport: () => _confirmAndImport(_results[index]),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final BangumiSubject subject;
  final bool isImporting;
  final bool anyImporting;
  final VoidCallback onImport;

  const _SearchResultTile({
    required this.subject,
    required this.isImporting,
    required this.anyImporting,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = StringBuffer();
    if (subject.platform != null) subtitle.write(subject.platform);
    if (subject.date != null) {
      if (subtitle.isNotEmpty) subtitle.write(' · ');
      subtitle.write(subject.date);
    }
    if (subject.score != null) {
      if (subtitle.isNotEmpty) subtitle.write(' · ');
      subtitle.write('★ ${subject.score!.toStringAsFixed(1)}');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 80,
                child: subject.imageUrl == null
                    ? Container(
                        color: Colors.black12,
                        child: const Icon(Icons.movie_outlined),
                      )
                    : Image.network(
                        subject.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subject.nameCn != null)
                    Text(
                      subject.nameCn!,
                      style: theme.textTheme.titleMedium,
                    ),
                  Text(
                    subject.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle.toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: (isImporting || anyImporting) ? null : onImport,
              child: isImporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }
}
