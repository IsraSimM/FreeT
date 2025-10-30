import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Delegados mínimos necesarios para configurar internacionalización.
class AppLocalizations {
  const AppLocalizations._();

  /// Locales soportados inicialmente por la app.
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Delegados estándar hasta integrar ARB generados.
  static const delegates = <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
