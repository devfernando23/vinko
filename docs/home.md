# Home — Pantalla principal

**Ruta:** `/`
**Código:** [home_screen.dart](../lib/features/home/home_screen.dart)

## Qué hace

Es el punto de entrada tras el onboarding. Está diseñada alrededor de una sola acción dominante: pedir ayuda en el momento.

### Elementos

- **Saludo** — "Hola. {nombre} te espera.", leído de `profileProvider`.
- **Botón de Ajustes** — icono de engranaje arriba a la derecha (`context.push('/settings')`).
- **Marca Vinko** — círculo azul con brújula, envuelto en el widget [Breathing](../lib/core/widgets/breathing.dart) (animación de respiración sutil), más el nombre y el lema "Qué hacer, justo en el momento".
- **CTA principal** — botón grande "Necesito ayuda ahora" (icono de rayo) que navega a `/situations`.
- **Misión de la semana** — tarjeta con el objetivo semanal del coach (ver [misiones.md](misiones.md)); el botón "Listo" la marca cumplida y la tarjeta pasa a verde hasta el lunes siguiente.
- **Atajos** — dos tarjetas en fila:
  - **Progreso**: muestra la racha actual ("{n} días seguidos", desde `progressProvider`) y navega a `/progress`.
  - **Insignias**: subtítulo fijo "Quién se está volviendo", navega a `/badges`.

## Estado que consume

| Provider | Uso |
|---|---|
| `profileProvider` | Nombre del niño en el saludo |
| `progressProvider` | `streakDays` en el atajo de Progreso |
| `missionProvider` / `missionDoneProvider` | Tarjeta de misión de la semana |

## Diseño

- La jerarquía visual empuja todo hacia el CTA: la marca ocupa el centro con `Spacer`s y el botón primario queda a la altura del pulgar.
- `_ShortcutCard` es un widget privado de esta pantalla construido sobre [VinkoCard](../lib/core/widgets/vinko_card.dart).
