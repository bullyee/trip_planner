import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../widgets/isnet_cutout_panel.dart';

/// SPIKE — isnet-anime cutout. Thin wrapper: pick a gallery image, run the
/// reusable [IsnetCutoutPanel], save the result PNG to temp. Throwaway at
/// /cutout-isnet; the panel is the real reusable piece (also used by the
/// collage cutout editor).
class IsnetCutoutScreen extends StatefulWidget {
  const IsnetCutoutScreen({super.key});

  @override
  State<IsnetCutoutScreen> createState() => _IsnetCutoutScreenState();
}

class _IsnetCutoutScreenState extends State<IsnetCutoutScreen> {
  final _picker = ImagePicker();
  File? _source;
  Uint8List? _result;

  Future<void> _pick() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _source = File(picked.path);
      _result = null;
    });
  }

  Future<void> _save() async {
    final png = _result;
    if (png == null) return;
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'isnet_cutout.png');
    await File(path).writeAsBytes(png, flush: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved PNG: $path')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutout: isnet-anime (修毛邊)'),
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save PNG to temp',
              onPressed: _save,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pick,
        icon: const Icon(Icons.image),
        label: Text(_source == null ? 'Pick image' : 'Pick another'),
      ),
      body: _source == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Pick a reference anime frame, then box / cut out / refine / '
                  'brush-fix the character.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : IsnetCutoutPanel(
              source: _source!,
              onResult: (png) => setState(() => _result = png),
            ),
    );
  }
}
