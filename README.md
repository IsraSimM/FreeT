
## Documento funcional y técnico integral para app móvil en Flutter

### 1. Visión general
Aplicación móvil de bienestar y entrenamiento físico desarrollada en Flutter (iOS/Android) que combina rutinas generadas mediante IA, seguimiento del progreso diario y evaluación de ejercicios con visión por computador. La plataforma debe brindar personalización avanzada (temas, idiomas, notificaciones), integración con dispositivos externos y un diseño modular orientado a escalabilidad, rendimiento y una estética moderna.

### 2. Objetivos del producto
- Incrementar la adherencia a rutinas saludables mediante recordatorios inteligentes y tips personalizados.
- Facilitar que entrenadores y usuarios gestionen rutinas flexibles con opciones de autogeneración y edición colaborativa.
- Evaluar técnica de ejercicios en tiempo real utilizando la cámara del dispositivo y modelos ML optimizados.
- Construir una comunidad con métricas sociales, rankings y funciones de gamificación.
- Garantizar seguridad de los datos personales y cumplimiento de normativas (GDPR/CCPA).

### 3. Arquitectura de la solución
- **Framework principal**: Flutter 3.x (canal estable) con soporte multiplataforma.
- **Patrón de arquitectura**: Presentación (Flutter UI) + Dominio (casos de uso) + Datos (repositorios) para facilitar pruebas y mantenimiento.
- **Gestión de estado**: Riverpod 2.x recomendado por su inmutabilidad, modularidad y compatibilidad con proveedores asincrónicos; documentación para alternar con Bloc si el equipo lo prefiere.
- **Backend-as-a-Service**: Firebase (Auth, Cloud Firestore, Cloud Functions, Storage, Cloud Messaging, Remote Config, Analytics, Crashlytics).
- **Machine Learning**: Google ML Kit o TensorFlow Lite con modelos de pose detection personalizados ejecutados on-device; fallback en la nube si se requiere procesamiento intensivo.
- **Internacionalización**: Paquete `flutter_intl` con soporte para español, inglés y extensible a más idiomas.
- **Tematización**: Uso de `ThemeExtension` y `ColorScheme` dinámico para temas claro, oscuro y personalizado.
- **Sincronización en tiempo real**: Firestore + Streams para dashboards y rutinas con soporte offline mediante `cloud_firestore` persistence.
- **Autenticación**: Correo/contraseña, proveedores sociales (Google/Apple), y autenticación con dispositivos wearables mediante tokens seguros.
- **Infraestructura**: Configuración de entornos (dev, staging, prod) con `flutter_dotenv` y Remote Config para toggles de características.

### 4. Estructura de carpetas propuesta
```
lib/
 ├── app/                # Configuración global (tema, rutas, providers)
 ├── core/               # Constantes, utilidades, estilos, localización
 ├── data/               # Clientes, DTOs, repositorios, fuentes remotas/locales
 ├── domain/             # Entidades, casos de uso, contratos de repositorios
 ├── features/
 │    ├── dashboard/
 │    ├── routines/
 │    ├── evaluation/
 │    ├── social/
 │    └── more/
 ├── services/           # Integraciones (notificaciones, analytics, devices)
 └── main.dart
assets/
 ├── icons/
 ├── images/
 └── translations/
test/
 ├── unit/
 ├── widget/
 ├── integration/
 └── golden/
```

### 5. Navegación principal y experiencia de usuario
#### Barra superior (Top Bar)
- Esquina superior izquierda: mostrar nombre e imagen del usuario autenticado (con placeholder y esqueletos de carga).
- Esquina superior derecha:
  - Botón de notificaciones con indicador numérico y acceso a bandeja filtrable.
  - Botón de configuración que despliega modal persistente con pestañas para tema, idioma y notificaciones.

