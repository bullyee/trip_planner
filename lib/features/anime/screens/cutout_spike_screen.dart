import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// SPIKE — anime-cutout proof (Path A: ML Kit Subject Segmentation, on-device,
/// Android). Pick a reference image, optionally drag a BOX to constrain to the
/// object, run auto subject segmentation, then tap a detected subject's
/// transparent-PNG cutout.
///
/// ML Kit has no prompt input — it auto-detects the prominent subjects. A box
/// simply CROPS the image before segmenting so the model focuses on the region
/// you want. (A brush/pre-mask was tried and removed: blacking out the
/// background strips the context ML Kit needs, so it detects poorly. Real
/// freeform prompting needs SAM, not ML Kit.) Throwaway screen at /cutout-spike;
/// see docs/anime-cutout-decision.md.
class CutoutSpikeScreen extends StatefulWidget {
  const CutoutSpikeScreen({super.key});

  @override
  State<CutoutSpikeScreen> createState() => _CutoutSpikeScreenState();
}

class _CutoutSpikeScreenState extends State<CutoutSpikeScreen> {
  final _picker = ImagePicker();

  File? _imageFile;
  int _origW = 0;
  int _origH = 0;

  // Box ROI in ORIGINAL-IMAGE pixel coords (null = whole image).
  Rect? _roi;
  Offset? _dragStart;

  List<Subject> _results = const [];
  int? _selected;
  bool _processing = false;
  String? _status;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final w = frame.image.width;
    final h = frame.image.height;
    frame.image.dispose();
    setState(() {
      _imageFile = file;
      _origW = w;
      _origH = h;
      _roi = null;
      _results = const [];
      _selected = null;
      _status = 'Optionally drag a box around the object, then "Cut out".';
    });
  }

  // Crop to the ROI before segmenting (null ROI = whole image).
  Future<File> _cropToBox() async {
    final roi = _roi;
    if (roi == null || _imageFile == null) return _imageFile!;
    final left = roi.left.clamp(0, (_origW - 1).toDouble());
    final top = roi.top.clamp(0, (_origH - 1).toDouble());
    final width = roi.width.clamp(1, _origW - left).toDouble();
    final height = roi.height.clamp(1, _origH - top).toDouble();

    final decoded = img.decodeImage(await _imageFile!.readAsBytes());
    if (decoded == null) return _imageFile!;
    final crop = img.copyCrop(decoded,
        x: left.round(),
        y: top.round(),
        width: width.round(),
        height: height.round());
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'cutout_roi_crop.png');
    await File(path).writeAsBytes(img.encodePng(crop), flush: true);
    return File(path);
  }

  Future<void> _segment() async {
    if (_imageFile == null) return;
    setState(() {
      _processing = true;
      _results = const [];
      _selected = null;
      _status = _roi != null ? 'Segmenting selection…' : 'Segmenting whole…';
    });

    final segmenter = SubjectSegmenter(
      options: SubjectSegmenterOptions(
        enableForegroundBitmap: false,
        enableForegroundConfidenceMask: false,
        enableMultipleSubjects: SubjectResultOptions(
          enableConfidenceMask: false,
          enableSubjectBitmap: true,
        ),
      ),
    );
    try {
      final file = await _cropToBox();
      final result =
          await segmenter.processImage(InputImage.fromFilePath(file.path));
      if (!mounted) return;
      setState(() {
        _results = result.subjects;
        _processing = false;
        _status = result.subjects.isEmpty
            ? 'No subjects detected — tighten the box around the object.'
            : '${result.subjects.length} subject'
                '${result.subjects.length == 1 ? '' : 's'} — tap a cutout below.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _status = 'Failed (model may still be downloading — retry): $e';
      });
    } finally {
      await segmenter.close();
    }
  }

  Future<void> _saveSelected() async {
    final i = _selected;
    if (i == null) return;
    final bitmap = _results[i].bitmap;
    if (bitmap == null) return;
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'cutout_spike_$i.png');
    await File(path).writeAsBytes(bitmap, flush: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved PNG: $path')));
  }

  void _clearSelection() => setState(() => _roi = null);

  @override
  Widget build(BuildContext context) {
    final imgAreaH = MediaQuery.sizeOf(context).height * 0.45;
    return Scaffold(
      appBar: AppBar(title: const Text('Cutout spike (ML Kit, box)')),
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
                  'Pick a reference image, optionally box the object, and cut it '
                  'out. A tight box gives the model a cleaner region to segment.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: imgAreaH,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(child: _buildImage(imgAreaH - 24)),
                  ),
                ),
                _buildControls(),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_processing)
                        const Center(child: CircularProgressIndicator())
                      else if (_status != null)
                        Text(_status!,
                            style: Theme.of(context).textTheme.bodyMedium),
                      if (_results.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildResults(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImage(double maxH) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (_origW == 0 || _origH == 0)
            ? 1.0
            : math.min(constraints.maxWidth / _origW, maxH / _origH);
        final dispW = _origW * scale;
        final dispH = _origH * scale;

        Offset toOrig(Offset local) => Offset(
              (local.dx / scale).clamp(0, _origW.toDouble()),
              (local.dy / scale).clamp(0, _origH.toDouble()),
            );

        return SizedBox(
          width: dispW,
          height: dispH,
          child: GestureDetector(
            onPanStart: (d) => setState(() {
              _dragStart = toOrig(d.localPosition);
              _roi = Rect.fromPoints(_dragStart!, _dragStart!);
            }),
            onPanUpdate: (d) => setState(() {
              if (_dragStart != null) {
                _roi = Rect.fromPoints(_dragStart!, toOrig(d.localPosition));
              }
            }),
            child: Stack(
              children: [
                Image.file(_imageFile!,
                    width: dispW, height: dispH, fit: BoxFit.fill),
                if (_roi != null)
                  Positioned.fromRect(
                    rect: Rect.fromLTRB(_roi!.left * scale, _roi!.top * scale,
                        _roi!.right * scale, _roi!.bottom * scale),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                        color: Colors.amber.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: _processing ? null : _segment,
            icon: const Icon(Icons.content_cut),
            label: const Text('Cut out'),
          ),
          const Spacer(),
          TextButton(
            onPressed: _processing ? null : _clearSelection,
            child: const Text('Clear box'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _results.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final bmp = _results[i].bitmap;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  width: 96,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    border: Border.all(
                      color: _selected == i ? Colors.amber : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: bmp == null
                      ? const Center(child: Text('—'))
                      : Image.memory(bmp, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 12),
          Container(
            color: Colors.grey.shade400,
            padding: const EdgeInsets.all(8),
            child: Image.memory(_results[_selected!].bitmap ?? Uint8List(0)),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saveSelected,
            icon: const Icon(Icons.save),
            label: const Text('Save PNG to temp'),
          ),
        ],
      ],
    );
  }
}
