import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../../camera/services/reinhard_match_service.dart';
import '../providers/poi_provider.dart';
import '../services/media_asset_service.dart';

/// One step in the edit history.
///
/// `bytes == null` means the source file as-is (no in-memory edit).
/// `tool` is the id of the chip that produced this state, used both to
/// highlight that chip and to label the step in tooltips. Carrying tool
/// alongside bytes means undo/redo restore both the visible image AND
/// the chip-selected state in a single hop.
///
/// For `tool == 'match'` only: `matchedBaseBytes` holds Reinhard's
/// full-strength output and `strength` ∈ [0, 1] is the current slider
/// position. The canvas renders a Stack of the original source image
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

/// Standalone photo editor — reads everything it needs from its
/// constructor args and saves directly via [persistMediaAsset], so the
/// same screen serves both the live camera flow ("just shot this") and
/// the POI-detail flow ("picked this from gallery") without either
/// path needing to seed any global state. Lives under `poi/screens`
/// because the result is a POI's media asset; reuses the colour-match
/// service that still ships from the camera feature.
class PhotoEditScreen extends ConsumerStatefulWidget {
  /// POI whose media assets list the saved photo joins.
  final String poiId;

  /// File on disk that this screen edits in place — the editor writes
  /// the edited bytes back onto this path before [persistMediaAsset]
  /// copies it into permanent app storage. Callers should hand over a
  /// temp copy (for gallery picks) or the camera's own capture file
  /// (which already lives in cache), not a path it can't safely mutate.
  final String sourcePath;

  /// Optional anime-scene reference: when set, the editor allows the
  /// reference-overlay toggle, the swipe-to-reference page, and the
  /// Match Color chip. When null, all three are disabled.
  final String? referencePath;

  /// If a reference image is provided, the matching `ReferenceImages`
  /// row id is passed through to the saved `MediaAsset` so the
  /// before/after pair survives in the database.
  final String? referenceImageId;

  /// `true` when [sourcePath] is a gallery-picked image rather than a
  /// fresh camera capture, picked up by [persistMediaAsset] so the
  /// resulting row's `type` column is `uploaded_image` and the POI
  /// detail list renders the upload icon.
  final bool wasUpload;

  const PhotoEditScreen({
    super.key,
    required this.poiId,
    required this.sourcePath,
    this.referencePath,
    this.referenceImageId,
    this.wasUpload = false,
  });

  @override
  ConsumerState<PhotoEditScreen> createState() => _PhotoEditScreenState();
}

class _PhotoEditScreenState extends ConsumerState<PhotoEditScreen> {
  // History always starts with the original (bytes: null, tool: null).
  // _historyIndex points at the currently-visible step; tapping a tool
  // truncates anything past it and appends the new step.
  List<_EditState> _history = const [_EditState()];
  int _historyIndex = 0;

  // Reference image is mutable — the AppBar's photo_library button lets
  // the user swap it (or add one when there isn't one yet) without
  // leaving the editor. When the swap happens we drop any pending
  // Match Color result because the matched bytes were computed against
  // the old reference and would mislead the user.
  String? _referencePath;
  String? _referenceImageId;

  bool _showOverlay = false;
  // Overlay pan / pinch / opacity, matched to the live camera's
  // reference overlay so behaviour transfers across screens.
  Offset _overlayOffset = Offset.zero;
  // Starts at 0.8 (not 1) so that when the user first toggles the
  // overlay on, the reference image is clearly inset from the canvas
  // edges — otherwise a full-size overlay can blanket the underlying
  // photo so completely that the user can't tell anything changed.
  double _overlayScale = 0.8;
  double _overlayOpacity = 0.4;
  Offset _gestureStartOffset = Offset.zero;
  Offset _gestureStartFocalPoint = Offset.zero;
  double _gestureStartScale = 1;

  bool _processing = false;
  bool _saving = false;
  int _page = 0;
  late final PageController _pageController = PageController();

  _EditState get _current => _history[_historyIndex];
  bool get _canUndo => _historyIndex > 0;
  bool get _canRedo => _historyIndex < _history.length - 1;

  File get _sourceFile => File(widget.sourcePath);
  File? get _referenceFile =>
      _referencePath != null ? File(_referencePath!) : null;
  bool get _hasReference => _referencePath != null;

