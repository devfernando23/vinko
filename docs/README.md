# Documentación de Vinko

**Vinko — Qué hacer, justo en el momento.** Guía para padres de niños tímidos (3 a 10 años): cuando ocurre una situación difícil, la app da una instrucción a la vez, corta y accionable, para que el padre sepa qué hacer en ese instante.

## Índice de features

| Documento | Feature | Ruta(s) |
|---|---|---|
| [onboarding.md](onboarding.md) | Alta y edición del perfil del niño | `/onboarding` |
| [home.md](home.md) | Pantalla principal | `/` |
| [situaciones.md](situaciones.md) | Catálogo y selector de situaciones | `/situations` |
| [guia-en-vivo.md](guia-en-vivo.md) | Guía en vivo, cierre y celebración | `/live/:id`, `/closure`, `/celebration` |
| [misiones.md](misiones.md) | Coach: misión semanal, práctica en casa, tip del día | Home y Progreso |
| [progreso.md](progreso.md) | Racha, pasos logrados y actividad semanal | `/progress` |
| [insignias.md](insignias.md) | Insignias de identidad | `/badges` |
| [recompensas.md](recompensas.md) | Configuración de la celebración | `/rewards` |
| [ajustes.md](ajustes.md) | Ajustes generales | `/settings` |
| [pendientes-y-sugerencias.md](pendientes-y-sugerencias.md) | Trabajo pendiente y mejoras propuestas | — |

## Arquitectura general

- **Flutter** con SDK Dart `^3.11.5`.
- **Estado**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod). Todos los providers viven en [app_state.dart](../lib/core/state/app_state.dart).
- **Navegación**: [go_router](https://pub.dev/packages/go_router). Las rutas se definen en [router.dart](../lib/app/router.dart). Un `redirect` global manda a `/onboarding` si todavía no existe perfil.
- **Persistencia**: [shared_preferences](https://pub.dev/packages/shared_preferences), 100 % local al dispositivo. La instancia se carga en [main.dart](../lib/main.dart) y se inyecta con `sharedPrefsProvider.overrideWithValue(...)`.
- **Contenido**: los guiones viven en [assets/content/situations.json](../assets/content/situations.json) y el contenido del coach (misiones, prácticas, tips) en [assets/content/coach.json](../assets/content/coach.json); los repositories los cargan al iniciar y `main()` los inyecta vía providers. Editar contenido no requiere tocar código Dart.
- **Iconografía**: [phosphor_flutter](https://pub.dev/packages/phosphor_flutter) (variante *fill*).
- **Tipografía**: Public Sans para el padre y Fredoka solo en la pantalla de celebración del niño ([app_theme.dart](../lib/core/theme/app_theme.dart)).

### Estructura de carpetas

```
assets/
└── content/
    ├── situations.json    # Situaciones, niveles y guiones
    └── coach.json         # Misiones semanales, prácticas en casa, tips
lib/
├── main.dart              # Bootstrap: prefs + catálogo, ProviderScope, router
├── app/
│   └── router.dart        # Rutas y redirect de onboarding
├── core/
│   ├── models/            # ChildProfile, Situation/GuideLevel/GuideStep, SessionRecord, BadgeInfo
│   ├── state/             # Providers Riverpod (perfil, historial, progreso, recompensas, ajustes)
│   ├── theme/             # VinkoColors, VinkoSpacing, VinkoTheme
│   └── widgets/           # VinkoButton, VinkoCard, VinkoListRow, VinkoBadge, Breathing
└── features/
    ├── onboarding/
    ├── home/
    ├── situations/        # Selector, loader del catálogo, nivel por situación
    ├── live/              # LiveScreen, ClosureScreen, CelebrationScreen
    ├── coach/             # Misión semanal, práctica en casa, tip del día
    ├── progress/
    ├── badges/            # Pantalla + cálculo de insignias desde el historial
    ├── rewards/
    └── settings/
```

### Sistema de diseño

- Paleta sin rojo: los errores/ajustes usan el naranja `adjust` (`#F2994A`). Azul `action` (`#4A90E2`) para acciones, verde `success` (`#6FCF97`) para logros.
- Espaciados y radios centralizados en `VinkoSpacing` (padding 20, gap 16, radio 16, botones de 56 px de alto).
- Animación `Breathing`: una respiración sutil de escala que se usa en la marca y en la tarjeta de instrucción, para transmitir calma.

### Flujo principal (happy path)

1. Primera vez → **Onboarding**: nombre, edad y desafíos del niño.
2. **Home** → botón "Necesito ayuda ahora".
3. **Selector de situaciones** → elegir qué está pasando.
4. **Guía en vivo** → 3 pasos, uno a la vez, con alternativa si "No funcionó".
5. **Cierre** → 3 caritas, un toque.
6. Si salió bien y está activada → **Celebración** (pantalla para el niño).
7. El progreso (racha, pasos) se actualiza y se refleja en Home y Progreso.
