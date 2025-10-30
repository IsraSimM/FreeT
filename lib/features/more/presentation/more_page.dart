import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';

/// Menú extendido con accesos a módulos secundarios.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  static const routeName = 'more';
  static const routePath = '/more';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const FreeTTopBar(username: 'Alex'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const <Widget>[
          _MoreSection(
            title: 'Principal',
            items: <_MoreItem>[
              _MoreItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
              _MoreItem(icon: Icons.notifications_outlined, label: 'Notificaciones'),
            ],
          ),
          _MoreSection(
            title: 'Entrenamiento',
            items: <_MoreItem>[
              _MoreItem(icon: Icons.fitness_center_outlined, label: 'Routines'),
              _MoreItem(icon: Icons.camera_alt_outlined, label: 'Evaluation'),
            ],
          ),
          _MoreSection(
            title: 'Dispositivos y entorno',
            items: <_MoreItem>[
              _MoreItem(icon: Icons.watch_outlined, label: 'Environment'),
              _MoreItem(icon: Icons.sensors_outlined, label: 'Wearables'),
            ],
          ),
          _MoreSection(
            title: 'Perfil y configuración',
            items: <_MoreItem>[
              _MoreItem(icon: Icons.person_outline, label: 'Profile'),
              _MoreItem(icon: Icons.settings_outlined, label: 'Settings'),
              _MoreItem(icon: Icons.help_outline, label: 'FAQ'),
            ],
          ),
          _MoreSection(
            title: 'Sesión',
            items: <_MoreItem>[
              _MoreItem(icon: Icons.logout, label: 'Log Out'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreSection extends StatelessWidget {
  const _MoreSection({required this.title, required this.items});

  final String title;
  final List<_MoreItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
