import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/session_record.dart';
import '../../core/state/app_state.dart';
import 'situations_data.dart';

/// Nivel de exposición para una situación, derivado del historial.
///
/// Regla: se arranca en el nivel 1. Dos "Lo logró" seguidos suben un nivel;
/// dos "Costó" seguidos bajan uno. "Más o menos" corta ambas rachas.
/// Las sesiones con intervención cuentan como "Costó" para la escalera.
/// Pura para poder testearla.
int levelForHistory(
  Iterable<SessionRecord> history,
  String situationId, {
  int maxLevel = 3,
}) {
  var level = 1;
  var ups = 0;
  var downs = 0;
  for (final r in history.where((r) => r.situationId == situationId)) {
    final asHard = r.result == SessionResult.hard || r.intervened;
    if (r.result == SessionResult.success && !r.intervened) {
      ups++;
      downs = 0;
      if (ups >= 2) {
        if (level < maxLevel) level++;
        ups = 0;
      }
    } else if (asHard) {
      downs++;
      ups = 0;
      if (downs >= 2) {
        if (level > 1) level--;
        downs = 0;
      }
    } else {
      ups = 0;
      downs = 0;
    }
  }
  return level;
}

/// Nivel actual (1..N) de una situación, según el historial guardado.
final situationLevelProvider = Provider.family<int, String>((ref, situationId) {
  final history = ref.watch(sessionHistoryProvider);
  final all = ref.watch(situationsProvider);
  final maxLevel = situationById(all, situationId).levels.length;
  return levelForHistory(history, situationId, maxLevel: maxLevel);
});
