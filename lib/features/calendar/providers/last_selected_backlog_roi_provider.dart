import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stores the last-selected ROI id for backlog dialog (session-scoped)
final lastSelectedBacklogRoiProvider = StateProvider<String?>((ref) => null);
