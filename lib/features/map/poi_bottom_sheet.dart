import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../anime/providers/anime_provider.dart';
import '../tag/providers/tag_provider.dart';

class PoiBottomSheet extends ConsumerWidget {
  final Poi poi;

  const PoiBottomSheet({super.key, required this.poi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animesAsync = ref.watch(animesForPoiProvider(poi.id));
    final tagsAsync = ref.watch(tagsForPoiProvider(poi.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (poi.coverImageUri != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(poi.coverImageUri!),
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 180,
                  color: Colors.black12,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
          if (poi.address != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  poi.address!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
          ],
          if (poi.description != null) ...[
            const SizedBox(height: 8),
            Text(poi.description!),
          ],
          if (poi.businessHours != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text(
                poi.businessHours!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          ],
          animesAsync.maybeWhen(
            data: (animes) => animes.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: animes
                          .map((a) => ActionChip(
                                avatar: const Icon(Icons.movie_outlined, size: 16),
                                label: Text(a.name),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onPressed: () =>
                                    context.push('/anime/${a.id}'),
                              ))
                          .toList(),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          tagsAsync.maybeWhen(
            data: (tags) => tags.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags
                          .map((t) => ActionChip(
                                label: Text(t.name),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onPressed: () =>
                                    context.push('/tag/${t.id}'),
                              ))
                          .toList(),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => context.push('/pois/${poi.id}'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open details'),
          ),
        ],
      ),
    );
  }
}
