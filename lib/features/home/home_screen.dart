import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/breathing.dart';
import '../../core/widgets/vinko_button.dart';
import '../../core/widgets/vinko_card.dart';
import '../coach/coach_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: VinkoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile != null ? 'Hola. ${profile.name} te espera.' : ' ',
                      style: theme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    tooltip: 'Ajustes',
                    icon: const PhosphorIcon(
                      PhosphorIconsFill.gearSix,
                      color: VinkoColors.textSecondary,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Marca Vinko con respiración sutil.
              Center(
                child: Breathing(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: VinkoColors.action,
                      shape: BoxShape.circle,
                      boxShadow: vinkoSoftShadow(opacity: 0.18),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsFill.compass,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Vinko',
                textAlign: TextAlign.center,
                style: theme.headlineMedium?.copyWith(letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'Qué hacer, justo en el momento',
                textAlign: TextAlign.center,
                style: theme.bodyLarge
                    ?.copyWith(color: VinkoColors.textSecondary),
              ),
              const Spacer(),
              VinkoPrimaryButton(
                label: 'Necesito ayuda ahora',
                icon: PhosphorIconsFill.lightning,
                onPressed: () => context.push('/situations'),
              ),
              const SizedBox(height: VinkoSpacing.gap),
              const _MissionCard(),
              const SizedBox(height: VinkoSpacing.gap),
              Row(
                children: [
                  Expanded(
                    child: _ShortcutCard(
                      icon: PhosphorIconsFill.chartLineUp,
                      label: 'Progreso',
                      detail: '${progress.streakDays} días seguidos',
                      onTap: () => context.push('/progress'),
                    ),
                  ),
                  const SizedBox(width: VinkoSpacing.gap),
                  Expanded(
                    child: _ShortcutCard(
                      icon: PhosphorIconsFill.medal,
                      label: 'Insignias',
                      detail: 'Quién se está volviendo',
                      onTap: () => context.push('/badges'),
                    ),
                  ),
                  const SizedBox(width: VinkoSpacing.gap),
                  Expanded(
                    child: _ShortcutCard(
                      icon: PhosphorIconsFill.clockCounterClockwise,
                      label: 'Historial',
                      detail: 'Qué funcionó',
                      onTap: () => context.push('/history'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VinkoSpacing.screenPadding),
            ],
          ),
        ),
      ),
    );
  }
}

/// Misión de la semana: un objetivo chico entre crisis, ligado al desafío
/// del niño y a su nivel actual. Se marca cumplida con un toque.
class _MissionCard extends ConsumerWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final mission = ref.watch(missionProvider);
    if (mission == null) return const SizedBox.shrink();
    final done = ref.watch(missionDoneProvider);

    return VinkoCard(
      color: done ? VinkoColors.successSoft : VinkoColors.surface,
      borderColor: done ? VinkoColors.success : VinkoColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PhosphorIcon(
            done ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.target,
            size: 28,
            color: done ? VinkoColors.success : VinkoColors.action,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done
                      ? 'Misión cumplida'
                      : 'Misión de la semana · ${mission.situationTitle}',
                  style: theme.labelLarge?.copyWith(
                    color: done ? VinkoColors.success : VinkoColors.action,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done
                      ? 'El lunes hay una nueva. Mientras, se practica.'
                      : mission.text,
                  style: theme.bodyMedium?.copyWith(color: VinkoColors.text),
                ),
              ],
            ),
          ),
          if (!done)
            TextButton(
              onPressed: () =>
                  ref.read(missionDoneProvider.notifier).markDone(),
              child: const Text('Listo',
                  style: TextStyle(color: VinkoColors.action)),
            ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final PhosphorIconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return VinkoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(icon, size: 28, color: VinkoColors.action),
          const SizedBox(height: 10),
          Text(label, style: theme.titleMedium),
          const SizedBox(height: 2),
          Text(detail,
              style: theme.bodySmall
                  ?.copyWith(color: VinkoColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
