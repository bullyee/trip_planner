import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../roi/providers/roi_provider.dart';

class RoiFilterBar extends ConsumerWidget {
  final String? selectedRoiId;
  final ValueChanged<String?> onChanged;

  const RoiFilterBar({
    super.key,
    required this.selectedRoiId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roisAsync = ref.watch(allRoisProvider);

    return roisAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => SizedBox(
        height: 56,
        child: Center(child: Text('Error: $err')),
      ),
      data: (rois) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: selectedRoiId == null,
              onSelected: (_) => onChanged(null),
            ),
            const SizedBox(width: 8),
            ...rois.map((roi) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(roi.name),
                    selected: selectedRoiId == roi.id,
                    onSelected: (_) => onChanged(roi.id),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
