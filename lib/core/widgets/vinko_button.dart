import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';

/// Botón principal de Vinko: grande (56px), redondeado, sombra suave.
/// Una acción principal por pantalla.
class VinkoPrimaryButton extends StatelessWidget {
  const VinkoPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = VinkoColors.action,
  });

  final String label;
  final VoidCallback? onPressed;
  final PhosphorIconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VinkoSpacing.radius),
        boxShadow: vinkoSoftShadow(opacity: 0.12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              PhosphorIcon(icon!, size: 24, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón secundario: borde suave sobre superficie blanca.
class VinkoSecondaryButton extends StatelessWidget {
  const VinkoSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.foreground = VinkoColors.action,
  });

  final String label;
  final VoidCallback? onPressed;
  final PhosphorIconData? icon;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: VinkoColors.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            PhosphorIcon(icon!, size: 22, color: foreground),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
