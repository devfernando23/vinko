import 'package:flutter_test/flutter_test.dart';

import 'package:vinko/core/models/session_record.dart';
import 'package:vinko/features/situations/situation_level.dart';

SessionRecord _session(
  SessionResult result, {
  String situation = 'greet',
  bool intervened = false,
}) =>
    SessionRecord(
      situationId: situation,
      stepsCompleted: 3,
      result: result,
      intervened: intervened,
      at: DateTime(2026, 7, 6),
    );

void main() {
  group('levelForHistory', () {
    test('sin historial arranca en nivel 1', () {
      expect(levelForHistory(const [], 'greet'), 1);
    });

    test('dos "Lo logró" seguidos suben un nivel', () {
      final h = [
        _session(SessionResult.success),
        _session(SessionResult.success),
      ];
      expect(levelForHistory(h, 'greet'), 2);
    });

    test('cuatro "Lo logró" seguidos llegan al nivel 3, y ahí se queda', () {
      final h = List.generate(8, (_) => _session(SessionResult.success));
      expect(levelForHistory(h, 'greet'), 3);
    });

    test('dos "Costó" seguidos bajan un nivel (sin pasar del 1)', () {
      final up = [
        _session(SessionResult.success),
        _session(SessionResult.success),
      ];
      final down = [
        _session(SessionResult.hard),
        _session(SessionResult.hard),
      ];
      expect(levelForHistory([...up, ...down], 'greet'), 1);
      expect(levelForHistory(down, 'greet'), 1);
    });

    test('"Más o menos" corta la racha de subida', () {
      final h = [
        _session(SessionResult.success),
        _session(SessionResult.soso),
        _session(SessionResult.success),
      ];
      expect(levelForHistory(h, 'greet'), 1);
    });

    test('una intervención cuenta como "Costó" para la escalera', () {
      final h = [
        _session(SessionResult.success),
        _session(SessionResult.success), // nivel 2
        _session(SessionResult.success, intervened: true),
        _session(SessionResult.hard), // segunda "dura" seguida → baja
      ];
      expect(levelForHistory(h, 'greet'), 1);
    });

    test('solo cuentan las sesiones de la situación pedida', () {
      final h = [
        _session(SessionResult.success, situation: 'fear'),
        _session(SessionResult.success, situation: 'fear'),
      ];
      expect(levelForHistory(h, 'greet'), 1);
      expect(levelForHistory(h, 'fear'), 2);
    });

    test('respeta maxLevel (situaciones de un solo nivel)', () {
      final h = List.generate(6, (_) => _session(SessionResult.success));
      expect(levelForHistory(h, 'greet', maxLevel: 1), 1);
    });
  });
}
