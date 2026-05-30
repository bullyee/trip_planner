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
/// Android). Pick a reference image, constrain to the object with a BOX or a
/// freeform BRUSH, run auto subject segmentation, pick a detected subject's
/// transparent-PNG cutout.
///
/// ML Kit has no prompt input, so the box/brush work by baking the selection
/// into the pixels before segmenting: the box crops; the brush keeps the
/// painted area and blacks out the rest. Paint LOOSELY (object + margin) so the
/// model still has background to trim. Throwaway screen at /cutout-spike; see
/// docs/anime-cutout-decision.md.
enum _Mode { box, brush }

/// A freeform brush stroke, points in ORIGINAL-IMAGE pixel coordinates.
class _Stroke {
  final List<Offset> points;
  final double width; // original-image pixels
  _Stroke(this.points, this.width);
}

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

  _Mode _mode = _Mode.box;

  // Box: ROI in ORIGINAL-IMAGE pixel coords (null = whole image).
  Rect? _roi;
  Offset? _dragStart;

  // Brush: strokes in ORIGINAL-IMAGE pixel coords + brush size in DISPLAY px.
  final List<_Stroke> _strokes = [];
  double _brushDisplay = 40;

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
      _strokes.clear();
      _results = const [];
      _selected = null;
      _status = _mode == _Mode.box
          ? 'Drag a box around the object, then "Cut out".'
          : 'Paint loosely over the object, then "Cut out".';
    });
  }

  // ---- Box mode: crop to the ROI ----------------------------------------
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

  // ---- Brush mode: keep painted pixels, black out the rest ---------------
  Future<File> _maskToBrush() async {
    if (_strokes.isEmpty || _imageFile == null) return _imageFile!;
    final bytes = await _imageFile!.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final orig = frame.image;

    final recorder = ui.PictureRecorder();
    final fullRect =
        Rect.fromLTWH(0, 0, _origW.toDouble(), _origH.toDouble());
    final canvas = Canvas(recorder, fullRect);
    canvas.drawRect(fullRect, Paint()..color = Colors.black);
    canvas.saveLayer(fullRect, Paint());
    final maskPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final s in _strokes) {
      if (s.points.isEmpty) continue;
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (final pt in s.points.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, maskPaint..strokeWidth = s.width);
    }
    // srcIn keeps the image only where the white mask was painted.
    canvas.drawImage(
        orig, Offset.zero, Paint()..blendMode = BlendMode.srcIn);
    canvas.restore();

    final outImg = await recorder.endRecording().toImage(_origW, _origH);
    final png = await outImg.toByteData(format: ui.ImageByteFormat.png);
    orig.dispose();
    outImg.dispose();

    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'cutout_brush_mask.png');
    await File(path).writeAsBytes(png!.buffer.asUint8List(), flush: true);
    return File(path);
  }

  Future<void> _segment() async {
    if (_imageFile == null) return;
    final hasSelection =
        _mode == _Mode.box ? _roi != null : _strokes.isNotEmpty;
    setState(() {
      _processing = true;
      _results = const [];
      _selected = null;
      _status = hasSelection ? 'Segmenting selection…' : 'Segmenting whole…';
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
      final file =
          _mode == _Mode.box ? await _cropToBox() : await _maskToBrush();
      final result =
          await segmenter.processImage(InputImage.fromFilePath(file.path));
      if (!mounted) return;
      setState(() {
        _results = result.subjects;
        _processing = false;
        _status = result.subjects.isEmpty
            ? 'No subjects detected — tighten the box / paint more of the object.'
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

  void _clearSelection() => setState(() {
        _roi = null;
        _strokes.clear();
      });

  @override
  Widget build(BuildContext context) {
    final imgAreaH = MediaQuery.sizeOf(context).height * 0.45;
    return Scaffold(
      appBar: AppBar(title: const Text('Cutout spike (box / brush)')),
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
                  'Pick a reference image, then box or paint the object and '
                  'cut it out. Constraining to the object gives a cleaner mask.',
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
              if (_mode == _Mode.box) {
                _dragStart = toOrig(d.localPosition);
                _roi = Rect.fromPoints(_dragStart!, _dragStart!);
              } else {
                _strokes.add(_Stroke([toOrig(d.localPosition)],
                    _brushDisplay / scale));
              }
            }),
            onPanUpdate: (d) => setState(() {
              if (_mode == _Mode.box) {
                if (_dragStart != null) {
                  _roi = Rect.fromPoints(_dragStart!, toOrig(d.localPosition));
                }
              } else if (_strokes.isNotEmpty) {
                _strokes.last.points.add(toOrig(d.localPosition));
              }
            }),
            child: Stack(
              children: [
                Image.file(_imageFile!,
                    width: dispW, height: dispH, fit: BoxFit.fill),
                if (_mode == _Mode.box && _roi != null)
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
                if (_mode == _Mode.brush)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BrushPainter(_strokes, scale),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SegmentedButton<_Mode>(
                segments: const [
                  ButtonSegment(
                      value: _Mode.box,
                      icon: Icon(Icons.crop_free),
                      label: Text('Box')),
                  ButtonSegment(
                      value: _Mode.brush,
                      icon: Icon(Icons.brush),
                      label: Text('Brush')),
                ],
                selected: {_mode},
                onSelectionChanged: _processing
                    ? null
                    : (s) => setState(() {
                          _mode = s.first;
                          _roi = null;
                          _strokes.clear();
                        }),
              ),
              const Spacer(),
              TextButton(
                onPressed: _processing ? null : _clearSelection,
                child: const Text('Clear'),
              ),
            ],
          ),
          if (_mode == _Mode.brush)
            Row(
              children: [
                const Icon(Icons.brush, size: 18),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 100,
                    value: _brushDisplay,
                    label: _brushDisplay.round().toString(),
                    onChanged: (v) => setState(() => _brushDisplay = v),
                  ),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _processing ? null : _segment,
              icon: const Icon(Icons.content_cut),
              label: const Text('Cut out'),
            ),
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

class _BrushPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final double scale; // display = original * scale

  _BrushPainter(this.strokes, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final s in strokes) {
      if (s.points.isEmpty) continue;
      final path = Path()
        ..moveTo(s.points.first.dx * scale, s.points.first.dy * scale);
      for (final pt in s.points.skip(1)) {
        path.lineTo(pt.dx * scale, pt.dy * scale);
      }
      canvas.drawPath(path, paint..strokeWidth = s.width * scale);
    }
  }

  @override
  bool shouldRepaint(covariant _BrushPainter old) => true;
}
