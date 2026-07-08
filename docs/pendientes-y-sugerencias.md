# Pendientes y sugerencias

Estado del documento: actualizado el 2026-07-08 a partir de la lectura del código. Empieza por el problema central del producto (contenido repetitivo), sigue con la deuda visible en la app y termina con una priorización.

---

## 1. Problema central: el contenido es estático y repetitivo

### Diagnóstico

Hoy todo el valor de Vinko vive en [situations_data.dart](../lib/features/situations/situations_data.dart): **6 situaciones × 3 pasos fijos × 1 sola alternativa por paso = 18 instrucciones + 18 fallbacks, siempre iguales**.

Consecuencias directas:

- A la segunda o tercera vez que el padre usa la misma situación, **ya se sabe el guion de memoria**. En ese punto la app no le aporta nada que no tenga en la cabeza.
- El guion es idéntico para un niño de 3 años que para uno de 10, aunque la edad se pide en el onboarding.
- El guion es idéntico si el niño lleva semanas mejorando o si es su primer intento: **no hay progresión**, y para un niño tímido la técnica correcta es precisamente subir la exigencia de a poco.
- Si el fallback tampoco funcionó, no hay un "plan C": el botón "No funcionó" se deshabilita tras un uso.
- La app es 100 % reactiva (solo sirve durante la crisis). Entre crisis no hay motivo para abrirla, así que tampoco construye hábito.

En resumen: tal como está, la app se agota en una semana de uso. Este es el pendiente número 1; todo lo demás es secundario.

### Propuesta A — Banco de variantes por paso (variedad inmediata) ✅ IMPLEMENTADA (2026-07-06)

> Estado: hecho. `GuideStep` ahora tiene `goal`, `variants` (4–5 por paso) y `fallbacks` (cadena de 3). La guía en vivo sortea una variante por paso evitando la de la sesión anterior (clave `variant_last_{situationId}` en prefs) y "No funcionó" recorre la cadena completa de fallbacks. Hay test de integridad del catálogo en `test/situations_data_test.dart`. Queda pendiente de esta sección: mover el contenido a JSON.

Cada paso deja de tener *una* instrucción y pasa a tener un **pool de variantes equivalentes** (mismo objetivo pedagógico, distinta táctica). La app elige una al azar evitando repetir las últimas usadas.

Ejemplo para `greet` (No quiere saludar), paso 1 — hoy solo existe "solo mirá 10 segundos":

- "Ponete a su altura. Decile a {n}: 'solo mirá 10 segundos'."
- "Decile a {n}: 'no hace falta hablar. Quedate al lado mío'."
- "Contá en voz baja con {n}: 'miramos hasta 10 y listo'."
- "Decile: 'primero saludo yo, vos solo mirá cómo lo hago'."
- "Preguntale bajito: '¿lo saludamos con la mano o con la voz?'. Que elija."

Con 4–5 variantes por paso, el catálogo pasa de 18 instrucciones a ~90 sin tocar la arquitectura. Es la mejora con mejor relación costo/impacto.

Cambio de modelo necesario en [situation.dart](../lib/core/models/situation.dart):

```dart
class GuideStep {
  final String goal;            // objetivo del paso (para mostrar u ordenar)
  final List<String> variants;  // instrucciones intercambiables
  final List<String> fallbacks; // cadena de alternativas (plan B, C, ...)
}
```

Y persistir en prefs las últimas variantes mostradas por situación para no repetirlas en sesiones consecutivas.

### Propuesta B — Niveles de progresión (escalera de exposición) ✅ IMPLEMENTADA (2026-07-06)

> Estado: hecho. Cada situación real tiene 3 niveles (`GuideLevel`) con guiones propios; "Otra situación" queda con nivel único. El nivel se deriva del historial en `situation_level.dart` (arranca en 1; dos "Lo logró" seguidos suben, dos "Costó" o intervenciones bajan, "Más o menos" corta la racha). La guía y el selector muestran el nivel actual, y el `SessionRecord` guarda el nivel jugado. Regla testeada en `test/situation_level_test.dart`.

Para niños tímidos el enfoque clásico es la **exposición gradual**: la misma situación se trabaja con exigencia creciente. Cada situación tendría 3 niveles, y el nivel se elige según el historial de resultados (las caritas del cierre, que hoy se descartan).

Ejemplo para `greet`:

| Nivel | Meta | Ejemplo de paso final |
|---|---|---|
| 1 — Observar | Estar presente sin saludar | "Con quedarse al lado tuyo alcanza. Eso ya es participar." |
| 2 — Gesto | Saludo no verbal | "Decile: 'con la mano alcanza. Sin palabras'." |
| 3 — Voz propia | Saludo verbal espontáneo | "Decile: 'ahora vos. Un hola bajito alcanza'." |

