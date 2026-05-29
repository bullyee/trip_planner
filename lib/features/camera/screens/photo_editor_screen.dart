import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../providers/camera_provider.dart';
import '../services/reinhard_match_service.dart';

/// One step in the edit history.
///
/// `bytes == null` means the original captured file (no in-memory edit).
/// `tool` is the id of the chip that produced this state, used both to
/// highlight that chip and to label the step in tooltips. Carrying tool
/// alongside bytes means undo/redo restore both the visible image AND
/// the chip-selected state in a single hop.
///
/// For `tool == 'match'` only: `matchedBaseBytes` holds Reinhard's
/// full-strength output and `strength` ∈ [0, 1] is the current slider
/// position. The canvas renders a Stack of the original captured image
/// + the matched bytes at `opacity = strength` so dragging the slider
/// is free (Flutter blends in the GPU), and Save flattens the lerp into
/// a single JPEG via `lerpJpegs` when `strength < 1.0`.
@immutable
class _EditState {
  final Uint8List? bytes;
  final String? tool;
  final Uint8List? matchedBaseBytes;
  final double strength;

  const _EditState({
    this.bytes,
    this.tool,
    this.matchedBaseBytes,
    this.strength = 1.0,
  });

  _EditState copyWith({
    Uint8List? bytes,
    String? tool,
    Uint8List? matchedBaseBytes,
    double? strength,
  }) {
    return _EditState(
      bytes: bytes ?? this.bytes,
      tool: tool ?? this.tool,
      matchedBaseBytes: matchedBaseBytes ?? this.matchedBaseBytes,
      strength: strength ?? this.strength,
    );
  }
}

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
  // History always starts with the original (bytes: null, tool: null).
  // _historyIndex points at the currently-visible step; tapping a tool
  // truncates anything past it and appends the new step.
  List<_EditState> _history = const [_EditState()];
  int _historyIndex = 0;

  bool _showOverlay = false;
  bool _processing = false;
  bool _saving = false;
  int _page = 0;
  late final PageController _pageController = PageController();

  _EditState get _current => _history[_historyIndex];
  bool get _canUndo => _historyIndex > 0;
  bool get _canRedo => _historyIndex < _history.length - 1;

  void _pushHistory(_EditState state) {
    // Drop any redo branch when a new edit is applied past an undo.
    final base = _historyIndex < _history.length - 1
        ? _history.sublist(0, _historyIndex + 1)
        : List<_EditState>.from(_history);
    base.add(state);
    _history = base;
    _historyIndex = _history.length - 1;
  }

  void _undo() {
    if (!_canUndo) return;
    setState(() => _historyIndex--);
  }

  void _redo() {
    if (!_canRedo) return;
    setState(() => _historyIndex++);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Runs the given compute-safe match algorithm against the current
  /// captured + reference bytes and pushes the result onto the edit
  /// history. Filters are applied against the **original** captured
  /// image (not the previous filter's output), so tapping a different
  /// chip swaps filter rather than stacking it — undo lets the user
  /// step back through previously-applied filters.
  Future<void> _runMatch(
    String activeTool,
    Future<Uint8List> Function(MatchArgs) algorithm, {
    bool storeMatchedBase = false,
  }) async {
    final camState = ref.read(cameraProvider);
    final captured = camState.capturedPhoto;
    final reference = camState.referenceImage;
    if (captured == null || reference == null) return;
    if (_processing) return;

    setState(() => _processing = true);
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
      setState(() => _pushHistory(_EditState(
            bytes: result,
            tool: activeTool,
            // Keep the full-strength match alongside so the slider can
            // lerp against the original without recomputing the filter.
            matchedBaseBytes: storeMatchedBase ? result : null,
            strength: 1.0,
          )));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  /// Updates the strength of the current Match Color state in place.
  /// Slider drags shouldn't push a new history step every frame, so we
  /// mutate the current entry — undo still goes back to before Match
  /// Color was tapped.
  void _setStrength(double value) {
    if (_current.tool != 'match' || _current.matchedBaseBytes == null) return;
    setState(() {
      final newHistory = List<_EditState>.from(_history);
      newHistory[_historyIndex] = _current.copyWith(strength: value);
      _history = newHistory;
    });
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
      final bytesToWrite = await _resolveBytesForSave(captured);
      if (bytesToWrite != null) {
        await captured.writeAsBytes(bytesToWrite, flush: true);
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

  /// Resolves the bytes that should be written over the captured file at
  /// Save time. For Match Color with `strength < 1.0`, this lerps the
  /// original captured bytes against the matched bytes — at strength 1
  /// we can skip the lerp because the matched bytes already are the
  /// answer; at strength 0 we skip the overwrite entirely so the user
  /// keeps the untouched shutter capture.
  Future<Uint8List?> _resolveBytesForSave(File captured) async {
    final state = _current;
    if (state.tool == 'match' && state.matchedBaseBytes != null) {
      final t = state.strength.clamp(0.0, 1.0);
      if (t >= 0.999) return state.matchedBaseBytes;
      if (t <= 0.001) return null; // original — don't overwrite
      final origBytes = await captured.readAsBytes();
      return compute(
        lerpJpegs,
        LerpArgs(
          jpegA: origBytes,
          jpegB: state.matchedBaseBytes!,
          strength: t,
        ),
      );
    }
    return state.bytes;
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
    final currentBytes = _current.bytes;
    final activeTool = _current.tool;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        // Wider leading slot to fit back + undo + redo in a row without
        // pushing the title — the editor has no title anyway.
        leadingWidth: 168,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: _back,
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: _canUndo && !_processing ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: _canRedo && !_processing ? _redo : null,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOverlay ? Icons.compare : Icons.compare_outlined,
            ),
            tooltip: hasReference
                ? 'Toggle reference overlay'
                : 'No reference image',
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
                  // Page 0 = editable canvas (current edit + optional
                  // semi-transparent reference overlay).
                  // Page 1 = the reference itself, full screen.
                  // PageView only carries the reference page when one is
                  // actually loaded — otherwise the swipe falls back to a
                  // single-page (no swipe) view.
                  PageView(
                    controller: _pageController,
                    physics: hasReference
                        ? const PageScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          // For Match Color: stack the original captured
                          // image and the full-strength Reinhard output,
                          // overlaying the matched bytes at `opacity =
                          // strength`. Flutter blends in the GPU, so the
                          // slider can drag at 60 fps without re-running
                          // the filter. For all other tools the canvas
                          // is a single Image of either the JPEG bytes
                          // or the original file.
                          Center(
                            child: _current.tool == 'match' &&
                                    _current.matchedBaseBytes != null
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.file(captured,
                                          fit: BoxFit.contain),
                                      Opacity(
                                        opacity: _current.strength
                                            .clamp(0.0, 1.0),
                                        child: Image.memory(
                                          _current.matchedBaseBytes!,
                                          fit: BoxFit.contain,
                                          gaplessPlayback: true,
                                        ),
                                      ),
                                    ],
                                  )
                                : (currentBytes != null
                                    ? Image.memory(currentBytes,
                                        fit: BoxFit.contain)
                                    : Image.file(captured,
                                        fit: BoxFit.contain)),
                          ),
                          if (hasReference && _showOverlay)
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.4,
                                child: Image.file(reference,
                                    fit: BoxFit.contain),
                              ),
                            ),
                        ],
                      ),
                      if (hasReference)
                        Center(
                          child: Image.file(reference, fit: BoxFit.contain),
                        ),
                    ],
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
                  if (hasReference)
                    // Tiny hint that the canvas is swipeable — sits at the
                    // bottom of the image area so it doesn't fight the
                    // tool strip below. Two dots: filled = current page.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: _SwipeHint(page: _page),
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
                          icon: Icons.palette,
                          label: 'Match Color',
                          enabled: hasReference && !_processing,
                          disabledHint: hasReference
                              ? null
                              : 'Pick a reference image first',
                          selected: activeTool == 'match',
                          // Reinhard LAB transfer at full strength. The
                          // slider below the chip strip lets the user
                          // dial it back via Flutter Stack opacity, no
                          // recompute needed.
                          onTap: () => _runMatch(
                            'match',
                            reinhardMatch,
                            storeMatchedBase: true,
                          ),
                        ),
                        // Future tools land here as additional _ToolChip rows.
                      ],
                    ),
                  ),
                  if (activeTool == 'match' &&
                      _current.matchedBaseBytes != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, right: 6),
                          child: Text(
                            'Strength',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: theme.colorScheme.primary,
                              overlayColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                            ),
                            child: Slider(
                              value: _current.strength.clamp(0.0, 1.0),
                              onChanged: _setStrength,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${(_current.strength * 100).round()}%',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
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

/// Two small dots at the bottom of the canvas — filled is the current
/// page, dimmed is the other. Page index is owned by the parent State so
/// this widget can stay stateless.
class _SwipeHint extends StatelessWidget {
  final int page;
  const _SwipeHint({required this.page});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i == page;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        );
      }),
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
