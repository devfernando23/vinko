import 'package:flutter/material.dart';

/// Única animación permitida en Vinko: una "respiración" sutil.
/// Escala 1.0 → 1.03 en un ciclo lento y calmo.
class Breathing extends StatefulWidget {
  const Breathing({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2600),
    this.scale = 1.03,
  });

  final Widget child;
  final Duration duration;
  final double scale;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween(begin: 1.0, end: widget.scale)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}
