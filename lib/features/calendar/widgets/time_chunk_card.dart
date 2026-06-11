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
    
    // 0 = synced, 1 = dirty, 2 = stashed
    final bool isStashed = chunk.syncStatus == 2;
    final bool isDirty = chunk.syncStatus == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: isStashed ? theme.colorScheme.errorContainer : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isStashed 
                ? BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5), width: 1.5)
                : BorderSide.none,
          ),
          elevation: isStashed ? 0 : 1,
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
                            color: isStashed ? theme.colorScheme.error : null,
                          ),
                        ),
                        Text(
                          chunk.endTime ?? '--:--',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isStashed 
                                ? theme.colorScheme.error.withValues(alpha: 0.7)
                                : theme.colorScheme.onSurfaceVariant,
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
                      color: isStashed ? theme.colorScheme.error : statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                poiName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isStashed ? theme.colorScheme.onErrorContainer : null,
                                  decoration: chunk.status == 'completed'
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isStashed)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Tooltip(
                                  message: '發生版本衝突。請將此積木重新拖回日曆以保留您的修改。',
                                  child: Icon(Icons.warning_rounded, size: 16, color: theme.colorScheme.error),
                                ),
                              )
                            else if (isDirty)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Tooltip(
                                  message: '尚未同步至雲端',
                                  child: Icon(Icons.cloud_upload_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          isStashed ? 'CONFLICT (STASHED)' : (chunk.status ?? 'backlog').toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isStashed ? theme.colorScheme.error : statusColor,
                            fontWeight: isStashed ? FontWeight.bold : FontWeight.normal,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isStashed) ...[
                    IconButton(
                      icon: const Icon(Icons.timer_outlined, size: 20),
                      tooltip: 'Adjust Duration',
                      onPressed: () => onAction('edit_duration'),
                    ),
                    IconButton(
                      icon: Icon(
                        chunk.isFixedTime ? Icons.lock : Icons.lock_open,
                        size: 20,
                        color: chunk.isFixedTime 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: chunk.isFixedTime ? 'Unlock Time' : 'Lock Time',
                      onPressed: () => onAction('toggle_fixed'),
                    ),
                  ],
                  PopupMenuButton<String>(
                    onSelected: onAction,
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (_) => [
                      if (chunk.status != 'scheduled' && !isStashed)
                        const PopupMenuItem(
                          value: 'scheduled', child: Text('Schedule'),
                        ),
                      if (chunk.status != 'completed' && !isStashed)
                        const PopupMenuItem(
                            value: 'completed', child: Text('Complete')),
                      if (chunk.status != 'skipped' && !isStashed)
                        const PopupMenuItem(
                            value: 'skipped', child: Text('Skip')),
                      if (chunk.status != 'backlog')
                        const PopupMenuItem(
                            value: 'backlog', child: Text('To Backlog')),
                      const PopupMenuDivider(),
                      if (!isStashed)
                        const PopupMenuItem(
                            value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete', child: Text(
                            'Delete', 
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  ),

                  if (!chunk.isFixedTime)
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.drag_handle, 
                          size: 24, 
                          color: isStashed 
                              ? theme.colorScheme.error 
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.drag_handle, 
                        size: 24, 
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Transit UI
        if (chunk.status == 'scheduled' && !isStashed)
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