# Guía en vivo — Live, Cierre y Celebración

**Rutas:** `/live/:id` → `/closure` → `/celebration`
**Código:** [live_screen.dart](../lib/features/live/live_screen.dart) · [closure_screen.dart](../lib/features/live/closure_screen.dart) · [celebration_screen.dart](../lib/features/live/celebration_screen.dart)

Es el corazón de la app: el flujo que el padre usa *durante* la situación difícil.

## 1. LiveScreen (`/live/:id`)

Muestra **una sola instrucción a la vez**, en texto grande (26 px), pensada para entenderse en menos de 2 segundos. La tarjeta usa la animación `Breathing` para transmitir calma.

### Nivel de exposición

Al entrar, la pantalla lee el **nivel actual** de la situación (`situationLevelProvider`, derivado del historial: 2 "Lo logró" seguidos suben, 2 "Costó" bajan — ver [situaciones.md](situaciones.md)) y usa los pasos de ese nivel para toda la sesión. Debajo de la barra de progreso se muestra un chip "Nivel N · {label}" (solo si la situación tiene escalera; "Otra situación" no la tiene). El nivel jugado se registra en el `SessionRecord`.

### Selección de variantes (anti-repetición)

Cada paso tiene un banco de variantes ([situaciones.md](situaciones.md)). En `initState` se sortea **una variante por paso** para toda la sesión, evitando la que se mostró en la sesión anterior de esa situación y nivel. El índice elegido por paso se persiste en `shared_preferences` bajo la clave `variant_last_{situationId}_l{nivel}`, de modo que dos sesiones consecutivas casi nunca repiten instrucciones.

### Estado interno

- `_level` — nivel de exposición de la sesión (1..N, fijado al entrar).
- `_step` — índice del paso actual (0..N-1).
- `_variantOfStep` — variante sorteada para cada paso de esta sesión.
- `_fallback` — `-1` muestra la variante principal; `>= 0` es el índice dentro de la cadena de `fallbacks` del paso (acento naranja `VinkoColors.adjust`, cabecera "Vinko · probá esto").

El texto del paso reemplaza `{n}` por el nombre del niño (de `profileProvider`, con fallback "tu hijo").

### Controles

| Botón | Comportamiento |
|---|---|
| **Lo hizo** (verde) | Avanza al siguiente paso y resetea `_fallback`. En el último paso, termina con `stepsCompleted = total` e `intervened = false`. |
| **No funcionó / Tampoco funcionó** (naranja) | Avanza por la cadena de fallbacks del paso (plan B → C → D). Se deshabilita al agotar la cadena (2–3 alternativas por paso en el catálogo actual). |
| **Intervenir** (gris) | Salida digna: termina de inmediato con los pasos completados hasta ahora e `intervened = true`. |
| **X** (AppBar) | `context.pop()`: abandona sin registrar nada. |

Arriba hay una barra de progreso lineal con "Paso X de N"; su color acompaña el estado (azul normal, naranja en ajuste).

Al terminar se navega con `pushReplacement('/closure', extra: {steps, intervened})` — reemplaza para que "atrás" no vuelva a la guía.

## 2. ClosureScreen (`/closure`)

Cierre post-situación: **3 caritas, 1 tap y listo**.

- Título: "¿Cómo salió?" — o "Está bien intervenir." si `intervened == true`, con un mensaje que quita culpa ("La próxima, {nombre} llega un paso más lejos.").
- Tres opciones: 😞 **Costó** (0) · 😐 **Más o menos** (1) · 🙂 **Lo logró** (2).

Al elegir cualquiera:

1. Se persiste un `SessionRecord` completo en el historial (`sessionHistoryProvider.add`): situación, pasos completados, resultado (`SessionResult.hard | soso | success`), si hubo intervención, el **nivel jugado** y la fecha. De ese historial se derivan racha, gráfico semanal, insignias, el refuerzo "Vinko vio esto" y el nivel de la próxima sesión (ver [progreso.md](progreso.md) y [situaciones.md](situaciones.md)).
2. Si el resultado es **Lo logró** y la opción `celebrationScreen` de Recompensas está activa → `pushReplacement('/celebration')`. Si no → `go('/')`.
3. **Aviso de cambio de nivel**: se compara el nivel de la situación antes y después de registrar; si la escalera subió o bajó, se muestra un SnackBar flotante sobre la pantalla siguiente ("Subieron un escalón. Próxima vez: nivel 2 · Con su voz." en azul, o "Bajamos un escalón, sin apuro..." en naranja). Así el nivel nunca cambia en silencio.

## 3. CelebrationScreen (`/celebration`)

La única pantalla pensada para mostrarse **al niño**. Celebración neutral, sin estridencias:

- Fondo verde suave (`successSoft`), círculo verde con check animado con `Breathing`.
- Tipografía **Fredoka** (vía `VinkoTheme.celebration`) — es la única pantalla que la usa.
- "¡Lo hiciste, {nombre}!" y, si `vinkoMessage` está activo, la frase "Hoy fue difícil. Y lo hiciste igual."
- Tres estrellas doradas arriba, solo si `stars` está activo en Recompensas.
- Botón **Listo** → vuelve a Home.

Qué se muestra se controla desde [Recompensas](recompensas.md). La opción `softSound` existe en la configuración pero esta pantalla todavía no reproduce ningún sonido (ver [pendientes](pendientes-y-sugerencias.md)).
