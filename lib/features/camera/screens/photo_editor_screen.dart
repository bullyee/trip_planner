import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../providers/camera_provider.dart';
import '../services/color_match_service.dart';

/// Post-capture editor. Owns its own Scaffold so it sits in place of the
/// older inline Compare Shot panel inside `CameraScreen.build`. Reads
/// `CameraState` through the existing `cameraProvider` — no constructor
/// arguments needed because the captured photo and reference image are
/// already published there from the live capture flow.
class PhotoEditorScreen extends ConsumerStatefulWidget {
  const PhotoEditorScreen({super.key});

  @override
  ConsumerState<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends ConsumerState<PhotoEditorScreen> {
  Uint8List? _editedBytes; // null → showing the original captured file
  bool _showOverlay = false;
  bool _processing = false;
  bool _saving = false;
  String? _activeTool; // id of the tool whose result is currently displayed

  /// Runs the given compute-safe match algorithm against the current
  /// captured + reference bytes and replaces `_editedBytes` with the
  /// result. [activeTool] is shown highlighted on the matching chip so
  /// the user can see which filter is currently applied.
  Future<void> _runMatch(
    String activeTool,
    Future<Uint8List> Function(MatchArgs) algorithm,
  ) async {
    final camState = ref.read(cameraProvider);
    final captured = camState.capturedPhoto;
    final reference = camState.referenceImage;
    if (captured == null || reference == null) return;
    if (_processing) return;

    setState(() {
      _processing = true;
      _activeTool = activeTool;
    });
    try {
      final capturedBytes = await captured.readAsBytes();
      final referenceBytes = await reference.readAsBytes();
      final result = await compute(
        algorithm,
        MatchArgs(
          capturedBytes: capturedBytes,
          referenceBytes: referenceBytes,
        ),
      );
      if (!mounted) return;
      setState(() => _editedBytes = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final notifier = ref.read(cameraProvider.notifier);
    final camState = ref.read(cameraProvider);
    final db = ref.read(databaseProvider);
    final captured = camState.capturedPhoto;
    if (captured == null) return;

    setState(() => _saving = true);
    try {
      // If there's an in-memory edit, write it over the captured file so
      // the existing savePhoto pipeline copies the edited bytes into app
      // storage rather than the untouched shutter capture.
      if (_editedBytes != null) {
        await captured.writeAsBytes(_editedBytes!, flush: true);
      }
      final ok = await notifier.savePhoto(db);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Photo saved.' : 'Save failed.')),
      );
      if (ok) {
        notifier.clearCapture();
        // CameraScreen's build will see capturedPhoto == null and swap
        // back to live preview; no explicit pop needed because the editor
        // lives inside that screen.
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _back() {
    ref.read(cameraProvider.notifier).clearCapture();
  }

  @override
  Widget build(BuildContext context) {
    final camState = ref.watch(cameraProvider);
    final captured = camState.capturedPhoto;
    final reference = camState.referenceImage;
    if (captured == null) {
      // Should not happen — CameraScreen only renders us when capturedPhoto
      // is set — but rather than crash, hand control back to the parent.
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final hasReference = reference != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _back,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOverlay ? Icons.compare : Icons.compare_outlined,
            ),
            tooltip: hasReference ? 'Toggle reference overlay' : 'No reference image',
            onPressed: hasReference
                ? () => setState(() => _showOverlay = !_showOverlay)
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: _editedBytes != null
                        ? Image.memory(_editedBytes!, fit: BoxFit.contain)
                        : Image.file(captured, fit: BoxFit.contain),
                  ),
                  if (hasReference && _showOverlay)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.file(reference, fit: BoxFit.contain),
                      ),
                    ),
                  if (_processing)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 64,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _ToolChip(
                          icon: Icons.brightness_6,
                          label: 'Enhance (Brightness)',
                          enabled: hasReference && !_processing,
                          disabledHint: hasReference
                              ? null
                              : 'Pick a reference image first',
                          selected: _activeTool == 'luminance',
                          onTap: () => _runMatch(
                              'luminance', histogramMatchLuminance),
                        ),
                        _ToolChip(
                          icon: Icons.auto_fix_high,
                          label: 'Enhance (RGB)',
                          enabled: hasReference && !_processing,
                          disabledHint: hasReference
                              ? null
                              : 'Pick a reference image first',
                          selected: _activeTool == 'rgb',
                          onTap: () =>
                              _runMatch('rgb', histogramMatchRgb),
                        ),
                        _ToolChip(
                          icon: Icons.gradient,
                          label: 'Enhance (LAB)',
                          enabled: hasReference && !_processing,
                          disabledHint: hasReference
                              ? null
                              : 'Pick a reference image first',
                          selected: _activeTool == 'lab',
                          onTap: () =>
                              _runMatch('lab', histogramMatchLab),
                        ),
                        // Future tools land here as additional _ToolChip rows.
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool selected;
  final String? disabledHint;
  final VoidCallback onTap;

  const _ToolChip({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.selected,
    required this.onTap,
    this.disabledHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = enabled
        ? (selected ? theme.colorScheme.primary : Colors.white)
        : Colors.white38;
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: foreground.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: foreground)),
        ],
      ),
    );
    return Tooltip(
      message: enabled ? '' : (disabledHint ?? ''),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: tile,
        ),
      ),
    );
  }
}
