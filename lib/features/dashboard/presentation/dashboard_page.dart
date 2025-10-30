import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';

/// Vista principal que muestra progreso diario, rutina y tips personalizados.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const routeName = 'dashboard';
  static const routePath = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const FreeTTopBar(username: 'Alex'),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Resumen diario',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryCards(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Rutina de hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _DailyRoutineSection(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Estadísticas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _StatsPlaceholder(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tips personalizados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _TipsList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Registrar asistencia'),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: const <Widget>[
        _SummaryCard(title: 'Progreso', value: '82%'),
        _SummaryCard(title: 'Racha', value: '12 días'),
        _SummaryCard(title: 'Calorías', value: '540 kcal'),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyRoutineSection extends StatelessWidget {
  const _DailyRoutineSection();

  @override
  Widget build(BuildContext context) {
    final exercises = <Map<String, String>>[
      {
        'name': 'Sentadillas',
        'sets': '4',
        'reps': '12',
        'weight': '60 kg',
        'recommended': '65 kg',
      },
      {
        'name': 'Press banca',
        'sets': '3',
        'reps': '10',
        'weight': '40 kg',
        'recommended': '42 kg',
      },
      {
        'name': 'Remo con barra',
        'sets': '4',
        'reps': '12',
        'weight': '35 kg',
        'recommended': '37 kg',
      },
    ];

    return Column(
      children: exercises
          .map(
            (exercise) => Card(
              child: ListTile(
                title: Text(exercise['name'] ?? ''),
                subtitle: Text(
                  '${exercise['sets']} sets · ${exercise['reps']} reps\nActual: ${exercise['weight']} · Recomendado: ${exercise['recommended']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {},
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatsPlaceholder extends StatelessWidget {
  const _StatsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'Gráficos y métricas se integrarán aquí',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _TipsList extends StatelessWidget {
  const _TipsList();

  @override
  Widget build(BuildContext context) {
    final tips = <Map<String, String>>[
      {'title': 'Nutrición', 'content': 'Incluye proteína magra en tu comida post entreno.'},
      {'title': 'Recuperación', 'content': 'Prioriza 8h de sueño y estiramientos suaves.'},
      {'title': 'Técnica', 'content': 'Mantén la espalda neutra durante las sentadillas.'},
    ];

    return Column(
      children: tips
          .map(
            (tip) => ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(tip['title'] ?? ''),
              subtitle: Text(tip['content'] ?? ''),
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}
