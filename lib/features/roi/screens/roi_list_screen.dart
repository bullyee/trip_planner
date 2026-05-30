import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
//import 'package:drift/drift.dart' show Value;

import '../providers/roi_provider.dart';
import '../controllers/roi_controller.dart';

class RoiListScreen extends ConsumerWidget {
  const RoiListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roisAsync = ref.watch(allRoisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regions'),
      ),
      body: roisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
                  title: Text(roi.name),
                  subtitle: roi.description != null
                      ? Text(roi.description!, maxLines: 2)
                      : null,
                  leading: Icon(
                    roi.isOfflineCached == 1
                        ? Icons.cloud_done
                        : Icons.cloud_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/rois/${roi.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              // 🌟 CLEAN UI: Delegate the action to the controller.
              // No database syntax, no Uuid(), no Value() in the UI layer.
              ref.read(roiControllerProvider.notifier).addRoi(
                name: name,
                description: descController.text,
              );
              
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
