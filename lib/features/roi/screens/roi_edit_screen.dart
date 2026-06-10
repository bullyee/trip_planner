import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../sync/providers/firestore_sync_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../controllers/roi_controller.dart';
import '../../../core/utils/app_result.dart';
import '../models/roi_model.dart';
import '../repositories/roi_repository.dart';
import '../../auth/providers/auth_provider.dart';        // REQUIRED for Auth Check

class RoiEditScreen extends ConsumerStatefulWidget {
  final String roiId;

  const RoiEditScreen({super.key, required this.roiId});

  @override
  ConsumerState<RoiEditScreen> createState() => _RoiEditScreenState();
}

class _RoiEditScreenState extends ConsumerState<RoiEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  RoiModel? _existing;

  bool _enableCloudSync = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repository = ref.read(roiRepositoryProvider);
      final roi = await repository.getRoiById(widget.roiId);

      _existing = roi;
      _nameController.text = roi.name;
      _descController.text = roi.description ?? '';
      
      _enableCloudSync = roi.isShared;
      
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Region not found.')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the trip is ALREADY synced to the cloud. 
    // If it is, we disable the switch to prevent turning it off, 
    // because cloud state cannot be easily reversed without risking data inconsistency.
    final bool isAlreadySynced = _existing?.isShared ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Region'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'e.g., Kyoto City',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_sync, 
                                color: isAlreadySynced || _enableCloudSync
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cloud Collaborative Workspace',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Switch(
                                value: _enableCloudSync,
                                onChanged: isAlreadySynced 
                                    ? null 
                                    : (val) {
                                        setState(() {
                                          _enableCloudSync = val;
                                        });
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAlreadySynced
                                ? 'This trip is currently synced to the cloud. Real-time collaboration is active.'
                                : 'Enable to sync this trip to Firestore. Once enabled, this trip cannot be reverted to local-only.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existing == null) return; 

    setState(() => _isSaving = true);

    try {
      // 1. Check if the user is upgrading this trip to Cloud (isShared transition: false -> true)
      final bool isUpgradingToCloud = !_existing!.isShared && _enableCloudSync;

      if (isUpgradingToCloud) {
        final currentUserId = ref.read(currentUserIdProvider);
        if (currentUserId.isEmpty || currentUserId == 'guest_local_user') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be signed in to enable Cloud Sync.')),
          );
          setState(() => _isSaving = false);
          return;
        }

        // Initialize Firestore Root Document (Creates the Trip Workspace)
        final firestoreService = ref.read(firestoreSyncServiceProvider);
        await firestoreService.initializeCloudTrip(
          widget.roiId, 
          currentUserId, 
          _nameController.text,
        );

        // Tell Local Repository to mark this ROI as shared
        await ref.read(roiRepositoryProvider).enableCloudSyncForRoi(widget.roiId);

        // Kick off the initial push immediately so POIs + chunks upload now,
        // rather than waiting for (or depending on) the background dirty-chunk
        // watcher. Best-effort: a transient push failure shouldn't fail the save.
        try {
          await ref.read(syncEngineProvider)?.executePush(widget.roiId);
        } catch (e) {
          debugPrint('Initial cloud push failed: $e');
        }
      }

      // 2. Perform normal ROI update (Name/Description)
      final result = await ref.read(roiControllerProvider.notifier).updateRoi(
        id: widget.roiId,
        name: _nameController.text,
        description: _descController.text,
        createdAt: _existing!.createdAt,
        existingIsOfflineCached: _existing!.isOfflineCached ? 1 : 0,
        isShared: _enableCloudSync ? true : _existing!.isShared, 
        authorId: _existing!.authorId,
      );

      if (!mounted) return;

      switch (result) {
        case Success():
          if (isUpgradingToCloud) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip upgraded to Cloud Collaborative Workspace!')),
             );
          }
          context.pop();
        case Failure(:final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save ROI: $error')),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}