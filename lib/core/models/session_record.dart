import 'dart:convert';

/// Cómo salió la situación, según la carita elegida en el cierre.
enum SessionResult { hard, soso, success }

/// Una sesión de guía cerrada. Es la unidad del historial:
/// de acá se derivan racha, pasos, gráfico semanal e insignias.
class SessionRecord {
  const SessionRecord({
    required this.situationId,
    required this.stepsCompleted,
    required this.result,
    required this.intervened,
    required this.at,
    this.level = 1,
    this.variantsShown,
  });

  final String situationId;
  final int stepsCompleted;
  final SessionResult result;
  final bool intervened;
  final DateTime at;

  /// Nivel de exposición en el que se jugó la sesión (1 = vara más baja).
  final int level;

  /// Índice de la variante mostrada en cada paso (por posición en
  /// `GuideLevel.steps[i].variants`). `null` en sesiones previas a este
  /// tracking (3.8).
  final List<int>? variantsShown;

  Map<String, dynamic> toMap() => {
        'sit': situationId,
        'steps': stepsCompleted,
        'result': result.name,
        'intervened': intervened,
        'at': at.toIso8601String(),
        'level': level,
        if (variantsShown != null) 'variants': variantsShown,
      };

  static SessionRecord fromMap(Map<String, dynamic> map) => SessionRecord(
        situationId: map['sit'] as String,
        stepsCompleted: map['steps'] as int,
        result: SessionResult.values.byName(map['result'] as String),
        intervened: map['intervened'] as bool,
        at: DateTime.parse(map['at'] as String),
        // Sesiones previas a los niveles quedan como nivel 1.
        level: map['level'] as int? ?? 1,
        variantsShown: (map['variants'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
      );

  static String listToJson(List<SessionRecord> records) =>
      jsonEncode([for (final r in records) r.toMap()]);

  static List<SessionRecord> listFromJson(String? json) {
    if (json == null || json.isEmpty) return const [];
    final list = jsonDecode(json) as List<dynamic>;
    return [
      for (final item in list) fromMap(item as Map<String, dynamic>),
    ];
  }
}