#### Barra inferior (Bottom Navigation Bar)
1. **Dashboard**
   - Pantalla de bienvenida con resumen diario, estado de cumplimiento y CTA para registrar asistencia.
   - Registro de rutina diaria con checkboxes animados, editor de pesos y sets, y comparativa con objetivos.
   - Visualización de estadísticas (gráficos lineales/barras usando `charts_flutter` o `syncfusion_flutter_charts`).
   - Tips personalizados basados en IA, hábitos y métricas históricas.
2. **Routines**
   - Listado de rutinas almacenadas en Firestore con filtros (objetivo, duración, intensidad).
   - Generación automática de rutinas vía Cloud Functions + modelo IA configurable (semanal, mensual, personalizado).
   - Editor modular (drag & drop) para modificar ejercicios, sets, repeticiones y peso recomendado.
   - Opciones para compartir/exportar (PDF, CSV, enlaces profundos) y clonar rutinas.
   - Toggles para autogeneración con programación y recordatorios calendarizados.
   - Ajustes de enfoque predefinidos (Completo, Pierna, Brazo, Cardio) y personalizados creados por el usuario.
3. **Evaluation**
   - Interfaz de cámara con overlays que guían la postura.
   - Procesamiento ML on-device para detección de articulaciones, feedback auditivo/háptico y reportes en tiempo real.
   - Registro de métricas post-evaluación (precisión, repeticiones válidas, recomendaciones de corrección).
4. **Social**
   - Rankings por rachas, pesos, calorías, puntos de experiencia y logros.
   - Perfiles sociales con estadísticas compartibles y posibilidad de crear grupos.
   - Sistema de reacciones/comentarios moderado con reportes y filtros anti-spam.
5. **More** (menú expandido)
   - Accesos directos a Dashboard, Notificaciones, Routines, Evaluation y Social.
   - **Environment**: gestión de wearables (emparejar/desvincular pulseras, HR monitors) y calibraciones.
   - **Profile**: CRUD de datos personales (altura, peso, objetivos, historial médico básico) con controles de privacidad.
   - **Settings**: ajustes de idioma, tema y notificaciones con granularidad por canal (push, email, in-app).
   - **FAQ & Support**: base de conocimiento, chat de soporte y envío de tickets.
   - **Log Out**: cierre de sesión con confirmación y opción de borrar datos locales.

### 6. Diseño visual y accesibilidad
- Implementar design system consistente con tipografías legibles, espaciados modulares y componentes reutilizables.
- Modo claro/oscuro con contraste AA mínimo y soporte para temas personalizados (paleta, tipografía, acentos).
- Animaciones suaves (Hero, Implicit Animations) sin afectar rendimiento.
- Accesibilidad: soporte para lectores de pantalla (semántica ARIA), tamaños de fuente dinámicos y gestos accesibles.
- Localización completa de cadenas, formatos de fecha/número y unidades (imperial/métrico).

### 7. Datos y modelos
- **Colecciones Firestore**:
  - `users/{userId}`: perfil, preferencias, métricas.
  - `users/{userId}/routines/{routineId}`: nombre, enfoque, ejercicios, historial.
  - `users/{userId}/workouts/{workoutId}`: registros diarios, estadísticas, feedback.
  - `leaderboards/{type}`: ranking semanal/mensual, métricas agregadas.
  - `notifications/{notificationId}`: plantillas y preferencias.
- **Reglas de Firestore**: validación de propiedad, control de lectura/escritura, roles (usuario, entrenador, admin).
- **Sincronización offline**: caché local cifrada, colas para operaciones pendientes y reconciliación de conflictos.
- **Encriptación**: uso de `flutter_secure_storage` para tokens y datos sensibles.

### 8. Integraciones externas y dispositivos
- Wearables (Bluetooth LE): lectura de ritmo cardiaco, pasos y energía; API desacoplada para soportar múltiples marcas.
- Servicios de terceros (Apple HealthKit, Google Fit) mediante permisos explícitos y sincronización programada.
- Push Notifications: FCM con topics, segmentos y campañas personalizadas.

