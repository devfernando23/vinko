import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/coach_content.dart';
import '../../core/state/app_state.dart';
import '../situations/situation_level.dart';
import '../situations/situations_data.dart';

/// Contenido del coach (misiones, prácticas, tips).
/// Se sobreescribe en main() con el JSON ya cargado.
final coachProvider = Provider<CoachContent>(
  (ref) => throw UnimplementedError('Override en main()'),
);

// ---------------------------------------------------------------------------
// Helpers puros (testeables): semana y rotación
// ---------------------------------------------------------------------------

/// Lunes 2020-01-06 como semana 0. Las semanas van de lunes a domingo.
final _weekEpoch = DateTime(2020, 1, 6);

int weekIndex(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(_weekEpoch).inDays ~/ 7;
}

/// Clave de la semana actual (el lunes, ISO) para persistir "misión cumplida".
String missionWeekKey(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return monday.toIso8601String().substring(0, 10);
}

/// Situación de la misión semanal: rota entre los desafíos del onboarding
/// (o todo el catálogo real si no marcó ninguno), una por semana.
String missionSituationId(
  List<String> challenges,
  List<String> allRealIds,
  DateTime now,
) {
  final pool = challenges.isNotEmpty ? challenges : allRealIds;
  if (pool.isEmpty) return 'other';
  return pool[weekIndex(now) % pool.length];
}

// ---------------------------------------------------------------------------
// Misión de la semana
// ---------------------------------------------------------------------------

class Mission {
  const Mission({
    required this.situationId,
    required this.situationTitle,
    required this.text,
    required this.practice,
  });

  final String situationId;
  final String situationTitle;

  /// Texto de la misión, ya con {n} reemplazado.
  final String text;

  /// Juego de práctica en casa de esta semana, ya con {n} reemplazado.
  final String practice;
}

final missionProvider = Provider<Mission?>((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return null;
  final coach = ref.watch(coachProvider);
  final all = ref.watch(situationsProvider);
  final now = DateTime.now();

  final realIds = [for (final s in all.where((s) => s.id != 'other')) s.id];
  final id = missionSituationId(profile.challenges, realIds, now);
  final situation = situationById(all, id);

  final missions = coach.missions[id] ?? coach.missions['other'] ?? const [''];
  final level = ref.watch(situationLevelProvider(id));
  final text = missions[min(level, missions.length) - 1];

  final practices =
      coach.practices[id] ?? coach.practices['other'] ?? const [''];
  final practice = practices[weekIndex(now) % practices.length];

  return Mission(
    situationId: id,
    situationTitle: situation.title,
    text: text.replaceAll('{n}', profile.name),
    practice: practice.replaceAll('{n}', profile.name),
  );
});

/// Cuerpo del aviso diario: la misión vigente o una frase genérica.
final reminderBodyProvider = Provider<String>((ref) {
  final mission = ref.watch(missionProvider);
  return mission?.text ?? 'Un momento pequeño hoy también cuenta.';
});

/// Si la misión de ESTA semana ya se marcó como cumplida.
class MissionDoneNotifier extends Notifier<bool> {
  String get _key => 'mission_done_${missionWeekKey(DateTime.now())}';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> markDone() async {
    state = true;
    await ref.read(sharedPrefsProvider).setBool(_key, true);
  }
}

final missionDoneProvider =
    NotifierProvider<MissionDoneNotifier, bool>(MissionDoneNotifier.new);

// ---------------------------------------------------------------------------
// Tip del día
// ---------------------------------------------------------------------------

final dailyTipProvider = Provider<String>((ref) {
  final coach = ref.watch(coachProvider);
  if (coach.tips.isEmpty) return '';
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  final tip = coach.tips[dayOfYear % coach.tips.length];
  final name = ref.watch(profileProvider)?.name ?? 'tu hijo';
  return tip.replaceAll('{n}', name);
});
