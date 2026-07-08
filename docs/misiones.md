# Coach — Misión de la semana, práctica en casa y tip del día

**Código:** [coach_providers.dart](../lib/features/coach/coach_providers.dart) · [coach_repository.dart](../lib/features/coach/coach_repository.dart) · [coach_content.dart](../lib/core/models/coach_content.dart)
**Contenido:** [assets/content/coach.json](../assets/content/coach.json)

## Concepto

La guía en vivo es reactiva (sirve *durante* la crisis). El coach es lo que pasa **entre crisis**: le da a la app un motivo de uso diario y prepara al niño para el próximo momento real mediante exposición ensayada sin presión.

Tres piezas:

| Pieza | Dónde se ve | Rota |
|---|---|---|
| **Misión de la semana** | Home, tarjeta bajo el CTA | Por semana (lunes) |
| **Práctica en casa** | Progreso, tarjeta "Práctica en casa" | Por semana |
| **Tip del día** | Progreso, tarjeta "Tip del día" | Por día |

## Misión de la semana

Un objetivo chico y concreto ("Esta semana: que {n} salude él primero, aunque sea bajito, una vez"), elegido así:

1. **Situación**: rota semanalmente entre los `challenges` marcados en el onboarding (si no marcó ninguno, rota por todo el catálogo real). `missionSituationId()` usa el índice de semana módulo el pool.
2. **Texto**: `coach.json` define una misión **por nivel** de cada situación; se usa la del nivel actual del niño (`situationLevelProvider`). Así la misión acompaña la escalera de exposición.
3. **Cumplida**: el botón "Listo" persiste `mission_done_{lunes-ISO}` en prefs; la tarjeta pasa a verde ("Misión cumplida") hasta el lunes siguiente.

`missionProvider` devuelve un `Mission` (situación, texto y práctica, con `{n}` ya reemplazado) o `null` si no hay perfil.

## Práctica en casa

Juegos de rol de 2 minutos por situación ("Armen una tiendita en casa: {n} pide, tú vendes"), definidos en `coach.json`. Se muestra la práctica de la situación de la misión vigente, rotando entre las disponibles por semana. La idea: lo ensayado en casa baja la dificultad del momento real.

## Tip del día

Psicoeducación breve para el padre ("No digas 'es tímido' delante de él. Decí: 'necesita un momento'"). Lista global en `coach.json`; `dailyTipProvider` rota por día del año.

## Helpers puros (testeados)

- `weekIndex(now)` — semanas desde el lunes 2020-01-06; estable de lunes a domingo.
- `missionWeekKey(now)` — fecha ISO del lunes de la semana (clave de "cumplida").
- `missionSituationId(challenges, allRealIds, now)` — rotación semanal del desafío.

Tests en [coach_test.dart](../test/coach_test.dart): integridad del JSON (toda situación del catálogo tiene misiones —una por nivel— y prácticas) y la rotación semanal.

## Pendiente relacionado

Los **recordatorios** de Ajustes ("un aviso por día") siguen sin implementar; cuando se hagan, la misión de la semana es el contenido natural de esa notificación.
