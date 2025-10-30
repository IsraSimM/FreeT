import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/app_settings_controller.dart';
import '../../../app/state/user_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';
import '../../../domain/entities/dashboard_snapshot.dart';
import '../../../domain/entities/routine.dart';
import '../../../domain/entities/tip.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../../settings/presentation/settings_sheet.dart';
import '../application/dashboard_controller.dart';

/// Vista principal que muestra progreso diario, rutina y tips personalizados.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const routeName = 'dashboard';
  static const routePath = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final dashboardController = ref.read(dashboardControllerProvider.notifier);
    final userState = ref.watch(userControllerProvider);

    final username = userState.maybeWhen(
      data: (profile) => profile.displayName,
      orElse: () => 'FreeT',
    );
    final photoUrl = userState.asData?.value.photoUrl;

    return Scaffold(
      appBar: FreeTTopBar(
        username: username,
        photoUrl: photoUrl,
        onNotificationsPressed: () => _openNotifications(context),
        onSettingsPressed: () => _openSettings(context),
      ),
      body: RefreshIndicator(
        onRefresh: dashboardController.refresh,
        child: dashboardState.snapshot.when(
          data: (snapshot) {
            return CustomScrollView(
              slivers: <Widget>[
                if (dashboardState.attendanceJustRegistered)
                  const SliverToBoxAdapter(
                    child: _AttendanceBanner(),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        _SummarySection(summary: snapshot.summary),
                        const SizedBox(height: AppSpacing.lg),
                        _RoutineSection(routine: snapshot.todaysRoutine),
                        const SizedBox(height: AppSpacing.lg),
                        _StatsSection(stats: snapshot.weeklyStats),
                        const SizedBox(height: AppSpacing.lg),
                        _GoalsSection(goals: snapshot.goals),
                        const SizedBox(height: AppSpacing.lg),
                        _TipsSection(tips: snapshot.tips),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _DashboardError(
            message: 'No pudimos cargar tu información. Intenta nuevamente.',
            onRetry: dashboardController.load,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: dashboardState.isRefreshing ? null : dashboardController.registerAttendance,
        icon: const Icon(Icons.check_circle_outline),
        label: Text(dashboardState.attendanceJustRegistered ? 'Asistencia registrada' : 'Registrar asistencia'),
      ),
    );
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

class _AttendanceBanner extends ConsumerWidget {
  const _AttendanceBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.emoji_events_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              locale.languageCode == 'en'
                  ? 'Streak updated! Keep the momentum going.'
                  : '¡Racha actualizada! Sigue con ese impulso.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _SummaryCard(
        title: 'Progreso diario',
        value: '${(summary.completion * 100).round()}%',
        subtitle: 'Objetivo completado',
        icon: Icons.task_alt,
      ),
      _SummaryCard(
        title: 'Racha activa',
        value: '${summary.activeStreak} días',
        subtitle: 'Sin ausencias',
        icon: Icons.local_fire_department_outlined,
      ),
      _SummaryCard(
        title: 'Calorías',
        value: '${summary.calories} kcal',
        subtitle: 'Estimado de hoy',
        icon: Icons.local_fire_department,
      ),
      _SummaryCard(
        title: 'Readiness',
        value: '${summary.readinessScore.round()}%',
        subtitle: 'Recuperación',
        icon: Icons.bolt_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Resumen diario', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: cards,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineSection extends ConsumerWidget {
  const _RoutineSection({required this.routine});

  final List<RoutineExercise> routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Rutina de hoy', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              onPressed: () => ref.read(dashboardControllerProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Actualizar'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...routine.map(
          (exercise) => Card(
            child: ListTile(
              title: Text(exercise.name),
              subtitle: Text(
                '${exercise.sets} sets · ${exercise.reps} reps',
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    exercise.weight != null
                        ? '${exercise.weight!.toStringAsFixed(1)} kg'
                        : 'Peso libre',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (exercise.recommendedWeight != null)
                    Text(
                      'Recomendado: ${exercise.recommendedWeight!.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final List<TrendStat> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Estadísticas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: stats
              .map(
                (stat) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(stat.label, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: (stat.latestValue / stat.goalValue).clamp(0, 1),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Último valor: ${stat.latestValue.toStringAsFixed(1)} ${stat.unit}'),
                          Text('Meta: ${stat.goalValue.toStringAsFixed(1)} ${stat.unit}'),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals});

  final List<GoalProgress> goals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Metas activas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...goals.map(
          (goal) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(goal.name, style: Theme.of(context).textTheme.titleMedium),
                      Text('${(goal.completion * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(value: goal.completion),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Actual: ${goal.current.toStringAsFixed(1)} ${goal.unit}'),
                  Text('Meta: ${goal.target.toStringAsFixed(1)} ${goal.unit}'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection({required this.tips});

  final List<Tip> tips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Tips personalizados', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...tips.map(
          (tip) => Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(tip.category.name.isNotEmpty
                    ? tip.category.name[0].toUpperCase()
                    : '?'),
              ),
              title: Text(tip.title),
              subtitle: Text(tip.description),
              trailing: tip.ctaLabel != null ? TextButton(onPressed: () {}, child: Text(tip.ctaLabel!)) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
