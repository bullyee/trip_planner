import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/tag_provider.dart';

class TagListScreen extends ConsumerWidget {
  const TagListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      body: tagsAsync.when(
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
                      ? Text(tag.description!, maxLines: 2)
                      : null,
                  trailing: Consumer(
                    builder: (context, ref, _) {
                      final count = ref.watch(poiCountForTagProvider(tag.id));
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
                  onTap: () => context.push('/tag/${tag.id}'),
                  onLongPress: () => context.push('/tags/${tag.id}/edit'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tags/new/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
