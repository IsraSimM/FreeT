import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/app_settings_controller.dart';
import '../../../app/state/user_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/free_t_top_bar.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../services/auth/auth_repository.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../../settings/presentation/settings_sheet.dart';

/// Menú extendido con accesos a módulos secundarios.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  static const routeName = 'more';
  static const routePath = '/more';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final settings = ref.watch(appSettingsControllerProvider);
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
      body: userState.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            _ProfileHeader(profile: profile),
            const SizedBox(height: AppSpacing.lg),
            _DevicesSection(devices: profile.devices),
            const SizedBox(height: AppSpacing.lg),
            _SettingsSection(settings: settings),
            const SizedBox(height: AppSpacing.lg),
            _SupportSection(onLogout: () => _logout(ref, context)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('No pudimos cargar tu perfil'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => ref.read(userControllerProvider.notifier).load(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
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

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada correctamente')),
      );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
                  child: profile.photoUrl == null
                      ? Text(profile.displayName.isNotEmpty ? profile.displayName[0] : '?')
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(profile.displayName, style: Theme.of(context).textTheme.titleMedium),
                      Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricTile(
                    label: 'Peso',
                    value: '${profile.weightKg.toStringAsFixed(1)} kg',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricTile(
                    label: 'Altura',
                    value: '${profile.heightCm.toStringAsFixed(0)} cm',
                    icon: Icons.height,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _DevicesSection extends StatelessWidget {
  const _DevicesSection({required this.devices});

  final List<UserDevice> devices;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Dispositivos vinculados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (devices.isEmpty)
              const Text('Sin dispositivos conectados'),
            ...devices.map(
              (device) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: device.isActive,
                title: Text(device.name),
                subtitle: Text('Tipo: ${device.type.name}'),
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_link),
              label: const Text('Vincular nuevo dispositivo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection({required this.settings});

  final AppSettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = settings.notifications;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Preferencias', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: const Text('Idioma'),
              subtitle: Text(settings.locale.languageCode.toUpperCase()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (_) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SettingsSheet(),
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: prefs.personalizedTips,
              title: const Text('Tips personalizados'),
              onChanged: (value) {
                ref.read(appSettingsControllerProvider.notifier).updateNotifications(
                      prefs.copyWith(personalizedTips: value),
                    );
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: prefs.dailyReminders,
              title: const Text('Recordatorios diarios'),
              onChanged: (value) {
                ref.read(appSettingsControllerProvider.notifier).updateNotifications(
                      prefs.copyWith(dailyReminders: value),
                    );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Telemetría y analítica'),
              subtitle: const Text('Configura métricas y paneles personalizados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Soporte', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('FAQ & Tickets'),
              subtitle: const Text('Consulta la base de conocimiento o levanta un caso'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
