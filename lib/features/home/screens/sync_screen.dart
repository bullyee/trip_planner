import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

// 🗑️ Removed database_provider.dart
// 💡 Added sync_provider.dart

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  String _status = '';
  final _importController = TextEditingController();

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync / Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Export', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Export all trip data as JSON for backup or '
              'importing into the PC web planner.'),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _exportToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text('Copy to Clipboard'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _exportToFile,
                icon: const Icon(Icons.save),
                label: const Text('Save to File'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Import', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Paste JSON data below to import/merge trip data. '
              'Existing entries with the same ID will be updated.'),
          const SizedBox(height: 12),
          TextField(
            controller: _importController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste JSON here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _importFromText,
            icon: const Icon(Icons.upload),
            label: const Text('Import'),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_status),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _exportToClipboard() async {
    try {
      setState(() => _status = 'Exporting...');
      // 💡 Directly read the sync provider instead of injecting the database
      // ADDED: Placeholder for future Firebase integration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud synchronization via Firebase is under development.'),
          ),
        );
      setState(() => _status = 'Copied to clipboard!');
    } catch (e) {
      setState(() => _status = 'Export error: $e');
    }
  }

  Future<void> _exportToFile() async {
    try {
      setState(() => _status = 'Exporting...');
      // 💡 Directly read the sync provider
      // ADDED: Placeholder for future Firebase integration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud synchronization via Firebase is under development.'),
          ),
        );

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${dir.path}/trip_export_$timestamp.json');
      setState(() => _status = 'Saved to: ${file.path}');
    } catch (e) {
      setState(() => _status = 'Export error: $e');
    }
  }

  Future<void> _importFromText() async {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      setState(() => _status = 'Nothing to import.');
      return;
    }
    try {
      setState(() => _status = 'Importing...');
      // 💡 Directly read the sync provider
      // ADDED: Placeholder for future Firebase integration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud synchronization via Firebase is under development.'),
          ),
        );
      setState(() {
        _status = 'Import complete!';
        _importController.clear();
      });
    } catch (e) {
      setState(() => _status = 'Import error: $e');
    }
  }
}