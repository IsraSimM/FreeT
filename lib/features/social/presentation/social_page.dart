import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';

/// Espacio social con rankings y actividad de la comunidad.
class SocialPage extends ConsumerWidget {
  const SocialPage({super.key});

  static const routeName = 'social';
  static const routePath = '/social';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const FreeTTopBar(username: 'Alex'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Rankings activos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                children: const <Widget>[
                  _LeaderboardCard(
                    title: 'Rachas',
                    description: 'Usuarios con más días consecutivos entrenando.',
                  ),
                  _LeaderboardCard(
                    title: 'Peso levantado',
                    description: 'Mayor tonelaje acumulado semanal.',
                  ),
                  _LeaderboardCard(
                    title: 'Cardio',
                    description: 'Minutos dedicados a cardio en la última semana.',
                  ),
                ],
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
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: const <Widget>[
                CircleAvatar(child: Text('AM')),
                SizedBox(width: AppSpacing.sm),
                CircleAvatar(child: Text('LC')),
                SizedBox(width: AppSpacing.sm),
                CircleAvatar(child: Text('PR')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