### 9. Seguridad, privacidad y cumplimiento
- Autenticación multifactor opcional, verificación de correo y protección contra brute force.
- Cumplimiento GDPR/CCPA: consentimiento explícito, derecho a olvido, exportación de datos.
- Auditoría de sesiones y logs de seguridad (Cloud Logging/Firestore).
- Pipeline de revisión de dependencias (SCA) y firma de apps.

### 10. Rendimiento y escalabilidad
- Uso de `const` widgets, memoization y diferido de cargas pesadas.
- Lazy loading/paginación para listas grandes, caching de imágenes con `cached_network_image`.
- Compilación con `flutter build` optimizado (split per ABI, shrinker, obfuscation para release).
- Monitoreo de rendimiento con Firebase Performance y alertas.
- Estrategias de reducción de tamaño de app (descarte de assets no usados, compresión de imágenes, vectorización).

### 11. Estrategia de pruebas completa
- **Pruebas unitarias**: casos de uso, validadores, repositorios con mocks (`mocktail`). Cobertura objetivo ≥ 80%.
- **Pruebas de widgets**: componentes clave (cards de rutina, top bar, bottom nav) con `golden tests` para verificar UI.
- **Pruebas de integración**: flujos críticos (registro, generación de rutina, evaluación de ejercicio, compartir rutina) usando `integration_test`.
- **Pruebas E2E**: escenarios reales con Firebase Emulator Suite y dispositivos físicos/CI.
- **Pruebas de rendimiento**: mediciones de FPS, memoria y latencia en escenarios de carga (dashboards con datos extensos).
- **Pruebas de accesibilidad**: auditorías con `flutter_gherkin` + checklists WCAG.
- **QA manual**: plan de pruebas regresivas por release con casos documentados en herramienta de gestión.

### 12. CI/CD y automatización
- Pipeline en GitHub Actions o Codemagic con etapas:
  1. Análisis estático (`dart analyze`, `flutter format --set-exit-if-changed`, `flutter test`).
  2. Ejecución de pruebas unitarias, widget e integración en emuladores.
  3. Generación de artefactos (APK, AAB, IPA ad-hoc) y distribución interna (Firebase App Distribution/TestFlight).
  4. Despliegue controlado con Remote Config y feature flags.
- Integración de escaneo de seguridad (dependabot, OWASP dependency-check).
- Automatización de traducciones y sincronización con herramientas de diseño (Figma, Zeplin) mediante plugins.

### 13. Analítica, personalización y experimentación
- Firebase Analytics + BigQuery para análisis avanzado de cohortes.
- Remote Config para personalizar experiencias (tips, recomendaciones) según segmento.
- Soporte de A/B testing con Firebase o plataformas externas.
- Modelos de recomendación (rutinas/tips) ejecutados en Cloud Functions con programaciones periódicas.

### 14. Monitoreo y soporte operativo
- Crashlytics con alertas en canales dedicados (Slack/Teams).
- Tableros de salud del sistema (dashboards de rendimiento, fallos de ML, uso de features).
- Procedimientos de respuesta a incidentes y postmortems documentados.
- Versionado semántico y changelog para releases.

### 15. Lineamientos de código y buenas prácticas
- Seguir `Effective Dart` y convenciones de nombres consistentes.
- Documentar clases y métodos públicos con `///` y generar documentación automáticamente.
- Usar `lint`/`flutter_lints` personalizados para mantener calidad.
- Mantenibilidad: modularización por feature, uso de interfaces y providers para permitir pruebas.
- Reutilizar componentes visuales (design system) y evitar lógica en widgets puros (delegar a view models/providers).

### 16. Checklist de entregables
- Código fuente con estructura modular descrita.
- Documentación técnica (diagramas de arquitectura, flujos de datos, contratos de APIs) y manual de usuario.
- Suites de pruebas automatizadas ejecutables y reporte de cobertura.
- Configuración de CI/CD operativa con artefactos listos para distribución interna.
- Recursos de diseño (Figma) sincronizados con implementación.
- Plan de lanzamiento y soporte post-producción (KPIs, SLA, canales de atención).
