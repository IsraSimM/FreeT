import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/free_t_top_bar.dart';

/// Pantalla de evaluación con cámara y feedback de postura.
class EvaluationPage extends ConsumerWidget {
  const EvaluationPage({super.key});

  static const routeName = 'evaluation';
  static const routePath = '/evaluation';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const FreeTTopBar(username: 'Alex'),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: const Center(
                child: Icon(Icons.camera_alt_outlined, size: 96),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Feedback en tiempo real',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text('Espalda neutra'),
                    subtitle: Text('Mantén la alineación, excelente ejecución.'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.warning_amber_outlined, color: Colors.orange),
                    title: Text('Rodillas'),
                    subtitle: Text('Evita que se vayan hacia adentro durante la bajada.'),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