Regla simple de arranque: 2 sesiones seguidas con "Lo logró" → sube de nivel; 2 con "Costó" → baja. Esto le da a la app algo que el padre **no** puede hacer de memoria: saber en qué escalón está su hijo y calibrar la próxima instrucción.

Los niveles definitivos quedaron así (labels reales del catálogo): `greet` Estar y mirar → Un gesto, un hola → Su voz, solo · `fear` Calma primero → Mirar acompañado → Un paso él solo · `limits` Decirlo juntos → Con su voz → Sostenerlo solo · `share` Prestar contigo → Prestar y esperar → Ofrecer él · `ask_help` Aceptar ayuda → Pedirla con la frase → Pedir solo.

### Propuesta C — Variantes por edad

La edad ya se recoge en el onboarding y no se usa. Con dos o tres bandas alcanza:

- **3–5**: frases más físicas y de modelado ("tomale la mano", "hacelo vos primero, que te copie").
- **6–8**: el catálogo actual.
- **9–10**: más autonomía y menos intervención del padre ("acordá una señal secreta antes de entrar", "esperá a distancia, sin mirar fijo").

Puede implementarse como filtro sobre el banco de variantes (cada variante declara rango de edad) en lugar de duplicar guiones completos.

### Propuesta D — Ampliar el catálogo de situaciones ✅ PARCIALMENTE HECHA (2026-07-06)

> Estado: el contenido se movió a `assets/content/situations.json` (cargado por `SituationsRepository`, inyectado vía `situationsProvider`) — agregar situaciones ya no requiere tocar código. Se sumaron 3 situaciones nuevas con sus 3 niveles: **No se suma a jugar** (`join_play`), **No se anima a pedir** (`order_shop`) y **Cumpleaños y fiestas** (`party`), con sus insignias (El Compañero, El Decidido, El Invitado). El selector además prioriza los `challenges` del onboarding (3.7). Quedan como ideas las demás candidatas de la lista.

Seis situaciones se quedan cortas rápido. Candidatas alineadas al mismo perfil (timidez/ansiedad social), agrupables por contexto:

- **Social**: cumpleaños o fiestas, conocer a un niño nuevo en la plaza, sumarse a un juego ya empezado, visitas en casa.
- **Escuela**: primer día o vuelta de vacaciones, hablar en clase / preguntar a la maestra, exponer delante de otros.
- **Vida diaria**: pedir algo en un negocio o restaurante, atender el teléfono / videollamada con familiares, ir al médico o al peluquero.
- **Conflicto**: un niño le sacó algo y no reacciona, se burlan de él, perder en un juego delante de otros.

Con la propuesta A + D, el picker podría además agrupar por categoría y priorizar los `challenges` marcados en el onboarding.

### Propuesta E — Contenido entre crisis (misiones y práctica en casa) ✅ IMPLEMENTADA (2026-07-06)

> Estado: hecho, ver [misiones.md](misiones.md). Contenido en `assets/content/coach.json` (misiones por situación y nivel, prácticas por situación, tips globales). **Misión de la semana** en Home (rota entre los `challenges`, texto según el nivel actual, "Listo" persiste por semana); **Práctica en casa** y **Tip del día** en Progreso. Lógica de rotación testeada en `test/coach_test.dart`.

Hoy la app solo sirve *durante* el momento difícil. Para que tenga uso diario y realmente construya progreso:

- **Misión de la semana**: un objetivo pequeño ligado al desafío principal del niño ("esta semana: que {n} pida algo en un negocio, una vez"). Aparece en Home y se marca como cumplida.
- **Práctica en casa**: mini juegos de rol de 2 minutos para ensayar sin presión ("jueguen a saludarse con voces raras", "practiquen decir 'basta' frente al espejo"). La exposición ensayada en casa baja la dificultad del momento real.
- **Tip del día**: una tarjeta breve de psicoeducación para el padre ("no digas 'es tímido' delante de él; decí 'necesita un momento'").

Esto convierte a Vinko de "botón de pánico" a acompañante del proceso, que es lo que justifica tenerla instalada.

### Propuesta F — ~~LLM en runtime~~ → Generación offline de casos (decisión 2026-07-07)

