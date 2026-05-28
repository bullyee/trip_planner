import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

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
  Roi? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = ref.read(databaseProvider);
      final roi = await db.getRoiById(widget.roiId);
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
    final db = ref.read(databaseProvider);
    String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

    await db.updateRoi(RoisCompanion(
      id: Value(widget.roiId),
      name: Value(_nameController.text.trim()),
      description: Value(nullIfEmpty(_descController.text)),
      isOfflineCached: Value(_existing?.isOfflineCached ?? 0),
      createdAt: Value(
        _existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      ),
    ));
    if (mounted) context.pop();
  }
}
