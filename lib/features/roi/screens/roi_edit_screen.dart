import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/roi_controller.dart';
import '../models/roi_model.dart';
import '../repositories/roi_repository.dart';

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
  RoiModel? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
  try {
    // Delegate fetching to the repository instead of Drift DB
    final repository = ref.read(roiRepositoryProvider);
    final roi = await repository.getRoiById(widget.roiId);

    _existing = roi;
    _nameController.text = roi.name;
    _descController.text = roi.description ?? '';
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
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if the data was successfully loaded before saving
    if (_existing == null) return; 

    final success = await ref.read(roiControllerProvider.notifier).updateRoi(
      id: widget.roiId,
      name: _nameController.text,
      description: _descController.text,
      createdAt: _existing!.createdAt,                     // Extract from _existing
      // Preserve the existing offline-cache flag; without this the repo defaults
      // it to 0 and silently clears offline caching on every edit.
      existingIsOfflineCached: _existing!.isOfflineCached ? 1 : 0,
      // NOTE: If your Drift 'Roi' class doesn't have an 'isShared' column yet,
      // just pass 'false' here for now.
      isShared: false,
    );

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save ROI. Please try again.')),
      );
    }
  }
}
