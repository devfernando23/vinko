import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/badge_info.dart';
import '../../core/models/session_record.dart';
import '../../core/state/app_state.dart';

/// Definición estática de cada insignia: identidad ligada a una situación.
class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.situationId,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String situationId;
  final String title;
  final String subtitle;
  final PhosphorIconData icon;
}

const badgeDefs = <BadgeDef>[
  BadgeDef(
    id: 'greeter',
    situationId: 'greet',
    title: 'El Saludador',
    subtitle: 'Saluda por su cuenta',
    icon: PhosphorIconsFill.handWaving,
  ),
  BadgeDef(
    id: 'brave',
    situationId: 'fear',
    title: 'El Valiente',
    subtitle: 'Mira de frente lo que le da miedo',
    icon: PhosphorIconsFill.shieldCheck,
  ),
  BadgeDef(
    id: 'friend',
    situationId: 'share',
    title: 'El Amigo',
    subtitle: 'Presta y espera la vuelta',
    icon: PhosphorIconsFill.usersThree,
  ),
  BadgeDef(
    id: 'firm',
    situationId: 'limits',
    title: 'El Firme',
    subtitle: 'Dice basta con su propia voz',
    icon: PhosphorIconsFill.hand,
  ),
  BadgeDef(
    id: 'asker',
    situationId: 'ask_help',
    title: 'El que Pide',
    subtitle: 'Pide ayuda cuando la necesita',
    icon: PhosphorIconsFill.chatCircleDots,
  ),
  BadgeDef(
    id: 'player',
    situationId: 'join_play',
    title: 'El Compañero',
    subtitle: 'Se suma a jugar con otros',
    icon: PhosphorIconsFill.puzzlePiece,
  ),
  BadgeDef(
    id: 'bold',
    situationId: 'order_shop',
    title: 'El Decidido',
    subtitle: 'Pide lo suyo con su voz',
    icon: PhosphorIconsFill.storefront,
  ),
  BadgeDef(
    id: 'guest',
    situationId: 'party',
    title: 'El Invitado',
    subtitle: 'Disfruta las fiestas a su ritmo',
    icon: PhosphorIconsFill.cake,
  ),
  BadgeDef(
    id: 'friendly',
    situationId: 'new_kid',
    title: 'El Amiguero',
    subtitle: 'Se acerca a niños nuevos',
    icon: PhosphorIconsFill.smiley,
  ),
  BadgeDef(
    id: 'voice_class',
    situationId: 'speak_class',
    title: 'El que Participa',
    subtitle: 'Habla en clase con su voz',
    icon: PhosphorIconsFill.chalkboardTeacher,
  ),
  BadgeDef(
    id: 'artist',
    situationId: 'perform',
    title: 'El Artista',
    subtitle: 'Muestra lo suyo delante de otros',
    icon: PhosphorIconsFill.presentation,
  ),
  BadgeDef(
    id: 'host',
    situationId: 'guests_home',
    title: 'El Anfitrión',
    subtitle: 'Recibe a las visitas en casa',
    icon: PhosphorIconsFill.house,
  ),
  BadgeDef(
    id: 'patient',
    situationId: 'doctor_visit',
    title: 'El Paciente',
    subtitle: 'Va a la consulta con calma',
    icon: PhosphorIconsFill.stethoscope,
  ),
  BadgeDef(
    id: 'talker',
    situationId: 'phone_call',
    title: 'El Conversador',
    subtitle: 'Contesta con su propia voz',
    icon: PhosphorIconsFill.phoneCall,
  ),
  BadgeDef(
    id: 'claimer',
    situationId: 'taken_toy',
    title: 'El que Reclama',
    subtitle: 'Pide que le devuelvan lo suyo',
    icon: PhosphorIconsFill.handGrabbing,
  ),
  BadgeDef(
    id: 'shield',
    situationId: 'teasing',
    title: 'El Escudo',
    subtitle: 'Frena las burlas con su voz',
    icon: PhosphorIconsFill.prohibit,
  ),
  BadgeDef(
    id: 'good_loser',
    situationId: 'losing_game',
    title: 'El Buen Perdedor',
    subtitle: 'Cierra el juego con la frente en alto',
    icon: PhosphorIconsFill.trophy,
  ),
  BadgeDef(
    id: 'student',
    situationId: 'school_start',
    title: 'El Estudiante',
    subtitle: 'Entra a clases por su cuenta',
    icon: PhosphorIconsFill.student,
  ),
];

/// Logros ("Lo logró") necesarios para cada tier.
const _copperAt = 1;
const _silverAt = 3;
const _goldAt = 5;

/// Tier y progreso hacia el siguiente, a partir de los logros acumulados.
/// Pura para poder testearla.
({BadgeTier tier, double progress}) badgeLevel(int successes) {
  if (successes >= _goldAt) return (tier: BadgeTier.gold, progress: 1);
  if (successes >= _silverAt) {
    return (
      tier: BadgeTier.silver,
      progress: (successes - _silverAt) / (_goldAt - _silverAt),
    );
  }
  if (successes >= _copperAt) {
    return (
      tier: BadgeTier.copper,
      progress: (successes - _copperAt) / (_silverAt - _copperAt),
    );
  }
  return (tier: BadgeTier.locked, progress: 0);
}

/// Insignias calculadas del historial: cuenta las sesiones con "Lo logró"
/// por situación y asigna tier y progreso.
final badgesProvider = Provider<List<BadgeInfo>>((ref) {
  final history = ref.watch(sessionHistoryProvider);
  final successes = <String, int>{};
  for (final r in history) {
    if (r.result == SessionResult.success && !r.intervened) {
      successes[r.situationId] = (successes[r.situationId] ?? 0) + 1;
    }
  }
  return [
    for (final def in badgeDefs)
      () {
        final level = badgeLevel(successes[def.situationId] ?? 0);
        return BadgeInfo(
          id: def.id,
          title: def.title,
          subtitle: def.subtitle,
          icon: def.icon,
          tier: level.tier,
          progress: level.progress,
        );
      }(),
  ];
});
