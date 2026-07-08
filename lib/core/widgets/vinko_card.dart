import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta estándar: superficie blanca, borde #E5E9F0, radio 16, sombra suave.
class VinkoCard extends StatelessWidget {
  const VinkoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(VinkoSpacing.gap),
    this.color = VinkoColors.surface,
    this.borderColor = VinkoColors.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(VinkoSpacing.radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: Border.all(color: borderColor),
        boxShadow: vinkoSoftShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
