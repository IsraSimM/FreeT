import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';

/// Gestión de rutinas personalizadas y generadas por IA.
class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  static const routeName = 'routines';
  static const routePath = '/routines';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const FreeTTopBar(username: 'Alex'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar rutinas',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_fix_high_outlined),
                  label: const Text('Generar IA'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: const <Widget>[
                Chip(label: Text('Completo')),
                Chip(label: Text('Pierna')),
                Chip(label: Text('Brazo')),
                Chip(label: Text('Cardio')),
                Chip(label: Text('Personalizado')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('Rutina ${index + 1}'),
                      subtitle: const Text('3 días · Enfoque pierna y core'),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (context) => const <PopupMenuEntry<String>>[
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'share', child: Text('Compartir')),
                          PopupMenuItem(value: 'export', child: Text('Exportar PDF')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_outlined),
        label: const Text('Nueva rutina'),
      ),
    );
  }
}
