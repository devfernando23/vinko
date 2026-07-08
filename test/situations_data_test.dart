import 'package:flutter_test/flutter_test.dart';

import 'package:vinko/core/models/situation.dart';
import 'package:vinko/features/situations/situations_data.dart';
import 'package:vinko/features/situations/situations_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Situation> situations;

  setUpAll(() async {
    situations = await SituationsRepository.load();
  });

  group('catálogo de situaciones (assets/content/situations.json)', () {
    test('carga el catálogo completo, con "other" al final', () {
      expect(situations.length, greaterThanOrEqualTo(9));
      expect(situations.last.id, 'other',
          reason: 'situationById usa la última como fallback');
      final ids = [for (final s in situations) s.id];
      expect(ids.toSet().length, ids.length, reason: 'ids duplicados');
    });

    test('las situaciones reales tienen 3 niveles; "other" al menos 1', () {
      for (final s in situations) {
        if (s.id == 'other') {
          expect(s.levels, isNotEmpty, reason: s.id);
        } else {
          expect(s.levels.length, 3, reason: s.id);
        }
        for (final level in s.levels) {
          expect(level.label.trim(), isNotEmpty, reason: s.id);
          expect(level.steps, isNotEmpty, reason: '${s.id} / ${level.label}');
        }
      }
    });

    test('todo paso tiene banco de variantes y cadena de fallbacks', () {
      for (final s in situations) {
        for (final level in s.levels) {
          for (final step in level.steps) {
            final where = '${s.id} / ${level.label} / ${step.goal}';
            expect(step.variants.length, greaterThanOrEqualTo(3),
                reason: where);
            expect(step.fallbacks.length, greaterThanOrEqualTo(2),
                reason: where);
          }
        }
      }
    });

    test('no hay textos vacíos ni duplicados dentro de un paso', () {
      for (final s in situations) {
        for (final level in s.levels) {
          for (final step in level.steps) {
            final where = '${s.id} / ${level.label} / ${step.goal}';
            final all = [...step.variants, ...step.fallbacks];
            for (final t in all) {
              expect(t.trim(), isNotEmpty, reason: where);
            }
            expect(all.toSet().length, all.length,
                reason: 'duplicado en $where');
          }
        }
      }
    });

    test('situationById cae en "other" si el id no existe', () {
      expect(situationById(situations, 'no_existe').id, 'other');
      expect(situationById(situations, 'fear').id, 'fear');
    });
  });
}
