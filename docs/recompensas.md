# Recompensas

**Ruta:** `/rewards` (accesible desde Ajustes)
**Código:** [rewards_screen.dart](../lib/features/rewards/rewards_screen.dart) · estado en [app_state.dart](../lib/core/state/app_state.dart#L102-L150)

## Qué hace

Permite al padre elegir **cómo se celebra** cuando el niño lo logra. La filosofía es una celebración neutral y calma, sin marca ni estridencias.

Cuatro switches:

| Opción | Clave prefs | Default | Efecto |
|---|---|---|---|
| Pantalla de celebración | `rw_celebration` | ✅ on | Si está apagada, tras "Lo logró" en el Cierre se vuelve directo a Home sin mostrar la [CelebrationScreen](guia-en-vivo.md). |
| Estrellas | `rw_stars` | ✅ on | Muestra las tres estrellas doradas en la celebración. |
| Mensaje de Vinko | `rw_message` | ✅ on | Muestra la frase de refuerzo ("Hoy fue difícil. Y lo hiciste igual."). |
| Sonido suave | `rw_sound` | ❌ off | **Sin implementación todavía**: el flag se guarda pero ninguna pantalla reproduce sonido. |

## Implementación

- `RewardSettings` es un value object con `copyWith`; `RewardsNotifier.update()` actualiza el estado y persiste los cuatro booleanos en `shared_preferences`.
- Quién lo consume:
  - [ClosureScreen](../lib/features/live/closure_screen.dart) lee `celebrationScreen` para decidir si navegar a `/celebration`.
  - [CelebrationScreen](../lib/features/live/celebration_screen.dart) lee `stars` y `vinkoMessage` para armar la pantalla.
