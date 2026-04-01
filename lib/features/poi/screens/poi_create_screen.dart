import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

class PoiCreateScreen extends ConsumerStatefulWidget {
  final String roiId;
  final String? editPoiId;

  const PoiCreateScreen({super.key, required this.roiId, this.editPoiId});

  @override
  ConsumerState<PoiCreateScreen> createState() => _PoiCreateScreenState();
}

class _PoiCreateScreenState extends ConsumerState<PoiCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _animeRefController = TextEditingController();
  final _tagsController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _contactInfoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editPoiId != null) {
      _loadExistingPoi();
    }
  }

  Future<void> _loadExistingPoi() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final poi = await db.getPoiById(widget.editPoiId!);
      _nameController.text = poi.name;
      _descController.text = poi.description ?? '';
      _addressController.text = poi.address ?? '';
      _latController.text = poi.lat.toString();
      _lngController.text = poi.lng.toString();
      _animeRefController.text = poi.animeSeriesRef ?? '';
      _tagsController.text = poi.tags ?? '';
      _businessHoursController.text = poi.businessHours ?? '';
      _contactInfoController.text = poi.contactInfo ?? '';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _animeRefController.dispose();
    _tagsController.dispose();
    _businessHoursController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editPoiId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Location' : 'New Location'),
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
                      hintText: 'e.g., Toyosato Elementary School',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _animeRefController,
                    decoration: const InputDecoration(
                      labelText: 'Anime Series',
                      hintText: 'e.g., K-On!',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Formatted physical address',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude *',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lngController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude *',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'indoor, rain-safe, food (comma-separated)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Business Hours',
                      hintText: 'e.g., Mon-Fri 09:00-17:00',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Info',
                      hintText: 'Phone, website, etc.',
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(isEditing ? Icons.save : Icons.add_location),
                    label: Text(isEditing ? 'Save Changes' : 'Create Location'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final id = widget.editPoiId ?? const Uuid().v4();

    String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

    final companion = PoisCompanion(
      id: Value(id),
      roiId: Value(widget.roiId),
      name: Value(_nameController.text.trim()),
      description: Value(nullIfEmpty(_descController.text)),
      address: Value(nullIfEmpty(_addressController.text)),
      lat: Value(double.parse(_latController.text.trim())),
      lng: Value(double.parse(_lngController.text.trim())),
      businessHours: Value(nullIfEmpty(_businessHoursController.text)),
      contactInfo: Value(nullIfEmpty(_contactInfoController.text)),
      coverImageUri: const Value(null),
      tags: Value(nullIfEmpty(_tagsController.text)),
      animeSeriesRef: Value(nullIfEmpty(_animeRefController.text)),
    );

    if (widget.editPoiId != null) {
      await db.updatePoi(companion);
    } else {
      await db.insertPoi(companion);
    }

    if (mounted) context.pop();
  }
}
