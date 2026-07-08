import 'package:flutter_test/flutter_test.dart';

import 'package:vinko/core/models/badge_info.dart';
import 'package:vinko/core/models/session_record.dart';
import 'package:vinko/core/state/app_state.dart';
import 'package:vinko/features/badges/badges_provider.dart';

SessionRecord _session(
  DateTime at, {
  String situation = 'greet',
  int steps = 3,
  SessionResult result = SessionResult.success,
  bool intervened = false,
}) =>
    SessionRecord(
      situationId: situation,
      stepsCompleted: steps,
      result: result,
      intervened: intervened,
      at: at,
    );

void main() {
  // Un momento fijo para que los tests no dependan de la hora real:
  // miércoles 2026-07-08, 15:00.
  final now = DateTime(2026, 7, 8, 15);

  group('ProgressData.fromHistory', () {
    test('sin historial, todo arranca en cero', () {
      final p = ProgressData.fromHistory(const [], now);
      expect(p.streakDays, 0);
      expect(p.stepsDone, 0);
      expect(p.situationsToday, 0);
      expect(p.weekSteps, List.filled(7, 0));
    });

    test('suma pasos y cuenta las situaciones de hoy', () {
      final p = ProgressData.fromHistory([
        _session(now.subtract(const Duration(hours: 2)), steps: 3),
        _session(now.subtract(const Duration(hours: 1)), steps: 2),
        _session(now.subtract(const Duration(days: 1)), steps: 1),
      ], now);
      expect(p.stepsDone, 6);
      expect(p.situationsToday, 2);
    });

    test('racha: días consecutivos hasta hoy', () {
      final p = ProgressData.fromHistory([
        _session(now.subtract(const Duration(days: 2))),
        _session(now.subtract(const Duration(days: 1))),
        _session(now),
      ], now);
      expect(p.streakDays, 3);
    });

    test('racha: se mantiene si hoy todavía no hubo actividad', () {
      final p = ProgressData.fromHistory([
        _session(now.subtract(const Duration(days: 2))),
        _session(now.subtract(const Duration(days: 1))),
      ], now);
      expect(p.streakDays, 2);
    });

    test('racha: se corta tras días sin actividad', () {
      final p = ProgressData.fromHistory([
        _session(now.subtract(const Duration(days: 5))),
        _session(now.subtract(const Duration(days: 4))),
        _session(now.subtract(const Duration(days: 3))),
      ], now);
      expect(p.streakDays, 0);
    });

    test('semana: los pasos caen en el día correcto (lunes a domingo)', () {
      // now es miércoles → índice 2. El lunes es índice 0.
      final p = ProgressData.fromHistory([
        _session(now, steps: 4),
        _session(now.subtract(const Duration(days: 2)), steps: 2), // lunes
        _session(now.subtract(const Duration(days: 7)), steps: 9), // fuera
      ], now);
      expect(p.weekSteps[2], 4);
      expect(p.weekSteps[0], 2);
      expect(p.weekSteps.reduce((a, b) => a + b), 6);
    });
  });

  group('badgeLevel', () {
    test('tiers según logros: 0 locked, 1 cobre, 3 plata, 5 oro', () {
      expect(badgeLevel(0).tier, BadgeTier.locked);
      expect(badgeLevel(1).tier, BadgeTier.copper);
      expect(badgeLevel(2).tier, BadgeTier.copper);
      expect(badgeLevel(3).tier, BadgeTier.silver);
      expect(badgeLevel(4).tier, BadgeTier.silver);
      expect(badgeLevel(5).tier, BadgeTier.gold);
      expect(badgeLevel(12).tier, BadgeTier.gold);
    });

    test('progreso hacia el siguiente tier', () {
      expect(badgeLevel(0).progress, 0);
      expect(badgeLevel(1).progress, 0);
      expect(badgeLevel(2).progress, 0.5);
      expect(badgeLevel(4).progress, 0.5);
      expect(badgeLevel(5).progress, 1);
    });
  });

  group('SessionRecord JSON', () {
    test('ida y vuelta sin pérdida', () {
      final records = [
        _session(now, situation: 'fear', result: SessionResult.hard),
        _session(now, intervened: true, result: SessionResult.soso),
      ];
      final decoded =
          SessionRecord.listFromJson(SessionRecord.listToJson(records));
      expect(decoded.length, 2);
      expect(decoded[0].situationId, 'fear');
      expect(decoded[0].result, SessionResult.hard);
      expect(decoded[1].intervened, true);
      expect(decoded[1].at, now);
    });

    test('null o vacío devuelve lista vacía', () {
      expect(SessionRecord.listFromJson(null), isEmpty);
      expect(SessionRecord.listFromJson(''), isEmpty);
    });

    test('variantsShown viaja ida y vuelta (3.8)', () {
      final withVariants = SessionRecord(
        situationId: 'greet',
        stepsCompleted: 2,
        result: SessionResult.success,
        intervened: false,
        at: now,
        variantsShown: const [0, 2],
      );
      final decoded = SessionRecord.listFromJson(
        SessionRecord.listToJson([withVariants]),
      );
      expect(decoded.single.variantsShown, [0, 2]);
    });

    test('sesiones previas sin variantsShown decodifican a null', () {
      final decoded = SessionRecord.listFromJson(
        SessionRecord.listToJson([_session(now)]),
      );
      expect(decoded.single.variantsShown, isNull);
    });
  });
}
