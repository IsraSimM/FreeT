import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/auth/auth_guard.dart';
import '../../dashboard/presentation/dashboard_page.dart';

/// Pantalla de onboarding inicial con accesos a configuración básica.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const routeName = 'onboarding';
  static const routePath = '/onboarding';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Bienvenido a FreeT',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Configura tus preferencias iniciales, conecta dispositivos y prepara tu primera rutina personalizada.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Comenzar'),
                onPressed: () {
                  ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;
                  context.go(DashboardPage.routePath);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.language),
                label: const Text('Cambiar idioma'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
