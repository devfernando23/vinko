# Insignias

**Ruta:** `/badges`
**Código:** [badges_screen.dart](../lib/features/badges/badges_screen.dart) · [badges_provider.dart](../lib/features/badges/badges_provider.dart) · [badge_info.dart](../lib/core/models/badge_info.dart) · [vinko_badge.dart](../lib/core/widgets/vinko_badge.dart)

## Concepto

Las insignias son de **identidad**: no premian tareas, sino que nombran *quién se está volviendo* el niño ("El Saludador", "El Valiente"...). La cabecera de la pantalla lo explicita: "Quién se está volviendo {nombre}, paso a paso."

## Cálculo (desde el historial real)

Desde 2026-07-06 los tiers ya no están hardcodeados: `badgesProvider` los calcula del [historial de sesiones](progreso.md). Cuenta las sesiones con resultado **"Lo logró"** (sin intervención) por situación y asigna tier y progreso con `badgeLevel(successes)`:

| Logros | Tier | Progreso |
|---|---|---|
| 0 | Por descubrir (locked) | 0 |
| 1–2 | Cobre | hacia plata (0 → 0.5) |
| 3–4 | Plata | hacia oro (0 → 0.5) |
| 5+ | Oro | 1 |

`badgeLevel` es una función pura, testeada en [session_history_test.dart](../test/session_history_test.dart).

## Catálogo de insignias

Definido como `badgeDefs` en el provider; cada insignia mapea a una situación:

| Insignia | Situación | Se gana con |
|---|---|---|
| El Saludador | `greet` | Saluda por su cuenta |
| El Valiente | `fear` | Mira de frente lo que le da miedo |
| El Amigo | `share` | Presta y espera la vuelta |
| El Firme | `limits` | Dice basta con su propia voz |
| El que Pide | `ask_help` | Pide ayuda cuando la necesita |
| El Compañero | `join_play` | Se suma a jugar con otros |
| El Decidido | `order_shop` | Pide lo suyo con su voz |
| El Invitado | `party` | Disfruta las fiestas a su ritmo |
| El Amiguero | `new_kid` | Se acerca a niños nuevos |
| El que Participa | `speak_class` | Habla en clase con su voz |
| El Artista | `perform` | Muestra lo suyo delante de otros |
| El Anfitrión | `guests_home` | Recibe a las visitas en casa |
| El Paciente | `doctor_visit` | Va a la consulta con calma |
| El Conversador | `phone_call` | Contesta con su propia voz |
| El que Reclama | `taken_toy` | Pide que le devuelvan lo suyo |
| El Escudo | `teasing` | Frena las burlas con su voz |
| El Buen Perdedor | `losing_game` | Cierra el juego con la frente en alto |
| El Estudiante | `school_start` | Entra a clases por su cuenta |

`other` no tiene insignia asociada.

## Render

`VinkoBadgeCard` muestra medallón con anillo del color del tier (candado si está bloqueada), etiqueta del tier y barra de progreso hacia el siguiente.
