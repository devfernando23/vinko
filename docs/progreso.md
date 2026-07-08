# Progreso

**Ruta:** `/progress`
**Código:** [progress_screen.dart](../lib/features/progress/progress_screen.dart) · estado en [app_state.dart](../lib/core/state/app_state.dart) · modelo en [session_record.dart](../lib/core/models/session_record.dart)

## Qué hace

Muestra al padre el avance acumulado del niño:

1. **Tarjetas de estadísticas** — racha ("{n} días seguidos", icono de llama) y total de "pasos logrados" (icono de huellas).
2. **"Vinko vio esto"** — tarjeta de refuerzo generada desde la **última sesión real**: combina la situación, el resultado (carita) y si hubo intervención. Ej.: «Hoy {n} lo logró: "no quiere saludar". Paso a paso, con su propio ritmo.» Si no hay sesiones todavía, muestra una invitación ("Vinko te espera").
3. **Esta semana** — gráfico de barras L-D con los pasos reales por día de la semana en curso; la barra del día actual se resalta. La escala se ajusta al máximo de la semana.
4. **Práctica en casa** — el juego de rol de la semana, ligado a la situación de la misión vigente (ver [misiones.md](misiones.md)).
5. **Tip del día** — psicoeducación breve para el padre, rota por día.

## Fuente de verdad: el historial de sesiones

Desde 2026-07-06 el progreso ya no se guarda como contadores sueltos: se **deriva del historial de sesiones**.

### `SessionRecord`

```dart
SessionRecord {
  String situationId;    // qué situación se trabajó
  int stepsCompleted;    // pasos completados
  SessionResult result;  // hard | soso | success (la carita del cierre)
  bool intervened;       // terminó con "Intervenir"
  DateTime at;           // cuándo
  int level;             // nivel de exposición jugado (default 1)
}
```

`SessionHistoryNotifier` persiste la lista como JSON en `shared_preferences` (clave `session_history`, tope de 300 entradas). La pantalla de Cierre agrega un registro con cada carita elegida.

### `ProgressData.fromHistory(history, now)`

Función pura (testeada en [session_history_test.dart](../test/session_history_test.dart)) que calcula:

- **`stepsDone`** — suma de pasos de todas las sesiones.
- **`situationsToday`** — sesiones cerradas hoy.
- **`weekSteps`** — pasos por día de la semana actual, lunes a domingo.
- **`streakDays`** — días *consecutivos* con actividad, contando hacia atrás desde hoy (o desde ayer si hoy aún no hubo). **La racha se corta** si pasan días sin uso — esto corrige el bug anterior donde solo sumaba.

`progressProvider` es ahora un `Provider` derivado: cualquier pantalla que lo observe (Home, Progreso) se recalcula sola cuando entra una sesión nueva.

## Comportamiento inicial

Un usuario nuevo arranca con todo en **cero** (antes había mocks: racha 3, pasos 12, gráfico inventado). El estado vacío se cubre con la tarjeta de invitación.
