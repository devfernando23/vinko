/// Contenido del "coach" de Vinko: lo que pasa ENTRE crisis.
/// Cargado desde assets/content/coach.json.
class CoachContent {
  const CoachContent({
    required this.tips,
    required this.missions,
    required this.practices,
  });

  /// Psicoeducación breve para el padre. Rota por día.
  final List<String> tips;

  /// Misión semanal por situación, una por nivel (índice = nivel - 1).
  final Map<String, List<String>> missions;

  /// Juegos de rol de 2 minutos por situación. Rotan por semana.
  final Map<String, List<String>> practices;
}
