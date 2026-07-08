import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/vinko_list_row.dart';

/// Cómo celebra Vinko cuando el niño lo logra. Neutral, sin marca.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final rewards = ref.watch(rewardsProvider);
    final notifier = ref.read(rewardsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Recompensas')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(VinkoSpacing.screenPadding),
          children: [
            Text('Elige cómo se celebra cuando lo logra.',
                style: theme.bodyMedium),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.confetti,
              title: 'Pantalla de celebración',
              subtitle: 'Se muestra al niño cuando lo logra',
              trailing: Switch(
                value: rewards.celebrationScreen,
                onChanged: (v) =>
                    notifier.update(rewards.copyWith(celebrationScreen: v)),
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.star,
              title: 'Estrellas',
              subtitle: 'Animación breve y calma',
              trailing: Switch(
                value: rewards.stars,
                onChanged: (v) => notifier.update(rewards.copyWith(stars: v)),
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.chatCircleText,
              title: 'Mensaje de Vinko',
              subtitle: 'Una frase concreta sobre lo que hizo',
              trailing: Switch(
                value: rewards.vinkoMessage,
                onChanged: (v) =>
                    notifier.update(rewards.copyWith(vinkoMessage: v)),
              ),
            ),
            const SizedBox(height: VinkoSpacing.gap),
            VinkoListRow(
              icon: PhosphorIconsFill.speakerSimpleHigh,
              title: 'Sonido suave',
              subtitle: 'Un tono corto, sin música',
              trailing: Switch(
                value: rewards.softSound,
                onChanged: (v) =>
                    notifier.update(rewards.copyWith(softSound: v)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