  @override
  void initState() {
    super.initState();
    _referencePath = widget.referencePath;
    _referenceImageId = widget.referenceImageId;
  }

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
  /// source + reference bytes and pushes the result onto the edit
  /// history. Filters are applied against the **original** source
  /// image (not the previous filter's output), so tapping a different
  /// chip swaps filter rather than stacking it — undo lets the user
  /// step back through previously-applied filters.
  Future<void> _runMatch(
    String activeTool,
    Future<Uint8List> Function(MatchArgs) algorithm, {
    bool storeMatchedBase = false,
  }) async {
    final ref = _referenceFile;
    if (ref == null) return;
    if (_processing) return;

    setState(() => _processing = true);
    try {
      final sourceBytes = await _sourceFile.readAsBytes();
      final referenceBytes = await ref.readAsBytes();
      final result = await compute(
        algorithm,
        MatchArgs(
          capturedBytes: sourceBytes,
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
    final db = ref.read(databaseProvider);

    setState(() => _saving = true);
    try {
      final bytesToWrite = await _resolveBytesForSave();
      if (bytesToWrite != null) {
        await _sourceFile.writeAsBytes(bytesToWrite, flush: true);
      }
      final ok = await persistMediaAsset(
        db: db,
        source: _sourceFile,
        poiId: widget.poiId,
        type: widget.wasUpload ? 'uploaded_image' : 'user_photo',
        referenceImageId: _referenceImageId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Photo saved.' : 'Save failed.')),
      );
      if (ok) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _back() {
    Navigator.of(context).pop();
  }

  /// Replace the reference image by picking from this POI's
  /// `ReferenceImages` rows — keeping the foreign-key link so the
  /// saved MediaAsset records which reference frame it was matched
  /// against. When the user is editing through a Match Color result,
  /// push a fresh original step on top of the history — the existing
  /// matched bytes were computed against the previous reference and
  /// would be misleading to keep displayed.
  Future<void> _changeReference() async {
    if (_processing) return;
    final images = await ref
        .read(referenceImagesByPoiProvider(widget.poiId).future);
    if (!mounted) return;
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No reference images on this POI. Add some on its page.'),
        ),
      );
      return;
    }

    final picked = await showModalBottomSheet<ReferenceImage>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: images.length,
        itemBuilder: (ctx, index) {
          final image = images[index];
          final file = File(image.localUri);
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Colors.black26,
                    child: Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
              ),
            ),
            title: Text(
              p.basenameWithoutExtension(image.localUri),
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.pop(ctx, image),
          );
        },
      ),
    );
    if (picked == null) return;
    if (!mounted) return;
    final file = File(picked.localUri);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image file not found: ${picked.localUri}')),
      );
      return;
    }
    setState(() {
      _referencePath = picked.localUri;
      _referenceImageId = picked.id;
      _overlayOffset = Offset.zero;
      _overlayScale = 0.8;
      _overlayOpacity = 0.4;
      if (_current.tool == 'match') {
        _pushHistory(const _EditState());
      }
    });
  }

  void _resetOverlay() {
    setState(() {
      _overlayOffset = Offset.zero;
      _overlayScale = 0.8;
      _overlayOpacity = 0.4;
    });
  }

  /// Resolves the bytes that should be written over the source file at
  /// Save time. For Match Color with `strength < 1.0`, this lerps the
  /// original source bytes against the matched bytes — at strength 1
  /// we can skip the lerp because the matched bytes already are the
  /// answer; at strength 0 we skip the overwrite entirely so the user
  /// keeps the untouched source.
  Future<Uint8List?> _resolveBytesForSave() async {
    final state = _current;
    if (state.tool == 'match' && state.matchedBaseBytes != null) {
      final t = state.strength.clamp(0.0, 1.0);
      if (t >= 0.999) return state.matchedBaseBytes;
      if (t <= 0.001) return null; // original — don't overwrite
      final origBytes = await _sourceFile.readAsBytes();
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
    final theme = Theme.of(context);
    final hasReference = _hasReference;
    final reference = _referenceFile;
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
            icon: const Icon(Icons.photo_library),
            tooltip: hasReference
                ? 'Change reference image'
                : 'Add reference image',
            onPressed: _processing ? null : _changeReference,
          ),
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
                  PageView(
                    controller: _pageController,
                    // When the user is dragging / pinching the overlay,
                    // the PageView mustn't steal the gesture as a
                    // swipe-to-reference — that would yank them to
                    // page 1 mid-edit. So lock the swipe while overlay
                    // mode is on (and obviously when there's no
                    // reference page to swipe to).
                    physics: hasReference && !_showOverlay
                        ? const PageScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: _current.tool == 'match' &&
                                    _current.matchedBaseBytes != null
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.file(_sourceFile,
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
                                    : Image.file(_sourceFile,
                                        fit: BoxFit.contain)),
                          ),
                          if (hasReference && _showOverlay)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onScaleStart: (details) {
                                  _gestureStartOffset = _overlayOffset;
                                  _gestureStartFocalPoint =
                                      details.focalPoint;
                                  _gestureStartScale = _overlayScale;
                                },
                                onScaleUpdate: (details) {
                                  setState(() {
                                    _overlayOffset = _gestureStartOffset +
                                        (details.focalPoint -
                                            _gestureStartFocalPoint);
                                    _overlayScale = (_gestureStartScale *
                                            details.scale)
                                        .clamp(0.35, 4)
                                        .toDouble();
                                  });
                                },
                                child: Center(
                                  child: Transform.translate(
                                    offset: _overlayOffset,
                                    child: Transform.scale(
                                      scale: _overlayScale,
                                      // Border lives OUTSIDE the
                                      // Opacity so it stays full-alpha
                                      // regardless of how transparent
                                      // the user dials the overlay —
                                      // a 20 % image with a 20 % frame
                                      // is invisible against a busy
                                      // captured scene, which beats
                                      // the whole point of "here is
                                      // where the reference sits".
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Opacity(
                                          opacity: _overlayOpacity,
                                          child: Image.file(
                                            reference!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (hasReference)
                        Center(
                          child: Image.file(reference!, fit: BoxFit.contain),
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
                  if (hasReference && !_showOverlay)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: _SwipeHint(page: _page),
                    ),
                  if (hasReference && _showOverlay)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _FloatingOverlayBar(
                        opacity: _overlayOpacity,
                        theme: theme,
                        onChanged: (v) =>
                            setState(() => _overlayOpacity = v),
                        onReset: _resetOverlay,
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
                          icon: Icons.palette,
                          label: 'Match Color',
                          enabled: hasReference && !_processing,
                          disabledHint: hasReference
                              ? null
                              : 'No reference image',
                          selected: activeTool == 'match',
                          onTap: () => _runMatch(
                            'match',
                            reinhardMatch,
                            storeMatchedBase: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Match Color strength slider keeps its dedicated
                  // line in the bottom strip. Overlay opacity now lives
                  // in a floating bar above the chip row (see
                  // `_FloatingOverlayBar` in the canvas Stack) so the
                  // two controls don't compete for the same slot when
                  // the user is both blending and matching at once.
                  if (activeTool == 'match' &&
                      _current.matchedBaseBytes != null) ...[
                    const SizedBox(height: 4),
                    _LabelledSlider(
                      label: 'Strength',
                      value: _current.strength.clamp(0.0, 1.0),
                      min: 0,
                      max: 1,
                      theme: theme,
                      onChanged: _setStrength,
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

/// Floating Overlay opacity bar — sits at the bottom edge of the canvas
/// area whenever the compare overlay is on, so the Match Color
/// strength slider can keep its dedicated line in the bottom strip
/// without one tool clobbering the other's UI. Has a built-in reset
/// button on the right edge (no AppBar entry needed).
class _FloatingOverlayBar extends StatelessWidget {
  final double opacity;
  final ThemeData theme;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  const _FloatingOverlayBar({
    required this.opacity,
    required this.theme,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            const Text(
              'Overlay',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: theme.colorScheme.primary,
                  overlayColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: opacity.clamp(0.1, 1),
                  min: 0.1,
                  max: 1,
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${(opacity * 100).round()}%',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.right,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              color: Colors.white,
              tooltip: 'Reset overlay',
              onPressed: onReset,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 36,
                height: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label + Slider + "NN%" row. Used for both the overlay-opacity
/// control and the Match Color strength control so the two read as the
/// same affordance from the user's side.
class _LabelledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ThemeData theme;
  final ValueChanged<double> onChanged;

  const _LabelledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final span = (max - min);
    final percent = span > 0 ? ((value - min) / span) * 100 : 0;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 6),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: theme.colorScheme.primary,
              overlayColor:
                  theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${percent.round()}%',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
      ],
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
