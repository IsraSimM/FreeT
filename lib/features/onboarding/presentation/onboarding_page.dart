import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/state/app_settings_controller.dart';
import '../../../app/state/user_controller.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../services/auth/auth_guard.dart';
import '../../dashboard/presentation/dashboard_page.dart';

/// Pantalla de onboarding inicial con accesos a configuración básica.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const routeName = 'onboarding';
  static const routePath = '/onboarding';

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool _devicesConnected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu experiencia'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: <Widget>[
            LinearProgressIndicator(value: (_currentIndex + 1) / 4),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _LanguageStep(onSelected: _onLanguageSelected, current: settings.locale),
                  _ThemeStep(onSelected: _onThemeSelected, current: settings.themeChoice),
                  _DevicesStep(
                    connected: _devicesConnected,
                    onToggle: (value) => setState(() => _devicesConnected = value),
                  ),
                  _SummaryStep(settings: settings, devicesConnected: _devicesConnected),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                if (_currentIndex > 0)
                  TextButton(
                    onPressed: _previous,
                    child: const Text('Atrás'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _currentIndex == 3 ? _finish : _next,
                  child: Text(_currentIndex == 3 ? 'Finalizar' : 'Siguiente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onLanguageSelected(Locale locale) {
    ref.read(appSettingsControllerProvider.notifier).changeLocale(locale);
    ref.read(userControllerProvider.notifier).updatePreferences(languageCode: locale.languageCode);
  }

  void _onThemeSelected(ThemeChoice choice) {
    ref.read(appSettingsControllerProvider.notifier).changeTheme(choice);
    ref.read(userControllerProvider.notifier).updatePreferences(theme: choice.name);
  }

  void _next() {
    if (_currentIndex < 3) {
      setState(() => _currentIndex += 1);
      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex -= 1);
      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;
    if (mounted) {
      context.go(DashboardPage.routePath);
    }
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({required this.onSelected, required this.current});

  final ValueChanged<Locale> onSelected;
  final Locale current;

  @override
  Widget build(BuildContext context) {
    final locales = const <Locale>[Locale('es'), Locale('en'), Locale('pt')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('¿En qué idioma quieres usar FreeT?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...locales.map(
          (locale) => RadioListTile<Locale>(
            value: locale,
            groupValue: current,
            title: Text(_label(locale)),
            onChanged: (selected) {
              if (selected != null) {
                onSelected(selected);
              }
            },
          ),
        ),
      ],
    );
  }

  String _label(Locale locale) {
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

class _ThemeStep extends StatelessWidget {
  const _ThemeStep({required this.onSelected, required this.current});

  final ValueChanged<ThemeChoice> onSelected;
  final ThemeChoice current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Selecciona un tema visual', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: ThemeChoice.values
              .map(
                (choice) => ChoiceChip(
                  label: Text(choice.name.toUpperCase()),
                  selected: choice == current,
                  onSelected: (value) {
                    if (value) {
                      onSelected(choice);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DevicesStep extends StatelessWidget {
  const _DevicesStep({required this.connected, required this.onToggle});

  final bool connected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Conecta tus dispositivos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          value: connected,
          title: const Text('Sincronizar FreeT Band Pro'),
          subtitle: const Text('Recoge frecuencia cardiaca y pasos en tiempo real'),
          onChanged: onToggle,
        ),
        SwitchListTile(
          value: connected,
          title: const Text('Sincronizar sensor de postura'),
          subtitle: const Text('Recibe feedback avanzado durante tus rutinas'),
          onChanged: onToggle,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_link),
          label: const Text('Configurar manualmente'),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.settings, required this.devicesConnected});

  final AppSettingsState settings;
  final bool devicesConnected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Todo listo', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Idioma'),
          subtitle: Text(settings.locale.languageCode.toUpperCase()),
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Tema'),
          subtitle: Text(settings.themeChoice.name.toUpperCase()),
        ),
        ListTile(
          leading: const Icon(Icons.watch_outlined),
          title: const Text('Dispositivos conectados'),
          subtitle: Text(devicesConnected ? 'Band Pro y sensor de postura' : 'Pendiente de configurar'),
        ),
        const Spacer(),
        const Text('Podrás ajustar estas preferencias en cualquier momento desde la sección More > Settings.'),
      ],
    );
  }
}
