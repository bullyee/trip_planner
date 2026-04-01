import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm;

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

final _ticketAssetsProvider = StreamProvider<List<MediaAsset>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.mediaAssets)
        ..where((m) => m.type.equals('ticket_qr'))
        ..orderBy([(m) => OrderingTerm.desc(m.id)]))
      .watch();
});

class TicketScreen extends ConsumerWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(_ticketAssetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.confirmation_number,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No tickets yet'),
                  const SizedBox(height: 4),
                  Text(
                    'Add QR codes from a POI detail screen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.qr_code_2, size: 40),
                  title: Text(ticket.localUri.split('/').last),
                  subtitle: ticket.metadata != null
                      ? Text(ticket.metadata!)
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final db = ref.read(databaseProvider);
                      db.deleteMediaAsset(ticket.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
