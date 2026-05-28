import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/anime_provider.dart';

class AnimeListScreen extends ConsumerWidget {
  const AnimeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animesAsync = ref.watch(allAnimesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime'),
      ),
      body: animesAsync.when(
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
                      ? Text(anime.description!, maxLines: 2)
                      : null,
                  trailing: Consumer(
                    builder: (context, ref, _) {
                      final count =
                          ref.watch(poiCountForAnimeProvider(anime.id));
                      return Text(
                        count.maybeWhen(
                          data: (n) => '$n POI${n == 1 ? '' : 's'}',
                          orElse: () => '',
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  onTap: () => context.push('/anime/${anime.id}'),
                  onLongPress: () =>
                      context.push('/animes/${anime.id}/edit'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/animes/new/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
