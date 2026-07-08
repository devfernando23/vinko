import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/situation.dart';

/// Catálogo de situaciones, cargado desde assets/content/situations.json
/// por SituationsRepository. Se sobreescribe en main() con el catálogo real.
///
/// Voz de los guiones: directa, breve, una instrucción a la vez.
/// `{n}` se reemplaza por el nombre del niño. Cada situación tiene niveles
/// (escalera de exposición) y cada paso un banco de variantes + fallbacks.
final situationsProvider = Provider<List<Situation>>(
  (ref) => throw UnimplementedError('Override en main()'),
);

/// Busca por id; si no existe cae en la última ('other', el guion genérico).
Situation situationById(List<Situation> all, String id) =>
    all.firstWhere((s) => s.id == id, orElse: () => all.last);
