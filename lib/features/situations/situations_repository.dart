import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/situation.dart';

/// Carga el catálogo de situaciones desde assets/content/situations.json.
///
/// El contenido vive en JSON para poder crecer sin tocar código Dart
/// (y, a futuro, reemplazarse por un JSON remoto con el mismo esquema).
abstract class SituationsRepository {
  static const assetPath = 'assets/content/situations.json';

  /// Nombres de icono usados en el JSON → iconos Phosphor (variante fill).
  /// Si un nombre no está acá, se usa la brújula como fallback.
  static const _icons = <String, PhosphorIconData>{
    'hand-waving': PhosphorIconsFill.handWaving,
    'shield-check': PhosphorIconsFill.shieldCheck,
    'hand': PhosphorIconsFill.hand,
    'users-three': PhosphorIconsFill.usersThree,
    'chat-circle-dots': PhosphorIconsFill.chatCircleDots,
    'puzzle-piece': PhosphorIconsFill.puzzlePiece,
    'storefront': PhosphorIconsFill.storefront,
    'cake': PhosphorIconsFill.cake,
    'dots-three-circle': PhosphorIconsFill.dotsThreeCircle,
    // Reservados para situaciones futuras (ver docs/prompt-generar-situaciones.md).
    'chalkboard-teacher': PhosphorIconsFill.chalkboardTeacher,
    'student': PhosphorIconsFill.student,
    'presentation': PhosphorIconsFill.presentation,
    'phone-call': PhosphorIconsFill.phoneCall,
    'stethoscope': PhosphorIconsFill.stethoscope,
    'scissors': PhosphorIconsFill.scissors,
    'house': PhosphorIconsFill.house,
    'trophy': PhosphorIconsFill.trophy,
    'smiley': PhosphorIconsFill.smiley,
    'hand-grabbing': PhosphorIconsFill.handGrabbing,
    'prohibit': PhosphorIconsFill.prohibit,
  };

  static Future<List<Situation>> load() async =>
      parse(await rootBundle.loadString(assetPath));

  /// Parseo separado de la carga, para poder testearlo.
  static List<Situation> parse(String json) {
    final root = jsonDecode(json) as Map<String, dynamic>;
    return [
      for (final s in root['situations'] as List<dynamic>)
        _situation(s as Map<String, dynamic>),
    ];
  }

  static Situation _situation(Map<String, dynamic> map) => Situation(
        id: map['id'] as String,
        title: map['title'] as String,
        icon: _icons[map['icon'] as String] ?? PhosphorIconsFill.compass,
        levels: [
          for (final l in map['levels'] as List<dynamic>)
            _level(l as Map<String, dynamic>),
        ],
      );

  static GuideLevel _level(Map<String, dynamic> map) => GuideLevel(
        label: map['label'] as String,
        steps: [
          for (final s in map['steps'] as List<dynamic>)
            _step(s as Map<String, dynamic>),
        ],
      );

  static GuideStep _step(Map<String, dynamic> map) => GuideStep(
        goal: map['goal'] as String,
        variants: (map['variants'] as List<dynamic>).cast<String>(),
        fallbacks: (map['fallbacks'] as List<dynamic>).cast<String>(),
      );
}
