import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/breathing.dart';
import '../../core/widgets/vinko_button.dart';

/// Pantalla del niño. Única pantalla con Fredoka. Celebración neutral,
/// sin marca, sin estridencias.
class CelebrationScreen extends ConsumerStatefulWidget {
  const CelebrationScreen({super.key});

  @override
  ConsumerState<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends ConsumerState<CelebrationScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (ref.read(rewardsProvider).softSound) {
      _player
          .play(AssetSource('sounds/soft_chime.wav'), volume: 0.6)
          .catchError((_) {}); // sin audio no se rompe la celebración
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(profileProvider)?.name ?? '';
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: VinkoColors.successSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (rewards.stars)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(PhosphorIconsFill.star,
                        size: 28, color: VinkoColors.gold),
                    SizedBox(width: 16),
                    PhosphorIcon(PhosphorIconsFill.star,
                        size: 40, color: VinkoColors.gold),
                    SizedBox(width: 16),
                    PhosphorIcon(PhosphorIconsFill.star,
                        size: 28, color: VinkoColors.gold),
                  ],
                ),
              const SizedBox(height: 32),
              Breathing(
                scale: 1.05,
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VinkoColors.success,
                    shape: BoxShape.circle,
                    boxShadow: vinkoSoftShadow(opacity: 0.2),
                  ),
                  child: const PhosphorIcon(
                    PhosphorIconsFill.checkCircle,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                name.isEmpty ? '¡Lo hiciste!' : '¡Lo hiciste, $name!',
                textAlign: TextAlign.center,
                style: VinkoTheme.celebration(fontSize: 36),
              ),
              if (rewards.vinkoMessage) ...[
                const SizedBox(height: 12),
                Text(
                  'Hoy fue difícil. Y lo hiciste igual.',
                  textAlign: TextAlign.center,
                  style: VinkoTheme.celebration(
                    fontSize: 20,
                    color: VinkoColors.textSecondary,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              VinkoPrimaryButton(
                label: 'Listo',
                color: VinkoColors.success,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: VinkoSpacing.screenPadding),
            ],
          ),
        ),
      ),
    );
  }
}
