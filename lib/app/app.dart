import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'localization/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

final _appRouterProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});

/// Widget raíz de la aplicación FreeT.
class FreeTApp extends ConsumerWidget {
  const FreeTApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'FreeT',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.delegates,
    );
  }
}
