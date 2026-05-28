import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../../roi/providers/roi_provider.dart';
import '../../anime/providers/anime_provider.dart';
import '../../tag/providers/tag_provider.dart';
import '../providers/poi_provider.dart';

class PoiBrowseScreen extends StatelessWidget {
  final String? initialTab;

  const PoiBrowseScreen({super.key, this.initialTab});

  static const _tabOrder = ['region', 'anime', 'tag', 'all'];

  @override
  Widget build(BuildContext context) {
    final initialIndex = _tabOrder.indexOf(initialTab ?? '');
    return DefaultTabController(
      key: ValueKey(initialTab ?? 'default'),
      length: 4,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: const Text('View POIs'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.layers), text: 'Region'),
              Tab(icon: Icon(Icons.movie_outlined), text: 'Anime'),
              Tab(icon: Icon(Icons.label_outline), text: 'Tag'),
              Tab(icon: Icon(Icons.list), text: 'All'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ByRegionTab(),
            _ByAnimeTab(),
            _ByTagTab(),
            _AllPoisTab(),
          ],
        ),
        floatingActionButton: const _MultiAddFab(),
      ),
    );
  }
}

class _MultiAddFab extends StatelessWidget {
  const _MultiAddFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Add',
      onPressed: () => _showAddSheet(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('New POI'),
              subtitle: const Text('Add a single location'),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/pois/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('New Region'),
              subtitle: const Text('Group POIs by area, e.g., Kyoto'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCreateRoiDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: const Text('New Anime'),
              subtitle: const Text('Add an anime series'),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/animes/new/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('New Tag'),
              subtitle: const Text('Add a tag'),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/tags/new/edit');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ByRegionTab extends ConsumerWidget {
  const _ByRegionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roisAsync = ref.watch(allRoisProvider);

    return roisAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (rois) {
        if (rois.isEmpty) {
          return const Center(
            child: Text('No regions yet. Tap + to create one.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rois.length,
          itemBuilder: (context, index) {
            final roi = rois[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  roi.isOfflineCached == 1
                      ? Icons.cloud_done
                      : Icons.cloud_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(roi.name),
                subtitle: roi.description != null
                    ? Text(roi.description!, maxLines: 2)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/rois/${roi.id}'),
                onLongPress: () => context.push('/rois/${roi.id}/edit'),
              ),
            );
          },
        );
      },
    );
  }
}

class _ByAnimeTab extends ConsumerWidget {
  const _ByAnimeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnimes = ref.watch(allAnimesProvider);

    return asyncAnimes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (animes) {
        if (animes.isEmpty) {
          return const Center(
            child: Text('No anime yet. Tap + to add one.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: animes.length,
          itemBuilder: (context, index) {
            final anime = animes[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.movie_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(anime.name),
                subtitle: anime.description != null
                    ? Text(anime.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/anime/${anime.id}'),
                onLongPress: () => context.push('/animes/${anime.id}/edit'),
              ),
            );
          },
        );
      },
    );
  }
}

class _ByTagTab extends ConsumerWidget {
  const _ByTagTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTags = ref.watch(allTagsProvider);

    return asyncTags.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (tags) {
        if (tags.isEmpty) {
          return const Center(
            child: Text('No tags yet. Tap + to add one.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final tag = tags[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.label_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(tag.name),
                subtitle: tag.description != null
                    ? Text(tag.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/tag/${tag.id}'),
                onLongPress: () => context.push('/tags/${tag.id}/edit'),
              ),
            );
          },
        );
      },
    );
  }
}

class _AllPoisTab extends ConsumerWidget {
  const _AllPoisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poisAsync = ref.watch(allPoisProvider);

    return poisAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (poisMap) {
        final pois = poisMap.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        if (pois.isEmpty) {
          return const Center(child: Text('No POIs yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pois.length,
          itemBuilder: (context, index) {
            final poi = pois[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(poi.name),
                subtitle: Consumer(
                  builder: (context, ref, _) {
                    final animesAsync = ref.watch(animesForPoiProvider(poi.id));
                    final firstAnime = animesAsync.maybeWhen(
                      data: (animes) =>
                          animes.isNotEmpty ? animes.first.name : null,
                      orElse: () => null,
                    );
                    final subtitle = firstAnime ?? poi.address;
                    return subtitle != null
                        ? Text(subtitle)
                        : const SizedBox.shrink();
                  },
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/pois/${poi.id}'),
              ),
            );
          },
        );
      },
    );
  }
}

void _showCreateRoiDialog(BuildContext context) {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) => AlertDialog(
        title: const Text('New Region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final db = ref.read(databaseProvider);
              db.insertRoi(RoisCompanion.insert(
                id: const Uuid().v4(),
                name: name,
                description: Value(descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim()),
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}
