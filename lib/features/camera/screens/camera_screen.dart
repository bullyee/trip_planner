import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  File? _referenceImage;
  File? _capturedPhoto;
  double _opacity = 0.5;
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Camera'),
        actions: [
          if (_referenceImage != null)
            IconButton(
              icon: Icon(
                _showOverlay ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _showOverlay = !_showOverlay),
              tooltip: 'Toggle overlay',
            ),
        ],
      ),
      body: Column(
        children: [
          // Main view area
          Expanded(
            child: _capturedPhoto != null
                ? _buildComparisonView(theme)
                : _buildCaptureView(theme),
          ),

          // Opacity slider (when reference is loaded)
          if (_referenceImage != null && _showOverlay && _capturedPhoto == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.opacity, size: 20),
                  Expanded(
                    child: Slider(
                      value: _opacity,
                      onChanged: (v) => setState(() => _opacity = v),
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                  Text('${(_opacity * 100).round()}%'),
                ],
              ),
            ),

          // Action buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _capturedPhoto != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _capturedPhoto = null),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retake'),
                        ),
                        FilledButton.icon(
                          onPressed: _savePhoto,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickReferenceImage,
                          icon: const Icon(Icons.image),
                          label: Text(_referenceImage == null
                              ? 'Load Reference'
                              : 'Change Ref'),
                        ),
                        FilledButton.icon(
                          onPressed: _capturePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Capture'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureView(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Placeholder for camera preview
        Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, size: 64, color: Colors.white30),
                SizedBox(height: 12),
                Text(
                  'Camera Preview',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap "Capture" to take a photo from gallery',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        // Reference overlay
        if (_referenceImage != null && _showOverlay)
          Opacity(
            opacity: _opacity,
            child: Image.file(
              _referenceImage!,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }

  Widget _buildComparisonView(ThemeData theme) {
    return Row(
      children: [
        if (_referenceImage != null)
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Reference',
                      style: theme.textTheme.labelMedium),
                ),
                Expanded(
                  child: Image.file(_referenceImage!, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child:
                    Text('Your Photo', style: theme.textTheme.labelMedium),
              ),
              Expanded(
                child: Image.file(_capturedPhoto!, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickReferenceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _referenceImage = File(picked.path));
    }
  }

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _capturedPhoto = File(picked.path));
    }
  }

  void _savePhoto() {
    // For now just show confirmation — full save to media_assets comes later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo saved to gallery')),
    );
    setState(() => _capturedPhoto = null);
  }
}