Se descartó integrar un LLM en la app (backend, costos, riesgo editorial). En su lugar, el catálogo crece **offline**: se generan situaciones nuevas con cualquier IA usando el prompt de [prompt-generar-situaciones.md](prompt-generar-situaciones.md), se revisan a mano y se pegan en `situations.json` + `coach.json`. Los tests de integridad validan la estructura automáticamente. El prompt incluye la voz de Vinko, la escalera de 3 niveles, las reglas técnicas y 10 situaciones candidatas (conocer a un niño nuevo, hablar en clase, exponer, visitas en casa, médico/peluquero, teléfono, le sacan algo, burlas, perder en un juego, primer día de escuela). El mapa de iconos del repository ya tiene reservados los nombres necesarios.

### Cómo sostener el crecimiento del contenido

1. ~~**Corto plazo**: mover los guiones a un JSON en `assets/` con un loader tipado.~~ ✅ Hecho (2026-07-06): `assets/content/situations.json` + `SituationsRepository`.
2. **Mediano plazo**: contenido remoto (un JSON versionado en un bucket/CDN o Firebase Remote Config) para publicar situaciones nuevas sin release en las tiendas. El esquema ya está definido; solo cambia la fuente.

---

## 2. Pendientes: funcionalidad prometida sin implementar

- [x] **Sonido suave** ✅ (2026-07-07): `CelebrationScreen` reproduce `assets/sounds/soft_chime.wav` (dos notas suaves C5→G5, WAV sintetizado) vía `audioplayers` cuando `rw_sound` está activo.
- [x] **Recordatorios** ✅ (2026-07-07): `ReminderService` ([reminder_service.dart](../lib/core/services/reminder_service.dart)) programa con `flutter_local_notifications` un aviso diario a las 19:00 (`zonedSchedule` inexacto + `DateTimeComponents.time`). El cuerpo es la **misión de la semana** (`reminderBodyProvider`) y se reprograma en cada arranque para seguir la rotación semanal y el nivel. El switch de Ajustes pide el permiso del sistema al activarse (si se niega, no se activa y avisa con SnackBar); soporta Android/iOS/macOS y en web/Windows/Linux informa que no está disponible. "Cambiar de hijo"/"Cerrar sesión" cancelan el aviso. Android quedó configurado (permisos y receivers en el manifest, desugaring en Gradle).

## 3. Pendientes: datos mock y lógica incompleta

> Actualización 2026-07-06: se implementó el **historial de sesiones persistente** (`SessionRecord` + `SessionHistoryNotifier`, clave `session_history`, tope 300 entradas) y con él cayeron 3.1 a 3.6. Ver [progreso.md](progreso.md) e [insignias.md](insignias.md).

- [x] **3.1 Gráfico semanal de Progreso**: ~~mock~~ ahora grafica los pasos reales por día de la semana en curso, derivados del historial.
- [x] **3.2 El resultado del cierre se descarta**: ~~se perdía~~ ahora cada cierre persiste un `SessionRecord` (situación, pasos, resultado como enum `SessionResult`, si intervino, fecha).
- [x] **3.3 Valores iniciales de progreso**: ~~racha 3 / pasos 12 falsos~~ un usuario nuevo arranca en cero, con tarjeta de invitación como estado vacío.
- [x] **3.4 Insignias**: ~~hardcodeadas~~ `badgesProvider` calcula tier y progreso contando los "Lo logró" por situación (cobre 1, plata 3, oro 5).
- [x] **3.5 "Vinko vio esto"**: ~~frase fija~~ se genera desde la última sesión real (situación + carita + intervención).
- [x] **3.6 La racha nunca se corta**: ~~solo sumaba~~ ahora se deriva del historial: días consecutivos hasta hoy (o ayer); si hubo un hueco, vuelve a 0.
- [x] **3.7 Los `challenges` del onboarding no se usan**: ~~nada los leía~~ el selector de situaciones ahora muestra primero las marcadas como desafío, después el resto y "Otra situación" al final.
- [x] **3.8 Guardar la variante usada en el `SessionRecord`** ✅ (2026-07-08): `SessionRecord.variantsShown` guarda el índice de variante mostrado en cada paso (`null` en sesiones previas a este cambio, retrocompatible). `LiveScreen` arma la lista (`_variantOfStep`, truncada a los pasos realmente vistos) y la pasa por `extra` a `ClosureScreen`, que la persiste al cerrar. Test de ida y vuelta en [session_history_test.dart](../test/session_history_test.dart).

## 4. Pendientes de calidad

- [x] **Tests de la lógica de estado**: `ProgressData.fromHistory` (racha con corte, semana, ceros), `badgeLevel`, serialización de `SessionRecord` y la integridad del catálogo están cubiertos ([session_history_test.dart](../test/session_history_test.dart), [situations_data_test.dart](../test/situations_data_test.dart)). Faltan: `ChildProfile.fromJson` y un widget test del flujo guía → cierre → historial.
- [ ] **Sin repositorio git**: el proyecto no está bajo control de versiones.
- [ ] **CI mínima**: `flutter analyze` + tests en cada push cuando exista el repo.

