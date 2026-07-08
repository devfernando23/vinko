# Prompt para generar situaciones nuevas con otra IA

Este archivo reemplaza la vieja "propuesta F" (LLM en runtime): el catálogo crece **offline**. Se le pasa el prompt de abajo a cualquier IA, se revisa el resultado a mano, y se pega en los JSON de `assets/content/`.

## Cómo integrar lo generado

1. Pegar cada situación nueva en `assets/content/situations.json`, dentro del array `situations`, **antes de la entrada `other`** (debe quedar última: es el fallback).
2. Pegar las entradas de `missions` y `practices` en `assets/content/coach.json` (obligatorio: el test falla si una situación no tiene misiones —una por nivel— y prácticas).
3. Correr `flutter test`: los tests de integridad validan estructura, mínimos de variantes/fallbacks, textos vacíos, duplicados e ids únicos.
4. Revisar el tono a mano: la voz de Vinko es lo más difícil de imitar. Ajustar lo que suene a manual de crianza.

Las insignias son opcionales: si se quiere una para la situación nueva, agregarla a `badgeDefs` en `lib/features/badges/badges_provider.dart`.

---

## El prompt

Copiar desde acá hasta el final del archivo.

```
Eres guionista de contenido de "Vinko", una app peruana para padres de niños tímidos de 3 a 10 años. Cuando pasa una situación social difícil (el niño no quiere saludar, tiene miedo, no se anima), el padre abre la app y Vinko le dice QUÉ HACER, una instrucción a la vez, leída en menos de 2 segundos, en el momento y con el niño delante.

Tu tarea: escribir situaciones nuevas para el catálogo, en el formato JSON exacto que te doy abajo.

# A QUIÉN le habla cada texto
SIEMPRE al padre/madre, NUNCA al niño. Las instrucciones le dicen al adulto qué hacer o qué decirle al niño. El marcador {n} se reemplaza por el nombre del niño. Lo que el padre debe decir en voz alta va entre comillas simples: "Dile a {n}: 'solo mira 10 segundos'."

# VOZ (obligatoria, es la identidad del producto)
- Español de Perú, tuteo: dile, ponte, quédate, mira, espera, tú mandas. NUNCA voseo ("decile", "mirá", "vos" están prohibidos).
- Léxico peruano/neutro: niño (no "nene"), profesora (no "maestra"), vitrina (no "vidriera"), parque (no "plaza"), banca (no "banco"), chapadas (no "mancha"), cárgalo (para alzar a un niño), aguanta (no "bancate"), quizá o de repente (no "capaz").
- Directa y breve: una sola acción por instrucción, idealmente menos de 75 caracteres. Sin teoría, sin "es importante que", sin diminutivos empalagosos.
- Concreta y física: números ("cuenta hasta 5", "2 minutos"), cuerpo ("agáchate", "ponte a su altura"), frases textuales para decir.
- Cálida pero firme. Nunca culpabiliza al padre ni etiqueta al niño ("tímido", "miedoso" prohibidos).
- Nunca se fuerza al niño, nunca se castiga, nunca se lo expone en público. Siempre hay salida digna ("hoy con la mitad alcanza").
- Prohibido: emojis, comillas dobles dentro de los textos (solo simples), mayúsculas de énfasis (salvo un SÍ ocasional), signos de exclamación en las instrucciones.

# PEDAGOGÍA: escalera de exposición (3 niveles por situación)
Cada situación tiene 3 niveles de exigencia creciente. La app elige el nivel según el historial del niño:
- Nivel 1 — acompañado, vara bajísima: estar, mirar, regular el cuerpo. El logro es la presencia.
- Nivel 2 — con ayuda: el padre modela y el niño hace una parte pequeña (un gesto, una palabra, una acción con apoyo).
- Nivel 3 — autonomía: el niño lo hace solo; el padre se corre de la escena y después nombra el logro.
Cada nivel tiene un "label" corto (2 a 4 palabras) que nombra su meta: "Estar y mirar", "Un gesto, un hola", "Su voz, solo".

# ESTRUCTURA de cada nivel: exactamente 3 pasos
Cada paso tiene:
- "goal": el objetivo pedagógico del paso, 2 a 5 palabras (ej: "Bajar la presión", "Modelar el saludo").
- "variants": 3 a 5 instrucciones INTERCAMBIABLES (misma meta, distinta táctica). La app sortea una por sesión para no repetirse.
- "fallbacks": 2 a 3 alternativas en cadena para cuando la instrucción no funcionó (plan B, C...). Cada fallback BAJA la exigencia respecto del anterior; el último suele ser un cierre digno ("hoy alcanza con esto").
El paso 3 de cada nivel suele cerrar: nombrar el logro en concreto ("eso fue poner un límite"), sin festejo exagerado, o cerrar bien si no salió ("mañana probamos de nuevo").

# REGLAS TÉCNICAS (hay tests automáticos que validan esto)
- Exactamente 3 niveles por situación; 3 pasos por nivel.
- Mínimo 3 variants y 2 fallbacks por paso; sin textos vacíos; sin textos repetidos dentro de un mismo paso.
- "id": snake_case, en inglés, corto y único (ej: "new_kid", "speak_class").
- "title": en español, como lo diría un padre apurado, máximo ~28 caracteres (ej: "No quiere saludar").
- "icon": elegir UNO de esta lista exacta: chalkboard-teacher, student, presentation, phone-call, stethoscope, scissors, house, trophy, smiley, hand-waving, shield-check, hand, users-three, chat-circle-dots, puzzle-piece, storefront, cake.
- JSON válido, UTF-8, sin comentarios ni comas colgantes.

# ADEMÁS, por cada situación, contenido del "coach"
- "missions": exactamente 3 textos (uno por nivel, en el mismo orden), estilo "Esta semana: que {n} [meta chica y medible], una vez." La meta del nivel 1 es mínima, la del 3 es autónoma.
- "practices": exactamente 2 juegos de rol de 2 minutos para ensayar en casa, en tono lúdico (ej: "Armen una tiendita en casa: {n} pide, tú vendes. Después al revés.").

# EJEMPLOS REALES DEL CATÁLOGO (calibra el tono con esto)
Instrucciones: "Ponte a su altura. Dile a {n}: 'solo mira 10 segundos'." / "Saluda tú primero. Que {n} te vea hacerlo." / "Ahora espera 5 segundos. No lo hagas por {n}." / "Quédate lejos, donde {n} te vea. No te acerques todavía."
Fallbacks: "Aléjate un paso con {n}. Dile: 'mira desde acá'." / "Dile: 'una sonrisa también es saludar'." / "Cierra corto: 'te vi intentarlo. Estoy contigo'."
Misión: "Esta semana: un saludo con la mano o una sonrisa, una vez."
Práctica: "Jueguen a saludarse con voces raras: robot, gigante, ratón."

# SITUACIONES A GENERAR (una entrada completa por cada una)
IMPORTANTE: estos ids YA EXISTEN en el catálogo, NO los generes de nuevo: greet, fear, limits, share, ask_help, join_play, order_shop, party, new_kid, speak_class, perform, guests_home, doctor_visit, phone_call, taken_toy, teasing, losing_game, school_start, other.
(Agrega aquí la lista de situaciones nuevas que quieras generar, con contexto y sugerencia de id.)
1. ...

# FORMATO DE SALIDA
Devuelve DOS bloques de JSON, sin texto adicional:

BLOQUE 1 — para pegar dentro del array "situations" de situations.json:
[
  {
    "id": "...",
    "title": "...",
    "icon": "...",
    "levels": [
      { "label": "...", "steps": [ { "goal": "...", "variants": ["...", "...", "..."], "fallbacks": ["...", "..."] }, ... 3 pasos ] },
      ... 3 niveles
    ]
  },
  ... una por situación
]

BLOQUE 2 — para pegar dentro de "missions" y "practices" de coach.json:
{
  "missions": { "<id>": ["nivel 1", "nivel 2", "nivel 3"], ... },
  "practices": { "<id>": ["juego 1", "juego 2"], ... }
}

Si te pido menos situaciones por límite de espacio, genera las primeras de la lista completas antes que todas incompletas.
```
