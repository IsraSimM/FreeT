import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/user_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';
import '../../../domain/entities/leaderboard.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../../settings/presentation/settings_sheet.dart';
import '../application/social_controller.dart';

/// Espacio social con rankings y actividad de la comunidad.
class SocialPage extends ConsumerWidget {
  const SocialPage({super.key});

  static const routeName = 'social';
  static const routePath = '/social';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socialControllerProvider);
    final controller = ref.read(socialControllerProvider.notifier);
    final userState = ref.watch(userControllerProvider);
    final username = userState.maybeWhen(
      data: (profile) => profile.displayName,
      orElse: () => 'FreeT',
    );

    return Scaffold(
      appBar: FreeTTopBar(
        username: username,
        onNotificationsPressed: () => _openNotifications(context),
        onSettingsPressed: () => _openSettings(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Rankings activos', style: Theme.of(context).textTheme.titleLarge),
                SegmentedButton<LeaderboardType>(
                  segments: LeaderboardType.values
                      .map(
                        (type) => ButtonSegment<LeaderboardType>(
                          value: type,
                          label: Text(_leaderboardLabel(type)),
                        ),
                      )
                      .toList(),
                  selected: <LeaderboardType>{state.selectedType},
                  onSelectionChanged: (selection) =>
                      controller.loadLeaderboard(selection.first),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: state.snapshot.when(
                data: (snapshot) {
                  return ListView.separated(
                    itemCount: snapshot.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = snapshot.entries[index];
                      return _LeaderboardTile(entry: entry, position: index + 1);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('No pudimos cargar los rankings'),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () => controller.loadLeaderboard(state.selectedType),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Invitar amigos'),
      ),
    );
  }

  String _leaderboardLabel(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.streak:
        return 'Rachas';
      case LeaderboardType.weightLifted:
        return 'Peso';
      case LeaderboardType.cardioMinutes:
        return 'Cardio';
      case LeaderboardType.communityScore:
        return 'Comunidad';
    }
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NotificationsSheet(),
    );
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SettingsSheet(),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, required this.position});

  final LeaderboardEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1 * position),
          child: Text(position.toString()),
        ),
        title: Text(entry.displayName),
        subtitle: Text('Puntaje: ${entry.value.toStringAsFixed(0)} (+${entry.delta.toStringAsFixed(0)})'),
        trailing: Icon(
          position == 1
              ? Icons.emoji_events_outlined
              : Icons.military_tech_outlined,
        ),
      ),
    );
  }
}
