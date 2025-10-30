import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/app_settings_controller.dart';
import '../../../app/state/user_controller.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsControllerProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          TabBar(
            controller: _controller,
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: const <Tab>[
              Tab(text: 'Tema'),
              Tab(text: 'Idioma'),
              Tab(text: 'Notificaciones'),
            ],
          ),
          SizedBox(
            height: 360,
            child: TabBarView(
              controller: _controller,
              children: <Widget>[
                _ThemeSettings(settings: settings),
                _LanguageSettings(settings: settings),
                _NotificationSettings(settings: settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ThemeSettings extends ConsumerWidget {
  const _ThemeSettings({required this.settings});

  final AppSettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Modo de tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ThemeChoice.values
                .map(
                  (choice) => ChoiceChip(
                    label: Text(choice.name.toUpperCase()),
                    selected: settings.themeChoice == choice,
                    onSelected: (value) {
                      if (value) {
                        ref.read(appSettingsControllerProvider.notifier).changeTheme(choice);
                        ref.read(userControllerProvider.notifier).updatePreferences(theme: choice.name);
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('Colores personalizados', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _ColorPreview(
                  label: 'Primario',
                  color: settings.customLightColor,
                  onTap: () => _showColorPicker(context, ref, isDark: false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ColorPreview(
                  label: 'Secundario',
                  color: settings.customDarkColor,
                  onTap: () => _showColorPicker(context, ref, isDark: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context, WidgetRef ref,
      {required bool isDark}) async {
    final colors = <Color>[
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.redAccent,
      Colors.teal,
      Colors.indigo,
    ];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona color base'),
          content: SizedBox(
            width: 300,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        if (isDark) {
                          ref
                              .read(appSettingsControllerProvider.notifier)
                              .updateCustomColors(dark: color);
                        } else {
                          ref
                              .read(appSettingsControllerProvider.notifier)
                              .updateCustomColors(light: color);
                        }
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(backgroundColor: color, radius: 24),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _LanguageSettings extends ConsumerWidget {
  const _LanguageSettings({required this.settings});

  final AppSettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = const <Locale>[
      Locale('es'),
      Locale('en'),
      Locale('pt'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Selecciona idioma', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...locales.map(
            (locale) => RadioListTile<Locale>(
              value: locale,
              groupValue: settings.locale,
              title: Text(_localeLabel(locale)),
              onChanged: (selected) {
                if (selected != null) {
                  ref.read(appSettingsControllerProvider.notifier).changeLocale(selected);
                  ref.read(userControllerProvider.notifier).updatePreferences(languageCode: selected.languageCode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _localeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Inglés';
      case 'pt':
        return 'Portugués';
      case 'es':
      default:
        return 'Español';
    }
  }
}

class _NotificationSettings extends ConsumerWidget {
  const _NotificationSettings({required this.settings});

  final AppSettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = settings.notifications;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            value: prefs.push,
            title: const Text('Push'),
            subtitle: const Text('Recibe alertas en el dispositivo'),
            onChanged: (value) {
              ref
                  .read(appSettingsControllerProvider.notifier)
                  .updateNotifications(prefs.copyWith(push: value));
            },
          ),
          SwitchListTile(
            value: prefs.email,
            title: const Text('Email'),
            subtitle: const Text('Resumen semanal y campañas'),
            onChanged: (value) {
              ref
                  .read(appSettingsControllerProvider.notifier)
                  .updateNotifications(prefs.copyWith(email: value));
            },
          ),
          SwitchListTile(
            value: prefs.inApp,
            title: const Text('In-App'),
            subtitle: const Text('Banners y recordatorios dentro de FreeT'),
            onChanged: (value) {
              ref
                  .read(appSettingsControllerProvider.notifier)
                  .updateNotifications(prefs.copyWith(inApp: value));
            },
          ),
          const Divider(height: 32),
          CheckboxListTile(
            value: prefs.dailyReminders,
            title: const Text('Recordatorios diarios'),
            onChanged: (value) {
              ref
                  .read(appSettingsControllerProvider.notifier)
                  .updateNotifications(prefs.copyWith(dailyReminders: value ?? prefs.dailyReminders));
            },
          ),
          CheckboxListTile(
            value: prefs.weeklySummary,
            title: const Text('Resumen semanal'),
            onChanged: (value) {
              ref
                  .read(appSettingsControllerProvider.notifier)
                  .updateNotifications(prefs.copyWith(weeklySummary: value ?? prefs.weeklySummary));
            },
          ),
          CheckboxListTile(
            value: prefs.personalizedTips,
            title: const Text('Tips personalizados'),
            onChanged: (value) {
              ref
                  .read(appSettingsControllerProvider.notifier)
                  .updateNotifications(prefs.copyWith(personalizedTips: value ?? prefs.personalizedTips));
            },
          ),
        ],
      ),
    );
  }
}