## 5. Otras sugerencias

### Producto

- **Multi-perfil real**: "Cambiar de hijo" hoy borra todo (`prefs.clear()`). Guardar perfiles por id y alternar sin perder el progreso de cada hijo.
- [x] **Vista de historial** ✅ (2026-07-08): pantalla `/history` ([history_screen.dart](../lib/features/history/history_screen.dart)) lista las sesiones más recientes primero (situación, fecha relativa, resultado, pasos), reusando `VinkoListRow`. Acceso desde un tercer atajo en Home, junto a Progreso e Insignias.
- **Exportar/respaldar datos**: todo vive en `shared_preferences`; desinstalar pierde el progreso. Exportación simple (JSON) o sincronización en la nube.
- **Onboarding con explicación del flujo**: mostrar el ciclo situación → guía → cierre antes del primer uso real.

### Técnica

- **Capa de repositorio**: `SessionRepository` / `ContentRepository` para que pantallas y notifiers no mezclen datos reales, mocks y contenido. Necesario de todos modos para el contenido en JSON.
- **Internacionalización**: los textos de UI están incrustados en widgets, en español de Perú (tuteo — todo el contenido se convirtió desde el rioplatense original el 2026-07-07). Si se apunta a más mercados, migrar a `flutter_localizations`/ARB (variantes es-ES/es-MX/es-AR). El contenido ya vive en JSON, lo que facilita versiones por región.
- **Modo oscuro**: `VinkoTheme` solo define `light()`. La paleta suave se presta a un dark theme calmo.
- **Accesibilidad**: complementar "Texto grande" con `Semantics` en los botones de la guía y las caritas del cierre; verificar contraste del naranja sobre blanco.
- ~~**Enum para el resultado del cierre**~~ — hecho: `SessionResult { hard, soso, success }` en [session_record.dart](../lib/core/models/session_record.dart).

---

## 6. Priorización sugerida

| # | Qué | Por qué primero |
|---|---|---|
| ✅ | ~~Banco de variantes por paso~~ (propuesta A) | Implementada el 2026-07-06: ~72 variantes + ~54 fallbacks, con anti-repetición. Falta solo mover el contenido a JSON. |
| ✅ | ~~Historial de sesiones persistente~~ (3.2) | Implementado el 2026-07-06: `SessionRecord` + progreso derivado. Cayeron también 3.1, 3.3, 3.4, 3.5 y 3.6 (gráfico real, ceros, insignias reales, refuerzo real, corte de racha). |
| ✅ | ~~Niveles de progresión~~ (propuesta B) | Implementada el 2026-07-06: 3 niveles por situación con guiones propios, regla 2-suben/2-bajan derivada del historial, nivel visible en guía y selector, y guardado en cada sesión. |
| ✅ | ~~Contenido a JSON + ampliar catálogo + usar `challenges`~~ (propuesta D, 3.7) | Implementado el 2026-07-06: `assets/content/situations.json` + `SituationsRepository`, 3 situaciones nuevas con niveles e insignias, y selector ordenado por desafíos. |
| ✅ | ~~Misiones / práctica en casa~~ (propuesta E) | Implementada el 2026-07-06: misión semanal en Home + práctica y tip del día en Progreso, contenido en `coach.json`. |
| ✅ | ~~Aviso de subida/bajada de nivel~~ | Implementado el 2026-07-06: SnackBar al cerrar la sesión cuando la escalera sube o baja. |
| ✅ | ~~Recordatorios y sonido~~ (sección 2) | Implementados el 2026-07-07: aviso diario a las 19:00 con la misión de la semana como texto, y tono suave en la celebración. |
| ✅ | ~~Vista de historial + variante usada en el registro~~ (3.8) | Implementado el 2026-07-08: pantalla `/history` y `SessionRecord.variantsShown`. |
| ✅ | ~~Generar e integrar las 10 situaciones candidatas~~ (propuesta F reformulada) | Integradas el 2026-07-07: el catálogo llegó a 19 situaciones, todas con misiones, prácticas e insignias. |
| ✅ | ~~Pulir el tono de las 8 situaciones generadas~~ | Niveladas el 2026-07-07: reescritas a mano con tácticas específicas por contexto (ensayo previo, misión con objeto, despedida corta, regla del "bien jugado", etc.), al nivel del catálogo original. |
| 1 | **Variantes por edad** (propuesta C) | El JSON facilita etiquetar variantes por rango de edad; la edad ya se recoge en onboarding. |
