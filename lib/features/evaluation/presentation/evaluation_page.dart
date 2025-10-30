import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/user_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../../settings/presentation/settings_sheet.dart';
import '../application/evaluation_controller.dart';

/// Pantalla de evaluación con cámara y feedback de postura.
class EvaluationPage extends ConsumerWidget {
  const EvaluationPage({super.key});

  static const routeName = 'evaluation';
  static const routePath = '/evaluation';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(evaluationControllerProvider);
    final controller = ref.read(evaluationControllerProvider.notifier);
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
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surfaceVariant,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Icon(Icons.camera_alt_outlined, size: 96),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Chip(
                        avatar: const Icon(Icons.timelapse_outlined),
                        label: Text('Fase: ${state.phase.name.toUpperCase()}'),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Chip(
                        avatar: const Icon(Icons.timer_outlined),
                        label: Text('${state.elapsedSeconds}s'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: EvaluationCue.values
                  .map(
                    (cue) => FilterChip(
                      label: Text(_cueLabel(cue)),
                      selected: state.cues.contains(cue),
                      onSelected: (_) => controller.toggleCue(cue),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.phase == EvaluationPhase.recording
                        ? controller.finishSession
                        : controller.startSession,
                    icon: Icon(
                      state.phase == EvaluationPhase.recording
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                    ),
                    label: Text(state.phase == EvaluationPhase.recording ? 'Finalizar' : 'Iniciar evaluación'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.reset,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Restablecer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.phase == EvaluationPhase.reviewing
                    ? _EvaluationSummary(metrics: state.metrics)
                    : _LiveFeedback(phase: state.phase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cueLabel(EvaluationCue cue) {
    switch (cue) {
      case EvaluationCue.posture:
        return 'Postura';
      case EvaluationCue.range:
        return 'Rango';
      case EvaluationCue.speed:
        return 'Ritmo';
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

class _LiveFeedback extends StatelessWidget {
  const _LiveFeedback({required this.phase});

  final EvaluationPhase phase;

  @override
  Widget build(BuildContext context) {
    final feedbackItems = <_FeedbackItem>[
      const _FeedbackItem(
        icon: Icons.check_circle_outline,
        title: 'Espalda neutra',
        description: 'Mantén la alineación, excelente ejecución.',
        color: Colors.green,
      ),
      const _FeedbackItem(
        icon: Icons.warning_amber_outlined,
        title: 'Rodillas',
        description: 'Evita que se proyecten hacia adentro durante la bajada.',
        color: Colors.orange,
      ),
      const _FeedbackItem(
        icon: Icons.tips_and_updates_outlined,
        title: 'Cadencia',
        description: 'Controla la velocidad de bajada a 2s y subida a 1s.',
        color: Colors.blueAccent,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          phase == EvaluationPhase.recording
              ? 'Feedback en vivo'
              : 'Listo para empezar, ajusta postura y luz.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: feedbackItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = feedbackItems[index];
              return ListTile(
                leading: Icon(item.icon, color: item.color),
                title: Text(item.title),
                subtitle: Text(item.description),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EvaluationSummary extends StatelessWidget {
  const _EvaluationSummary({required this.metrics});

  final List<EvaluationMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Resumen de sesión', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: metrics.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return ListTile(
                title: Text(metric.label),
                subtitle: Text(metric.value),
                trailing: Chip(
                  label: Text('${(metric.score * 100).round()}%'),
                  avatar: const Icon(Icons.assessment_outlined),
                ),
              );
            },
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar en historial'),
        ),
      ],
    );
  }
}

class _FeedbackItem {
  const _FeedbackItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}
