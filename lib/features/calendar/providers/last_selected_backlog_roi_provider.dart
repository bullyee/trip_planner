import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_selected_backlog_roi_provider.g.dart';

// Stores the last-selected ROI id for backlog dialog (session-scoped)
@riverpod
class LastSelectedBacklogRoi extends _$LastSelectedBacklogRoi {
  @override
  String? build() => null;

  void updateRoi(String? id) {
    state = id;
  }
}