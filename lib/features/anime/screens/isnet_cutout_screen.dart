import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/cutout_refine.dart';
import '../services/isnet_cutout_service.dart';

/// SPIKE — isnet-anime (rembg) cutout, the non-Google path. Auto-segments the
/// foreground (no prompt), then exposes "修毛邊" edge refinement so you can A/B
/// the raw mask vs guided-filter + erode + feather. Throwaway at /cutout-isnet.
class IsnetCutoutScreen extends StatefulWidget {
  const IsnetCutoutScreen({super.key});

  @override
  State<IsnetCutoutScreen> createState() => _IsnetCutoutScreenState();
}

class _IsnetCutoutScreenState extends State<IsnetCutoutScreen> {
  final _picker = ImagePicker();
  final _service = IsnetCutoutService();

  File? _imageFile;
  img.Image? _original; // decoded, kept for re-compositing
  IsnetMask? _mask; // raw model output, refined on demand

  // 修毛邊 controls.
  bool _refine = true;
  bool _guided = true;
  double _erode = 1;
  double _feather = 4;

  Uint8List? _resultPng;
  bool _processing = false;
  String? _status;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _original = decoded;
      _mask = null;
      _resultPng = null;
      _status = 'Tap "Cut out" to run isnet-anime.';
    });
  }

  Future<void> _cutout() async {
    final original = _original;
    if (original == null) return;
    setState(() {
      _processing = true;
      _status = 'Running isnet-anime (first run downloads nothing — local model)…';
    });
    try {
      final mask = await _service.segment(original);
      if (!mounted) return;
      _mask = mask;
      await _recomposite(setProcessing: false);
      if (!mounted) return;
      setState(() => _status = 'Done — toggle 修毛邊 / drag sliders to compare.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _status = 'Failed: $e';
      });
    }
  }

  Future<void> _recomposite({bool setProcessing = true}) async {
    final mask = _mask;
    final original = _original;
    if (mask == null || original == null) return;
    if (setProcessing) setState(() => _processing = true);
    final opt = _refine
        ? RefineOptions(
            guided: _guided,
            erode: _erode.round(),
            feather: _feather,
          )
        : const RefineOptions();
    // Heavy CPU on the main isolate — fine for a spike (one-shot, not live).
    final png = buildCutoutPng(original, mask, opt);
    if (!mounted) return;
    setState(() {
      _resultPng = png;
      _processing = false;
    });
  }

  Future<void> _save() async {
    final png = _resultPng;
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
      appBar: AppBar(title: const Text('Cutout: isnet-anime (修毛邊)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _processing ? null : _pickImage,
        icon: const Icon(Icons.image),
        label: Text(_imageFile == null ? 'Pick image' : 'Pick another'),
      ),
      body: _imageFile == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Pick a reference anime frame, run isnet-anime, then refine the '
                  'edges (guided filter / erode / feather) and compare.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionLabel(context, 'Input'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_imageFile!, height: 180, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _processing ? null : _cutout,
                  icon: const Icon(Icons.content_cut),
                  label: const Text('Cut out'),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 8),
                  Text(_status!, style: Theme.of(context).textTheme.bodySmall),
                ],
                if (_mask != null) ...[
                  const Divider(height: 32),
                  _refineControls(),
                ],
                if (_resultPng != null) ...[
                  const Divider(height: 32),
                  _sectionLabel(context, _refine ? 'Refined cutout' : 'Raw cutout'),
                  _CheckerBox(child: Image.memory(_resultPng!)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save PNG to temp'),
                  ),
                ],
                if (_processing) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
    );
  }

  Widget _refineControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('修毛邊 (edge refine)'),
          subtitle: const Text('Off = raw isnet alpha, On = guided/erode/feather'),
          value: _refine,
          onChanged: _processing
              ? null
              : (v) {
                  setState(() => _refine = v);
                  _recomposite();
                },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Guided filter (edge-snap)'),
          value: _guided,
          onChanged: (!_refine || _processing)
              ? null
              : (v) {
                  setState(() => _guided = v);
                  _recomposite();
                },
        ),
        _slider('Erode (de-halo)', _erode, 0, 6, (_erode).round().toString(),
            (v) => setState(() => _erode = v)),
        _slider('Feather (soften)', _feather, 0, 12,
            (_feather).round().toString(), (v) => setState(() => _feather = v)),
      ],
    );
  }

  Widget _slider(String label, double value, double min, double max,
      String display, ValueChanged<double> onChanged) {
    final enabled = _refine && !_processing;
    return Row(
      children: [
        SizedBox(width: 130, child: Text('$label  $display')),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            divisions: (max - min).round(),
            value: value,
            label: display,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: enabled ? (_) => _recomposite() : null,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

/// Checkerboard backdrop so the cutout's transparency (and any edge halo) shows.
class _CheckerBox extends StatelessWidget {
  final Widget child;
  const _CheckerBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        painter: _CheckerPainter(),
        child: child,
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 12.0;
    final light = Paint()..color = const Color(0xFFE0E0E0);
    final dark = Paint()..color = const Color(0xFFB8B8B8);
    canvas.drawRect(Offset.zero & size, light);
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        if (((x ~/ cell) + (y ~/ cell)).isEven) continue;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), dark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
