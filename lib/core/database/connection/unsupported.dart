import 'package:drift/drift.dart';

/// Fallback executor if the platform is completely unrecognized.
QueryExecutor openConnection() {
  throw UnsupportedError(
    'No suitable database implementation was found on this platform.',
  );
}
