import 'package:flutter_test/flutter_test.dart';

import 'package:vinko/core/models/coach_content.dart';
import 'package:vinko/core/models/situation.dart';
import 'package:vinko/features/coach/coach_providers.dart';
import 'package:vinko/features/coach/coach_repository.dart';
import 'package:vinko/features/situations/situations_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoachContent coach;
  late List<Situation> situations;

  setUpAll(() async {
    coach = await CoachRepository.load();
    situations = await SituationsRepository.load();
  });

  group('contenido del coach (assets/content/coach.json)', () {
    test('hay tips y ninguno está vacío', () {
      expect(coach.tips.length, greaterThanOrEqualTo(5));
      for (final t in coach.tips) {
        expect(t.trim(), isNotEmpty);
      }
    });

    test('toda situación del catálogo tiene misiones (una por nivel) '
        'y prácticas', () {
      for (final s in situations) {
        final missions = coach.missions[s.id];
        expect(missions, isNotNull, reason: 'sin misiones: ${s.id}');
        expect(missions!.length, s.levels.length,
            reason: 'misiones vs niveles: ${s.id}');
        final practices = coach.practices[s.id];
        expect(practices, isNotNull, reason: 'sin prácticas: ${s.id}');
        expect(practices!, isNotEmpty, reason: s.id);
        for (final t in [...missions, ...practices]) {
          expect(t.trim(), isNotEmpty, reason: s.id);
        }
      }
    });
  });

  group('rotación semanal', () {
    test('weekIndex es estable dentro de la semana y cambia el lunes', () {
      // 2026-07-06 fue lunes.
      final monday = DateTime(2026, 7, 6, 9);
      final sunday = DateTime(2026, 7, 12, 23);
      final nextMonday = DateTime(2026, 7, 13, 0, 5);
      expect(weekIndex(monday), weekIndex(sunday));
      expect(weekIndex(nextMonday), weekIndex(monday) + 1);
    });

    test('missionWeekKey es el lunes de la semana', () {
      expect(missionWeekKey(DateTime(2026, 7, 8)), '2026-07-06');
      expect(missionWeekKey(DateTime(2026, 7, 6)), '2026-07-06');
      expect(missionWeekKey(DateTime(2026, 7, 12)), '2026-07-06');
    });

    test('la misión rota entre los desafíos elegidos', () {
      const challenges = ['greet', 'fear'];
      const allIds = ['greet', 'fear', 'limits'];
      final w1 = DateTime(2026, 7, 6);
      final w2 = DateTime(2026, 7, 13);
      final id1 = missionSituationId(challenges, allIds, w1);
      final id2 = missionSituationId(challenges, allIds, w2);
      expect(challenges, contains(id1));
      expect(challenges, contains(id2));
      expect(id1, isNot(id2), reason: 'semanas seguidas rotan el desafío');
    });

    test('sin desafíos, rota por todo el catálogo real', () {
      const allIds = ['greet', 'fear', 'limits'];
      final id = missionSituationId(const [], allIds, DateTime(2026, 7, 6));
      expect(allIds, contains(id));
    });
  });
}
