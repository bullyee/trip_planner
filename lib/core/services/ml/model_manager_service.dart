// --- Code/Comments must be in English ---
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class CutoutStrategy {
  Future<void> initialize();
  Future<String> processImage(String imagePath);
}

class LocalOnnxCutoutStrategy implements CutoutStrategy {
  @override
  Future<void> initialize() async {
    // 1. Check if model exists in application documents directory
    // 2. If not, download from cloud storage (e.g., Firebase Storage)
    // 3. Load model into memory
  }

  @override
  Future<String> processImage(String imagePath) async {
    // Execute local ONNX inference
    return 'path/to/processed_image.png';
  }
}

class CloudApiCutoutStrategy implements CutoutStrategy {
  @override
  Future<void> initialize() async {
    // Check network connectivity and API token validity
  }

  @override
  Future<String> processImage(String imagePath) async {
    // Send image to a backend service or Firebase Cloud Function
    // Return the URL or local cached path of the processed image
    return 'url/to/processed_image.png';
  }
}

class CutoutServiceFactory {
  static CutoutStrategy create() {
    if (kIsWeb) {
      // Force Web platform to use Cloud API due to WASM memory constraints
      return CloudApiCutoutStrategy();
    } else {
      // Mobile/Desktop platforms can utilize local hardware acceleration
      return LocalOnnxCutoutStrategy();
    }
  }
}