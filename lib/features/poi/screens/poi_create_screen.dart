import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../providers/poi_provider.dart';

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
  final _businessHoursController = TextEditingController();
  final _contactInfoController = TextEditingController();

  String? _animeSeriesRef;
  List<String> _selectedTags = [];
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
      _animeSeriesRef = poi.animeSeriesRef;
      _selectedTags = (poi.tags ?? '')
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
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
                  InkWell(
                    onTap: _pickAnimeSeries,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Anime Series',
                        hintText: 'Tap to select or add',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      isEmpty: _animeSeriesRef == null ||
                          _animeSeriesRef!.isEmpty,
                      child: Text(_animeSeriesRef ?? ''),
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
                  InkWell(
                    onTap: _pickTags,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'Tap to select or add',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      isEmpty: _selectedTags.isEmpty,
                      child: _selectedTags.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _selectedTags
                                    .map((t) => Chip(
                                          label: Text(t),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            ),
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
      tags: Value(_selectedTags.isEmpty ? null : _selectedTags.join(', ')),
      animeSeriesRef: Value(
        _animeSeriesRef == null || _animeSeriesRef!.trim().isEmpty
            ? null
            : _animeSeriesRef!.trim(),
      ),
    );

    if (widget.editPoiId != null) {
      await db.updatePoi(companion);
    } else {
      await db.insertPoi(companion);
    }

    if (mounted) context.pop();
  }

  Future<void> _pickAnimeSeries() async {
    final picked = await showModalBottomSheet<_AnimeSeriesPickerResult>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AnimeSeriesPickerSheet(currentValue: _animeSeriesRef),
    );

    if (picked == null) return;
    setState(() {
      _animeSeriesRef = picked.value;
    });
  }

  Future<void> _pickTags() async {
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _TagsPickerSheet(currentTags: _selectedTags),
    );

    if (picked == null) return;
    setState(() {
      _selectedTags = picked;
    });
  }
}

class _AnimeSeriesPickerResult {
  final String? value;
  const _AnimeSeriesPickerResult(this.value);
}

class _AnimeSeriesPickerSheet extends ConsumerWidget {
  final String? currentValue;

  const _AnimeSeriesPickerSheet({required this.currentValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSeries = ref.watch(distinctAnimeSeriesProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'Anime Series',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: asyncSeries.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error: $err')),
              ),
              data: (series) => ListView(
                shrinkWrap: true,
                children: [
                  if (currentValue != null && currentValue!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.clear),
                      title: const Text('Clear selection'),
                      onTap: () => Navigator.pop(
                        context,
                        const _AnimeSeriesPickerResult(null),
                      ),
                    ),
                  ...series.map((name) => ListTile(
                        leading: const Icon(Icons.movie_outlined),
                        title: Text(name),
                        selected: name == currentValue,
                        trailing: name == currentValue
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.pop(
                          context,
                          _AnimeSeriesPickerResult(name),
                        ),
                      )),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add new anime'),
                    onTap: () async {
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (_) => const _AddAnimeDialog(),
                      );
                      if (newName == null || newName.isEmpty) return;
                      if (!context.mounted) return;
                      Navigator.pop(
                        context,
                        _AnimeSeriesPickerResult(newName),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAnimeDialog extends StatefulWidget {
  const _AddAnimeDialog();

  @override
  State<_AddAnimeDialog> createState() => _AddAnimeDialogState();
}

class _AddAnimeDialogState extends State<_AddAnimeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Anime Series'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'e.g., K-On!'),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _TagsPickerSheet extends ConsumerStatefulWidget {
  final List<String> currentTags;

  const _TagsPickerSheet({required this.currentTags});

  @override
  ConsumerState<_TagsPickerSheet> createState() => _TagsPickerSheetState();
}

class _TagsPickerSheetState extends ConsumerState<_TagsPickerSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentTags.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final asyncTags = ref.watch(distinctTagsProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: FilledButton(
              onPressed: () => Navigator.pop(
                context,
                (_selected.toList()..sort()),
              ),
              child: const Text('Done'),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: asyncTags.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error: $err')),
              ),
              data: (knownTags) {
                final extra = _selected
                    .where((t) => !knownTags.contains(t))
                    .toList()
                  ..sort();
                final allTags = [...knownTags, ...extra];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...allTags.map((tag) => FilterChip(
                            label: Text(tag),
                            selected: _selected.contains(tag),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selected.add(tag);
                                } else {
                                  _selected.remove(tag);
                                }
                              });
                            },
                          )),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Add new tag'),
                        onPressed: () async {
                          final newTag = await showDialog<String>(
                            context: context,
                            builder: (_) => const _AddTagDialog(),
                          );
                          if (newTag == null || newTag.isEmpty) return;
                          setState(() => _selected.add(newTag));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTagDialog extends StatefulWidget {
  const _AddTagDialog();

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'e.g., rain-safe'),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
