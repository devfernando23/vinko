import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/badge_info.dart';
import '../theme/app_theme.dart';
import 'vinko_card.dart';

Color tierColor(BadgeTier tier) => switch (tier) {
      BadgeTier.copper => VinkoColors.copper,
      BadgeTier.silver => VinkoColors.silver,
      BadgeTier.gold => VinkoColors.gold,
      BadgeTier.locked => VinkoColors.border,
    };

String tierLabel(BadgeTier tier) => switch (tier) {
      BadgeTier.copper => 'Cobre',
      BadgeTier.silver => 'Plata',
      BadgeTier.gold => 'Oro',
      BadgeTier.locked => 'Por descubrir',
    };

/// Medallón circular de insignia con anillo del color del tier.
class VinkoBadgeMedal extends StatelessWidget {
  const VinkoBadgeMedal({
    super.key,
    required this.badge,
    this.size = 64,
  });

  final BadgeInfo badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final locked = badge.tier == BadgeTier.locked;
    final color = tierColor(badge.tier);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: locked ? VinkoColors.background : color.withValues(alpha: 0.14),
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: PhosphorIcon(
          locked ? PhosphorIconsFill.lockSimple : badge.icon,
          size: size * 0.42,
          color: locked ? VinkoColors.textSecondary : color,
        ),
      ),
    );
  }
}

/// Tarjeta completa de insignia: medallón + nombre + tier + progreso.
class VinkoBadgeCard extends StatelessWidget {
  const VinkoBadgeCard({super.key, required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final locked = badge.tier == BadgeTier.locked;
    return VinkoCard(
      child: Row(
        children: [
          VinkoBadgeMedal(badge: badge),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.title, style: theme.titleMedium),
                const SizedBox(height: 2),
                Text(badge.subtitle,
                    style: theme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tierColor(badge.tier).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tierLabel(badge.tier),
                        style: theme.labelMedium?.copyWith(
                          color: locked
                              ? VinkoColors.textSecondary
                              : tierColor(badge.tier),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: badge.progress,
                          minHeight: 6,
                          backgroundColor: VinkoColors.border,
                          color: locked
                              ? VinkoColors.textSecondary
                              : tierColor(badge.tier),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
