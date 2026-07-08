import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Un paso de la guía en vivo.
///
/// Los textos usan `{n}` como marcador del nombre del niño:
/// "Dile a {n}: 'solo mira 10 segundos'".
class GuideStep {
  const GuideStep({
    required this.goal,
    required this.variants,
    required this.fallbacks,
  });

  /// Objetivo pedagógico del paso (igual en todas las variantes).
  final String goal;

  /// Instrucciones intercambiables: misma meta, distinta táctica.
  /// La guía elige una evitando repetir la de la sesión anterior.
  final List<String> variants;

  /// Cadena de alternativas para "No funcionó": plan B, C, D...
  final List<String> fallbacks;
}

/// Un nivel de la escalera de exposición: misma situación,
/// exigencia creciente. El nivel activo se deriva del historial.
class GuideLevel {
  const GuideLevel({required this.label, required this.steps});

  /// Nombre corto de la meta del nivel: "Estar y mirar", "Su voz, solo".
  final String label;

  final List<GuideStep> steps;
}

class Situation {
  const Situation({
    required this.id,
    required this.title,
    required this.icon,
    required this.levels,
  });

  final String id;
  final String title;
  final PhosphorIconData icon;

  /// Niveles en orden de exigencia (1 = vara más baja).
  final List<GuideLevel> levels;
}
