import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/user_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';
import '../../../domain/entities/routine.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../../settings/presentation/settings_sheet.dart';
import '../application/routines_controller.dart';

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  static const routeName = 'routines';
  static const routePath = '/routines';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesState = ref.watch(routinesControllerProvider);
    final routinesController = ref.read(routinesControllerProvider.notifier);
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
                Text('Tus rutinas', style: Theme.of(context).textTheme.titleLarge),
                FilledButton.icon(
                  onPressed: routinesState.isGenerating
                      ? null
                      : () => routinesController.generateRoutine(routinesState.focusFilter),
                  icon: routinesState.isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(routinesState.isGenerating ? 'Generando...' : 'Generar IA'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RoutineFocusFilter.values
                    .map(
                      (focus) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(_focusLabel(focus)),
                          selected: routinesState.focusFilter == focus,
                          onSelected: (_) => routinesController.changeFocus(focus),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: routinesState.autogenerationEnabled,
              title: const Text('Autogeneración de rutinas'),
              subtitle: const Text('Programa nuevas rutinas en función de tus objetivos'),
              onChanged: routinesController.toggleAutogeneration,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: routinesState.autogenerationEnabled
                  ? Row(
                      children: <Widget>[
                        const Text('Frecuencia:'),
                        const SizedBox(width: AppSpacing.sm),
                        DropdownButton<AutogenerationFrequency>(
                          value: routinesState.frequency,
                          items: AutogenerationFrequency.values
                              .map(
                                (frequency) => DropdownMenuItem<AutogenerationFrequency>(
                                  value: frequency,
                                  child: Text(_frequencyLabel(frequency)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              routinesController.changeFrequency(value);
                            }
                          },
                        ),
                        const Spacer(),
                        if (routinesState.lastGenerated != null)
                          Text('Última: ${_relativeTime(routinesState.lastGenerated!)}'),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: routinesState.routines.when(
                data: (routines) {
                  final filtered = routinesController.filteredRoutines();
                  if (filtered.isEmpty) {
                    return const _EmptyState();
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final routine = filtered[index];
                      return _RoutineCard(routine: routine);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _RoutineError(
                  onRetry: routinesController.load,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _focusLabel(RoutineFocusFilter filter) {
    switch (filter) {
      case RoutineFocusFilter.full:
        return 'Completo';
      case RoutineFocusFilter.leg:
        return 'Pierna';
      case RoutineFocusFilter.arm:
        return 'Brazo';
      case RoutineFocusFilter.cardio:
        return 'Cardio';
      case RoutineFocusFilter.custom:
        return 'Personalizado';
      case RoutineFocusFilter.all:
      default:
        return 'Todos';
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

  String _frequencyLabel(AutogenerationFrequency frequency) {
    switch (frequency) {
      case AutogenerationFrequency.weekly:
        return 'Semanal';
      case AutogenerationFrequency.monthly:
        return 'Mensual';
      case AutogenerationFrequency.custom:
        return 'Personalizado';
    }
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h';
    }
    return '${difference.inDays} d';
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(routine.name),
        subtitle: Text(routine.focus),
        leading: const Icon(Icons.fitness_center_outlined),
        children: routine.exercises
            .map(
              (exercise) => ListTile(
                title: Text(exercise.name),
                subtitle: Text('${exercise.sets}x${exercise.reps}'),
                trailing: exercise.weight != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('${exercise.weight?.toStringAsFixed(1)} kg'),
                          if (exercise.recommendedWeight != null)
                            Text(
                              'Recomendado: ${exercise.recommendedWeight?.toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      )
                    : const Text('Peso libre'),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RoutineError extends StatelessWidget {
  const _RoutineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('No fue posible cargar tus rutinas.'),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.inbox_outlined, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text('Aún no tienes rutinas con este enfoque',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Genera una nueva rutina o cambia el filtro para ver más opciones.'),
        ],
      ),
    );
  }
}
