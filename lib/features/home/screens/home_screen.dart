import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:trip_planner/features/auth/providers/auth_provider.dart';

import '../../sync/services/sync_engine_service.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          ref.read(syncEngineProvider).startSync();
        } else {
          ref.read(syncEngineProvider).stopSync();
        }
      });
    });
    final theme = Theme.of(context);
    
    // Watch the authentication state to determine which button to show
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planner'),
        actions: [
          authState.when(
            data: (user) {
              final isLoggedIn = user != null;
              if (isLoggedIn) {
                // Show logout button if the user is already authenticated
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    // Make sure to use your actual auth provider's sign out method
                    await ref.read(authControllerProvider.notifier).signOut();
                  },
                );
              } else {
                // Show an opt-in login button for offline-first users
                return TextButton.icon(
                  icon: const Icon(Icons.cloud_sync),
                  label: const Text('Sign In'),
                  onPressed: () => context.push('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                );
              }
            },
            // Show a subtle loading indicator while checking auth state
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            // Hide the button gracefully if an error occurs
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Anime Pilgrimage',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plan your anime location visits',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _HomeCard(
                icon: Icons.layers,
                title: 'View POIs',
                subtitle: 'Browse and manage regions, anime, tags, POIs',
                onTap: () => context.push('/pois'),
              ),
              const SizedBox(height: 12),
              _HomeCard(
                icon: Icons.map,
                title: 'Map',
                subtitle: 'Visualize POIs on the map',
                onTap: () => context.push('/map'),
              ),
              const SizedBox(height: 12),
              _HomeCard(
                icon: Icons.calendar_month,
                title: 'Trip Calendar',
                subtitle: 'Schedule your visits',
                onTap: () => context.push('/calendar'),
              ),
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
                const SizedBox(height: 12),
                _HomeCard(
                  icon: Icons.camera_alt,
                  title: 'Anime Camera',
                  subtitle: 'AR photo overlay with reference',
                  onTap: () => context.push('/camera'),
                ),
              ],
              const SizedBox(height: 12),
              _HomeCard(
                icon: Icons.confirmation_number,
                title: 'Tickets',
                subtitle: 'QR codes & bookings',
                onTap: () => context.push('/tickets'),
              ),
              const SizedBox(height: 12),
              _HomeCard(
                icon: Icons.sync,
                title: 'Export / Import',
                subtitle: 'JSON sync between devices',
                onTap: () => context.push('/sync'),
              ),
            ],
          ),
        ),      
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
