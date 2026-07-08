import 'package:phosphor_flutter/phosphor_flutter.dart';

enum BadgeTier { locked, copper, silver, gold }

/// Insignia de identidad: nombra quién se está volviendo el niño.
class BadgeInfo {
  const BadgeInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tier,
    required this.progress,
  });

  final String id;
  final String title;
  final String subtitle;
  final PhosphorIconData icon;
  final BadgeTier tier;

  /// 0..1 hacia el siguiente tier.
  final double progress;
}
