import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/session_record.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../situations/situation_level.dart';
import '../situations/situations_data.dart';

/// Cierre post-situación: 3 caritas, 1 tap y listo.
class ClosureScreen extends ConsumerWidget {
  const ClosureScreen({
    super.key,
    required this.situationId,
    required this.stepsCompleted,
    required this.intervened,
    this.level = 1,
    this.variantsShown,
  });

  final String situationId;
  final int stepsCompleted;
  final bool intervened;
  final int level;
  final List<int>? variantsShown;

  Future<void> _pick(
      BuildContext context, WidgetRef ref, SessionResult result) async {
    final levelBefore = ref.read(situationLevelProvider(situationId));
    await ref.read(sessionHistoryProvider.notifier).add(
          SessionRecord(
            situationId: situationId,
            stepsCompleted: stepsCompleted,
            result: result,
            intervened: intervened,
            at: DateTime.now(),
            level: level,
            variantsShown: variantsShown,
          ),
        );
    if (!context.mounted) return;
    final levelAfter = ref.read(situationLevelProvider(situationId));
    final messenger = ScaffoldMessenger.of(context);
    final celebrate = result == SessionResult.success &&
        ref.read(rewardsProvider).celebrationScreen;
    if (celebrate) {
      context.pushReplacement('/celebration');
    } else {
      context.go('/');
    }
    // Aviso de cambio de nivel: que la escalera no suba ni baje en silencio.
    if (levelAfter != levelBefore) {
      final label = situationById(ref.read(situationsProvider), situationId)
          .levels[levelAfter - 1]
          .label;
      final up = levelAfter > levelBefore;
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: up ? VinkoColors.action : VinkoColors.adjust,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VinkoSpacing.radius),
          ),
          duration: const Duration(seconds: 4),
          content: Text(
            up
                ? 'Subieron un escalón. Próxima vez: nivel $levelAfter · $label.'
                : 'Bajamos un escalón, sin apuro. Próxima vez: $label.',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final name = ref.watch(profileProvider)?.name ?? 'tu hijo';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                intervened ? 'Está bien intervenir.' : '¿Cómo salió?',
                textAlign: TextAlign.center,
                style: theme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                intervened
                    ? 'La próxima, $name llega un paso más lejos.'
                    : 'Un toque. Vinko guarda el resto.',
                textAlign: TextAlign.center,
                style: theme.bodyLarge
                    ?.copyWith(color: VinkoColors.textSecondary),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FaceButton(
                    icon: PhosphorIconsFill.smileySad,
                    label: 'Costó',
                    color: VinkoColors.adjust,
                    onTap: () => _pick(context, ref, SessionResult.hard),
                  ),
                  _FaceButton(
                    icon: PhosphorIconsFill.smileyMeh,
                    label: 'Más o menos',
                    color: VinkoColors.action,
                    onTap: () => _pick(context, ref, SessionResult.soso),
                  ),
                  _FaceButton(
                    icon: PhosphorIconsFill.smiley,
                    label: 'Lo logró',
                    color: VinkoColors.success,
                    onTap: () => _pick(context, ref, SessionResult.success),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final PhosphorIconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: PhosphorIcon(icon, size: 44, color: color),
              ),
            ),
            const SizedBox(height: 10),
            Text(label, style: theme.labelLarge),
          ],
        ),
      ),
    );
  }
}
