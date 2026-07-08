import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/models/coach_content.dart';

/// Carga el contenido del coach desde assets/content/coach.json.
abstract class CoachRepository {
  static const assetPath = 'assets/content/coach.json';

  static Future<CoachContent> load() async =>
      parse(await rootBundle.loadString(assetPath));

  /// Parseo separado de la carga, para poder testearlo.
  static CoachContent parse(String json) {
    final root = jsonDecode(json) as Map<String, dynamic>;
    Map<String, List<String>> section(String key) => {
          for (final e in (root[key] as Map<String, dynamic>).entries)
            e.key: (e.value as List<dynamic>).cast<String>(),
        };
    return CoachContent(
      tips: (root['tips'] as List<dynamic>).cast<String>(),
      missions: section('missions'),
      practices: section('practices'),
    );
  }
}
