import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../poi/models/poi_model.dart';
import '../../poi/repositories/poi_repository.dart';
import '../providers/roi_provider.dart';
import '../../poi/providers/poi_provider.dart';
import '../../anime/providers/anime_provider.dart';
import '../repositories/roi_repository.dart';

class RoiDetailScreen extends ConsumerWidget {
  final String roiId;

  const RoiDetailScreen({super.key, required this.roiId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roiAsync = ref.watch(roiByIdProvider(roiId));
    final poisAsync = ref.watch(poisByRoiProvider(roiId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pois?tab=region'),
        ),
        title: roiAsync.when(
          data: (roi) => Text(roi?.name ?? 'Unknown'),
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Error'),
        ),
        actions: [
          roiAsync.when(
            data: (roi) {
              if (roi == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    context.push('/rois/${roi.id}/edit');
                  } else if (action == 'delete') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Region?'),
                        content: Text(
                            'This will permanently delete "${roi.name}". Locations in this region will become regionless (not deleted).'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          FilledButton(
                            onPressed: () async {
                              await ref.read(roiRepositoryProvider).deleteRoi(roi.id);
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                context.go('/rois');
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: poisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (pois) {
          if (pois.isEmpty) {
            return const Center(
              child: Text('No locations yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pois.length,
            itemBuilder: (context, index) {
              final poi = pois[index];
              return Card(
                child: ListTile(
                  title: Text(poi.name),
                  subtitle: Consumer(
                    builder: (context, ref, _) {
                      final animesAsync =
                          ref.watch(animesForPoiProvider(poi.id));
                      final firstAnime = animesAsync.maybeWhen(
                        data: (animes) =>
                            animes.isNotEmpty ? animes.first.name : null,
                        orElse: () => null,
                      );
                      final subtitle = firstAnime ?? poi.address;
                      return subtitle != null ? Text(subtitle) : const SizedBox.shrink();
                    },
                  ),
                  leading: const Icon(Icons.location_on),
                  onTap: () => context.push('/pois/${poi.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (ctx) => _BatchAddBottomSheet(roiId: roiId),
          );
        },
        icon: const Icon(Icons.playlist_add),
        label: const Text('Add Places'),
      ),
    );
  }
}

class _BatchAddBottomSheet extends ConsumerStatefulWidget {
  final String roiId;
  const _BatchAddBottomSheet({required this.roiId});

  @override
  ConsumerState<_BatchAddBottomSheet> createState() => _BatchAddBottomSheetState();
}

class _BatchAddBottomSheetState extends ConsumerState<_BatchAddBottomSheet> {
  final Set<String> _selectedIds = {};
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final poisMapAsync = ref.watch(allPoisProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Import Locations', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/rois/${widget.roiId}/pois/new');
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New'),
              ),
            ],
          ),
          const Divider(),
          
          Expanded(
            child: poisMapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (poisMap) {
                final draftPois = poisMap.values.where((p) => p.roiId == null).toList();

                if (draftPois.isEmpty) {
                  return const Center(
                    child: Text(
                      'No unassigned drafts found.\nImport from Bangumi or create a new one!',
                      textAlign: TextAlign.center,
                    )
                  );
                }

                final bool isAllSelected = _selectedIds.length == draftPois.length;

                return Column(
                  children: [
                    // Sticky Select All Checkbox
                    CheckboxListTile(
                      title: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: isAllSelected,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            // Add all draft IDs to the set
                            _selectedIds.addAll(draftPois.map((p) => p.id));
                          } else {
                            // Clear all selections
                            _selectedIds.clear();
                          }
                        });
                      },
                    ),
                    const Divider(height: 1),
                    // 景點列表 (List of POIs)
                    Expanded(
                      child: ListView.builder(
                        itemCount: draftPois.length,
                        itemBuilder: (ctx, index) {
                          final poi = draftPois[index];
                          final isSelected = _selectedIds.contains(poi.id);
                          return CheckboxListTile(
                            title: Text(poi.name),
                            subtitle: Text(poi.address ?? 'No address'),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedIds.add(poi.id);
                                } else {
                                  _selectedIds.remove(poi.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 底部確認按鈕 (Keep as is)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: FilledButton.icon(
              onPressed: (_selectedIds.isEmpty || _isSaving) ? null : _saveSelected,
              icon: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.check),
              label: Text('Import ${_selectedIds.length} locations'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSelected() async {
    setState(() => _isSaving = true);
    try {
      final poisMap = ref.read(allPoisProvider).value ?? {};
      
      for (final id in _selectedIds) {
        final poi = poisMap[id];
        if (poi != null) {
          final updatedPoi = PoiModel(
            id: poi.id,
            name: poi.name,
            roiId: widget.roiId,
            authorId: poi.authorId,
            description: poi.description,
            address: poi.address,
            lat: poi.lat,
            lng: poi.lng,
            businessHours: poi.businessHours,
            contactInfo: poi.contactInfo,
            createdAt: poi.createdAt,
            isShared: poi.isShared,
          );
          await ref.read(poiRepositoryProvider).updatePoi(updatedPoi);
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added ${_selectedIds.length} locations!')),
        );
      }
    } catch (e) {
      debugPrint('Batch import error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}