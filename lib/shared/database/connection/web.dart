import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens a WebAssembly SQLite3 database connection with strict OPFS support.
/// Throws an [UnsupportedError] if the browser lacks the required features.
QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'trip_planner_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    // Strictly enforce the presence of all required OPFS features.
    // Throw an exception immediately instead of silently logging or degrading.
    if (result.missingFeatures.isNotEmpty) {
      throw UnsupportedError(
        'Critical setup failure: The current browser environment lacks required '
        'features for OPFS Wasm SQLite execution. Ensure Cross-Origin Isolation '
        'headers are properly configured. Missing features: ${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  }));
}