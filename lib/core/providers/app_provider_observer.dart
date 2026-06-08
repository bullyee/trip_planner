// lib/core/providers/app_provider_observer.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

/// Observes all state changes and errors across Riverpod providers.
class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Provider failed to update its state',
      error: error,
      stackTrace: stackTrace,
      name: 'ProviderObserver [${provider.name ?? provider.runtimeType}]',
    );
  }

  // Optional: You can also override didUpdateProvider to track state changes
  // if you need to debug how data flows during your sync process.
}