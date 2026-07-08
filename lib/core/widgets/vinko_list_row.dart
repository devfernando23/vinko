import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import 'vinko_card.dart';

/// Fila de lista: ícono relleno en cápsula azul suave, título, subtítulo
/// opcional y acción a la derecha (chevron por defecto).
class VinkoListRow extends StatelessWidget {
  const VinkoListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor = VinkoColors.action,
    this.iconBackground = VinkoColors.actionSoft,
  });

  final PhosphorIconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return VinkoCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: PhosphorIcon(icon, size: 26, color: iconColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.titleMedium, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              const PhosphorIcon(
                PhosphorIconsFill.caretRight,
                size: 20,
                color: VinkoColors.textSecondary,
              ),
        ],
      ),
    );
  }
}
