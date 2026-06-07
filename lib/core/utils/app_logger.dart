// lib/core/utils/app_logger.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// A centralized logger utility for the application.
class AppLogger {
  /// Logs an error with its associated stack trace.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? name,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'AppError',
        error: error,
        stackTrace: stackTrace,
        level: 1000, // Severe level
      );
    }
    // TODO: Integrate with Crashlytics or local file storage in the future
  }

  /// Logs general informational messages.
  static void info(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'AppInfo',
        level: 800, // Info level
      );
    }
  }
}