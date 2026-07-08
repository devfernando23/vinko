# Situaciones — Catálogo y selector

**Ruta:** `/situations`
**Código:** [situation_picker_screen.dart](../lib/features/situations/situation_picker_screen.dart) · [situations_repository.dart](../lib/features/situations/situations_repository.dart) · [situations_data.dart](../lib/features/situations/situations_data.dart) · [situation.dart](../lib/core/models/situation.dart)
**Contenido:** [assets/content/situations.json](../assets/content/situations.json)

## Qué hace

Tras tocar "Necesito ayuda ahora", el padre elige **qué está pasando**. La pantalla muestra una grilla de 2 columnas con tarjetas (icono + título + nivel actual). Al tocar una, navega a la guía en vivo: `/live/{id}`.

El orden no es fijo: **las situaciones marcadas como desafíos en el onboarding aparecen primero**, después el resto, y "Otra situación" siempre al final.

## De dónde sale el contenido

Los guiones viven en `assets/content/situations.json` (no en código Dart). `SituationsRepository.load()` lo parsea al iniciar la app y `main()` lo inyecta vía `situationsProvider`. Editar o agregar situaciones **no requiere tocar código**: solo el JSON (los iconos se mapean por nombre en el repository; si el nombre no existe, cae en la brújula). El mismo esquema serviría a futuro para contenido remoto.

## Modelo de datos

```dart
Situation {
  String id;                // 'greet', 'fear', 'limits', 'share', 'ask_help', 'other'
  String title;             // "No quiere saludar", "Tiene miedo", ...
  PhosphorIconData icon;
  List<GuideLevel> levels;  // escalera de exposición: 3 niveles (1 en 'other')
}

GuideLevel {
  String label;            // meta del nivel: "Estar y mirar", "Su voz, solo"...
  List<GuideStep> steps;   // 3 pasos por nivel
}

GuideStep {
  String goal;             // objetivo pedagógico del paso
  List<String> variants;   // instrucciones intercambiables (misma meta, distinta táctica)
  List<String> fallbacks;  // cadena de alternativas para "No funcionó" (plan B, C, D)
}
```

Los textos usan el marcador `{n}`, que la guía en vivo reemplaza por el nombre del niño.

Dos mecanismos evitan que el contenido se agote:

1. **Niveles de progresión** (escalera de exposición): cada situación tiene 3 niveles con guiones propios; la exigencia sube de a poco. El nivel activo se deriva del historial en [situation_level.dart](../lib/features/situations/situation_level.dart): se arranca en nivel 1, **dos "Lo logró" seguidos suben un nivel, dos "Costó" seguidos (o intervenciones) bajan uno**, y "Más o menos" corta la racha. `situationLevelProvider` (family por id) lo expone a las pantallas; el selector muestra el nivel actual en cada tarjeta.
2. **Banco de variantes**: dentro de cada nivel, cada paso tiene 3–5 variantes y 2–3 fallbacks encadenados. La guía sortea una variante por paso, evitando repetir la de la sesión anterior de ese nivel (ver [guia-en-vivo.md](guia-en-vivo.md)).

## Catálogo actual

| id | Título | Nivel 1 | Nivel 2 | Nivel 3 |
|---|---|---|---|---|
| `greet` | No quiere saludar | Estar y mirar | Un gesto, un hola | Su voz, solo |
| `fear` | Tiene miedo | Calma primero | Mirar acompañado | Un paso él solo |
| `limits` | No pone límites | Decirlo juntos | Con su voz | Sostenerlo solo |
| `share` | No comparte | Prestar contigo | Prestar y esperar | Ofrecer él |
| `ask_help` | No pide ayuda | Aceptar ayuda | Pedirla con la frase | Pedir solo |
| `join_play` | No se suma a jugar | Mirar el juego | Entrar con ayuda | Sumarse solo |
| `order_shop` | No se anima a pedir | Mirar cómo se pide | Pedir juntos | Pedir solo |
| `party` | Cumpleaños y fiestas | Llegar y ubicarse | Acercarse al grupo | Disfrutar a su ritmo |
| `new_kid` | Conocer a un niño nuevo | Estar y mirar | Un gesto, un hola | Su voz, solo |
| `speak_class` | No habla en clase | Estar y escuchar | Un gesto, una duda | Su voz, solo |
| `perform` | No quiere actuar | Estar y mirar | Una parte pequeña | Solo al frente |
| `guests_home` | Se esconde con visitas | Estar cerca | Salir un momento | Recibir él |
| `doctor_visit` | No quiere ir al médico | Saber qué viene | Participar con ayuda | Su consulta |
| `phone_call` | Llamadas y videollamadas | Estar y oír | Una palabra | Habla solo |
| `taken_toy` | Le quitan algo | Parar y nombrar | Pedirlo con ayuda | Defiende solo |
| `teasing` | Se burlan | Refugio primero | Frase corta | Se protege solo |
| `losing_game` | Pierde y se bloquea | Parar y regular | Cerrar con ayuda | Cierra solo |
| `school_start` | Primer día de clases | Conocer el terreno | Entrar con ayuda | Entra solo |
| `other` | Otra situación | Paso a paso (nivel único) | — | — |

Cada nivel tiene 3 pasos con su propio `goal`; en total son ~165 pasos con ~500 variantes + ~360 fallbacks. **`other` debe quedar último en el JSON**: es el fallback de `situationById`. Las 10 situaciones desde `new_kid` en adelante se generaron con el prompt de [prompt-generar-situaciones.md](prompt-generar-situaciones.md) (2026-07-07) y se revisaron a mano al integrarlas.

La voz de los guiones es deliberada: **directa, breve, una instrucción a la vez**, en español de Perú (tuteo: "dile", "ponte", "mira" — nunca voseo).

## Helpers

- `situationById(List<Situation>, String id)` devuelve la situación por id; si no existe, cae en la última (`other`) como fallback seguro.
- En el onboarding, el catálogo (sin `other`) se reutiliza como opciones de "¿Qué le cuesta más?" — las situaciones nuevas aparecen ahí automáticamente.

## Notas

- Hay un test de integridad del catálogo en [situations_data_test.dart](../test/situations_data_test.dart): carga el JSON real y valida niveles, mínimo de variantes/fallbacks por paso, sin vacíos ni duplicados, ids únicos y `other` al final.
- Del plan de contenido de [pendientes-y-sugerencias.md](pendientes-y-sugerencias.md) quedan pendientes: variantes por edad (propuesta C), misiones entre crisis (E) y guía generada para "Otra situación" (F).
