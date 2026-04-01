import 'package:flutter/material.dart';

import '../../../core/database/database.dart';

class TimeChunkCard extends StatelessWidget {
  final TimeChunk chunk;
  final String poiName;
  final ValueChanged<String> onAction;

  const TimeChunkCard({
    super.key,
    required this.chunk,
    required this.poiName,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(chunk.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
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
                      chunk.status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: onAction,
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (_) => [
                  if (chunk.status != 'completed')
                    const PopupMenuItem(
                        value: 'completed', child: Text('Complete')),
                  if (chunk.status != 'skipped')
                    const PopupMenuItem(
                        value: 'skipped', child: Text('Skip')),
                  if (chunk.status != 'backlog')
                    const PopupMenuItem(
                        value: 'backlog', child: Text('To Backlog')),
                  const PopupMenuItem(
                      value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
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
