import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/time_chunk_model.dart';

class TimeChunkCard extends StatelessWidget {
  final TimeChunkModel chunk;
  final String poiName;
  final ValueChanged<String> onAction;
  final int index;

  const TimeChunkCard({
    super.key,
    required this.chunk,
    required this.poiName,
    required this.onAction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(chunk.status ?? 'backlog');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/pois/${chunk.poiId}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Time column
                  SizedBox(
                    width: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chunk.startTime ?? '--:--',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          chunk.endTime ?? '--:--',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status bar
                  Container(
                    width: 4,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poiName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: chunk.status == 'completed'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          (chunk.status ?? 'backlog').toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  IconButton(
                    icon: const Icon(Icons.timer_outlined, size: 20),
                    tooltip: 'Adjust Duration',
                    onPressed: () => onAction('edit_duration'),
                  ),
                  PopupMenuButton<String>(
                    onSelected: onAction,
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (_) => [
                      if (chunk.status != 'scheduled')
                        const PopupMenuItem(
                          value: 'scheduled', child: Text('Schedule'),
                        ),
                      if (chunk.status != 'completed')
                        const PopupMenuItem(
                            value: 'completed', child: Text('Complete')),
                      if (chunk.status != 'skipped')
                        const PopupMenuItem(
                            value: 'skipped', child: Text('Skip')),
                      if (chunk.status != 'backlog')
                        const PopupMenuItem(
                            value: 'backlog', child: Text('To Backlog')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                  ),

                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.drag_handle, 
                        size: 24, 
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (chunk.status == 'scheduled')
          Padding(
            padding: const EdgeInsets.only(left: 36.0, top: 4.0, bottom: 4.0),
            child: Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Container(
                  width: 2,
                  height: 20,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => onAction('edit_transit'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      chunk.transitDuration == 0 
                          ? 'Add Transit Time' 
                          : 'Transit: ${chunk.transitDuration} min',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chunk.transitDuration == 0 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'completed' => Colors.green,
      'scheduled' => Colors.blue,
      'skipped' => Colors.orange,
      _ => Colors.grey,
    };
  }
}
